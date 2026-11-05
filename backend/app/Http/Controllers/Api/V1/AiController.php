<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\AiJobStatus;
use App\Enums\AiJobType;
use App\Http\Controllers\Controller;
use App\Jobs\GenerateWebsiteJob;
use App\Models\AiJob;
use App\Models\Project;
use App\Models\Website;
use App\Services\AI\AiRemixService;
use App\Services\AI\AiWebsiteGenerator;
use App\Services\AI\ModelSelector;
use App\Services\AI\OpenRouterClient;
use App\Services\AI\Prompts\BusinessAnalysisPrompt;
use App\Services\AI\Prompts\PromptHelper;
use App\Services\AI\Prompts\StructuredEditPrompt;
use App\Services\AI\Prompts\WebsitePlanPrompt;
use App\Services\AI\StructuredAiEditor;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AiController extends Controller
{
    public function __construct(
        protected AiWebsiteGenerator $generator,
        protected AiRemixService $remixService,
        protected StructuredAiEditor $editor,
        protected OpenRouterClient $client,
        protected ModelSelector $modelSelector
    ) {}

    /**
     * Plan a website without full document generation.
     */
    public function plan(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'prompt' => ['required', 'string', 'min:5', 'max:2000'],
        ]);

        try {
            $analysisRes = $this->client->chatCompletion(
                messages: BusinessAnalysisPrompt::build($validated['prompt']),
                preferredModel: $this->modelSelector->getModelForTask('business_analysis'),
                jsonMode: true
            );
            $businessInfo = PromptHelper::extractJson($analysisRes['content']);

            $planRes = $this->client->chatCompletion(
                messages: WebsitePlanPrompt::build($businessInfo),
                preferredModel: $this->modelSelector->getModelForTask('website_planning'),
                jsonMode: true
            );
            $plan = PromptHelper::extractJson($planRes['content']);

            return response()->json([
                'business_analysis' => $businessInfo,
                'plan' => $plan,
            ]);
        } catch (Exception $e) {
            return response()->json(['message' => 'AI planning failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Generate a new website through the staged AI pipeline.
     */
    public function generate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'project_id' => ['required', 'uuid', 'exists:projects,id'],
            'prompt' => ['required', 'string', 'min:5', 'max:2000'],
            'industry' => ['nullable', 'string', 'max:100'],
            'sync' => ['nullable', 'boolean'],
        ]);

        $project = Project::findOrFail($validated['project_id']);
        Gate::authorize('update', $project);

        $aiJob = AiJob::create([
            'user_id' => $request->user()->id,
            'type' => AiJobType::Generate,
            'status' => AiJobStatus::Pending,
            'input' => [
                'prompt' => $validated['prompt'],
                'industry' => $validated['industry'] ?? null,
                'project_id' => $project->id,
            ],
            'progress' => 0,
        ]);

        // If sync requested (e.g. testing or immediate generation), run inline
        if ($request->boolean('sync')) {
            GenerateWebsiteJob::dispatchSync(
                aiJobId: $aiJob->id,
                prompt: $validated['prompt'],
                projectId: $project->id,
                industry: $validated['industry'] ?? null
            );
            $aiJob->refresh();

            return response()->json([
                'message' => 'Website generated successfully.',
                'job' => $aiJob,
                'website_id' => $aiJob->website_id,
            ], 201);
        }

        // Dispatch background job
        GenerateWebsiteJob::dispatch(
            aiJobId: $aiJob->id,
            prompt: $validated['prompt'],
            projectId: $project->id,
            industry: $validated['industry'] ?? null
        );

        return response()->json([
            'message' => 'Website generation job queued.',
            'job_id' => $aiJob->id,
            'status' => $aiJob->status,
        ], 202);
    }

    /**
     * Remix an existing website with new business information.
     */
    public function remix(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'website_id' => ['required', 'uuid', 'exists:websites,id'],
            'business_name' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'max:2000'],
            'brand_colors' => ['nullable', 'array'],
            'goal' => ['nullable', 'string', 'max:100'],
        ]);

        $website = Website::findOrFail($validated['website_id']);
        Gate::authorize('update', $website);

        try {
            $updatedWebsite = $this->remixService->remix(
                website: $website,
                businessInfo: [
                    'name' => $validated['business_name'],
                    'description' => $validated['description'],
                    'colors' => $validated['brand_colors'] ?? null,
                    'goal' => $validated['goal'] ?? 'Adapt to my business',
                ],
                author: $request->user()
            );

            return response()->json([
                'message' => 'Website successfully remixed.',
                'website' => $updatedWebsite,
            ]);
        } catch (Exception $e) {
            return response()->json(['message' => 'AI Remix failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Edit website via natural language instruction (structured AI editing).
     */
    public function edit(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'website_id' => ['required', 'uuid', 'exists:websites,id'],
            'instruction' => ['required', 'string', 'min:3', 'max:1000'],
            'target_section_id' => ['nullable', 'string'],
        ]);

        $website = Website::findOrFail($validated['website_id']);
        Gate::authorize('update', $website);

        try {
            $prompt = StructuredEditPrompt::build(
                currentDocument: $website->document,
                instruction: $validated['instruction'],
                targetSectionId: $validated['target_section_id'] ?? null
            );

            $aiRes = $this->client->chatCompletion(
                messages: $prompt,
                preferredModel: $this->modelSelector->getModelForTask('editing'),
                jsonMode: true
            );

            $parsed = PromptHelper::extractJson($aiRes['content']);
            $operations = $parsed['operations'] ?? [];
            $summary = $parsed['summary'] ?? "AI Edit: {$validated['instruction']}";

            $updatedWebsite = $this->editor->applyOperations(
                website: $website,
                operations: $operations,
                summary: $summary,
                author: $request->user()
            );

            return response()->json([
                'message' => 'Website updated successfully.',
                'summary' => $summary,
                'operations_applied' => count($operations),
                'website' => $updatedWebsite,
            ]);
        } catch (Exception $e) {
            return response()->json(['message' => 'AI Edit failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Get the status and progress of an AI job.
     */
    public function getJob(AiJob $job): JsonResponse
    {
        Gate::authorize('view', $job);

        return response()->json([
            'id' => $job->id,
            'type' => $job->type,
            'status' => $job->status,
            'progress' => $job->progress,
            'website_id' => $job->website_id,
            'error' => $job->error,
            'result' => $job->result,
            'completed_at' => $job->completed_at,
        ]);
    }
}
