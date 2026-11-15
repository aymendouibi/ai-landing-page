<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\Project;
use App\Models\User;
use App\Models\Website;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MediaAssetTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_list_their_assets(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        MediaAsset::create([
            'user_id' => $user->id,
            'original_filename' => 'photo1.jpg',
            'filename' => 'photo1.jpg',
            'mime_type' => 'image/jpeg',
            'file_size' => 1024,
            'storage_path' => 'media/photo1.jpg',
            'url' => 'https://example.com/photo1.jpg',
        ]);

        $response = $this->getJson('/api/v1/assets');

        $response->assertStatus(200)
            ->assertJsonPath('total', 1)
            ->assertJsonPath('data.0.filename', 'photo1.jpg');
    }

    public function test_user_can_create_and_delete_asset(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/assets', [
            'url' => 'https://example.com/demo.png',
            'filename' => 'demo.png',
            'mime_type' => 'image/png',
            'file_size' => 2048,
        ]);

        $response->assertStatus(201);
        $assetId = $response->json('asset.id');

        $this->assertDatabaseHas('media_assets', [
            'id' => $assetId,
            'user_id' => $user->id,
        ]);

        $deleteResponse = $this->deleteJson("/api/v1/assets/{$assetId}");
        $deleteResponse->assertStatus(200);

        $this->assertSoftDeleted('media_assets', ['id' => $assetId]);
    }
}

