<?php

namespace Tests\Feature;

use App\Enums\RevisionSource;
use App\Models\Project;
use App\Models\User;
use App\Models\Website;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WebsiteTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Project $project;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        $this->project = Project::create([
            'user_id' => $this->user->id,
            'name' => 'Test Project',
        ]);
    }

    public function test_user_can_create_website_with_default_document(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/websites', [
                'project_id' => $this->project->id,
                'name' => 'Starlight Coffee',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('website.name', 'Starlight Coffee')
            ->assertJsonPath('website.revision_number', 1)
            ->assertJsonStructure([
                'website' => [
                    'id',
                    'name',
                    'slug',
                    'document' => [
                        'schema_version',
                        'site' => ['name', 'theme'],
                        'pages',
                        'navigation',
                    ],
                    'current_revision',
                ],
            ]);

        $this->assertDatabaseHas('websites', [
            'name' => 'Starlight Coffee',
            'project_id' => $this->project->id,
            'revision_number' => 1,
        ]);

        $this->assertDatabaseHas('website_revisions', [
            'revision_number' => 1,
            'source' => RevisionSource::Manual->value,
        ]);
    }

    public function test_user_can_update_website_document_and_create_new_revision(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Base Site',
            'slug' => 'base-site',
            'document' => DefaultDocumentFactory::createDefault('Base Site'),
            'revision_number' => 1,
        ]);

        $updatedDoc = $website->document;
        $updatedDoc['site']['name'] = 'Renamed Site Brand';
        $updatedDoc['pages'][0]['sections'][0]['props']['headline'] = 'Brand New Headline';

        $response = $this->actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/websites/{$website->id}/document", [
                'document' => $updatedDoc,
                'expected_revision_number' => 1,
                'description' => 'Updated hero headline',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('website.revision_number', 2)
            ->assertJsonPath('website.document.site.name', 'Renamed Site Brand');

        $this->assertDatabaseHas('websites', [
            'id' => $website->id,
            'revision_number' => 2,
        ]);

        $this->assertDatabaseHas('website_revisions', [
            'website_id' => $website->id,
            'revision_number' => 2,
            'description' => 'Updated hero headline',
        ]);
    }

    public function test_optimistic_locking_prevents_concurrent_overwrite(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Conflict Site',
            'slug' => 'conflict-site',
            'document' => DefaultDocumentFactory::createDefault('Conflict Site'),
            'revision_number' => 5, // Currently at revision 5
        ]);

        $updatedDoc = $website->document;

        // User submits update thinking the website is still at revision 4
        $response = $this->actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/websites/{$website->id}/document", [
                'document' => $updatedDoc,
                'expected_revision_number' => 4, // Stale!
            ]);

        $response->assertStatus(409)
            ->assertJsonPath('current_revision_number', 5);
    }

    public function test_document_validation_rejects_unsupported_components(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Invalid Site',
            'slug' => 'invalid-site',
            'document' => DefaultDocumentFactory::createDefault('Invalid Site'),
            'revision_number' => 1,
        ]);

        $invalidDoc = $website->document;
        // Inject an unsupported component type
        $invalidDoc['pages'][0]['sections'][0]['component'] = 'arbitrary_unsupported_hacked_component';

        $response = $this->actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/websites/{$website->id}/document", [
                'document' => $invalidDoc,
            ]);

        $response->assertStatus(422)
            ->assertJsonStructure(['message', 'errors']);
    }

    public function test_document_validation_rejects_duplicate_section_ids(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Dup ID Site',
            'slug' => 'dup-site',
            'document' => DefaultDocumentFactory::createDefault('Dup Site'),
            'revision_number' => 1,
        ]);

        $invalidDoc = $website->document;
        // Force both sections to share the same ID
        $invalidDoc['pages'][0]['sections'][1]['id'] = $invalidDoc['pages'][0]['sections'][0]['id'];

        $response = $this->actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/websites/{$website->id}/document", [
                'document' => $invalidDoc,
            ]);

        $response->assertStatus(422)
            ->assertJsonStructure(['message', 'errors']);
    }

    public function test_user_can_view_revisions_and_restore_prior_version(): void
    {
        // 1. Initial
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'History Site',
            'slug' => 'history-site',
            'document' => DefaultDocumentFactory::createDefault('Original V1 Name'),
            'revision_number' => 1,
        ]);

        $rev1 = $website->revisions()->create([
            'revision_number' => 1,
            'document' => $website->document,
            'source' => RevisionSource::Manual,
            'description' => 'Rev 1',
        ]);

        // 2. Update to V2
        $doc2 = $website->document;
        $doc2['site']['name'] = 'Changed V2 Name';
        $website->update(['document' => $doc2, 'revision_number' => 2]);
        $website->revisions()->create([
            'revision_number' => 2,
            'document' => $doc2,
            'source' => RevisionSource::Manual,
            'description' => 'Rev 2',
        ]);

        // List revisions
        $listResponse = $this->actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/websites/{$website->id}/revisions");

        $listResponse->assertStatus(200)
            ->assertJsonCount(2, 'data');

        // Restore revision #1
        $restoreResponse = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/websites/{$website->id}/revisions/{$rev1->id}/restore");

        $restoreResponse->assertStatus(200)
            ->assertJsonPath('website.revision_number', 3)
            ->assertJsonPath('website.document.site.name', 'Original V1 Name');

        $this->assertDatabaseHas('websites', [
            'id' => $website->id,
            'revision_number' => 3,
        ]);
    }

    public function test_editing_lock_mechanism(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Lock Test',
            'slug' => 'lock-test',
            'document' => DefaultDocumentFactory::createDefault('Lock Test'),
            'revision_number' => 1,
        ]);

        // Acquire lock
        $lockRes = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/websites/{$website->id}/lock", ['lock_token' => 'my-secret-token-123']);

        $lockRes->assertStatus(200)
            ->assertJsonPath('lock_token', 'my-secret-token-123');

        // Second session trying with different token should fail (423 locked)
        $secondRes = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/websites/{$website->id}/lock", ['lock_token' => 'another-token']);

        $secondRes->assertStatus(423);

        // Updating document with wrong lock token should fail (423 locked)
        $updateRes = $this->actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/websites/{$website->id}/document", [
                'document' => $website->document,
                'lock_token' => 'wrong-token',
            ]);

        $updateRes->assertStatus(423);

        // Release lock
        $unlockRes = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/websites/{$website->id}/unlock", ['lock_token' => 'my-secret-token-123']);

        $unlockRes->assertStatus(200);
    }

    public function test_user_cannot_access_or_modify_another_users_website(): void
    {
        $otherUser = User::factory()->create();

        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Private Site',
            'slug' => 'private-site',
            'document' => DefaultDocumentFactory::createDefault('Private Site'),
            'revision_number' => 1,
        ]);

        $resShow = $this->actingAs($otherUser, 'sanctum')
            ->getJson("/api/v1/websites/{$website->id}");
        $resShow->assertStatus(403);

        $resUpdate = $this->actingAs($otherUser, 'sanctum')
            ->putJson("/api/v1/websites/{$website->id}/document", [
                'document' => $website->document,
            ]);
        $resUpdate->assertStatus(403);
    }

    public function test_user_can_create_blank_website_with_custom_document(): void
    {
        $blankDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Blank Site',
                'theme' => [
                    'colors' => ['primary' => '#000000', 'background' => '#FFFFFF'],
                    'typography' => ['headingFamily' => 'Inter', 'bodyFamily' => 'Inter'],
                ],
                'settings' => ['language' => 'en'],
            ],
            'navigation' => ['logo' => ['text' => 'Blank Site'], 'items' => []],
            'pages' => [
                ['id' => 'page_home', 'slug' => '/', 'title' => 'Home', 'sections' => []],
            ],
        ];

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/websites', [
                'project_id' => $this->project->id,
                'name' => 'Blank Site',
                'document' => $blankDoc,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('website.name', 'Blank Site')
            ->assertJsonPath('website.document.schema_version', 1);
    }

    public function test_user_can_delete_website_by_uuid(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'To Be Deleted',
            'slug' => 'to-be-deleted',
            'status' => 'draft',
            'document' => DefaultDocumentFactory::createDefault('To Be Deleted'),
            'revision_number' => 1,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/websites/{$website->id}");

        $response->assertStatus(200)
            ->assertJsonPath('message', 'Website deleted successfully.');

        $this->assertSoftDeleted('websites', [
            'id' => $website->id,
        ]);
    }

    public function test_user_can_delete_website_by_slug(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Slug Deletion Test',
            'slug' => 'slug-deletion-test',
            'status' => 'draft',
            'document' => DefaultDocumentFactory::createDefault('Slug Deletion Test'),
            'revision_number' => 1,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/websites/{$website->slug}");

        $response->assertStatus(200)
            ->assertJsonPath('message', 'Website deleted successfully.');

        $this->assertSoftDeleted('websites', [
            'id' => $website->id,
        ]);
    }

    public function test_user_can_delete_showcase_website_by_showcase_id(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Studio Marlow',
            'slug' => 'studio-marlow',
            'status' => 'published',
            'document' => DefaultDocumentFactory::createDefault('Studio Marlow'),
            'revision_number' => 1,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/websites/showcase_studio_marlow");

        $response->assertStatus(200)
            ->assertJsonPath('message', 'Website deleted successfully.');

        $this->assertSoftDeleted('websites', [
            'id' => $website->id,
        ]);
    }
}

