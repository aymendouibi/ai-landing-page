<?php

namespace App\Services\Auth;

use Exception;
use Illuminate\Support\Facades\Log;

class AppleTokenVerifier
{
    /**
     * Known allowed bundle identifiers for the iOS client and services.
     */
    protected const DEFAULT_ALLOWED_AUDIENCES = [
        'com.douibi.landing.ai',
        'com.aibuilder.aibuilder',
    ];

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

        // Validate audience against configured Apple Service/App ID and allowed bundle IDs
        $allowedAudiences = $this->getAllowedAudiences();
        $tokenAud = (string) ($payload['aud'] ?? '');

        if (!empty($allowedAudiences) && !in_array($tokenAud, $allowedAudiences, true)) {
            Log::warning('Apple token verification failed: audience mismatch', [
                'received_aud' => $tokenAud,
                'allowed_audiences' => $allowedAudiences,
            ]);
            throw new Exception('Apple token audience does not match configured Apple Service ID or Bundle ID.');
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

    /**
     * Resolve the complete list of allowed audiences from configuration and defaults.
     *
     * @return array<string>
     */
    public function getAllowedAudiences(): array
    {
        $sources = [
            config('services.apple.client_id'),
            config('services.apple.bundle_id'),
            config('services.apple.allowed_bundle_ids'),
            config('services.apple.allowed_audiences'),
            self::DEFAULT_ALLOWED_AUDIENCES,
        ];

        $audiences = [];
        foreach ($sources as $source) {
            if (is_array($source)) {
                foreach ($source as $val) {
                    if (is_string($val) && trim($val) !== '') {
                        $audiences[] = trim($val);
                    }
                }
            } elseif (is_string($source) && trim($source) !== '') {
                foreach (explode(',', $source) as $val) {
                    $val = trim($val);
                    if ($val !== '') {
                        $audiences[] = $val;
                    }
                }
            }
        }

        return array_values(array_unique($audiences));
    }
}
