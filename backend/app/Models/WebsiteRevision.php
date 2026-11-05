<?php

namespace App\Models;

use App\Enums\RevisionSource;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WebsiteRevision extends Model
{
    use HasUuids;

    protected $fillable = [
        'website_id',
        'revision_number',
        'document',
        'source',
        'description',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'document' => 'array',
            'source' => RevisionSource::class,
            'revision_number' => 'integer',
        ];
    }

    public function website(): BelongsTo
    {
        return $this->belongsTo(Website::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
