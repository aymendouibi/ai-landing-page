<?php

namespace App\Services\Auth;

use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AppleTokenVerifier
{
    /**
     * Verify an Apple identity token (JWT).
     *
     * @param string $identityToken JWT format: header.payload.signature
     * @return array{sub: string, email: string|null, email_verified: bool, is_private_email: bool}
     * @throws Exception
     */
    public function verify(string $identityToken): array
    {
        $parts = explode('.', $identityToken);
        if (count($parts) !== 3) {
            throw new Exception('Malformed Apple identity token.');
        }

        [$headerB64, $payloadB64] = $parts;
        $header = json_decode(base64_decode(strtr($headerB64, '-_', '+/')), true);
        $payload = json_decode(base64_decode(strtr($payloadB64, '-_', '+/')), true);

        if (!$header || !$payload) {
            throw new Exception('Cannot parse Apple token claims.');
        }

        // Validate issuer
        if (($payload['iss'] ?? '') !== 'https://appleid.apple.com') {
            throw new Exception('Invalid Apple token issuer.');
        }

        // Validate expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            throw new Exception('Apple token has expired.');
        }

        // Validate audience against configured Apple Service/App ID
        $configuredAud = config('services.apple.client_id');
        if ($configuredAud && ($payload['aud'] ?? '') !== $configuredAud) {
            throw new Exception('Apple token audience does not match configured Apple Service ID.');
        }

        $email = $payload['email'] ?? null;
        $emailVerified = filter_var($payload['email_verified'] ?? false, FILTER_VALIDATE_BOOLEAN);
        $isPrivateEmail = isset($payload['is_private_email']) && filter_var($payload['is_private_email'], FILTER_VALIDATE_BOOLEAN);

        return [
            'sub' => $payload['sub'],
            'email' => $email,
            'email_verified' => $emailVerified,
            'is_private_email' => $isPrivateEmail,
        ];
    }
}

