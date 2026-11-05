<?php

namespace Tests\Unit;

use App\Models\Project;
use App\Models\User;
use App\Models\Website;
use App\Services\AI\Prompts\PromptHelper;
use App\Services\AI\StructuredAiEditor;
use App\Services\Documents\DefaultDocumentFactory;
use App\Services\Documents\DocumentValidator;
use App\Services\Documents\WebsiteDocumentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StructuredAiEditorTest extends TestCase
{
    use RefreshDatabase;

    protected StructuredAiEditor $editor;
    protected Website $website;

    protected function setUp(): void
    {
        parent::setUp();
        $validator = new DocumentValidator();
        $docService = new WebsiteDocumentService($validator);
        $this->editor = new StructuredAiEditor($docService, $validator);

        $user = User::factory()->create();
        $project = Project::create(['user_id' => $user->id, 'name' => 'Test Project']);
        $doc = DefaultDocumentFactory::createDefault('Editor Test');

        $this->website = Website::create([
            'project_id' => $project->id,
            'name' => 'Editor Test',
            'slug' => 'editor-test',
            'document' => $doc,
            'revision_number' => 1,
        ]);
    }

    public function test_prompt_helper_extracts_json_from_markdown_blocks(): void
    {
        $raw = "Here is your plan:\n```json\n{\"business_name\": \"Acme Coffee\", \"industry\": \"Cafe\"}\n```\nHope you like it!";
        $parsed = PromptHelper::extractJson($raw);

        $this->assertEquals('Acme Coffee', $parsed['business_name']);
        $this->assertEquals('Cafe', $parsed['industry']);
    }

    public function test_apply_update_component_operation(): void
    {
        $targetSectionId = $this->website->document['pages'][0]['sections'][0]['id'];

        $updatedSite = $this->editor->applyOperations(
            website: $this->website,
            operations: [
                [
                    'type' => 'update_component',
                    'section_id' => $targetSectionId,
                    'props' => ['headline' => 'AI Modified Headline'],
                ],
            ],
            summary: 'Updated hero headline via AI'
        );

        $this->assertEquals(2, $updatedSite->revision_number);
        $firstSec = $updatedSite->document['pages'][0]['sections'][0];
        $this->assertEquals('AI Modified Headline', $firstSec['props']['headline']);
    }

    public function test_apply_add_and_remove_component_operations(): void
    {
        // 1. Add component
        $updatedSite = $this->editor->applyOperations(
            website: $this->website,
            operations: [
                [
                    'type' => 'add_component',
                    'page_id' => 'page_home',
                    'order' => 1,
                    'section' => [
                        'id' => 'sec_testimonials_new',
                        'component' => 'testimonials',
                        'variant' => 'cards',
                        'order' => 1,
                        'props' => ['title' => 'Happy Clients', 'items' => []],
                    ],
                ],
            ]
        );

        $this->assertEquals(2, $updatedSite->revision_number);
        $sections = $updatedSite->document['pages'][0]['sections'];
        $hasTestimonials = collect($sections)->contains('id', 'sec_testimonials_new');
        $this->assertTrue($hasTestimonials);

        // 2. Remove component
        $siteAfterRemove = $this->editor->applyOperations(
            website: $updatedSite,
            operations: [
                ['type' => 'remove_component', 'section_id' => 'sec_testimonials_new'],
            ]
        );

        $this->assertEquals(3, $siteAfterRemove->revision_number);
        $hasTestimonialsAfter = collect($siteAfterRemove->document['pages'][0]['sections'])->contains('id', 'sec_testimonials_new');
        $this->assertFalse($hasTestimonialsAfter);
    }

    public function test_apply_update_design_token_operation(): void
    {
        $updatedSite = $this->editor->applyOperations(
            website: $this->website,
            operations: [
                [
                    'type' => 'update_design_token',
                    'path' => 'colors.primary',
                    'value' => '#10B981',
                ],
            ]
        );

        $this->assertEquals('#10B981', $updatedSite->document['site']['theme']['colors']['primary']);
    }
}

