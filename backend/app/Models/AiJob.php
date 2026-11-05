<?php

namespace App\Models;

use App\Enums\AiJobStatus;
use App\Enums\AiJobType;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiJob extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'website_id',
        'type',
        'status',
        'input',
        'result',
        'model_used',
        'tokens_input',
        'tokens_output',
        'cost',
        'progress',
        'error',
        'started_at',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'type' => AiJobType::class,
            'status' => AiJobStatus::class,
            'input' => 'array',
            'result' => 'array',
            'tokens_input' => 'integer',
            'tokens_output' => 'integer',
            'cost' => 'decimal:6',
            'progress' => 'integer',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function website(): BelongsTo
    {
        return $this->belongsTo(Website::class);
    }

    public function isCompleted(): bool
    {
        return $this->status === AiJobStatus::Completed;
    }

    public function isFailed(): bool
    {
        return $this->status === AiJobStatus::Failed;
    }

    public function isProcessing(): bool
    {
        return $this->status === AiJobStatus::Processing;
    }

    public function markProcessing(): void
    {
        $this->update([
            'status' => AiJobStatus::Processing,
            'started_at' => now(),
        ]);
    }

    public function markCompleted(array $result, string $modelUsed, int $tokensIn, int $tokensOut, float $cost = 0): void
    {
        $this->update([
            'status' => AiJobStatus::Completed,
            'result' => $result,
            'model_used' => $modelUsed,
            'tokens_input' => $tokensIn,
            'tokens_output' => $tokensOut,
            'cost' => $cost,
            'progress' => 100,
            'completed_at' => now(),
        ]);
    }

    public function markFailed(string $error): void
    {
        $this->update([
            'status' => AiJobStatus::Failed,
            'error' => $error,
            'completed_at' => now(),
        ]);
    }
}

