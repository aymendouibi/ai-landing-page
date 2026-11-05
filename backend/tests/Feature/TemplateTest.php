<?php

namespace Tests\Feature;

use App\Enums\TemplateStatus;
use App\Models\Project;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use App\Models\User;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TemplateTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Project $project;
    protected TemplateCategory $category;
    protected Template $template;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        $this->project = Project::create([
            'user_id' => $this->user->id,
            'name' => 'Demo Project',
        ]);

        $this->category = TemplateCategory::create([
            'name' => 'Restaurants',
            'slug' => 'restaurants',
            'sort_order' => 1,
        ]);

        $this->template = Template::create([
            'category_id' => $this->category->id,
            'name' => 'Gourmet Bistro',
            'slug' => 'gourmet-bistro',
            'description' => 'A cozy dining experience.',
            'industry' => 'Restaurant',
            'status' => TemplateStatus::Published,
            'license_type' => 'internal',
            'use_count' => 10,
        ]);

        $doc = DefaultDocumentFactory::createDefault('Gourmet Bistro');
        TemplateVersion::create([
            'template_id' => $this->template->id,
            'version' => 1,
            'document' => $doc,
            'is_active' => true,
        ]);
    }

    public function test_anyone_can_list_template_categories(): void
    {
        $response = $this->getJson('/api/v1/templates/categories');

        $response->assertStatus(200)
            ->assertJsonFragment(['name' => 'Restaurants']);
    }

    public function test_anyone_can_browse_published_templates(): void
    {
        $response = $this->getJson('/api/v1/templates');

        $response->assertStatus(200)
            ->assertJsonFragment(['name' => 'Gourmet Bistro']);
    }

    public function test_anyone_can_view_single_published_template_with_document(): void
    {
        $response = $this->getJson("/api/v1/templates/{$this->template->id}");

        $response->assertStatus(200)
            ->assertJsonPath('template.name', 'Gourmet Bistro')
            ->assertJsonStructure([
                'template' => [
                    'id',
                    'name',
                    'active_version' => ['document'],
                ],
            ]);
    }

    public function test_user_can_use_template_to_create_website(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/templates/{$this->template->id}/use", [
                'project_id' => $this->project->id,
                'name' => 'Luigi Italian Table',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('website.name', 'Luigi Italian Table')
            ->assertJsonPath('website.revision_number', 1)
            ->assertJsonPath('website.document.site.name', 'Luigi Italian Table');

        $this->assertDatabaseHas('websites', [
            'name' => 'Luigi Italian Table',
            'project_id' => $this->project->id,
        ]);

        // Template usage count should be incremented
        $this->assertEquals(11, $this->template->fresh()->use_count);
    }
}

