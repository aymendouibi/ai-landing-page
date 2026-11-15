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
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'status' => WebsiteStatus::class,
            'document' => 'array',
            'locked_at' => 'datetime',
            'published_at' => 'datetime',
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

    /**
     * Resolve route binding by UUID, slug, or normalized showcase slug.
     */
    public function resolveRouteBinding($value, $field = null)
    {
        // 1. Direct ID match (only query if value is a valid UUID to avoid PostgreSQL 22P02 error)
        if (\Illuminate\Support\Str::isUuid($value)) {
            $website = $this->where('id', $value)->first();
            if ($website) {
                return $website;
            }
        }

        // 2. Direct slug match (e.g. 'studio-marlow', 'kite-yoga')
        $website = $this->where('slug', $value)->first();
        if ($website) {
            return $website;
        }

        // 3. Normalized showcase or demo slug (e.g. 'showcase_studio_marlow' -> 'studio-marlow')
        $cleanSlug = str_replace('_', '-', preg_replace('/^(showcase_|demo_)/', '', $value));
        $website = $this->where('slug', $cleanSlug)->first();
        if ($website) {
            return $website;
        }

        // 4. Lazy creation/restoration for authenticated user modifying/accessing a showcase site
        if (str_starts_with($value, 'showcase_') || in_array($cleanSlug, ['studio-marlow', 'kite-yoga'])) {
            $user = request()->user();
            if ($user) {
                $project = $user->projects()->first() ?? $user->projects()->create(['name' => 'My Projects']);

                // Check if already exists for this project (including trashed)
                $existing = $this->withTrashed()->where('project_id', $project->id)->where('slug', $cleanSlug)->first();
                if ($existing) {
                    if ($existing->trashed()) {
                        $existing->restore();
                    }
                    return $existing;
                }

                $template = \App\Models\Template::where('slug', $cleanSlug)->first();
                $name = $template?->name ?? ($cleanSlug === 'kite-yoga' ? 'Kite Yoga' : 'Studio Marlow');
                $doc = $template?->document ?? \App\Services\Documents\DefaultDocumentFactory::createDefault($name);
                $subdomain = str_replace('-', '', $cleanSlug) . '-' . strtolower(\Illuminate\Support\Str::random(5));

                return $this->create([
                    'project_id' => $project->id,
                    'name' => $name,
                    'slug' => $cleanSlug,
                    'subdomain' => $subdomain,
                    'status' => WebsiteStatus::Published,
                    'revision_number' => 1,
                    'document' => $doc,
                ]);
            }
        }

        return null;
    }
}

