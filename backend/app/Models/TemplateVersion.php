<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TemplateVersion extends Model
{
    use HasUuids;

    protected $fillable = [
        'template_id',
        'version',
        'document',
        'design_tokens',
        'fonts',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'document' => 'array',
            'design_tokens' => 'array',
            'fonts' => 'array',
            'is_active' => 'boolean',
            'version' => 'integer',
        ];
    }

    public function template(): BelongsTo
    {
        return $this->belongsTo(Template::class);
    }
}
