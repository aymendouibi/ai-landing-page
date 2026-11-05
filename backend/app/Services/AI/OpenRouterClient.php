<?php

namespace App\Services\AI;

use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OpenRouterClient
{
    protected string $apiKey;
    protected string $baseUrl;

    /**
     * Default cascade of fallback models if primary model fails.
     *
     * @var array<string>
     */
    public const DEFAULT_FALLBACK_MODELS = [
        'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
        'nvidia/nemotron-3.5-lightning:free',
    ];

    public function __construct()
    {
        $this->apiKey = (string) config('services.openrouter.api_key');
        $this->baseUrl = (string) config('services.openrouter.base_url', 'https://openrouter.ai/api/v1');
    }

    /**
     * Send a chat completion request to OpenRouter with automatic model fallback cascade.
     *
     * @param array<array{role: string, content: string}> $messages
     * @param string|null $preferredModel
     * @param array<string, mixed> $parameters
     * @param bool $jsonMode
     * @return array{content: string, model_used: string, tokens_input: int, tokens_output: int, cost: float}
     * @throws Exception
     */
    public function chatCompletion(
        array $messages,
        ?string $preferredModel = null,
        array $parameters = [],
        bool $jsonMode = false
    ): array {
        if (empty($this->apiKey)) {
            throw new Exception('OpenRouter API key is not configured.');
        }

        // Build list of models to try in order
        $modelsToTry = [];
        if ($preferredModel) {
            $modelsToTry[] = $preferredModel;
        }
        foreach (self::DEFAULT_FALLBACK_MODELS as $fallback) {
            if (!in_array($fallback, $modelsToTry, true)) {
                $modelsToTry[] = $fallback;
            }
        }

        $lastException = null;

        foreach ($modelsToTry as $model) {
            try {
                return $this->executeRequest($model, $messages, $parameters, $jsonMode);
            } catch (Exception $e) {
                Log::warning("OpenRouter model {$model} failed: {$e->getMessage()}. Attempting fallback...");
                $lastException = $e;
                continue;
            }
        }

        throw new Exception("All OpenRouter models failed. Last error: " . ($lastException?->getMessage() ?? 'Unknown error'));
    }

    /**
     * Execute HTTP request to OpenRouter.
     *
     * @param string $model
     * @param array<array{role: string, content: string}> $messages
     * @param array<string, mixed> $parameters
     * @param bool $jsonMode
     * @return array{content: string, model_used: string, tokens_input: int, tokens_output: int, cost: float}
     * @throws Exception
     */
    protected function executeRequest(
        string $model,
        array $messages,
        array $parameters,
        bool $jsonMode
    ): array {
        $body = array_merge([
            'model' => $model,
            'messages' => $messages,
            'temperature' => 0.7,
            'max_tokens' => 8000,
        ], $parameters);

        if ($jsonMode) {
            $body['response_format'] = ['type' => 'json_object'];
        }

        $startTime = microtime(true);

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'HTTP-Referer' => config('app.url', 'http://localhost:8000'),
            'X-Title' => 'AI Website Builder',
            'Content-Type' => 'application/json',
        ])
        ->timeout(45)
        ->retry(2, 500, throw: false)
        ->post($this->baseUrl . '/chat/completions', $body);

        $durationMs = round((microtime(true) - $startTime) * 1000);

        if (!$response->successful()) {
            $status = $response->status();
            $errorBody = $response->body();
            Log::error("OpenRouter API error [{$status}] for model {$model}", ['response' => $errorBody]);
            throw new Exception("OpenRouter API HTTP {$status}: {$errorBody}");
        }

        $data = $response->json();
        $choice = $data['choices'][0] ?? null;

        if (!$choice || !isset($choice['message']['content'])) {
            throw new Exception("Malformed OpenRouter response from model {$model}");
        }

        $content = trim($choice['message']['content']);
        $usage = $data['usage'] ?? [];
        $tokensInput = (int) ($usage['prompt_tokens'] ?? 0);
        $tokensOutput = (int) ($usage['completion_tokens'] ?? 0);

        Log::info("OpenRouter completion successful", [
            'model' => $model,
            'duration_ms' => $durationMs,
            'tokens_in' => $tokensInput,
            'tokens_out' => $tokensOutput,
        ]);

        return [
            'content' => $content,
            'model_used' => $data['model'] ?? $model,
            'tokens_input' => $tokensInput,
            'tokens_output' => $tokensOutput,
            'cost' => 0.0, // OpenRouter free models have 0 cost
        ];
    }
}

