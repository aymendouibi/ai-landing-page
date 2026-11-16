<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\AppErrorLog;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminErrorLogTest extends TestCase
{
    use RefreshDatabase;

    public function test_payment_and_ai_errors_can_be_logged_and_viewed_in_admin(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $user = User::factory()->create(['name' => 'Bob Payer']);

        AppErrorLog::logPaymentError(
            'Stripe card_declined: Insufficient funds',
            ['code' => 'card_declined', 'amount' => 999],
            $user->id
        );

        AppErrorLog::logAiError(
            'OpenRouter API rate limit reached 429',
            ['model' => 'anthropic/claude-3.5-sonnet']
        );

        $response = $this->actingAs($admin)->get('/admin/logs');

        $response->assertStatus(200)
            ->assertSee('Stripe card_declined: Insufficient funds')
            ->assertSee('OpenRouter API rate limit reached 429')
            ->assertSee('PAIEMENT')
            ->assertSee('PIPELINE IA');
    }

    public function test_admin_can_resolve_error_log(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);

        $log = AppErrorLog::logPaymentError('Temporary webhook timeout');
        $this->assertNull($log->resolved_at);

        $resp = $this->actingAs($admin)->post("/admin/logs/{$log->id}/resolve");
        $resp->assertRedirect();

        $this->assertNotNull($log->fresh()->resolved_at);
    }
}
