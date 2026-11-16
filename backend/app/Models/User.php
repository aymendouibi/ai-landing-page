<?php

namespace App\Models;

use App\Enums\SubscriptionStatus;
use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements MustVerifyEmail
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, HasUuids, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'avatar_url',
        'preferences',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'role' => UserRole::class,
            'preferences' => 'array',
        ];
    }

    public function authProviders(): HasMany
    {
        return $this->hasMany(UserAuthProvider::class);
    }

    public function projects(): HasMany
    {
        return $this->hasMany(Project::class);
    }

    public function websites(): \Illuminate\Database\Eloquent\Relations\HasManyThrough
    {
        return $this->hasManyThrough(Website::class, Project::class);
    }

    public function mediaAssets(): HasMany
    {
        return $this->hasMany(MediaAsset::class);
    }

    public function aiJobs(): HasMany
    {
        return $this->hasMany(AiJob::class);
    }

    public function subscription(): HasOne
    {
        return $this->hasOne(Subscription::class)->latest('created_at');
    }

    public function billingCustomer(): HasOne
    {
        return $this->hasOne(BillingCustomer::class);
    }

    public function usageRecords(): HasMany
    {
        return $this->hasMany(UsageRecord::class);
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::Admin;
    }

    public function hasAuthProvider(string $provider): bool
    {
        return $this->authProviders()->where('provider', $provider)->exists();
    }

    public function getActiveSubscription(): ?Subscription
    {
        return $this->subscription()
            ->where('status', SubscriptionStatus::Active)
            ->first();
    }

    public function isPremium(): bool
    {
        $sub = $this->subscription;
        if (!$sub || !$sub->isActive()) {
            return false;
        }

        $slug = $sub->plan?->slug;
        return in_array($slug, ['pro', 'premium', 'business'], true);
    }

    public function getTierLabel(): string
    {
        if ($this->isAdmin()) {
            return 'Admin';
        }
        if ($this->isPremium()) {
            return $this->subscription?->plan?->name ?? 'Premium';
        }
        return 'Free';
    }
}
