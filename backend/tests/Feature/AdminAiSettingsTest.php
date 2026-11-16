<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\User;
use App\Services\AI\ModelSelector;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminAiSettingsTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_view_ai_settings_and_update_openrouter_model(): void
    {
        $admin = User::factory()->create(['role' => UserRole::Admin]);

        $response = $this->actingAs($admin)->get('/admin/ai-settings');
        $response->assertStatus(200)
            ->assertSee('Configuration Modèle IA (OpenRouter)')
            ->assertSee('Gemini 2.5 Flash');

        // Update model to Claude 3.5 Sonnet
        $updateResp = $this->actingAs($admin)->post('/admin/ai-settings', [
            'model' => 'anthropic/claude-3.5-sonnet',
            'task' => 'global',
        ]);

        $updateResp->assertRedirect();

        // ModelSelector should now resolve anthropic/claude-3.5-sonnet for document generation and editing
        $modelSelector = app(ModelSelector::class);
        $this->assertEquals('anthropic/claude-3.5-sonnet', $modelSelector->getModelForTask('document_generation'));
        $this->assertEquals('anthropic/claude-3.5-sonnet', $modelSelector->getModelForTask('editing'));
    }
}
