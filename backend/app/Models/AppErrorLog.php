<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AppErrorLog extends Model
{
    use HasUuids;

    protected $table = 'app_error_logs';

    protected $fillable = [
        'category',
        'severity',
        'user_id',
        'message',
        'exception_class',
        'context',
        'stack_trace',
        'resolved_at',
    ];

    protected function casts(): array
    {
        return [
            'context' => 'array',
            'resolved_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public static function logAuthError(string $message, array $context = [], ?string $userId = null, ?\Throwable $exception = null): self
    {
        return static::create([
            'category' => 'auth',
            'severity' => 'warning',
            'user_id' => $userId,
            'message' => $message,
            'exception_class' => $exception ? get_class($exception) : null,
            'context' => $context,
            'stack_trace' => $exception ? substr($exception->getTraceAsString(), 0, 4000) : null,
        ]);
    }

    public static function logPaymentError(string $message, array $context = [], ?string $userId = null, ?\Throwable $exception = null): self
    {
        return static::create([
            'category' => 'payment',
            'severity' => 'error',
            'user_id' => $userId,
            'message' => $message,
            'exception_class' => $exception ? get_class($exception) : null,
            'context' => $context,
            'stack_trace' => $exception ? substr($exception->getTraceAsString(), 0, 4000) : null,
        ]);
    }

    public static function logAiError(string $message, array $context = [], ?string $userId = null, ?\Throwable $exception = null): self
    {
        return static::create([
            'category' => 'ai',
            'severity' => 'error',
            'user_id' => $userId,
            'message' => $message,
            'exception_class' => $exception ? get_class($exception) : null,
            'context' => $context,
            'stack_trace' => $exception ? substr($exception->getTraceAsString(), 0, 4000) : null,
        ]);
    }

    public static function logSystemError(string $message, array $context = [], ?string $userId = null, ?\Throwable $exception = null): self
    {
        return static::create([
            'category' => 'system',
            'severity' => 'error',
            'user_id' => $userId,
            'message' => $message,
            'exception_class' => $exception ? get_class($exception) : null,
            'context' => $context,
            'stack_trace' => $exception ? substr($exception->getTraceAsString(), 0, 4000) : null,
        ]);
    }
}
