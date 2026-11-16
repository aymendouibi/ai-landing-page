<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AiModelConfig;
use App\Services\AI\ModelSelector;
use App\Services\AI\OpenRouterClient;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\View\View;

class AdminAiSettingsController extends Controller
{
    /**
     * Curated popular OpenRouter models for quick selection.
     */
    public const POPULAR_MODELS = [
        [
            'id' => 'google/gemini-2.5-flash',
            'name' => 'Gemini 2.5 Flash',
            'provider' => 'Google',
            'badge' => 'Recommended · High Speed',
            'description' => 'Sub-second structured JSON latency, ideal for real-time mobile page generation.',
        ],
        [
            'id' => 'anthropic/claude-3.5-sonnet',
            'name' => 'Claude 3.5 Sonnet',
            'provider' => 'Anthropic',
            'badge' => 'Highest Quality Copy',
            'description' => 'Exceptional copywriting, layout reasoning, and design consistency.',
        ],
        [
            'id' => 'openai/gpt-4o',
            'name' => 'GPT-4o',
            'provider' => 'OpenAI',
            'badge' => 'High Intelligence',
            'description' => 'Flagship multimodal model with strong structured JSON schema adherence.',
        ],
        [
            'id' => 'meta-llama/llama-3.3-70b-instruct',
            'name' => 'Llama 3.3 70B',
            'provider' => 'Meta',
            'badge' => 'Open Weights Powerhouse',
            'description' => 'Fast, cost-effective, high-tier instruction following.',
        ],
        [
            'id' => 'deepseek/deepseek-chat',
            'name' => 'DeepSeek V3',
            'provider' => 'DeepSeek',
            'badge' => 'Economical & Fast',
            'description' => 'High performance benchmark scores with extremely low token cost.',
        ],
        [
            'id' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
            'name' => 'Nemotron 3 Nano Reasoning',
            'provider' => 'NVIDIA',
            'badge' => 'Free Tier Default',
            'description' => 'Zero-cost inference model provided via OpenRouter free tier.',
        ],
    ];

    public function __construct(
        protected ModelSelector $modelSelector,
        protected OpenRouterClient $openRouterClient
    ) {}

    /**
     * Display AI Model & OpenRouter Configuration panel.
     */
    public function index(): View
    {
        $currentGlobalModel = $this->modelSelector->getModelForTask('document_generation');
        $resolvedModels = $this->modelSelector->getAllResolvedModels();

        $activeGlobalConfig = AiModelConfig::where('task', 'global')->where('is_active', true)->first();
        $apiKeyConfigured = !empty(config('services.openrouter.api_key'));

        return view('admin.ai_settings', [
            'currentGlobalModel' => $activeGlobalConfig?->model ?? $currentGlobalModel,
            'resolvedModels' => $resolvedModels,
            'popularModels' => self::POPULAR_MODELS,
            'apiKeyConfigured' => $apiKeyConfigured,
            'apiBaseUrl' => config('services.openrouter.base_url', 'https://openrouter.ai/api/v1'),
            'envFallback' => config('services.openrouter.edit_model'),
        ]);
    }

    /**
     * Update the active OpenRouter model used across the application.
     */
    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'model' => ['required', 'string', 'max:255'],
            'task' => ['nullable', 'string', 'max:50'],
        ]);

        $task = $validated['task'] ?? 'global';
        $modelName = trim($validated['model']);

        // Update or create the active config for this task
        AiModelConfig::updateOrCreate(
            ['task' => $task],
            [
                'provider' => 'openrouter',
                'model' => $modelName,
                'is_active' => true,
                'priority' => 10,
            ]
        );

        // If setting global, also update document_generation and editing for total consistency
        if ($task === 'global') {
            foreach (['document_generation', 'editing', 'remix'] as $t) {
                AiModelConfig::updateOrCreate(
                    ['task' => $t],
                    [
                        'provider' => 'openrouter',
                        'model' => $modelName,
                        'is_active' => true,
                        'priority' => 10,
                    ]
                );
            }
        }

        return back()->with('success', "OpenRouter model successfully set to '{$modelName}'. All AI generations and remixes will now use this model.");
    }

    /**
     * Test OpenRouter connection with a specific or currently configured model.
     */
    public function testConnection(Request $request): JsonResponse
    {
        $model = trim($request->input('model') ?? $this->modelSelector->getModelForTask('document_generation'));

        $startTime = microtime(true);
        try {
            $response = $this->openRouterClient->chatCompletion(
                messages: [
                    ['role' => 'system', 'content' => 'You are an AI benchmark ping. Reply in valid JSON with {"status": "ok", "message": "Pong!"}'],
                    ['role' => 'user', 'content' => 'Ping'],
                ],
                preferredModel: $model,
                jsonMode: true
            );

            $durationMs = round((microtime(true) - $startTime) * 1000);

            return response()->json([
                'success' => true,
                'model' => $response['model_used'] ?? $model,
                'duration_ms' => $durationMs,
                'tokens_input' => $response['tokens_input'] ?? 0,
                'tokens_output' => $response['tokens_output'] ?? 0,
                'message' => 'Connection verified successfully! Model responded in ' . $durationMs . 'ms.',
            ]);
        } catch (Exception $e) {
            $durationMs = round((microtime(true) - $startTime) * 1000);
            Log::error('OpenRouter model test failed', ['model' => $model, 'error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'model' => $model,
                'duration_ms' => $durationMs,
                'error' => $e->getMessage(),
            ], 422);
        }
    }
}
