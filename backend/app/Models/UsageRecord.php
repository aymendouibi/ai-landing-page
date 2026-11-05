<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\DB;

class UsageRecord extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'metric',
        'quantity',
        'period',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public static function recordUsage(string $userId, string $metric, int $quantity = 1): void
    {
        $period = now()->format('Y-m');

        $record = static::firstOrCreate(
            ['user_id' => $userId, 'metric' => $metric, 'period' => $period],
            ['quantity' => 0]
        );

        $record->increment('quantity', $quantity);
    }

    public static function getUsage(string $userId, string $metric, ?string $period = null): int
    {
        $period ??= now()->format('Y-m');

        return (int) (static::where('user_id', $userId)
            ->where('metric', $metric)
            ->where('period', $period)
            ->value('quantity') ?? 0);
    }
}
