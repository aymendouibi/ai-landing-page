<?php

namespace App\Models;

use App\Enums\DeploymentStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Deployment extends Model
{
    use HasUuids;

    protected $fillable = [
        'website_id',
        'revision_id',
        'status',
        'storage_path',
        'domains_deployed',
        'build_log',
        'deployed_at',
    ];

    protected function casts(): array
    {
        return [
            'status' => DeploymentStatus::class,
            'domains_deployed' => 'array',
            'build_log' => 'array',
            'deployed_at' => 'datetime',
        ];
    }

    public function website(): BelongsTo
    {
        return $this->belongsTo(Website::class);
    }

    public function revision(): BelongsTo
    {
        return $this->belongsTo(WebsiteRevision::class, 'revision_id');
    }

    public function isDeployed(): bool
    {
        return $this->status === DeploymentStatus::Deployed;
    }
}

