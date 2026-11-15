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
                'ai_generations_monthly' => 4,
                'ai_edits_monthly' => 20,
                'custom_domains' => 0,
                'has_ads' => true,
                'all_templates' => false,
                'ssl_enabled' => false,
            ],
            'price_monthly' => 0,
            'is_active' => true,
        ]);

        $this->proPlan = SubscriptionPlan::create([
            'name' => 'Premium',
            'slug' => 'pro',
            'google_play_product_id' => 'com.aibuilder.pro_monthly',
            'limits' => [
                'max_websites' => 10,
                'max_published' => 5,
                'ai_generations_monthly' => 90,
                'ai_edits_monthly' => 100,
                'custom_domains' => 5,
                'has_ads' => false,
                'all_templates' => true,
                'premium_templates' => true,
                'ssl_enabled' => true,
            ],
            'price_monthly' => 9.99,
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

    public function test_free_user_cannot_use_premium_template(): void
    {
        $template = \App\Models\Template::create([
            'name' => 'Luxury Villa',
            'slug' => 'luxury-villa',
            'is_premium' => true,
            'is_public' => true,
            'status' => \App\Enums\TemplateStatus::Published,
        ]);

        \App\Models\TemplateVersion::create([
            'template_id' => $template->id,
            'version_number' => 1,
            'document' => DefaultDocumentFactory::createDefault('Luxury Villa'),
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/templates/{$template->id}/use", [
            'project_id' => $this->project->id,
            'name' => 'My Villa Project',
        ]);

        $response->assertStatus(403)
            ->assertJsonPath('error', 'subscription_limit_exceeded')
            ->assertJsonPath('entitlement.metric', 'premium_templates');
    }

    public function test_user_can_switch_to_premium_and_access_premium_features(): void
    {
        // 1. Upgrade to Premium
        $subResponse = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/billing/subscribe', [
            'plan_slug' => 'pro',
        ]);

        $subResponse->assertStatus(200)
            ->assertJsonPath('summary.plan.slug', 'pro');

        // 2. Can now use premium template
        $template = \App\Models\Template::create([
            'name' => 'High-end Studio',
            'slug' => 'highend-studio',
            'badge' => 'PRO',
            'is_public' => true,
            'status' => \App\Enums\TemplateStatus::Published,
        ]);

        \App\Models\TemplateVersion::create([
            'template_id' => $template->id,
            'version_number' => 1,
            'document' => DefaultDocumentFactory::createDefault('High-end Studio'),
            'is_active' => true,
        ]);

        $useResponse = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/templates/{$template->id}/use", [
            'project_id' => $this->project->id,
            'name' => 'My Pro Site',
        ]);

        $useResponse->assertStatus(201)
            ->assertJsonPath('website.name', 'My Pro Site');
    }

    public function test_user_can_create_payment_intent_for_mobile_payment_sheet(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/billing/payment-intent', [
            'interval' => 'monthly',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'paymentIntentId',
                'clientSecret',
                'amount',
                'currency',
            ])
            ->assertJsonPath('amount', 499)
            ->assertJsonPath('currency', 'eur');
    }

    public function test_stripe_webhook_payment_intent_succeeded_activates_pro_subscription(): void
    {
        $payload = [
            'id' => 'evt_pi_success_' . uniqid(),
            'type' => 'payment_intent.succeeded',
            'data' => [
                'object' => [
                    'id' => 'pi_test_' . uniqid(),
                    'customer' => null,
                    'amount' => 499,
                    'currency' => 'eur',
                    'metadata' => [
                        'user_id' => $this->user->id,
                        'interval' => 'monthly',
                    ],
                ],
            ],
        ];

        $response = $this->postJson('/api/v1/billing/webhook/stripe', $payload, [
            'Stripe-Signature' => 'mock_signature',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->user->refresh();
        $entitlementService = app(\App\Services\Billing\SubscriptionEntitlementService::class);
        $this->assertEquals('pro', $entitlementService->getUserPlan($this->user)->slug);
    }

    public function test_user_can_subscribe_yearly_with_stripe_provider_and_one_year_period(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/billing/subscribe', [
            'plan_slug' => 'pro',
            'interval' => 'yearly',
            'provider' => 'stripe',
            'payment_intent_id' => 'pi_test_yearly_12345',
        ]);

        $response->assertStatus(200);

        $subscription = \App\Models\Subscription::where('user_id', $this->user->id)->first();
        $this->assertNotNull($subscription);
        $this->assertEquals('stripe', $subscription->provider->value);
        $this->assertEquals('pi_test_yearly_12345', $subscription->provider_subscription_id);
        $this->assertTrue($subscription->current_period_end->isAfter(now()->addMonths(11)));

        // Billing event logged
        $event = \App\Models\BillingEvent::where('provider_event_id', 'pi_test_yearly_12345')->first();
        $this->assertNotNull($event);
        $this->assertEquals('stripe', $event->provider);

        // Can retrieve billing history
        $historyRes = $this->actingAs($this->user, 'sanctum')->getJson('/api/v1/billing/history');
        $historyRes->assertStatus(200)
            ->assertJsonStructure(['history' => [['title', 'amount', 'status', 'reference']]]);
        $this->assertNotEmpty($historyRes->json('history'));
    }

    public function test_free_user_cannot_export_project_zip_and_gets_entitlement_error(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Free Export Test Site',
            'slug' => 'free-export-test-site',
            'status' => WebsiteStatus::Draft,
            'subdomain' => 'freeexport',
            'revision_number' => 1,
            'document' => DefaultDocumentFactory::createDefault('Free Export Test Site'),
        ]);

        $response = $this->actingAs($this->user, 'sanctum')->getJson("/api/v1/websites/{$website->id}/export");

        $response->assertStatus(403)
            ->assertJsonPath('error', 'subscription_limit_exceeded')
            ->assertJsonPath('entitlement.metric', 'code_export')
            ->assertJsonPath('entitlement.upgrade_required', true);
    }

    public function test_premium_user_can_export_project_zip(): void
    {
        // Upgrade user to Pro / Premium
        $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/billing/subscribe', [
            'plan_slug' => 'pro',
        ]);

        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Pro Export Test Site',
            'slug' => 'pro-export-test-site',
            'status' => WebsiteStatus::Published,
            'subdomain' => 'proexport',
            'revision_number' => 1,
            'document' => DefaultDocumentFactory::createDefault('Pro Export Test Site'),
        ]);

        $response = $this->actingAs($this->user, 'sanctum')->get("/api/v1/websites/{$website->id}/export");

        $response->assertStatus(200)
            ->assertHeader('Content-Type', 'application/zip');

        $this->assertStringContainsString('filename=pro-export-test-site-project.zip', $response->headers->get('Content-Disposition'));

        // Verify that the response file exists and contains valid zip binary data (starts with PK)
        $file = $response->getFile();
        $this->assertFileExists($file->getPathname());
        $content = file_get_contents($file->getPathname());
        $this->assertStringStartsWith("PK", $content);
    }
}

