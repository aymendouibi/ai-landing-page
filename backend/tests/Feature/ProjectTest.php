<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProjectTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_project(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/projects', [
                'name' => 'Acme Corporation',
                'description' => 'Main marketing website project',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('project.name', 'Acme Corporation')
            ->assertJsonPath('project.user_id', $user->id);

        $this->assertDatabaseHas('projects', [
            'name' => 'Acme Corporation',
            'user_id' => $user->id,
        ]);
    }

    public function test_user_can_list_only_their_own_projects(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        Project::create(['user_id' => $user1->id, 'name' => 'User 1 Project A']);
        Project::create(['user_id' => $user1->id, 'name' => 'User 1 Project B']);
        Project::create(['user_id' => $user2->id, 'name' => 'User 2 Project']);

        $response = $this->actingAs($user1, 'sanctum')
            ->getJson('/api/v1/projects');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data')
            ->assertJsonFragment(['name' => 'User 1 Project A'])
            ->assertJsonFragment(['name' => 'User 1 Project B'])
            ->assertJsonMissing(['name' => 'User 2 Project']);
    }

    public function test_user_cannot_view_another_users_project(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $project = Project::create(['user_id' => $user1->id, 'name' => 'Private Project']);

        $response = $this->actingAs($user2, 'sanctum')
            ->getJson("/api/v1/projects/{$project->id}");

        $response->assertStatus(403);
    }

    public function test_user_can_update_their_project(): void
    {
        $user = User::factory()->create();
        $project = Project::create(['user_id' => $user->id, 'name' => 'Old Name']);

        $response = $this->actingAs($user, 'sanctum')
            ->putJson("/api/v1/projects/{$project->id}", [
                'name' => 'Updated Name',
                'description' => 'New Description',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('project.name', 'Updated Name');

        $this->assertDatabaseHas('projects', [
            'id' => $project->id,
            'name' => 'Updated Name',
        ]);
    }

    public function test_user_cannot_update_another_users_project(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $project = Project::create(['user_id' => $user1->id, 'name' => 'Protected Project']);

        $response = $this->actingAs($user2, 'sanctum')
            ->putJson("/api/v1/projects/{$project->id}", [
                'name' => 'Hacked Name',
            ]);

        $response->assertStatus(403);
    }

    public function test_user_can_delete_their_project(): void
    {
        $user = User::factory()->create();
        $project = Project::create(['user_id' => $user->id, 'name' => 'To Delete']);

        $response = $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/projects/{$project->id}");

        $response->assertStatus(200);

        $this->assertSoftDeleted('projects', ['id' => $project->id]);
    }
}
