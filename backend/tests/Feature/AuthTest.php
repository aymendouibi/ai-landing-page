<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_with_email_and_password(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'SecurePass123!',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'user' => ['id', 'name', 'email', 'role'],
                'token',
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
            'name' => 'John Doe',
        ]);
    }

    public function test_registration_fails_with_duplicate_email(): void
    {
        User::factory()->create([
            'email' => 'existing@example.com',
        ]);

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Another User',
            'email' => 'existing@example.com',
            'password' => 'SecurePass123!',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'alex@example.com',
            'password' => bcrypt('ValidPassword123!'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'alex@example.com',
            'password' => 'ValidPassword123!',
            'device_name' => 'Pixel 8',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'user' => ['id', 'name', 'email'],
                'token',
            ]);
    }

    public function test_user_cannot_login_with_invalid_credentials(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('CorrectPassword123!'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'WrongPassword!',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    public function test_authenticated_user_can_get_profile(): void
    {
        $user = User::factory()->create(['name' => 'Profile User']);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('user.id', $user->id)
            ->assertJsonPath('user.name', 'Profile User')
            ->assertJsonPath('is_admin', false);
    }

    public function test_authenticated_user_can_logout(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test_token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/logout');

        $response->assertStatus(200)
            ->assertJson(['message' => 'Successfully logged out.']);
    }

    public function test_unauthenticated_request_to_protected_route_is_rejected(): void
    {
        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(401);
    }

    public function test_user_can_authenticate_with_google(): void
    {
        $mockVerifier = $this->createMock(\App\Services\Auth\GoogleTokenVerifier::class);
        $mockVerifier->method('verify')->willReturn([
            'sub' => 'google_sub_123456',
            'email' => 'googleuser@example.com',
            'name' => 'Google User',
            'picture' => 'https://example.com/avatar.jpg',
            'email_verified' => true,
        ]);
        $this->app->instance(\App\Services\Auth\GoogleTokenVerifier::class, $mockVerifier);

        $response = $this->postJson('/api/v1/auth/google', [
            'id_token' => 'valid_mock_google_id_token',
            'device_name' => 'iPhone Simulator',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'user' => ['id', 'name', 'email'],
                'token',
            ])
            ->assertJsonPath('user.email', 'googleuser@example.com');

        $this->assertDatabaseHas('users', [
            'email' => 'googleuser@example.com',
            'name' => 'Google User',
        ]);

        $this->assertDatabaseHas('user_auth_providers', [
            'provider' => \App\Enums\AuthProvider::Google->value,
            'provider_user_id' => 'google_sub_123456',
        ]);
    }

    public function test_google_sign_in_rejects_invalid_token(): void
    {
        $mockVerifier = $this->createMock(\App\Services\Auth\GoogleTokenVerifier::class);
        $mockVerifier->method('verify')->willThrowException(new \Exception('Invalid Google ID token.'));
        $this->app->instance(\App\Services\Auth\GoogleTokenVerifier::class, $mockVerifier);

        $response = $this->postJson('/api/v1/auth/google', [
            'id_token' => 'invalid_token_sample',
        ]);

        $response->assertStatus(401)
            ->assertJson(['message' => 'Invalid Google ID token.']);
    }

    public function test_user_can_authenticate_with_apple(): void
    {
        $mockVerifier = $this->createMock(\App\Services\Auth\AppleTokenVerifier::class);
        $mockVerifier->method('verify')->willReturn([
            'sub' => 'apple_sub_987654',
            'email' => 'appleuser@privaterelay.appleid.com',
            'email_verified' => true,
            'is_private_email' => true,
        ]);
        $this->app->instance(\App\Services\Auth\AppleTokenVerifier::class, $mockVerifier);

        $response = $this->postJson('/api/v1/auth/apple', [
            'identity_token' => 'valid_mock_apple_identity_token',
            'name' => 'Apple User',
            'device_name' => 'iPhone 17 Pro',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'user' => ['id', 'name', 'email'],
                'token',
            ])
            ->assertJsonPath('user.email', 'appleuser@privaterelay.appleid.com');

        $this->assertDatabaseHas('users', [
            'email' => 'appleuser@privaterelay.appleid.com',
            'name' => 'Apple User',
        ]);

        $this->assertDatabaseHas('user_auth_providers', [
            'provider' => \App\Enums\AuthProvider::Apple->value,
            'provider_user_id' => 'apple_sub_987654',
        ]);
    }

    public function test_apple_sign_in_rejects_invalid_token(): void
    {
        $mockVerifier = $this->createMock(\App\Services\Auth\AppleTokenVerifier::class);
        $mockVerifier->method('verify')->willThrowException(new \Exception('Malformed Apple identity token.'));
        $this->app->instance(\App\Services\Auth\AppleTokenVerifier::class, $mockVerifier);

        $response = $this->postJson('/api/v1/auth/apple', [
            'identity_token' => 'invalid_apple_jwt',
        ]);

        $response->assertStatus(401)
            ->assertJson(['message' => 'Malformed Apple identity token.']);
    }
}

