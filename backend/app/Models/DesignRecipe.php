<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class DesignRecipe extends Model
{
    use HasUuids;

    protected $fillable = [
        'name',
        'slug',
        'industry',
        'description',
        'theme',
        'layout_rules',
        'component_recommendations',
        'image_direction',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'theme' => 'array',
            'layout_rules' => 'array',
            'component_recommendations' => 'array',
            'image_direction' => 'array',
            'is_active' => 'boolean',
        ];
    }

    public static function findByIndustry(string $industry): ?self
    {
        return static::where('industry', $industry)
            ->where('is_active', true)
            ->first();
    }
}
