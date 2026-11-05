<?php

namespace App\Models;

use App\Enums\WebsiteStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Website extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'project_id',
        'name',
        'slug',
        'status',
        'document',
        'revision_number',
        'current_revision_id',
        'lock_token',
        'locked_at',
        'subdomain',
    ];

    protected function casts(): array
    {
        return [
            'status' => WebsiteStatus::class,
            'document' => 'array',
            'locked_at' => 'datetime',
            'revision_number' => 'integer',
        ];
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }

    public function revisions(): HasMany
    {
        return $this->hasMany(WebsiteRevision::class)->orderByDesc('revision_number');
    }

    public function currentRevision(): BelongsTo
    {
        return $this->belongsTo(WebsiteRevision::class, 'current_revision_id');
    }

    public function domains(): HasMany
    {
        return $this->hasMany(Domain::class);
    }

    public function deployments(): HasMany
    {
        return $this->hasMany(Deployment::class)->orderByDesc('created_at');
    }

    public function mediaAssets(): HasMany
    {
        return $this->hasMany(MediaAsset::class);
    }

    public function aiJobs(): HasMany
    {
        return $this->hasMany(AiJob::class);
    }

    public function forms(): HasMany
    {
        return $this->hasMany(WebsiteForm::class);
    }

    public function isLocked(): bool
    {
        if (!$this->lock_token || !$this->locked_at) {
            return false;
        }
        return $this->locked_at->diffInMinutes(now()) < 5;
    }

    public function acquireLock(string $token): bool
    {
        if ($this->isLocked() && $this->lock_token !== $token) {
            return false;
        }

        $this->update([
            'lock_token' => $token,
            'locked_at' => now(),
        ]);

        return true;
    }

    public function releaseLock(string $token): bool
    {
        if ($this->lock_token !== $token) {
            return false;
        }

        $this->update([
            'lock_token' => null,
            'locked_at' => null,
        ]);

        return true;
    }

    public function isPublished(): bool
    {
        return $this->status === WebsiteStatus::Published;
    }
}

