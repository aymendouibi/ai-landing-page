<?php

namespace Tests\Feature;

use App\Enums\TemplateStatus;
use App\Enums\UserRole;
use App\Models\Project;
use App\Models\Template;
use App\Models\User;
use App\Models\Website;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TemplateSharingAndAdminTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_templates_with_curated_badges(): void
    {
        Template::create([
            'name' => 'Lumen Coffee',
            'slug' => 'lumen-coffee-test',
            'badge' => "EDITOR'S PICK",
            'is_featured' => true,
            'is_public' => true,
            'status' => TemplateStatus::Published,
            'industry' => 'Food & drink',
        ]);

        $response = $this->getJson('/api/v1/templates?tab=for_you');
        $response->assertStatus(200);
        $response->assertJsonFragment(['name' => 'Lumen Coffee']);
        $response->assertJsonFragment(['badge' => "EDITOR'S PICK"]);
    }

    public function test_user_can_share_website_as_template(): void
    {
        $user = User::factory()->create(['role' => UserRole::User]);
        $project = Project::create(['user_id' => $user->id, 'name' => 'Bakery Project']);
        $website = Website::create([
            'project_id' => $project->id,
            'name' => 'My Custom Bakery',
            'slug' => 'my-custom-bakery',
            'status' => \App\Enums\WebsiteStatus::Draft,
            'document' => [
                'schema_version' => 1,
                'site' => ['name' => 'My Custom Bakery'],
                'pages' => [
                    [
                        'id' => 'home',
                        'title' => 'Home',
                        'sections' => [
                            [
                                'id' => 'sec_hero',
                                'component' => 'hero',
                                'props' => [
                                    'headline' => 'Fresh Sourdough Daily',
                                    'ctaText' => 'Order Now',
                                    'image' => ['src' => 'https://example.com/bread.jpg'],
                                ],
                            ],
                        ],
                    ],
                ],
            ],
        ]);

        $response = $this->actingAs($user)->postJson("/api/v1/websites/{$website->id}/share-template", [
            'name' => 'Artisan Bakery Theme',
            'description' => 'A rustic layout for local bakeries.',
            'industry' => 'Food & drink',
            'badge' => 'COMMUNITY',
        ]);

        $response->assertStatus(201);
        $response->assertJsonFragment(['name' => 'Artisan Bakery Theme']);
        $response->assertJsonFragment(['badge' => 'COMMUNITY']);

        $this->assertDatabaseHas('templates', [
            'name' => 'Artisan Bakery Theme',
            'user_id' => $user->id,
            'source_website_id' => $website->id,
        ]);
    }

    public function test_admin_dashboard_web_view_loads_successfully(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $response = $this->actingAs($admin)->get('/admin/templates');
        $response->assertStatus(200);
        $response->assertSee('Template Studio');
        $response->assertSee('Admin');
    }

    public function test_admin_can_toggle_featured_status_on_template(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $template = Template::create([
            'name' => 'Raw Minimalist',
            'slug' => 'raw-minimalist',
            'badge' => null,
            'is_featured' => false,
            'is_public' => true,
            'status' => TemplateStatus::Published,
        ]);

        $response = $this->actingAs($admin)->post("/admin/templates/{$template->id}/toggle-feature", [
            'badge' => 'EDITOR PICK',
        ]);

        $response->assertRedirect();
        $this->assertTrue($template->fresh()->is_featured);
        $this->assertEquals('EDITOR PICK', $template->fresh()->badge);
    }

    public function test_guest_is_redirected_to_admin_login(): void
    {
        $response = $this->get('/admin');
        $response->assertRedirect(route('admin.login'));
    }

    public function test_regular_user_cannot_access_admin_dashboard(): void
    {
        $user = User::factory()->create(['role' => UserRole::User]);
        $response = $this->actingAs($user)->get('/admin');
        $response->assertStatus(403);
    }

    public function test_admin_overview_dashboard_loads(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $response = $this->actingAs($admin)->get('/admin');
        $response->assertStatus(200);
        $response->assertSee('Dashboard');
        $response->assertSee('Total Users');
        $response->assertSee('Websites');
        $response->assertSee('Templates');
    }

    public function test_admin_can_view_websites_and_toggle_status(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $project = Project::create(['user_id' => $admin->id, 'name' => 'Test Project']);
        $site = Website::create([
            'project_id' => $project->id,
            'name' => 'Sample Site',
            'slug' => 'sample-site',
            'status' => \App\Enums\WebsiteStatus::Draft,
            'document' => ['site' => ['name' => 'Sample Site'], 'pages' => []],
        ]);

        $response = $this->actingAs($admin)->get('/admin/websites');
        $response->assertStatus(200);
        $response->assertSee('Sample Site');

        // Toggle to Published
        $toggleResp = $this->actingAs($admin)->post("/admin/websites/{$site->id}/toggle-status");
        $toggleResp->assertRedirect();
        $this->assertEquals(\App\Enums\WebsiteStatus::Published, $site->fresh()->status);
    }

    public function test_admin_can_convert_website_to_curated_template(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $project = Project::create(['user_id' => $admin->id, 'name' => 'Showcase Project']);
        $site = Website::create([
            'project_id' => $project->id,
            'name' => 'Luxe Salon',
            'slug' => 'luxe-salon',
            'status' => \App\Enums\WebsiteStatus::Published,
            'document' => [
                'site' => [
                    'name' => 'Luxe Salon',
                    'theme' => ['colors' => ['primary' => '#111']],
                    'settings' => ['googleFonts' => ['Inter']],
                ],
                'pages' => [],
            ],
        ]);

        $response = $this->actingAs($admin)->post("/admin/websites/{$site->id}/convert-to-template", [
            'name' => 'Luxe Salon Master Template',
            'industry' => 'Beauty',
            'badge' => "EDITOR'S PICK",
            'is_featured' => true,
        ]);

        $response->assertRedirect(route('admin.templates.index'));
        $this->assertDatabaseHas('templates', [
            'name' => 'Luxe Salon Master Template',
            'industry' => 'Beauty',
            'badge' => "EDITOR'S PICK",
            'is_featured' => true,
            'source_website_id' => $site->id,
        ]);
    }

    public function test_admin_can_view_users_and_toggle_role(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $creator = User::factory()->create(['role' => UserRole::User, 'name' => 'Jane Creator']);

        $response = $this->actingAs($admin)->get('/admin/users');
        $response->assertStatus(200);
        $response->assertSee('Jane Creator');

        // Promote Jane to Admin
        $promoteResp = $this->actingAs($admin)->post("/admin/users/{$creator->id}/toggle-role");
        $promoteResp->assertRedirect();
        $this->assertEquals(UserRole::Admin, $creator->fresh()->role);
    }

    public function test_admin_can_view_system_health(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $response = $this->actingAs($admin)->get('/admin/system');
        $response->assertStatus(200);
        $response->assertSee('System Health');
        $response->assertSee('Database Service');
        $response->assertSee('Renderer Engine');
    }

    public function test_admin_can_import_template_from_url(): void
    {
        \Illuminate\Support\Facades\Http::fake([
            'https://modern-agency.design' => \Illuminate\Support\Facades\Http::response(
                '<!DOCTYPE html><html><head><title>Apex Studio - High Performance Agency</title><meta name="description" content="Award-winning digital experiences."><meta property="og:image" content="https://images.unsplash.com/photo-1497366216548-37526070297c"></head><body><span class="badge">✦ AWARD WINNER 2026</span><h1>Crafting Products for Future Pioneers</h1><p class="lead">We engineer ultra-refined digital platforms.</p><h2>Global Scale</h2><p>Serving over 50 enterprise clients globally.</p><h2>Design Systems</h2><p>Scalable component libraries.</p></body></html>',
                200
            ),
        ]);

        $admin = User::factory()->create(['role' => UserRole::Admin]);

        $response = $this->actingAs($admin)->post('/admin/templates/import-url', [
            'url' => 'https://modern-agency.design',
            'name' => 'Apex Studio Modern',
            'badge' => 'AWARD WINNER',
            'industry' => 'Agency & Design',
            'is_featured' => true,
        ]);

        $response->assertRedirect(route('admin.templates.index'));
        $this->assertDatabaseHas('templates', [
            'name' => 'Apex Studio Modern',
            'badge' => 'AWARD WINNER',
            'industry' => 'Agency & Design',
            'is_featured' => true,
            'status' => TemplateStatus::Published->value,
        ]);
    }
}
