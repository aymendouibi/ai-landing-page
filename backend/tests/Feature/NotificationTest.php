<?php

namespace Tests\Feature;

use App\Enums\WebsiteStatus;
use App\Models\AppNotification;
use App\Models\Project;
use App\Models\User;
use App\Models\Website;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    protected function createWebsite(User $user, string $name, WebsiteStatus $status = WebsiteStatus::Draft, array $attrs = []): Website
    {
        $project = Project::create([
            'user_id' => $user->id,
            'name' => 'Project for ' . $name,
        ]);

        return Website::create(array_merge([
            'project_id' => $project->id,
            'name' => $name,
            'slug' => Str::slug($name) . '-' . Str::random(4),
            'subdomain' => Str::slug($name) . '-' . Str::random(4),
            'status' => $status,
            'document' => [
                'meta' => ['name' => $name],
                'pages' => [],
            ],
        ], $attrs));
    }

    public function test_notification_service_creates_ai_modification_notification_in_user_language(): void
    {
        $user = User::factory()->create([
            'preferences' => ['locale' => 'fr'],
        ]);
        $website = $this->createWebsite($user, 'Boutique Parisienne', WebsiteStatus::Draft);

        $service = app(NotificationService::class);
        $notif = $service->sendAiModification($user, $website, 'Couleur d\'accent modifiée');

        $this->assertInstanceOf(AppNotification::class, $notif);
        $this->assertEquals($user->id, $notif->user_id);
        $this->assertEquals('ai_modification', $notif->type);
        $this->assertEquals('fr', $notif->locale);
        $this->assertStringContainsString('Modification IA terminée', $notif->title);
        $this->assertStringContainsString('Boutique Parisienne', $notif->body);
    }

    public function test_notification_service_creates_site_live_notification_in_spanish(): void
    {
        $user = User::factory()->create([
            'preferences' => ['locale' => 'es'],
        ]);
        $website = $this->createWebsite($user, 'Cafetería Del Sol', WebsiteStatus::Published);

        $service = app(NotificationService::class);
        $notif = $service->sendSiteLive($user, $website, 'https://api.ai-landing-page.xyz/sites/cafeteria-del-sol');

        $this->assertEquals('site_live', $notif->type);
        $this->assertEquals('es', $notif->locale);
        $this->assertStringContainsString('¡Tu sitio web está en línea!', $notif->title);
        $this->assertStringContainsString('Cafetería Del Sol', $notif->body);
        $this->assertEquals('https://api.ai-landing-page.xyz/sites/cafeteria-del-sol', $notif->data['url']);
    }

    public function test_notification_service_creates_draft_reminder_in_arabic(): void
    {
        $user = User::factory()->create([
            'preferences' => ['locale' => 'ar'],
        ]);
        $website = $this->createWebsite($user, 'متجر المستقبل', WebsiteStatus::Draft);

        $service = app(NotificationService::class);
        $notif = $service->sendDraftReminder($user, $website);

        $this->assertEquals('draft_reminder', $notif->type);
        $this->assertEquals('ar', $notif->locale);
        $this->assertStringContainsString('أكمل موقعك الإلكتروني', $notif->title);
        $this->assertStringContainsString('متجر المستقبل', $notif->body);
    }

    public function test_api_can_fetch_notifications_and_mark_as_read(): void
    {
        $user = User::factory()->create();
        AppNotification::create([
            'user_id' => $user->id,
            'type' => 'ai_modification',
            'title' => 'Test Notification 1',
            'body' => 'Details here',
            'locale' => 'en',
        ]);
        $notif2 = AppNotification::create([
            'user_id' => $user->id,
            'type' => 'site_live',
            'title' => 'Test Notification 2',
            'body' => 'Details here 2',
            'locale' => 'en',
        ]);

        // Fetch notifications
        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/notifications');
        $response->assertOk()
            ->assertJsonPath('unread_count', 2)
            ->assertJsonCount(2, 'data');

        // Mark single as read
        $readRes = $this->actingAs($user, 'sanctum')->postJson("/api/v1/notifications/{$notif2->id}/read");
        $readRes->assertOk();
        $this->assertNotNull($notif2->fresh()->read_at);

        // Mark all as read
        $readAllRes = $this->actingAs($user, 'sanctum')->postJson('/api/v1/notifications/read-all');
        $readAllRes->assertOk()->assertJsonPath('unread_count', 0);
    }

    public function test_api_can_update_user_notification_preferences(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/notifications/preferences', [
            'locale' => 'fr',
            'theme_mode' => 'dark',
            'device_token' => 'fcm_mock_token_123',
        ]);

        $response->assertOk()
            ->assertJsonPath('preferences.locale', 'fr')
            ->assertJsonPath('preferences.theme_mode', 'dark')
            ->assertJsonPath('resolved_locale', 'fr');

        $this->assertEquals('fr', $user->fresh()->preferences['locale']);
    }

    public function test_artisan_command_sends_draft_reminders(): void
    {
        $user = User::factory()->create(['preferences' => ['locale' => 'de']]);
        $site = $this->createWebsite($user, 'Berliner Kaffee', WebsiteStatus::Draft);
        Website::where('id', $site->id)->update(['updated_at' => now()->subHours(2)]);

        $this->artisan('notifications:remind-drafts', ['--hours' => 1])
            ->assertSuccessful();

        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $user->id,
            'type' => 'draft_reminder',
            'locale' => 'de',
        ]);
    }

    public function test_admin_can_view_and_send_notifications(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $targetUser = User::factory()->create(['name' => 'Alice']);

        // View notifications admin panel
        $res = $this->actingAs($admin)->get(route('admin.notifications.index'));
        $res->assertOk()->assertViewIs('admin.notifications');

        // Send broadcast to all users
        $sendRes = $this->actingAs($admin)->post(route('admin.notifications.send'), [
            'target' => 'all',
            'title' => 'Important Maintenance',
            'body' => 'We are upgrading our servers tonight.',
            'locale' => 'auto',
            'type' => 'admin_broadcast',
        ]);
        $sendRes->assertRedirect()->assertSessionHas('success');

        $this->assertDatabaseHas('app_notifications', [
            'title' => 'Important Maintenance',
            'type' => 'admin_broadcast',
        ]);

        // Send to specific user
        $sendSpecific = $this->actingAs($admin)->post(route('admin.notifications.send'), [
            'target' => 'specific',
            'user_id' => $targetUser->id,
            'title' => 'Welcome Alice',
            'body' => 'Thanks for trying AI Landing Page!',
            'locale' => 'en',
            'type' => 'admin_broadcast',
        ]);
        $sendSpecific->assertRedirect()->assertSessionHas('success');

        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $targetUser->id,
            'title' => 'Welcome Alice',
        ]);
    }
}
