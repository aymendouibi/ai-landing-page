<?php

namespace App\Jobs;

use App\Enums\AiJobStatus;
use App\Enums\RevisionSource;
use App\Enums\WebsiteStatus;
use App\Models\AiJob;
use App\Models\Project;
use App\Models\Website;
use App\Models\WebsiteRevision;
use App\Services\AI\AiWebsiteGenerator;
use Exception;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class GenerateWebsiteJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $timeout = 180;

    public function __construct(
        public string $aiJobId,
        public string $prompt,
        public string $projectId,
        public ?string $industry = null
    ) {}

    public function handle(AiWebsiteGenerator $generator): void
    {
        $aiJob = AiJob::find($this->aiJobId);
        if (!$aiJob) return;

        $aiJob->markProcessing();

        try {
            $result = $generator->generate(
                userPrompt: $this->prompt,
                preferredIndustry: $this->industry,
                progressCallback: function (int $percent, string $msg) use ($aiJob) {
                    $aiJob->update(['progress' => $percent]);
                }
            );

            $document = $result['document'];
            $siteName = $document['site']['name'] ?? 'Generated Website';
            $slug = Str::slug($siteName) . '-' . Str::random(5);
            $subdomain = Str::slug($siteName) . '-' . strtolower(Str::random(4));

            $website = DB::transaction(function () use ($document, $siteName, $slug, $subdomain, $aiJob) {
                $website = Website::create([
                    'project_id' => $this->projectId,
                    'name' => $siteName,
                    'slug' => $slug,
                    'status' => WebsiteStatus::Draft,
                    'document' => $document,
                    'revision_number' => 1,
                    'subdomain' => $subdomain,
                ]);

                $revision = WebsiteRevision::create([
                    'website_id' => $website->id,
                    'revision_number' => 1,
                    'document' => $document,
                    'source' => RevisionSource::AiGenerate,
                    'description' => "AI generated from prompt: " . substr($this->prompt, 0, 80),
                    'created_by' => $aiJob->user_id,
                ]);

                $website->update(['current_revision_id' => $revision->id]);
                return $website;
            });

            $aiJob->update([
                'website_id' => $website->id,
                'result' => [
                    'website_id' => $website->id,
                    'website_name' => $website->name,
                    'document' => $website->document,
                ],
            ]);

            $aiJob->markCompleted(
                result: ['website_id' => $website->id],
                modelUsed: $result['model_used'],
                tokensIn: $result['tokens_used'],
                tokensOut: 0
            );

        } catch (Exception $e) {
            $aiJob->markFailed($e->getMessage());
        }
    }
}
