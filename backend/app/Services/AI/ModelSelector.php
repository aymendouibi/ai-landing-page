<?php

namespace App\Services\AI;

use App\Models\AiModelConfig;

class ModelSelector
{
    /**
     * Default model recommendations by task.
     *
     * @var array<string, string>
     */
    protected const DEFAULT_MODELS_BY_TASK = [
        'business_analysis' => 'google/gemma-4-31b-it:free',
        'design_planning' => 'google/gemma-4-31b-it:free',
        'website_planning' => 'google/gemma-4-31b-it:free',
        'content_generation' => 'google/gemma-4-31b-it:free',
        'document_generation' => 'google/gemma-4-31b-it:free',
        'editing' => 'google/gemma-4-31b-it:free',
        'remix' => 'google/gemma-4-31b-it:free',
        'vision_qa' => 'nvidia/nemotron-3.5-super-vl:free',
    ];

    /**
     * Get the best model for a specific task.
     *
     * @param string $task
     * @return string Model identifier
     */
    public function getModelForTask(string $task): string
    {
        // 1. Check if an active model config is configured in DB
        $config = AiModelConfig::getForTask($task);
        if ($config && !empty($config->model)) {
            return $config->model;
        }

        // 2. Return sensible default
        return self::DEFAULT_MODELS_BY_TASK[$task] ?? 'google/gemma-4-31b-it:free';
    }
}
