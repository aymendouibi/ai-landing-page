<?php

namespace Tests\Unit;

use App\Services\Auth\AppleTokenVerifier;
use Exception;
use Tests\TestCase;

class AppleTokenVerifierTest extends TestCase
{
    private AppleTokenVerifier $verifier;

    protected function setUp(): void
    {
        parent::setUp();
        $this->verifier = new AppleTokenVerifier();
    }

    /**
     * Helper to forge a valid base64url-encoded Apple JWT.
     */
    private function forgeAppleJwt(array $claims, array $header = ['alg' => 'RS256', 'kid' => 'test_kid']): string
    {
        $b64UrlEncode = fn(string $data) => rtrim(strtr(base64_encode($data), '+/', '-_'), '=');

        $headerEncoded = $b64UrlEncode(json_encode($header));
        $payloadEncoded = $b64UrlEncode(json_encode($claims));
        $signatureEncoded = $b64UrlEncode('fake_signature_bytes');

        return "{$headerEncoded}.{$payloadEncoded}.{$signatureEncoded}";
    }

    public function test_verify_succeeds_with_current_bundle_id(): void
    {
        $jwt = $this->forgeAppleJwt([
            'iss' => 'https://appleid.apple.com',
            'aud' => 'com.douibi.landing.ai',
            'exp' => time() + 3600,
            'sub' => '001234.user.apple.id',
            'email' => 'user@apple.com',
            'email_verified' => 'true',
            'is_private_email' => 'false',
        ]);

        $result = $this->verifier->verify($jwt);

        $this->assertSame('001234.user.apple.id', $result['sub']);
        $this->assertSame('user@apple.com', $result['email']);
        $this->assertTrue($result['email_verified']);
        $this->assertFalse($result['is_private_email']);
    }

    public function test_verify_succeeds_with_legacy_bundle_id(): void
    {
        $jwt = $this->forgeAppleJwt([
            'iss' => 'https://appleid.apple.com',
            'aud' => 'com.aibuilder.aibuilder',
            'exp' => time() + 3600,
            'sub' => '001234.legacy.id',
            'email' => 'legacy@apple.com',
            'email_verified' => true,
        ]);

        $result = $this->verifier->verify($jwt);

        $this->assertSame('001234.legacy.id', $result['sub']);
        $this->assertSame('legacy@apple.com', $result['email']);
    }

    public function test_verify_succeeds_with_configured_service_id(): void
    {
        config(['services.apple.client_id' => 'com.douibi.landing.ai.service']);

        $jwt = $this->forgeAppleJwt([
            'iss' => 'https://appleid.apple.com',
            'aud' => 'com.douibi.landing.ai.service',
            'exp' => time() + 3600,
            'sub' => '001234.service.id',
        ]);

        $result = $this->verifier->verify($jwt);

        $this->assertSame('001234.service.id', $result['sub']);
    }

    public function test_verify_rejects_unauthorized_audience(): void
    {
        $jwt = $this->forgeAppleJwt([
            'iss' => 'https://appleid.apple.com',
            'aud' => 'com.malicious.app',
            'exp' => time() + 3600,
            'sub' => '001234.attacker.id',
        ]);

        $this->expectException(Exception::class);
        $this->expectExceptionMessage('Apple token audience does not match configured Apple Service ID or Bundle ID.');

        $this->verifier->verify($jwt);
    }

    public function test_verify_rejects_expired_token(): void
    {
        $jwt = $this->forgeAppleJwt([
            'iss' => 'https://appleid.apple.com',
            'aud' => 'com.douibi.landing.ai',
            'exp' => time() - 60,
            'sub' => '001234.expired.id',
        ]);

        $this->expectException(Exception::class);
        $this->expectExceptionMessage('Apple token has expired.');

        $this->verifier->verify($jwt);
    }

    public function test_verify_rejects_invalid_issuer(): void
    {
        $jwt = $this->forgeAppleJwt([
            'iss' => 'https://accounts.google.com',
            'aud' => 'com.douibi.landing.ai',
            'exp' => time() + 3600,
            'sub' => '001234.fake.id',
        ]);

        $this->expectException(Exception::class);
        $this->expectExceptionMessage('Invalid Apple token issuer.');

        $this->verifier->verify($jwt);
    }

    public function test_verify_rejects_malformed_token(): void
    {
        $this->expectException(Exception::class);
        $this->expectExceptionMessage('Malformed Apple identity token.');

        $this->verifier->verify('not.a.valid.jwt.with.four.dots');
    }
}
