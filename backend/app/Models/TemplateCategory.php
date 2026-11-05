<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TemplateCategory extends Model
{
    use HasUuids;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
        ];
    }

    public function templates(): HasMany
    {
        return $this->hasMany(Template::class, 'category_id');
    }
}

