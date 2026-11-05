<?php

namespace App\Models;

use App\Enums\DomainStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Domain extends Model
{
    use HasUuids;

    protected $fillable = [
        'website_id',
        'domain',
        'type',
        'status',
        'verification_token',
        'provider_hostname_id',
        'ssl_status',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'status' => DomainStatus::class,
            'ssl_status' => 'array',
            'verified_at' => 'datetime',
        ];
    }

    public function website(): BelongsTo
    {
        return $this->belongsTo(Website::class);
    }

    public function isActive(): bool
    {
        return $this->status === DomainStatus::Active;
    }

    public function isPending(): bool
    {
        return $this->status === DomainStatus::Pending;
    }
}

