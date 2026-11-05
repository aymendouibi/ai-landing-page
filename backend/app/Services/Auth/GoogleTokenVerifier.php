<?php

namespace App\Services\Auth;

use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GoogleTokenVerifier
{
    /**
     * Verify a Google ID token received from Android Credential Manager or Web.
     *
     * @param string $idToken
     * @return array{sub: string, email: string|null, name: string|null, picture: string|null, email_verified: bool}
     * @throws Exception
     */
    public function verify(string $idToken): array
    {
        $response = Http::timeout(10)->get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $idToken,
        ]);

        if (!$response->successful()) {
            Log::warning('Google token verification failed', ['response' => $response->body()]);
            throw new Exception('Invalid Google ID token.');
        }

        $payload = $response->json();

        // Validate issuer
        $validIssuers = ['accounts.google.com', 'https://accounts.google.com'];
        if (!in_array($payload['iss'] ?? '', $validIssuers, true)) {
            throw new Exception('Invalid Google token issuer.');
        }

        // Validate audience against configured client IDs if configured
        $configuredAud = array_filter([
            config('services.google.client_id'),
            config('services.google.android_client_id'),
        ]);

        if (!empty($configuredAud)) {
            $tokenAud = $payload['aud'] ?? '';
            if (!in_array($tokenAud, $configuredAud, true)) {
                throw new Exception('Google token audience does not match configured client IDs.');
            }
        }

        return [
            'sub' => $payload['sub'],
            'email' => $payload['email'] ?? null,
            'name' => $payload['name'] ?? null,
            'picture' => $payload['picture'] ?? null,
            'email_verified' => filter_var($payload['email_verified'] ?? false, FILTER_VALIDATE_BOOLEAN),
        ];
    }
}

