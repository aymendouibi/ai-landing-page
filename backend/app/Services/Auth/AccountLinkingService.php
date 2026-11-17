<?php

namespace App\Services\Auth;

use App\Enums\AuthProvider;
use App\Models\User;
use App\Models\UserAuthProvider;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AccountLinkingService
{
    /**
     * Link an external auth provider to an existing authenticated user.
     *
     * @param User $user
     * @param AuthProvider $provider
     * @param string $providerUserId
     * @param string|null $providerEmail
     * @param array<string, mixed>|null $providerData
     * @return UserAuthProvider
     * @throws ValidationException
     */
    public function linkProvider(
        User $user,
        AuthProvider $provider,
        string $providerUserId,
        ?string $providerEmail = null,
        ?array $providerData = null
    ): UserAuthProvider {
        // Check if this provider identity is already linked to ANOTHER user
        $existing = UserAuthProvider::where('provider', $provider)
            ->where('provider_user_id', $providerUserId)
            ->first();

        if ($existing) {
            if ($existing->user_id === $user->id) {
                // Already linked to this user, update details if any
                $existing->update([
                    'provider_email' => $providerEmail ?? $existing->provider_email,
                    'provider_data' => array_merge($existing->provider_data ?? [], $providerData ?? []),
                ]);
                return $existing;
            }

            throw ValidationException::withMessages([
                'provider' => ["This {$provider->value} account is already linked to another user."],
            ]);
        }

        return UserAuthProvider::create([
            'user_id' => $user->id,
            'provider' => $provider,
            'provider_user_id' => $providerUserId,
            'provider_email' => $providerEmail,
            'provider_data' => $providerData,
        ]);
    }

    /**
     * Unlink a provider from an authenticated user.
     * The user must have a password or at least one other active auth provider so they don't lock themselves out.
     *
     * @param User $user
     * @param AuthProvider $provider
     * @return bool
     * @throws ValidationException
     */
    public function unlinkProvider(User $user, AuthProvider $provider): bool
    {
        $hasPassword = !empty($user->password);
        $totalProviders = $user->authProviders()->count();

        // If user has no password and only this provider, disallow unlinking
        if (!$hasPassword && $totalProviders <= 1) {
            throw ValidationException::withMessages([
                'provider' => ['You cannot unlink your only login method without setting a password first.'],
            ]);
        }

        $deleted = $user->authProviders()->where('provider', $provider)->delete();

        return (bool) $deleted;
    }

    /**
     * Resolve or register a user from verified OAuth credentials.
     * Never automatically merge with an existing account solely because an unverified email matched!
     *
     * @param AuthProvider $provider
     * @param string $providerUserId
     * @param string|null $email
     * @param string|null $name
     * @param bool $emailVerified Whether the OAuth provider confirmed the email is verified
     * @param array<string, mixed>|null $providerData
     * @return User
     */
    public function findOrCreateFromOAuth(
        AuthProvider $provider,
        string $providerUserId,
        ?string $email,
        ?string $name,
        bool $emailVerified = false,
        ?array $providerData = null
    ): User {
        return DB::transaction(function () use ($provider, $providerUserId, $email, $name, $emailVerified, $providerData) {
            // 1. Check if provider account is already linked
            $authProvider = UserAuthProvider::where('provider', $provider)
                ->where('provider_user_id', $providerUserId)
                ->first();

            if ($authProvider) {
                // Update email or provider data if provided
                if ($email && !$authProvider->provider_email) {
                    $authProvider->update(['provider_email' => $email]);
                }
                $user = $authProvider->user;
                $newAvatar = $providerData['picture'] ?? $providerData['avatar'] ?? null;
                if ($newAvatar && empty($user->avatar_url)) {
                    $user->update(['avatar_url' => $newAvatar]);
                }
                return $user;
            }

            // 2. If the email is provided AND verified by the provider (e.g. Google or Apple verified),
            // check if an existing user with this exact verified email exists
            if ($email && $emailVerified) {
                $existingUser = User::where('email', $email)->first();
                if ($existingUser) {
                    // Link the provider to the existing verified user
                    UserAuthProvider::create([
                        'user_id' => $existingUser->id,
                        'provider' => $provider,
                        'provider_user_id' => $providerUserId,
                        'provider_email' => $email,
                        'provider_data' => $providerData,
                    ]);

                    $newAvatar = $providerData['picture'] ?? $providerData['avatar'] ?? null;
                    if ($newAvatar && empty($existingUser->avatar_url)) {
                        $existingUser->update(['avatar_url' => $newAvatar]);
                    }

                    return $existingUser;
                }
            }

            // 3. Otherwise create a brand new user
            // If the incoming email already belongs to an existing user but is NOT verified by OAuth,
            // we must not claim that email or collide with the unique constraint.
            $finalEmail = $email;
            if (!$finalEmail || User::where('email', $finalEmail)->exists()) {
                $finalEmail = $provider->value . '_' . $providerUserId . '@auth.local';
            }

            $user = User::create([
                'name' => $name ?? 'User ' . substr($providerUserId, 0, 6),
                'email' => $finalEmail,
                'password' => null, // No password for pure OAuth signups
                'email_verified_at' => $emailVerified ? now() : null,
                'avatar_url' => $providerData['picture'] ?? $providerData['avatar'] ?? null,
            ]);

            \App\Models\Project::create([
                'user_id' => $user->id,
                'name' => 'Default Workspace',
                'description' => 'Main workspace for your landing pages',
            ]);

            UserAuthProvider::create([
                'user_id' => $user->id,
                'provider' => $provider,
                'provider_user_id' => $providerUserId,
                'provider_email' => $email,
                'provider_data' => $providerData,
            ]);

            return $user;
        });
    }
}
