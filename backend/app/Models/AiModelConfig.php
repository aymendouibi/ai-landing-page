<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class AiModelConfig extends Model
{
    use HasUuids;

    protected $fillable = [
        'task',
        'provider',
        'model',
        'capabilities',
        'parameters',
        'is_active',
        'priority',
    ];

    protected function casts(): array
    {
        return [
            'capabilities' => 'array',
            'parameters' => 'array',
            'is_active' => 'boolean',
            'priority' => 'integer',
        ];
    }

    public function supportsCapability(string $capability): bool
    {
        return in_array($capability, $this->capabilities ?? [], true);
    }

    public static function getForTask(string $task): ?self
    {
        return static::where('task', $task)
            ->where('is_active', true)
            ->orderByDesc('priority')
            ->first();
    }
}

