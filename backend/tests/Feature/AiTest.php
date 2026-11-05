<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\User;
use App\Models\Website;
use App\Services\AI\OpenRouterClient;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Mockery;
use Tests\TestCase;

class AiTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Project $project;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        $this->project = Project::create([
            'user_id' => $this->user->id,
            'name' => 'AI Test Project',
        ]);
    }

    public function test_ai_planning_endpoint(): void
    {
        $mockClient = Mockery::mock(OpenRouterClient::class);

        // Stage 1 mock: business analysis
        $mockClient->shouldReceive('chatCompletion')
            ->once()
            ->andReturn([
                'content' => json_encode([
                    'business_name' => 'Zenith Fitness',
                    'industry' => 'Fitness',
                    'tagline' => 'Transform your body and mind',
                    'value_proposition' => 'High intensity functional training',
                    'target_audience' => 'Young professionals',
                    'primary_goal' => 'bookings',
                    'suggested_tone' => 'bold',
                    'key_features' => ['Group classes', 'Personal coaching'],
                    'recommended_pages' => ['Home', 'Classes'],
                ]),
                'model_used' => 'google/gemma-4-31b-it:free',
                'tokens_input' => 100,
                'tokens_output' => 150,
                'cost' => 0.0,
            ]);

        // Stage 2 mock: website planning
        $mockClient->shouldReceive('chatCompletion')
            ->once()
            ->andReturn([
                'content' => json_encode([
                    'navigation_items' => [
                        ['label' => 'Home', 'href' => '/', 'type' => 'link'],
                        ['label' => 'Join Now', 'href' => '#contact', 'type' => 'button'],
                    ],
                    'sections' => [
                        ['component' => 'hero', 'variant' => 'split_image', 'purpose' => 'Hero conversion', 'background' => 'surface'],
                        ['component' => 'features', 'variant' => 'grid_3col', 'purpose' => 'Show features', 'background' => 'default'],
                    ],
                ]),
                'model_used' => 'google/gemma-4-31b-it:free',
                'tokens_input' => 150,
                'tokens_output' => 200,
                'cost' => 0.0,
            ]);

        $this->app->instance(OpenRouterClient::class, $mockClient);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/ai/plan', [
                'prompt' => 'A luxury gym in downtown Seattle offering personal training and infrared sauna.',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('business_analysis.business_name', 'Zenith Fitness')
            ->assertJsonPath('plan.sections.0.component', 'hero');
    }

    public function test_ai_website_generation_synchronous(): void
    {
        $mockClient = Mockery::mock(OpenRouterClient::class);

        // 1. Business analysis
        $mockClient->shouldReceive('chatCompletion')
            ->andReturn(
                [
                    'content' => json_encode(['business_name' => 'Apex Robotics', 'industry' => 'Technology']),
                    'model_used' => 'google/gemma-4-31b-it:free',
                    'tokens_input' => 50,
                    'tokens_output' => 50,
                    'cost' => 0.0,
                ],
                // 2. Design brief
                [
                    'content' => json_encode([
                        'theme' => [
                            'colors' => [
                                'primary' => '#4F46E5',
                                'secondary' => '#06B6D4',
                                'accent' => '#10B981',
                                'background' => '#0F172A',
                                'surface' => '#1E293B',
                                'text' => ['primary' => '#F8FAFC', 'secondary' => '#94A3B8', 'inverse' => '#0F172A'],
                            ],
                            'typography' => ['headingFamily' => 'Inter', 'bodyFamily' => 'Inter'],
                        ],
                    ]),
                    'model_used' => 'google/gemma-4-31b-it:free',
                    'tokens_input' => 100,
                    'tokens_output' => 100,
                    'cost' => 0.0,
                ],
                // 3. Website plan
                [
                    'content' => json_encode([
                        'navigation_items' => [['label' => 'Home', 'href' => '/', 'type' => 'link']],
                        'sections' => [
                            ['component' => 'hero', 'variant' => 'split_image'],
                            ['component' => 'features', 'variant' => 'grid_3col'],
                            ['component' => 'cta', 'variant' => 'centered'],
                        ],
                    ]),
                    'model_used' => 'google/gemma-4-31b-it:free',
                    'tokens_input' => 120,
                    'tokens_output' => 120,
                    'cost' => 0.0,
                ],
                // 4. Content generation
                [
                    'content' => json_encode([
                        'sections_content' => [
                            [
                                'component' => 'hero',
                                'props' => [
                                    'headline' => 'Next Generation Robotics',
                                    'subheadline' => 'Autonomous automation for high-throughput logistics',
                                    'ctaText' => 'Deploy Now',
                                ],
                            ],
                            [
                                'component' => 'features',
                                'props' => [
                                    'title' => 'Intelligent Fleet',
                                    'items' => [
                                        ['icon' => 'zap', 'title' => 'Ultra Fast', 'description' => 'Real-time telemetry'],
                                    ],
                                ],
                            ],
                            [
                                'component' => 'cta',
                                'props' => [
                                    'headline' => 'Schedule a Demo',
                                    'buttonText' => 'Contact Us',
                                ],
                            ],
                        ],
                    ]),
                    'model_used' => 'google/gemma-4-31b-it:free',
                    'tokens_input' => 200,
                    'tokens_output' => 200,
                    'cost' => 0.0,
                ]
            );

        $this->app->instance(OpenRouterClient::class, $mockClient);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/ai/generate', [
                'project_id' => $this->project->id,
                'prompt' => 'An autonomous robotics startup developing warehouse logistics drones.',
                'sync' => true,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('job.status', 'completed')
            ->assertJsonStructure([
                'message',
                'job' => ['id', 'status', 'website_id'],
                'website_id',
            ]);

        $this->assertDatabaseHas('websites', [
            'name' => 'Apex Robotics',
            'project_id' => $this->project->id,
        ]);
    }

    public function test_ai_structured_edit_endpoint(): void
    {
        $website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Original Site',
            'slug' => 'original-site',
            'document' => DefaultDocumentFactory::createDefault('Original Site'),
            'revision_number' => 1,
        ]);

        $targetSecId = $website->document['pages'][0]['sections'][0]['id'];

        $mockClient = Mockery::mock(OpenRouterClient::class);
        $mockClient->shouldReceive('chatCompletion')
            ->once()
            ->andReturn([
                'content' => json_encode([
                    'operations' => [
                        [
                            'type' => 'update_component',
                            'section_id' => $targetSecId,
                            'props' => ['headline' => 'AI Generated Brand New Headline'],
                        ],
                    ],
                    'summary' => 'Changed hero headline',
                ]),
                'model_used' => 'google/gemma-4-31b-it:free',
                'tokens_input' => 80,
                'tokens_output' => 60,
                'cost' => 0.0,
            ]);

        $this->app->instance(OpenRouterClient::class, $mockClient);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/ai/edit', [
                'website_id' => $website->id,
                'instruction' => 'Change the hero headline to AI Generated Brand New Headline',
                'target_section_id' => $targetSecId,
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('operations_applied', 1)
            ->assertJsonPath('website.revision_number', 2)
            ->assertJsonPath('website.document.pages.0.sections.0.props.headline', 'AI Generated Brand New Headline');
    }
}
