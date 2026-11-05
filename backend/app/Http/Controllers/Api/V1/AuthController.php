<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\AuthProvider;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\AppleAuthRequest;
use App\Http\Requests\Auth\GoogleAuthRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\User;
use App\Services\Auth\AccountLinkingService;
use App\Services\Auth\AppleTokenVerifier;
use App\Services\Auth\GoogleTokenVerifier;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        protected AccountLinkingService $accountLinkingService,
        protected GoogleTokenVerifier $googleTokenVerifier,
        protected AppleTokenVerifier $appleTokenVerifier
    ) {}

    /**
     * Register a new user with email and password.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->validated('name'),
            'email' => $request->validated('email'),
            'password' => Hash::make($request->validated('password')),
            'role' => \App\Enums\UserRole::User,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registration successful.',
            'user' => $user->load('authProviders'),
            'token' => $token,
        ], 201);
    }

    /**
     * Authenticate a user with email and password.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->validated('email'))->first();

        if (!$user || !$user->password || !Hash::check($request->validated('password'), $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid email or password.'],
            ]);
        }

        $deviceName = $request->validated('device_name', 'auth_token');
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'message' => 'Login successful.',
            'user' => $user->load('authProviders'),
            'token' => $token,
        ]);
    }

    /**
     * Log out the current user (revokes current access token).
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json([
            'message' => 'Successfully logged out.',
        ]);
    }

    /**
     * Get authenticated user profile.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['authProviders', 'subscription.plan']);

        return response()->json([
            'user' => $user,
            'is_admin' => $user->isAdmin(),
            'active_subscription' => $user->getActiveSubscription(),
        ]);
    }

    /**
     * Authenticate or register using Google Sign-In (Credential Manager token).
     */
    public function google(GoogleAuthRequest $request): JsonResponse
    {
        try {
            $googlePayload = $this->googleTokenVerifier->verify($request->validated('id_token'));
        } catch (Exception $e) {
            return response()->json(['message' => $e->getMessage()], 401);
        }

        $user = $this->accountLinkingService->findOrCreateFromOAuth(
            provider: AuthProvider::Google,
            providerUserId: $googlePayload['sub'],
            email: $googlePayload['email'],
            name: $googlePayload['name'],
            emailVerified: $googlePayload['email_verified'],
            providerData: [
                'picture' => $googlePayload['picture'],
            ]
        );

        $deviceName = $request->validated('device_name', 'google_auth_token');
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'message' => 'Google sign-in successful.',
            'user' => $user->load('authProviders'),
            'token' => $token,
        ]);
    }

    /**
     * Authenticate or register using Sign in with Apple.
     */
    public function apple(AppleAuthRequest $request): JsonResponse
    {
        try {
            $applePayload = $this->appleTokenVerifier->verify($request->validated('identity_token'));
        } catch (Exception $e) {
            return response()->json(['message' => $e->getMessage()], 401);
        }

        $user = $this->accountLinkingService->findOrCreateFromOAuth(
            provider: AuthProvider::Apple,
            providerUserId: $applePayload['sub'],
            email: $applePayload['email'],
            name: $request->validated('name'),
            emailVerified: $applePayload['email_verified'],
            providerData: [
                'is_private_email' => $applePayload['is_private_email'],
            ]
        );

        $deviceName = $request->validated('device_name', 'apple_auth_token');
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'message' => 'Apple sign-in successful.',
            'user' => $user->load('authProviders'),
            'token' => $token,
        ]);
    }

    /**
     * Link an external OAuth provider to the current user's account.
     */
    public function linkProvider(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'provider' => ['required', 'string', 'in:google,apple'],
            'id_token' => ['required', 'string'],
        ]);

        $user = $request->user();

        if ($validated['provider'] === 'google') {
            try {
                $payload = $this->googleTokenVerifier->verify($validated['id_token']);
            } catch (Exception $e) {
                return response()->json(['message' => $e->getMessage()], 401);
            }

            $providerRecord = $this->accountLinkingService->linkProvider(
                user: $user,
                provider: AuthProvider::Google,
                providerUserId: $payload['sub'],
                providerEmail: $payload['email'],
                providerData: ['picture' => $payload['picture']]
            );
        } else {
            try {
                $payload = $this->appleTokenVerifier->verify($validated['id_token']);
            } catch (Exception $e) {
                return response()->json(['message' => $e->getMessage()], 401);
            }

            $providerRecord = $this->accountLinkingService->linkProvider(
                user: $user,
                provider: AuthProvider::Apple,
                providerUserId: $payload['sub'],
                providerEmail: $payload['email'],
                providerData: ['is_private_email' => $payload['is_private_email']]
            );
        }

        return response()->json([
            'message' => "Successfully linked {$validated['provider']} account.",
            'provider' => $providerRecord,
        ]);
    }

    /**
     * Unlink an OAuth provider from the current user's account.
     */
    public function unlinkProvider(Request $request, string $provider): JsonResponse
    {
        $authProvider = AuthProvider::tryFrom($provider);
        if (!$authProvider) {
            return response()->json(['message' => 'Invalid auth provider.'], 400);
        }

        $this->accountLinkingService->unlinkProvider($request->user(), $authProvider);

        return response()->json([
            'message' => "Successfully unlinked {$provider} account.",
        ]);
    }
}
