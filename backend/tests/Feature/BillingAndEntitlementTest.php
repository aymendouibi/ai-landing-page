<?php

namespace Tests\Feature;

use App\Enums\SubscriptionStatus;
use App\Enums\WebsiteStatus;
use App\Models\BillingCustomer;
use App\Models\Project;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use App\Models\Website;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class BillingAndEntitlementTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Project $project;
    protected SubscriptionPlan $freePlan;
    protected SubscriptionPlan $proPlan;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('hosting');

        $this->user = User::factory()->create();

        $this->freePlan = SubscriptionPlan::create([
            'name' => 'Free',
            'slug' => 'free',
            'limits' => [
                'max_websites' => 2,
                'max_published' => 1,
                'ai_generations_monthly' => 5,
                'ai_edits_monthly' => 20,
                'custom_domains' => 0,
            ],
            'price_monthly' => 0,
            'is_active' => true,
        ]);

        $this->proPlan = SubscriptionPlan::create([
            'name' => 'Pro',
            'slug' => 'pro',
            'google_play_product_id' => 'com.aibuilder.pro_monthly',
            'limits' => [
                'max_websites' => 10,
                'max_published' => 5,
                'ai_generations_monthly' => 50,
                'ai_edits_monthly' => 100,
                'custom_domains' => 5,
            ],
            'price_monthly' => 29.00,
            'is_active' => true,
        ]);

        $this->project = Project::create([
            'user_id' => $this->user->id,
            'name' => 'Entitlement Test Project',
            'slug' => 'entitlement-test-project',
        ]);
    }

    public function test_can_list_plans_and_get_user_entitlement_summary(): void
    {
        $plansResponse = $this->actingAs($this->user, 'sanctum')->getJson('/api/v1/billing/plans');
        $plansResponse->assertStatus(200)
            ->assertJsonStructure(['plans' => [['name', 'slug', 'limits']]]);

        $subResponse = $this->actingAs($this->user, 'sanctum')->getJson('/api/v1/billing/subscription');
        $subResponse->assertStatus(200)
            ->assertJsonPath('plan.slug', 'free')
            ->assertJsonStructure(['limits', 'usage']);
    }

    public function test_free_user_cannot_attach_custom_domain(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Free Site',
            'slug' => 'free-site',
            'subdomain' => 'free-site',
            'document' => DefaultDocumentFactory::createDefault('Free Site'),
        ]);

        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$website->id}/domains", [
            'domain' => 'https://custom.mybrand.com',
        ]);

        $response->assertStatus(403)
            ->assertJsonPath('error', 'subscription_limit_exceeded')
            ->assertJsonPath('entitlement.metric', 'custom_domains')
            ->assertJsonPath('entitlement.upgrade_required', true);
    }

    public function test_free_user_hits_website_limit(): void
    {
        // Limit is 2
        Website::create([
            'project_id' => $this->project->id,
            'name' => 'Site 1',
            'slug' => 'site-1',
            'subdomain' => 'site-1',
            'document' => DefaultDocumentFactory::createDefault('Site 1'),
        ]);

        Website::create([
            'project_id' => $this->project->id,
            'name' => 'Site 2',
            'slug' => 'site-2',
            'subdomain' => 'site-2',
            'document' => DefaultDocumentFactory::createDefault('Site 2'),
        ]);

        // Attempt to create 3rd website
        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/websites', [
            'project_id' => $this->project->id,
            'name' => 'Site 3 (Limit Exceeded)',
        ]);

        $response->assertStatus(403)
            ->assertJsonPath('error', 'subscription_limit_exceeded')
            ->assertJsonPath('entitlement.metric', 'max_websites');
    }

    public function test_free_user_hits_published_website_limit(): void
    {
        // 1st site published
        $site1 = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Published Site 1',
            'slug' => 'pub-1',
            'subdomain' => 'pub-1',
            'document' => DefaultDocumentFactory::createDefault('Published Site 1'),
            'status' => WebsiteStatus::Draft,
        ]);

        $pubRes1 = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$site1->id}/publish");
        $pubRes1->assertStatus(200);

        // 2nd site publication should fail (limit is 1 for Free)
        $site2 = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Published Site 2',
            'slug' => 'pub-2',
            'subdomain' => 'pub-2',
            'document' => DefaultDocumentFactory::createDefault('Published Site 2'),
            'status' => WebsiteStatus::Draft,
        ]);

        $pubRes2 = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$site2->id}/publish");
        $pubRes2->assertStatus(403)
            ->assertJsonPath('error', 'subscription_limit_exceeded')
            ->assertJsonPath('entitlement.metric', 'max_published');
    }

    public function test_google_play_purchase_verification_activates_pro_subscription(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/billing/google-play/verify', [
            'product_id' => 'com.aibuilder.pro_monthly',
            'purchase_token' => 'sample_gp_token_987654321',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('subscription.status', SubscriptionStatus::Active->value)
            ->assertJsonPath('subscription.plan.slug', 'pro');

        $this->assertDatabaseHas('subscriptions', [
            'user_id' => $this->user->id,
            'status' => SubscriptionStatus::Active->value,
            'provider' => 'google_play',
        ]);
    }

    public function test_stripe_webhook_checkout_session_activates_pro_subscription_idempotently(): void
    {
        $customer = BillingCustomer::create([
            'user_id' => $this->user->id,
            'stripe_customer_id' => 'cus_stripe_test_123',
        ]);

        $webhookPayload = [
            'id' => 'evt_test_checkout_session_123',
            'type' => 'checkout.session.completed',
            'data' => [
                'object' => [
                    'id' => 'cs_test_abc123',
                    'customer' => 'cus_stripe_test_123',
                    'subscription' => 'sub_stripe_real_456',
                    'metadata' => [
                        'user_id' => $this->user->id,
                        'plan_slug' => 'pro',
                    ],
                ],
            ],
        ];

        // 1st delivery
        $response1 = $this->postJson('/api/v1/billing/webhook/stripe', $webhookPayload);
        $response1->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertDatabaseHas('subscriptions', [
            'user_id' => $this->user->id,
            'status' => SubscriptionStatus::Active->value,
            'provider' => 'stripe',
            'provider_subscription_id' => 'sub_stripe_real_456',
        ]);

        // Duplicate delivery (idempotency check)
        $response2 = $this->postJson('/api/v1/billing/webhook/stripe', $webhookPayload);
        $response2->assertStatus(200)
            ->assertJsonPath('status', 'already_processed');
    }
}

