<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\Feedback;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminFeedbackTest extends TestCase
{
    use RefreshDatabase;

    public function test_mobile_user_can_submit_feedback_via_api(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/feedback', [
            'category' => 'feature',
            'message' => 'Please add multi-language landing page support!',
            'rating' => 5,
            'metadata' => [
                'platform' => 'iOS',
                'app_version' => '1.0.4',
            ],
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('feedback.category', 'feature')
            ->assertJsonPath('feedback.status', 'new');

        $this->assertDatabaseHas('feedbacks', [
            'user_id' => $user->id,
            'category' => 'feature',
            'message' => 'Please add multi-language landing page support!',
            'status' => 'new',
        ]);
    }

    public function test_admin_can_view_feedbacks_in_dashboard(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);
        $creator = User::factory()->create(['name' => 'Alice Creator']);

        Feedback::create([
            'user_id' => $creator->id,
            'category' => 'bug',
            'message' => 'Publishing failed on mobile.',
            'status' => 'new',
        ]);

        $response = $this->actingAs($admin)->get('/admin/feedback');

        $response->assertStatus(200)
            ->assertSee('Alice Creator')
            ->assertSee('Publishing failed on mobile.')
            ->assertSee('Bug / Problème');
    }

    public function test_admin_can_update_feedback_status_and_delete(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);

        $feedback = Feedback::create([
            'category' => 'general',
            'message' => 'Great mobile app!',
            'status' => 'new',
        ]);

        // Update status
        $updateResp = $this->actingAs($admin)->patch("/admin/feedback/{$feedback->id}", [
            'status' => 'reviewed',
            'admin_notes' => 'Acknowledged by support',
        ]);

        $updateResp->assertRedirect();
        $this->assertDatabaseHas('feedbacks', [
            'id' => $feedback->id,
            'status' => 'reviewed',
            'admin_notes' => 'Acknowledged by support',
        ]);

        // Delete
        $deleteResp = $this->actingAs($admin)->delete("/admin/feedback/{$feedback->id}");
        $deleteResp->assertRedirect();
        $this->assertDatabaseMissing('feedbacks', ['id' => $feedback->id]);
    }
}
