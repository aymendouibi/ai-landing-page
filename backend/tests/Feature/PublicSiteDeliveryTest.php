<?php

namespace Tests\Feature;

use App\Enums\SubscriptionStatus;
use App\Enums\WebsiteStatus;
use App\Models\Project;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use App\Models\Website;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PublicSiteDeliveryTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Website $website;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('hosting');

        $this->user = User::factory()->create();

        $proPlan = SubscriptionPlan::create([
            'name' => 'Pro',
            'slug' => 'pro',
            'limits' => [
                'max_websites' => 5,
                'max_published' => 5,
                'ai_generations_monthly' => 50,
                'ai_edits_monthly' => 100,
                'custom_domains' => 5,
            ],
            'price_monthly' => 29.00,
        ]);

        Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $proPlan->id,
            'status' => SubscriptionStatus::Active,
            'provider' => 'stripe',
            'current_period_end' => now()->addMonth(),
        ]);

        $project = Project::create([
            'user_id' => $this->user->id,
            'name' => 'Cafe Project',
            'slug' => 'cafe-project',
        ]);

        $this->website = Website::create([
            'project_id' => $project->id,
            'name' => 'Lumen Coffee',
            'slug' => 'lumen-coffee',
            'subdomain' => 'lumen-coffee',
            'document' => DefaultDocumentFactory::createDefault('Lumen Coffee'),
            'status' => WebsiteStatus::Draft,
        ]);
    }

    public function test_unpublished_website_returns_404(): void
    {
        $response = $this->get('/lumen-coffee');
        $response->assertStatus(404);
    }

    public function test_published_website_is_accessible_via_path_route(): void
    {
        // 1. Publish the website
        $publishRes = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");
        $publishRes->assertStatus(200);

        // 2. Access published page directly
        $response = $this->get('/lumen-coffee');
        $response->assertStatus(200);
        $response->assertHeader('Content-Type', 'text/html; charset=UTF-8');
        $this->assertStringContainsString('Lumen Coffee', $response->getContent());
        $this->assertStringContainsString('<base href="/lumen-coffee/">', $response->getContent());

        // 3. Access compiled CSS
        $cssResponse = $this->get('/lumen-coffee/assets/style.css');
        $cssResponse->assertStatus(200);
        $cssResponse->assertHeader('Content-Type', 'text/css; charset=UTF-8');

        // 4. Access compiled JS
        $jsResponse = $this->get('/lumen-coffee/assets/main.js');
        $jsResponse->assertStatus(200);
        $jsResponse->assertHeader('Content-Type', 'application/javascript; charset=UTF-8');
    }

    public function test_accessible_via_prefixed_sites_route(): void
    {
        $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");

        $response = $this->get('/sites/lumen-coffee');
        $response->assertStatus(200);
        $this->assertStringContainsString('Lumen Coffee', $response->getContent());
        $this->assertStringContainsString('<base href="/sites/lumen-coffee/">', $response->getContent());
    }

    public function test_reserved_subdomain_returns_404(): void
    {
        $response = $this->get('/sites/admin');
        $response->assertStatus(404);
    }

    public function test_published_website_with_image_and_rich_components(): void
    {
        $doc = $this->website->document;
        $doc['pages'][0]['sections'][] = [
            'id' => 'sec-img-1',
            'component' => 'image',
            'props' => [
                'url' => 'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
                'alt' => 'Sunlit seating inside the Lumen Coffee café',
                'fit' => 'crop',
                'caption' => 'Portland flagship roastery',
            ],
        ];
        $doc['pages'][0]['sections'][] = [
            'id' => 'sec-prod-1',
            'component' => 'products',
            'props' => [
                'headline' => 'Seasonal Roasts',
                'items' => [
                    ['name' => 'Ethiopia Yirgacheffe', 'price' => '$21.00', 'description' => 'Floral notes with bergamot.'],
                ],
            ],
        ];

        $this->website->update(['document' => $doc]);

        $publishRes = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");
        $publishRes->assertStatus(200);

        $response = $this->get('/lumen-coffee');
        $response->assertStatus(200);
        $html = $response->getContent();

        $this->assertStringContainsString('Sunlit seating inside the Lumen Coffee café', $html);
        $this->assertStringContainsString('Portland flagship roastery', $html);
        $this->assertStringContainsString('Seasonal Roasts', $html);
        $this->assertStringContainsString('Ethiopia Yirgacheffe', $html);
    }

    public function test_app_ads_txt_route_serves_content(): void
    {
        $response = $this->get('/app-ads.txt');
        $response->assertStatus(200);
        $this->assertStringContainsString('start.io, 112660328, DIRECT', $response->getContent());
    }

    public function test_api_subdomain_is_not_intercepted_by_subdomain_route(): void
    {
        $response = $this->get('http://api.ai-landing-page.xyz/api/v1/health');
        $response->assertStatus(200);
        $response->assertJson([
            'status' => 'ok',
        ]);
    }

    public function test_published_website_is_accessible_via_subdomain_route(): void
    {
        $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/publish");

        $response = $this->get('http://lumen-coffee.ai-landing-page.xyz/');
        $response->assertStatus(200);
        $response->assertHeader('Content-Type', 'text/html; charset=UTF-8');
        $this->assertStringContainsString('Lumen Coffee', $response->getContent());
    }
}
