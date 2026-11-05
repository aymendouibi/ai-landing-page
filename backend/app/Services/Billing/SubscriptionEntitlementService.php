<?php

namespace App\Services\Billing;

use App\Enums\DomainStatus;
use App\Enums\SubscriptionStatus;
use App\Enums\WebsiteStatus;
use App\Exceptions\SubscriptionLimitExceededException;
use App\Models\Domain;
use App\Models\SubscriptionPlan;
use App\Models\UsageRecord;
use App\Models\User;
use App\Models\Website;
use Illuminate\Support\Facades\DB;

class SubscriptionEntitlementService
{
    /**
     * Retrieve the active subscription plan for a user, or fall back to the Free tier.
     */
    public function getUserPlan(User $user): SubscriptionPlan
    {
        $activeSub = $user->subscription()
            ->where('status', SubscriptionStatus::Active)
            ->with('plan')
            ->first();

        if ($activeSub && $activeSub->plan) {
            return $activeSub->plan;
        }

        return SubscriptionPlan::where('slug', 'free')->first() ?? new SubscriptionPlan([
            'name' => 'Free',
            'slug' => 'free',
            'limits' => [
                'max_websites' => 3,
                'max_published' => 1,
                'ai_generations_monthly' => 5,
                'ai_edits_monthly' => 20,
                'custom_domains' => 0,
                'storage_mb' => 100,
            ],
        ]);
    }

    /**
     * Get plan limits array.
     */
    public function getLimits(User $user): array
    {
        $plan = $this->getUserPlan($user);
        return $plan->limits ?? [];
    }

    /**
     * Query current usage for a given metric.
     */
    public function getUsage(User $user, string $metric): int
    {
        return match ($metric) {
            'websites_count' => Website::whereHas('project', fn($q) => $q->where('user_id', $user->id))->count(),
            'published_websites_count' => Website::whereHas('project', fn($q) => $q->where('user_id', $user->id))
                ->where('status', WebsiteStatus::Published)
                ->count(),
            'custom_domains_count' => Domain::whereHas('website.project', fn($q) => $q->where('user_id', $user->id))
                ->count(),
            'ai_generations_monthly' => (int) UsageRecord::where('user_id', $user->id)
                ->where('metric', 'ai_generations')
                ->where('period', date('Y-m'))
                ->sum('quantity'),
            'ai_edits_monthly' => (int) UsageRecord::where('user_id', $user->id)
                ->where('metric', 'ai_edits')
                ->where('period', date('Y-m'))
                ->sum('quantity'),
            default => 0,
        };
    }

    /**
     * Record usage for a specific metric in the current monthly period.
     */
    public function recordUsage(User $user, string $metric, int $quantity = 1): void
    {
        $period = date('Y-m');

        DB::transaction(function () use ($user, $metric, $quantity, $period) {
            $record = UsageRecord::firstOrCreate(
                [
                    'user_id' => $user->id,
                    'metric' => $metric,
                    'period' => $period,
                ],
                ['quantity' => 0]
            );

            $record->increment('quantity', $quantity);
        });
    }

    /**
     * Assert that the user is entitled to perform an action, or throw SubscriptionLimitExceededException.
     *
     * @throws SubscriptionLimitExceededException
     */
    public function assertCan(User $user, string $action): void
    {
        $limits = $this->getLimits($user);

        switch ($action) {
            case 'create_website':
                $maxWebsites = (int) ($limits['max_websites'] ?? 3);
                $currentWebsites = $this->getUsage($user, 'websites_count');
                if ($currentWebsites >= $maxWebsites) {
                    throw new SubscriptionLimitExceededException(
                        "You have reached your limit of {$maxWebsites} websites. Upgrade to Pro for up to 5 websites or Agency for unlimited.",
                        'max_websites',
                        $maxWebsites,
                        $currentWebsites,
                        'pro'
                    );
                }
                break;

            case 'publish_website':
                $maxPublished = (int) ($limits['max_published'] ?? 1);
                $currentPublished = $this->getUsage($user, 'published_websites_count');
                if ($currentPublished >= $maxPublished) {
                    throw new SubscriptionLimitExceededException(
                        "You have reached your limit of {$maxPublished} published websites. Upgrade to Pro to publish more websites.",
                        'max_published',
                        $maxPublished,
                        $currentPublished,
                        'pro'
                    );
                }
                break;

            case 'custom_domain':
                $maxDomains = (int) ($limits['custom_domains'] ?? 0);
                $currentDomains = $this->getUsage($user, 'custom_domains_count');
                if ($maxDomains === 0 || $currentDomains >= $maxDomains) {
                    throw new SubscriptionLimitExceededException(
                        "Custom domains are not available on your current plan. Upgrade to Pro to attach your own branded domains.",
                        'custom_domains',
                        $maxDomains,
                        $currentDomains,
                        'pro'
                    );
                }
                break;

            case 'ai_generation':
                $maxAi = (int) ($limits['ai_generations_monthly'] ?? 5);
                $currentAi = $this->getUsage($user, 'ai_generations_monthly');
                if ($currentAi >= $maxAi) {
                    throw new SubscriptionLimitExceededException(
                        "You have used all {$maxAi} AI generations for this monthly billing cycle. Upgrade to Pro for 50 monthly generations.",
                        'ai_generations_monthly',
                        $maxAi,
                        $currentAi,
                        'pro'
                    );
                }
                break;

            case 'ai_edit':
                $maxEdits = (int) ($limits['ai_edits_monthly'] ?? 20);
                $currentEdits = $this->getUsage($user, 'ai_edits_monthly');
                if ($currentEdits >= $maxEdits) {
                    throw new SubscriptionLimitExceededException(
                        "You have reached your monthly AI structured edits limit of {$maxEdits}. Upgrade for increased capacity.",
                        'ai_edits_monthly',
                        $maxEdits,
                        $currentEdits,
                        'pro'
                    );
                }
                break;
        }
    }

    /**
     * Complete usage summary report for API response.
     */
    public function getSummary(User $user): array
    {
        $plan = $this->getUserPlan($user);
        $limits = $plan->limits ?? [];

        return [
            'plan' => [
                'name' => $plan->name,
                'slug' => $plan->slug,
                'price_monthly' => $plan->price_monthly,
            ],
            'limits' => $limits,
            'usage' => [
                'websites_count' => $this->getUsage($user, 'websites_count'),
                'published_websites_count' => $this->getUsage($user, 'published_websites_count'),
                'custom_domains_count' => $this->getUsage($user, 'custom_domains_count'),
                'ai_generations_used' => $this->getUsage($user, 'ai_generations_monthly'),
                'ai_edits_used' => $this->getUsage($user, 'ai_edits_monthly'),
            ],
            'period' => date('Y-m'),
        ];
    }
}
