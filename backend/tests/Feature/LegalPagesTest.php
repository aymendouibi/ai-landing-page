<?php

namespace Tests\Feature;

use Tests\TestCase;

class LegalPagesTest extends TestCase
{
    public function test_privacy_policy_page_loads_successfully(): void
    {
        $response = $this->get('/privacy');

        $response->assertStatus(200);
        $response->assertSee('Privacy Policy');
        $response->assertSee('1. Information We Collect');
        $response->assertSee('2. How We Use Your Data');
        $response->assertSee('3. AI Generation &amp; Privacy Safeguards', false);
        $response->assertSee('4. Storage &amp; Security', false);
        $response->assertSee('5. Third-Party Service Providers');
        $response->assertSee('6. Your Rights &amp; Data Portability', false);
        $response->assertSee('7. Contact &amp; Data Controller', false);
        $response->assertSee('privacy@aibuilder.app');
        $response->assertSee('Zero Training on User Data');
    }

    public function test_privacy_policy_redirects_to_privacy(): void
    {
        $response = $this->get('/privacy-policy');

        $response->assertRedirect('/privacy');
    }

    public function test_terms_of_service_page_loads_successfully(): void
    {
        $response = $this->get('/terms');

        $response->assertStatus(200);
        $response->assertSee('Terms of Service');
        $response->assertSee('1. Acceptance of Terms');
        $response->assertSee('2. Ownership of Generated Content');
        $response->assertSee('3. Acceptable Use Policy');
        $response->assertSee('4. AI Generation &amp; Limitations', false);
        $response->assertSee('5. Subscriptions &amp; Billing', false);
        $response->assertSee('6. Limitation of Liability');
        $response->assertSee('7. Governing Law');
        $response->assertSee('legal@aibuilder.app');
    }

    public function test_terms_of_service_redirects_to_terms(): void
    {
        $response = $this->get('/terms-of-service');

        $response->assertRedirect('/terms');
    }

    public function test_landing_page_footer_links_to_privacy_and_terms(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
        $response->assertSee('href="/privacy"', false);
        $response->assertSee('href="/terms"', false);
    }
}
