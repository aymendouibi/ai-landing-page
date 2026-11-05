<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    use HasUuids;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'limits',
        'price_monthly',
        'price_annual',
        'stripe_price_monthly_id',
        'stripe_price_annual_id',
        'google_play_product_id',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'limits' => 'array',
            'price_monthly' => 'decimal:2',
            'price_annual' => 'decimal:2',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function getLimit(string $key, mixed $default = null): mixed
    {
        return $this->limits[$key] ?? $default;
    }
}

