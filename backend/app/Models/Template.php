<?php

namespace App\Models;

use App\Enums\TemplateStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Template extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'user_id',
        'category_id',
        'name',
        'slug',
        'description',
        'industry',
        'badge',
        'is_featured',
        'is_public',
        'source_website_id',
        'preview_images',
        'status',
        'license_type',
        'author',
        'use_count',
        'is_premium',
    ];

    protected function casts(): array
    {
        return [
            'status' => TemplateStatus::class,
            'preview_images' => 'array',
            'is_premium' => 'boolean',
            'is_featured' => 'boolean',
            'is_public' => 'boolean',
            'use_count' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function sourceWebsite(): BelongsTo
    {
        return $this->belongsTo(Website::class, 'source_website_id');
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeCommunity($query)
    {
        return $query->whereNotNull('user_id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(TemplateCategory::class, 'category_id');
    }

    public function versions(): HasMany
    {
        return $this->hasMany(TemplateVersion::class);
    }

    public function activeVersion(): HasOne
    {
        return $this->hasOne(TemplateVersion::class)->where('is_active', true);
    }

    public function isPublished(): bool
    {
        return $this->status === TemplateStatus::Published;
    }

    public function incrementUseCount(): void
    {
        $this->increment('use_count');
    }
}

