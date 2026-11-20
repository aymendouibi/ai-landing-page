<?php

namespace Tests\Feature;

use App\Models\Feedback;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AccountDeletionPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_delete_account_page_loads_successfully_with_screenshots(): void
    {
        $response = $this->get('/delete-account');

        $response->assertStatus(200);
        $response->assertSee('Delete Your Account');
        $response->assertSee('How to Delete Your Account in the Mobile App');
        $response->assertSee('Step 1');
        $response->assertSee('Step 2');
        $response->assertSee('Step 3');
        $response->assertSee('/images/account-deletion/step1-navigate.jpg');
        $response->assertSee('/images/account-deletion/step2-profile.jpg');
        $response->assertSee('/images/account-deletion/step3-delete-button.png');
        $response->assertSee('Web Deletion Request');
        $response->assertSee('Data Retention &amp; Safety Specification', false);
        $response->assertSee('privacy@aibuilder.app');
    }

    public function test_account_deletion_alias_redirects(): void
    {
        $response = $this->get('/account-deletion');

        $response->assertRedirect('/delete-account');
    }

    public function test_web_deletion_request_submission_creates_record(): void
    {
        $user = User::factory()->create([
            'email' => 'malekdouibi09@gmail.com',
            'name' => 'Malek Douibi',
        ]);

        $response = $this->post('/delete-account', [
            'email' => 'malekdouibi09@gmail.com',
            'reason' => 'Testing deletion flow',
            'confirm_deletion' => '1',
        ]);

        $response->assertRedirect('/delete-account');
        $response->assertSessionHas('success_message');

        $this->assertDatabaseHas('feedbacks', [
            'category' => 'account_deletion',
            'user_id' => $user->id,
            'status' => 'new',
        ]);

        $feedback = Feedback::where('category', 'account_deletion')->first();
        $this->assertNotNull($feedback);
        $this->assertEquals('malekdouibi09@gmail.com', $feedback->metadata['email']);
        $this->assertEquals('Testing deletion flow', $feedback->metadata['reason']);
        $this->assertTrue($feedback->metadata['user_exists']);
    }

    public function test_web_deletion_request_requires_valid_email_and_confirmation(): void
    {
        $response = $this->post('/delete-account', [
            'email' => 'invalid-email',
            'confirm_deletion' => '0',
        ]);

        $response->assertSessionHasErrors(['email', 'confirm_deletion']);
        $this->assertEquals(0, Feedback::where('category', 'account_deletion')->count());
    }

    public function test_landing_page_footer_links_to_delete_account(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
        $response->assertSee('href="/delete-account"', false);
    }
}
