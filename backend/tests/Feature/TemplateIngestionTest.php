<?php

namespace Tests\Feature;

use App\Enums\TemplateStatus;
use App\Enums\UserRole;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;
use ZipArchive;

class TemplateIngestionTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected User $admin;
    protected TemplateCategory $category;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create([
            'role' => UserRole::User,
        ]);

        $this->admin = User::factory()->create([
            'role' => UserRole::Admin,
        ]);

        $this->category = TemplateCategory::create([
            'name' => 'Business',
            'slug' => 'business',
            'description' => 'Corporate and business templates',
            'sort_order' => 1,
        ]);
    }

    public function test_user_can_ingest_valid_zip_template(): void
    {
        $zipPath = tempnam(sys_get_temp_dir(), 'test_zip_') . '.zip';
        $zip = new ZipArchive();
        $zip->open($zipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE);
        $zip->addFromString('index.html', '<html><body><h1>Boutique Hotel</h1><p class="lead">Luxury stay in Paris</p><h2>Suites</h2><h2>Dining</h2></body></html>');
        $zip->close();

        $uploadedFile = new UploadedFile(
            $zipPath,
            'hotel_template.zip',
            'application/zip',
            null,
            true
        );

        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/templates/ingest/zip', [
            'file' => $uploadedFile,
            'name' => 'Boutique Hotel Paris',
            'category_id' => $this->category->id,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('template.name', 'Boutique Hotel Paris')
            ->assertJsonPath('template.status', TemplateStatus::Review->value);

        $this->assertDatabaseHas('templates', [
            'name' => 'Boutique Hotel Paris',
            'status' => TemplateStatus::Review->value,
        ]);

        @unlink($zipPath);
    }

    public function test_zip_slip_vulnerability_is_blocked(): void
    {
        $zipPath = tempnam(sys_get_temp_dir(), 'test_zip_slip_') . '.zip';
        $zip = new ZipArchive();
        $zip->open($zipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE);
        $zip->addFromString('../../../etc/passwd', 'malicious content');
        $zip->addFromString('index.html', '<html><body><h1>Malicious</h1></body></html>');
        $zip->close();

        $uploadedFile = new UploadedFile(
            $zipPath,
            'malicious.zip',
            'application/zip',
            null,
            true
        );

        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/templates/ingest/zip', [
            'file' => $uploadedFile,
            'name' => 'Malicious Zip',
        ]);

        $response->assertStatus(422)
            ->assertJsonFragment([
                'message' => 'Template ingestion failed: ZIP archive contains unsafe entry: ../../../etc/passwd',
            ]);

        @unlink($zipPath);
    }

    public function test_url_ingestion_blocks_ssrf_attacks(): void
    {
        // Local loopback
        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/templates/ingest/url', [
            'url' => 'http://127.0.0.1/admin',
            'name' => 'Loopback Target',
        ]);

        $response->assertStatus(422);
        $this->assertStringContainsString('private or reserved IP', $response->json('message'));

        // Cloud metadata
        $responseMetadata = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/templates/ingest/url', [
            'url' => 'http://169.254.169.254/latest/meta-data/',
            'name' => 'Cloud Metadata Target',
        ]);

        $responseMetadata->assertStatus(422);
    }

    public function test_url_ingestion_with_mocked_external_html_success(): void
    {
        Http::fake([
            'https://example.com/demo-site' => Http::response(
                '<!DOCTYPE html><html><head><title>Modern Law Firm</title></head><body><h1>Premier Legal Counsel</h1><p class="lead">Protecting your corporate interests.</p><h2>Practice Areas</h2><h2>Attorneys</h2></body></html>',
                200
            ),
        ]);

        $response = $this->actingAs($this->user, 'sanctum')->postJson('/api/v1/templates/ingest/url', [
            'url' => 'https://example.com/demo-site',
            'name' => 'Premier Law Firm',
            'category_id' => $this->category->id,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('template.name', 'Premier Law Firm')
            ->assertJsonPath('template.status', TemplateStatus::Review->value);

        $this->assertDatabaseHas('templates', [
            'name' => 'Premier Law Firm',
            'status' => TemplateStatus::Review->value,
        ]);
    }

    public function test_template_approval_requires_admin(): void
    {
        $template = Template::create([
            'category_id' => $this->category->id,
            'name' => 'Pending Template',
            'slug' => 'pending-template',
            'status' => TemplateStatus::Review,
            'license_type' => 'user_submitted',
        ]);

        // Regular user cannot approve
        $forbiddenResponse = $this->actingAs($this->user, 'sanctum')->postJson("/api/v1/templates/{$template->id}/approve");
        $forbiddenResponse->assertStatus(403);

        // Admin can approve
        $successResponse = $this->actingAs($this->admin, 'sanctum')->postJson("/api/v1/templates/{$template->id}/approve");
        $successResponse->assertStatus(200)
            ->assertJsonPath('template.status', TemplateStatus::Published->value);

        $this->assertEquals(TemplateStatus::Published, $template->fresh()->status);
    }
}
