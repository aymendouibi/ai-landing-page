<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\User;
use App\Models\Website;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VisualQaTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected User $otherUser;
    protected Project $project;
    protected Website $website;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $this->otherUser = User::factory()->create();
        $this->project = Project::create([
            'user_id' => $this->user->id,
            'name' => 'QA Project',
            'slug' => 'qa-project',
        ]);

        $doc = DefaultDocumentFactory::createDefault('Flawed Site');
        // Intentionally introduce visual flaws:
        // 1. Inaccessible contrast (white text on white background)
        $doc['site']['theme']['colors']['text'] = '#ffffff';
        $doc['site']['theme']['colors']['background'] = '#ffffff';

        // 2. Empty hero headline
        $doc['pages'][0]['sections'][0]['props']['headline'] = '';

        // 3. Missing SEO title and description
        $doc['pages'][0]['seo']['title'] = '';
        $doc['pages'][0]['seo']['description'] = '';

        $this->website = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Flawed Site',
            'slug' => 'flawed-site',
            'subdomain' => 'flawed-site',
            'document' => $doc,
            'current_revision_number' => 1,
        ]);
    }

    public function test_qa_detects_contrast_and_structural_issues(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/qa", [
            'auto_fix' => false,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('qa_report.passed', false)
            ->assertJsonPath('qa_report.auto_fixed', false);

        $report = $response->json('qa_report');
        $this->assertGreaterThan(0, $report['issues_count']);
        $this->assertLessThan(100, $report['score']);

        $issueTypes = collect($report['issues'])->pluck('type')->all();
        $this->assertContains('contrast', $issueTypes);
        $this->assertContains('empty_heading', $issueTypes);
        $this->assertContains('seo_title', $issueTypes);
    }

    public function test_qa_auto_fix_repairs_issues_and_bumps_revision(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/qa", [
            'auto_fix' => true,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('qa_report.auto_fixed', true);

        $fresh = $this->website->fresh();
        // Revision should have been bumped from 1 to 2
        $this->assertEquals(2, $fresh->revision_number);

        // Headline should be filled
        $headline = $fresh->document['pages'][0]['sections'][0]['props']['headline'];
        $this->assertNotEmpty($headline);

        // Text color should no longer be #ffffff on #ffffff
        $text = $fresh->document['site']['theme']['colors']['text'];
        $textColor = is_array($text) ? $text['primary'] : $text;
        $this->assertNotEquals('#ffffff', $textColor);
        $this->assertEquals('#0f172a', $textColor);

        // SEO title should be filled
        $seoTitle = $fresh->document['pages'][0]['seo']['title'];
        $this->assertNotEmpty($seoTitle);
    }

    public function test_qa_requires_website_authorization(): void
    {
        $response = $this->actingAs($this->otherUser, 'sanctum')->postJson("/api/v1/websites/{$this->website->id}/qa", [
            'auto_fix' => false,
        ]);

        $response->assertStatus(403);
    }

    public function test_perfect_document_scores_100_percent(): void
    {
        $cleanDoc = DefaultDocumentFactory::createDefault('Clean Business');
        // Ensure complete SEO and proper contrast
        $cleanDoc['pages'][0]['seo']['title'] = 'Clean Business Home';
        $cleanDoc['pages'][0]['seo']['description'] = 'Welcome to Clean Business, your partner in excellence.';

        $cleanWebsite = Website::create([
            'project_id' => $this->project->id,
            'name' => 'Clean Business',
            'slug' => 'clean-business',
            'subdomain' => 'clean-business',
            'document' => $cleanDoc,
            'current_revision_number' => 1,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/websites/{$cleanWebsite->id}/qa", [
            'auto_fix' => false,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('qa_report.passed', true)
            ->assertJsonPath('qa_report.score', 100)
            ->assertJsonPath('qa_report.issues_count', 0);
    }
}
