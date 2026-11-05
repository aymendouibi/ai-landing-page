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
        'business_analysis' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
        'design_planning' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
        'website_planning' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
        'content_generation' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
        'document_generation' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
        'editing' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
        'remix' => 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
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
        return self::DEFAULT_MODELS_BY_TASK[$task] ?? 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free';
    }
}

