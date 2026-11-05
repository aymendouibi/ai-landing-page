<?php

namespace Tests\Feature;

use App\Enums\DeploymentStatus;
use App\Enums\DomainStatus;
use App\Enums\WebsiteStatus;
use App\Models\Deployment;
use App\Models\Project;
use App\Models\User;
use App\Models\Website;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PublishingAndDomainTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected User $otherUser;
    protected Project $project;
    protected Website $website;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('hosting');

        $this->user = User::factory()->create();
        $this->otherUser = User::factory()->create();

        $this->project = Project::create([
            'user_id' => $this->user->id,
            'name' => 'Publishing Project',
            'slug' => 'publishing-project',
        ]);

        $this->website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Startup Site',
            'slug' => 'startup-site',
            'subdomain' => 'startup-site',
            'document' => DefaultDocumentFactory::createDefault('Startup Site'),
            'status' => WebsiteStatus::Draft,
        ]);
    }

    public function test_user_can_publish_website_and_generates_static_assets(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");

        $response->assertStatus(200)
            ->assertJsonPath('website.status', WebsiteStatus::Published->value)
            ->assertJsonStructure([
                'deployment' => ['id', 'status', 'storage_path'],
                'live_url',
            ]);

        $fresh = $this->website->fresh();
        $this->assertEquals(WebsiteStatus::Published, $fresh->status);
        $this->assertNotNull($fresh->published_at);

        // Verify storage contains static compilation files
        $disk = Storage::disk('hosting');
        $this->assertTrue($disk->exists("sites/{$this->website->id}/live/index.html"));
        $this->assertTrue($disk->exists("sites/{$this->website->id}/live/404.html"));
        $this->assertTrue($disk->exists("sites/{$this->website->id}/live/assets/style.css"));
        $this->assertTrue($disk->exists("sites/{$this->website->id}/live/assets/main.js"));

        // Content check
        $html = $disk->get("sites/{$this->website->id}/live/index.html");
        $this->assertStringContainsString('Startup Site', $html);
        $this->assertStringContainsString('assets/style.css', $html);
    }

    public function test_publishing_rejects_reserved_subdomain(): void
    {
        $this->website->update(['subdomain' => 'admin']);

        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");

        $response->assertStatus(422)
            ->assertJsonFragment([
                'message' => "Publishing failed: The subdomain 'admin' is reserved by the platform and cannot be used.",
            ]);
    }

    public function test_user_can_unpublish_website(): void
    {
        // First publish
        $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");

        // Then unpublish
        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/unpublish");

        $response->assertStatus(200)
            ->assertJsonPath('website.status', WebsiteStatus::Draft->value);

        $fresh = $this->website->fresh();
        $this->assertEquals(WebsiteStatus::Draft, $fresh->status);
        $this->assertNull($fresh->published_at);

        // Live index.html must now serve the unavailable page
        $disk = Storage::disk('hosting');
        $html = $disk->get("sites/{$this->website->id}/live/index.html");
        $this->assertStringContainsString('Website Unavailable', $html);
    }

    public function test_user_can_rollback_to_previous_deployment(): void
    {
        // Deployment 1
        $res1 = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");
        $deployment1Id = $res1->json('deployment.id');

        // Modify site and trigger Deployment 2
        $doc = $this->website->document;
        $doc['pages'][0]['sections'][0]['props']['headline'] = 'Updated Headline V2';
        $this->website->update(['document' => $doc]);

        $res2 = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");
        $deployment2Id = $res2->json('deployment.id');

        $this->assertNotEquals($deployment1Id, $deployment2Id);

        // Rollback to Deployment 1
        $rollbackResponse = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/websites/{$this->website->id}/deployments/{$deployment1Id}/rollback");

        $rollbackResponse->assertStatus(200)
            ->assertJsonPath('deployment.status', DeploymentStatus::Deployed->value);

        // Deployment history should now have 3 deployments
        $deploymentsResponse = $this->actingAs($this->user, 'sanctum')->getJson("/api/v1/websites/{$this->website->id}/deployments");
        $deploymentsResponse->assertStatus(200)
            ->assertJsonPath('total', 3);
    }

    public function test_custom_domain_attachment_and_verification(): void
    {
        // 1. Attach domain
        $attachResponse = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/domains", [
            'domain' => 'https://startup.mybrand.com/',
        ]);

        $attachResponse->assertStatus(201)
            ->assertJsonPath('domain.domain', 'startup.mybrand.com')
            ->assertJsonPath('domain.status', DomainStatus::Pending->value)
            ->assertJsonStructure([
                'dns_instructions' => ['cname_record', 'txt_record'],
            ]);

        $domainId = $attachResponse->json('domain.id');

        // 2. Trigger verification
        $verifyResponse = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/websites/{$this->website->id}/domains/{$domainId}/verify");

        $verifyResponse->assertStatus(200)
            ->assertJsonPath('verified', true)
            ->assertJsonPath('domain.status', DomainStatus::Active->value);

        // 3. Remove domain
        $deleteResponse = $this->actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/websites/{$this->website->id}/domains/{$domainId}");

        $deleteResponse->assertStatus(200);
        $this->assertDatabaseMissing('domains', ['id' => $domainId]);
    }

    public function test_unauthorized_user_cannot_publish_or_manage_domains(): void
    {
        $response = $this->actingAs($this->otherUser, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");
        $response->assertStatus(403);

        $domainResponse = $this->actingAs($this->otherUser, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/domains", [
            'domain' => 'hacked.com',
        ]);
        $domainResponse->assertStatus(403);
    }
}
