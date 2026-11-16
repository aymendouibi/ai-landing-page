<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AdminAuthSecurityTest extends TestCase
{
    use RefreshDatabase;

    public function test_quick_login_is_forbidden_in_production(): void
    {
        $this->app->detectEnvironment(fn() => 'production');

        $response = $this->get('/admin/quick-login');

        $response->assertStatus(403);
    }

    public function test_quick_login_allowed_in_local(): void
    {
        $this->app->detectEnvironment(fn() => 'local');

        $response = $this->get('/admin/quick-login');

        $response->assertRedirect(route('admin.dashboard'));
        $this->assertAuthenticated();
        $this->assertTrue(auth()->user()->isAdmin());
    }

    public function test_login_page_renders_empty_fields_in_production(): void
    {
        $this->app->detectEnvironment(fn() => 'production');

        $response = $this->get('/admin/login');

        $response->assertStatus(200);
        $response->assertDontSee('value="admin@aibuilder.local"', false);
        $response->assertDontSee('value="AdminSecret123!"', false);
        $response->assertDontSee('⚡ 1-Click Dev Admin Login');
    }

    public function test_admin_can_login_with_valid_credentials(): void
    {
        $admin = User::factory()->create([
            'email' => 'realadmin@example.com',
            'password' => Hash::make('SuperSecurePass123!'),
            'role' => UserRole::Admin,
        ]);

        $response = $this->post('/admin/login', [
            'email' => 'realadmin@example.com',
            'password' => 'SuperSecurePass123!',
        ]);

        $response->assertRedirect(route('admin.dashboard'));
        $this->assertAuthenticatedAs($admin);
    }

    public function test_non_admin_cannot_login_to_admin_portal(): void
    {
        $user = User::factory()->create([
            'email' => 'regularuser@example.com',
            'password' => Hash::make('RegularPass123!'),
            'role' => UserRole::User,
        ]);

        $response = $this->post('/admin/login', [
            'email' => 'regularuser@example.com',
            'password' => 'RegularPass123!',
        ]);

        $response->assertSessionHasErrors(['email']);
        $this->assertGuest();
    }
}
