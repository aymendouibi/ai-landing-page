<?php

namespace App\Models;

use App\Enums\AuthProvider;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserAuthProvider extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'provider',
        'provider_user_id',
        'provider_email',
        'provider_data',
    ];

    protected function casts(): array
    {
        return [
            'provider' => AuthProvider::class,
            'provider_data' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

