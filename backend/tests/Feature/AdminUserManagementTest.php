<?php

namespace Tests\Feature;

use App\Enums\SubscriptionStatus;
use App\Enums\UserRole;
use App\Models\Project;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use App\Models\Website;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminUserManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_users_list_orders_premium_subscribers_first(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);

        // Standard free user created earlier
        $freeUser = User::factory()->create([
            'name' => 'Free Creator',
            'created_at' => now()->subDays(5),
        ]);

        // Premium user created later
        $premiumUser = User::factory()->create([
            'name' => 'Premium Creator VIP',
            'created_at' => now()->subDay(),
        ]);

        $proPlan = SubscriptionPlan::create([
            'name' => 'Premium',
            'slug' => 'pro',
            'description' => 'Pro tier',
            'limits' => ['max_websites' => 50],
            'price_monthly' => 9.99,
            'is_active' => true,
        ]);

        Subscription::create([
            'user_id' => $premiumUser->id,
            'plan_id' => $proPlan->id,
            'provider' => \App\Enums\BillingProvider::Stripe,
            'status' => SubscriptionStatus::Active,
        ]);

        $response = $this->actingAs($admin)->get('/admin/users');

        $response->assertStatus(200);
        $content = $response->getContent();

        // Premium user should appear before Free user in the HTML table
        $posPremium = strpos($content, 'Premium Creator VIP');
        $posFree = strpos($content, 'Free Creator');

        $this->assertNotFalse($posPremium);
        $this->assertNotFalse($posFree);
        $this->assertTrue($posPremium < $posFree, 'Premium user must appear before free user in the dashboard list.');
    }

    public function test_admin_can_inspect_user_profile_and_generated_websites(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $creator = User::factory()->create(['name' => 'Jane Designer']);

        $project = Project::create([
            'user_id' => $creator->id,
            'name' => 'Portfolio Project',
        ]);

        $site = Website::create([
            'project_id' => $project->id,
            'name' => 'Jane Architecture Studio',
            'slug' => 'jane-architecture',
            'subdomain' => 'jane-arch',
            'status' => 'published',
            'document' => [
                'site' => ['name' => 'Jane Architecture Studio'],
                'sections' => [
                    ['id' => 'sec_1', 'component' => 'hero'],
                    ['id' => 'sec_2', 'component' => 'gallery'],
                ],
            ],
        ]);

        // Web view
        $viewResp = $this->actingAs($admin)->get("/admin/users/{$creator->id}");
        $viewResp->assertStatus(200)
            ->assertSee('Jane Architecture Studio')
            ->assertSee('jane-arch.ai-landing-page.xyz');

        // JSON endpoint for instant modal
        $jsonResp = $this->actingAs($admin)->getJson("/admin/users/{$creator->id}");
        $jsonResp->assertStatus(200)
            ->assertJsonPath('user.name', 'Jane Designer')
            ->assertJsonPath('websites.0.name', 'Jane Architecture Studio')
            ->assertJsonPath('websites.0.subdomain', 'jane-arch');
    }

    public function test_admin_can_upgrade_account_to_premium_with_duration(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $creator = User::factory()->create(['name' => 'Bob Creator']);

        $proPlan = SubscriptionPlan::create([
            'name' => 'Premium',
            'slug' => 'pro',
            'description' => 'Pro tier',
            'limits' => ['max_websites' => 50],
            'price_monthly' => 4.99,
            'is_active' => true,
        ]);

        $this->assertFalse($creator->isPremium());

        $response = $this->actingAs($admin)->post("/admin/users/{$creator->id}/upgrade-premium", [
            'plan_slug' => 'pro',
            'duration' => '1_year',
            'note' => 'VIP partner upgrade',
        ]);

        $response->assertRedirect();
        $response->assertSessionHas('success');

        $creator->refresh();
        $this->assertTrue($creator->isPremium());
        $this->assertEquals('Premium', $creator->getTierLabel());

        $sub = $creator->getActiveSubscription();
        $this->assertNotNull($sub);
        $this->assertEquals(\App\Enums\BillingProvider::Manual, $sub->provider);
        $this->assertEquals(\App\Enums\SubscriptionStatus::Active, $sub->status);
        $this->assertTrue($sub->current_period_end->isFuture());

        // An in-app notification should have been dispatched to the creator
        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $creator->id,
            'type' => 'subscription_upgraded',
        ]);

        // A BillingEvent should have been logged for audit trail
        $this->assertDatabaseHas('billing_events', [
            'provider' => 'manual',
            'event_type' => 'subscription.admin_upgraded',
        ]);
    }

    public function test_admin_can_upgrade_via_ajax_json_endpoint(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $creator = User::factory()->create(['name' => 'Sarah Creator']);

        SubscriptionPlan::create([
            'name' => 'Business & Agency',
            'slug' => 'business',
            'description' => 'Business tier',
            'limits' => ['max_websites' => 500],
            'price_monthly' => 29.99,
            'is_active' => true,
        ]);

        $jsonResp = $this->actingAs($admin)->postJson("/admin/users/{$creator->id}/upgrade-premium", [
            'plan_slug' => 'business',
            'duration' => 'lifetime',
            'note' => 'Lifetime agency creator',
        ]);

        $jsonResp->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('user.is_premium', true)
            ->assertJsonPath('user.subscription.plan_name', 'Business & Agency')
            ->assertJsonPath('user.subscription.current_period_end', 'À vie');

        $creator->refresh();
        $this->assertTrue($creator->isPremium());
        $this->assertEquals('Business & Agency', $creator->getTierLabel());
    }

    public function test_admin_can_cancel_or_downgrade_premium_subscription(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $creator = User::factory()->create(['name' => 'Alex Creator']);

        $proPlan = SubscriptionPlan::create([
            'name' => 'Premium',
            'slug' => 'pro',
            'limits' => ['max_websites' => 50],
            'price_monthly' => 4.99,
            'is_active' => true,
        ]);

        Subscription::create([
            'user_id' => $creator->id,
            'plan_id' => $proPlan->id,
            'provider' => \App\Enums\BillingProvider::Manual,
            'status' => SubscriptionStatus::Active,
            'current_period_end' => now()->addYear(),
        ]);

        $this->assertTrue($creator->isPremium());

        $response = $this->actingAs($admin)->post("/admin/users/{$creator->id}/cancel-premium");
        $response->assertRedirect();
        $response->assertSessionHas('success');

        $creator->refresh();
        $this->assertFalse($creator->isPremium());
        $this->assertEquals('Free', $creator->getTierLabel());

        $this->assertDatabaseHas('billing_events', [
            'provider' => 'manual',
            'event_type' => 'subscription.admin_downgraded',
        ]);
    }

    public function test_non_admin_cannot_upgrade_accounts(): void
    {
        $regularUser = User::factory()->create(['role' => UserRole::User]);
        $targetUser = User::factory()->create();

        $response = $this->actingAs($regularUser)->post("/admin/users/{$targetUser->id}/upgrade-premium", [
            'plan_slug' => 'pro',
        ]);

        $response->assertStatus(403);
    }
}
