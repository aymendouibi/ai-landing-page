<?php

namespace Tests\Feature;

use App\Enums\AuthProvider;
use App\Models\User;
use App\Models\UserAuthProvider;
use App\Services\Auth\AccountLinkingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class AccountLinkingTest extends TestCase
{
    use RefreshDatabase;

    protected AccountLinkingService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = app(AccountLinkingService::class);
    }

    public function test_link_provider_to_user(): void
    {
        $user = User::factory()->create();

        $link = $this->service->linkProvider(
            user: $user,
            provider: AuthProvider::Google,
            providerUserId: 'google_uid_12345',
            providerEmail: 'test@gmail.com'
        );

        $this->assertDatabaseHas('user_auth_providers', [
            'user_id' => $user->id,
            'provider' => AuthProvider::Google->value,
            'provider_user_id' => 'google_uid_12345',
        ]);
    }

    public function test_cannot_link_provider_already_associated_with_another_user(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $this->service->linkProvider(
            user: $user1,
            provider: AuthProvider::Google,
            providerUserId: 'google_uid_shared',
        );

        $this->expectException(ValidationException::class);

        $this->service->linkProvider(
            user: $user2,
            provider: AuthProvider::Google,
            providerUserId: 'google_uid_shared',
        );
    }

    public function test_user_can_unlink_provider_if_they_have_a_password(): void
    {
        $user = User::factory()->create(['password' => bcrypt('Password123!')]);

        $this->service->linkProvider(
            user: $user,
            provider: AuthProvider::Google,
            providerUserId: 'google_uid_999',
        );

        $result = $this->service->unlinkProvider($user, AuthProvider::Google);
        $this->assertTrue($result);

        $this->assertDatabaseMissing('user_auth_providers', [
            'user_id' => $user->id,
            'provider' => AuthProvider::Google->value,
        ]);
    }

    public function test_user_cannot_unlink_only_provider_without_a_password(): void
    {
        $user = User::factory()->create(['password' => null]);

        $this->service->linkProvider(
            user: $user,
            provider: AuthProvider::Google,
            providerUserId: 'google_uid_only',
        );

        $this->expectException(ValidationException::class);

        $this->service->unlinkProvider($user, AuthProvider::Google);
    }

    public function test_find_or_create_from_oauth_links_if_email_is_verified(): void
    {
        $existingUser = User::factory()->create(['email' => 'verified@domain.com']);

        $user = $this->service->findOrCreateFromOAuth(
            provider: AuthProvider::Google,
            providerUserId: 'google_uid_verified_1',
            email: 'verified@domain.com',
            name: 'Verified User',
            emailVerified: true
        );

        $this->assertEquals($existingUser->id, $user->id);
        $this->assertDatabaseHas('user_auth_providers', [
            'user_id' => $existingUser->id,
            'provider' => AuthProvider::Google->value,
            'provider_user_id' => 'google_uid_verified_1',
        ]);
    }

    public function test_find_or_create_from_oauth_creates_new_user_if_unverified(): void
    {
        User::factory()->create(['email' => 'target@domain.com']);

        // OAuth login with unverified email must NOT link to the existing account
        $newUser = $this->service->findOrCreateFromOAuth(
            provider: AuthProvider::Google,
            providerUserId: 'google_uid_unverified_2',
            email: 'target@domain.com',
            name: 'Target User',
            emailVerified: false // UNVERIFIED!
        );

        // A separate placeholder user should be created
        $this->assertNotEquals('target@domain.com', $newUser->email);
        $this->assertStringContainsString('@auth.local', $newUser->email);
    }
}
