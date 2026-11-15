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
        'editing' => 'google/gemini-2.5-flash',
        'remix' => 'google/gemini-2.5-flash',
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
        // 1. Check for specific environment override for this task
        if (in_array($task, ['editing', 'remix'], true)) {
            $configuredEditModel = config('services.openrouter.edit_model');
            if (!empty($configuredEditModel)) {
                return (string) $configuredEditModel;
            }
        }

        // 2. Check if an active model config is configured in DB
        $config = AiModelConfig::getForTask($task);
        if ($config && !empty($config->model)) {
            return $config->model;
        }

        // 3. Return sensible default
        return self::DEFAULT_MODELS_BY_TASK[$task] ?? 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free';
    }
}

