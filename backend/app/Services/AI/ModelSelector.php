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
        'business_analysis' => 'google/gemini-2.5-flash',
        'design_planning' => 'google/gemini-2.5-flash',
        'website_planning' => 'google/gemini-2.5-flash',
        'content_generation' => 'google/gemini-2.5-flash',
        'document_generation' => 'google/gemini-2.5-flash',
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
        // 1. Check if an active task-specific model config exists in DB
        $config = AiModelConfig::getForTask($task);
        if ($config && !empty($config->model)) {
            return $config->model;
        }

        // 2. Check if an active global model config is set in DB
        $globalConfig = AiModelConfig::getForTask('global');
        if ($globalConfig && !empty($globalConfig->model)) {
            return $globalConfig->model;
        }

        // 3. Check for specific environment override for editing/remix
        if (in_array($task, ['editing', 'remix'], true)) {
            $configuredEditModel = config('services.openrouter.edit_model');
            if (!empty($configuredEditModel)) {
                return (string) $configuredEditModel;
            }
        }

        // 4. Return sensible default
        return self::DEFAULT_MODELS_BY_TASK[$task] ?? 'google/gemini-2.5-flash';
    }

    /**
     * Get all currently resolved models mapped by task.
     *
     * @return array<string, string>
     */
    public function getAllResolvedModels(): array
    {
        $tasks = array_keys(self::DEFAULT_MODELS_BY_TASK);
        $result = [];
        foreach ($tasks as $task) {
            $result[$task] = $this->getModelForTask($task);
        }
        return $result;
    }
}
