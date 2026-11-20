<?php

namespace App\Http\Controllers\Admin;

use App\Enums\BillingProvider;
use App\Enums\SubscriptionStatus;
use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\BillingCustomer;
use App\Models\BillingEvent;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\View\View;

class AdminUserController extends Controller
{
    /**
     * Display a listing of all users ordered by Premium first.
     */
    public function index(Request $request): View
    {
        $role = $request->query('role');
        $tier = $request->query('tier');
        $search = $request->query('search');

        $query = User::withCount(['projects', 'websites'])
            ->with([
                'subscription.plan',
                'websites' => fn ($q) => $q->latest('updated_at'),
            ])
            ->when($role, fn ($q) => $q->where('role', $role))
            ->when($tier === 'premium', function ($q) {
                $q->whereHas('subscription', function ($sub) {
                    $sub->where('status', 'active')
                        ->whereHas('plan', fn ($p) => $p->whereIn('slug', ['pro', 'premium', 'business']));
                });
            })
            ->when($tier === 'free', function ($q) {
                $q->whereDoesntHave('subscription', function ($sub) {
                    $sub->where('status', 'active')
                        ->whereHas('plan', fn ($p) => $p->whereIn('slug', ['pro', 'premium', 'business']));
                });
            })
            ->when($search, function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('name', 'ilike', "%{$search}%")
                        ->orWhere('email', 'ilike', "%{$search}%");
                });
            });

        // Always order starting by Premium creators first, then by registration date
        $query->orderByRaw("
            CASE 
                WHEN EXISTS (
                    SELECT 1 FROM subscriptions s 
                    JOIN subscription_plans sp ON s.plan_id = sp.id 
                    WHERE s.user_id = users.id 
                      AND s.status = 'active' 
                      AND sp.slug IN ('pro', 'premium', 'business')
                ) THEN 1 
                ELSE 2 
            END ASC
        ")->orderByDesc('created_at');

        $users = $query->paginate(15);

        $premiumCount = User::whereHas('subscription', function ($sub) {
            $sub->where('status', 'active')
                ->whereHas('plan', fn ($p) => $p->whereIn('slug', ['pro', 'premium', 'business']));
        })->count();

        $metrics = [
            'total' => User::count(),
            'admins' => User::where('role', UserRole::Admin)->count(),
            'premium' => $premiumCount,
            'free' => max(0, User::count() - $premiumCount),
            'verified' => User::whereNotNull('email_verified_at')->count(),
        ];

        $plans = SubscriptionPlan::where('slug', '!=', 'free')
            ->orderBy('sort_order')
            ->get();

        return view('admin.users', [
            'users' => $users,
            'metrics' => $metrics,
            'plans' => $plans,
            'currentRole' => $role,
            'currentTier' => $tier,
            'search' => $search,
        ]);
    }

    /**
     * Display a specific user's full profile and all generated landing pages.
     */
    public function show(Request $request, User $user): View|JsonResponse
    {
        $user->load([
            'subscription.plan',
            'projects.websites' => fn ($q) => $q->latest('updated_at'),
            'websites' => fn ($q) => $q->latest('updated_at'),
            'authProviders',
        ]);

        $platformDomain = config('app.platform_domain', 'ai-landing-page.xyz');

        $websites = $user->websites->map(function ($site) use ($platformDomain) {
            $subdomain = $site->subdomain ?? $site->slug;
            $liveUrl = "https://{$subdomain}.{$platformDomain}";

            return [
                'id' => $site->id,
                'name' => $site->name ?? 'Untitled Site',
                'slug' => $site->slug,
                'subdomain' => $subdomain,
                'status' => $site->status->value ?? 'draft',
                'is_published' => ($site->status->value ?? 'draft') === 'published',
                'live_url' => $liveUrl,
                'preview_url' => "/sites/{$subdomain}",
                'revision_number' => $site->revision_number ?? 1,
                'published_at' => $site->published_at?->format('M d, Y H:i'),
                'created_at' => $site->created_at->format('M d, Y'),
                'updated_at' => $site->updated_at->format('M d, Y H:i'),
                'sections_count' => count($site->document['sections'] ?? []),
            ];
        });

        if ($request->wantsJson() || $request->ajax()) {
            return response()->json([
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role->value,
                    'tier' => $user->getTierLabel(),
                    'is_premium' => $user->isPremium(),
                    'avatar_url' => $user->avatar_url,
                    'email_verified_at' => $user->email_verified_at?->format('M d, Y H:i'),
                    'created_at' => $user->created_at->format('M d, Y'),
                    'subscription' => $user->subscription ? [
                        'plan_name' => $user->subscription->plan?->name ?? 'Custom',
                        'plan_slug' => $user->subscription->plan?->slug ?? 'custom',
                        'status' => $user->subscription->status->value,
                        'provider' => $user->subscription->provider->value ?? 'stripe',
                        'current_period_start' => $user->subscription->current_period_start?->format('M d, Y'),
                        'current_period_end' => $user->subscription->current_period_end?->format('M d, Y'),
                    ] : null,
                ],
                'websites' => $websites,
            ]);
        }

        $plans = SubscriptionPlan::where('slug', '!=', 'free')
            ->orderBy('sort_order')
            ->get();

        return view('admin.user_show', [
            'user' => $user,
            'websites' => $websites,
            'plans' => $plans,
        ]);
    }

    /**
     * Toggle a user's role between Admin and standard User.
     */
    public function toggleRole(User $user): RedirectResponse
    {
        if ($user->role === UserRole::Admin) {
            // Safety guard: prevent demoting oneself
            if (Auth::id() === $user->id) {
                return back()->with('error', 'You cannot demote your own administrator account.');
            }

            // Safety guard: ensure at least one admin remains
            $adminCount = User::where('role', UserRole::Admin)->count();
            if ($adminCount <= 1) {
                return back()->with('error', 'Cannot demote the last administrator in the system.');
            }

            $user->update(['role' => UserRole::User]);
            $msg = "User '{$user->name}' demoted to standard user.";
        } else {
            $user->update(['role' => UserRole::Admin]);
            $msg = "User '{$user->name}' promoted to Administrator.";
        }

        return back()->with('success', $msg);
    }

    /**
     * Upgrade a user account to Premium (or a specific paid plan) directly from admin.
     */
    public function upgradePremium(Request $request, User $user): RedirectResponse|JsonResponse
    {
        $validated = $request->validate([
            'plan_id' => 'nullable|string|exists:subscription_plans,id',
            'plan_slug' => 'nullable|string|exists:subscription_plans,slug',
            'duration' => 'nullable|string|in:1_month,3_months,6_months,1_year,lifetime',
            'note' => 'nullable|string|max:500',
        ]);

        // Find selected plan, or fallback to Pro / Premium
        $plan = null;
        if (!empty($validated['plan_id'])) {
            $plan = SubscriptionPlan::find($validated['plan_id']);
        } elseif (!empty($validated['plan_slug'])) {
            $plan = SubscriptionPlan::where('slug', $validated['plan_slug'])->first();
        }

        if (!$plan) {
            $plan = SubscriptionPlan::where('slug', 'pro')->first()
                ?? SubscriptionPlan::where('slug', 'premium')->first()
                ?? SubscriptionPlan::where('slug', '!=', 'free')->first();
        }

        if (!$plan) {
            // Safety fallback: ensure a pro plan exists if not seeded
            $plan = SubscriptionPlan::firstOrCreate(
                ['slug' => 'pro'],
                [
                    'name' => 'Premium',
                    'description' => '100 AI generations, ad-free experience, custom domains with SSL, and all templates.',
                    'price_monthly' => 4.99,
                    'price_annual' => 39.90,
                    'is_active' => true,
                    'sort_order' => 1,
                    'limits' => [
                        'max_websites' => 100,
                        'max_published' => 25,
                        'ai_generations_monthly' => 100,
                        'ai_edits_monthly' => 500,
                        'storage_mb' => 5120,
                        'custom_domains' => 10,
                        'has_ads' => false,
                        'all_templates' => true,
                        'premium_templates' => true,
                        'ssl_enabled' => true,
                        'code_export' => true,
                    ],
                ]
            );
        }

        $duration = $validated['duration'] ?? '1_year';
        $startsAt = now();
        $endsAt = match ($duration) {
            '1_month' => now()->addMonth(),
            '3_months' => now()->addMonths(3),
            '6_months' => now()->addMonths(6),
            'lifetime' => now()->addYears(100),
            default => now()->addYear(),
        };

        $durationLabels = [
            '1_month' => '1 mois',
            '3_months' => '3 mois',
            '6_months' => '6 mois',
            '1_year' => '1 an',
            'lifetime' => 'À vie (Permanent)',
        ];
        $durationLabel = $durationLabels[$duration] ?? '1 an';

        // Update or create active subscription for this user
        Subscription::updateOrCreate(
            ['user_id' => $user->id],
            [
                'plan_id' => $plan->id,
                'status' => SubscriptionStatus::Active,
                'provider' => BillingProvider::Manual,
                'provider_subscription_id' => 'admin_granted_' . Str::random(10),
                'current_period_start' => $startsAt,
                'current_period_end' => $endsAt,
                'cancelled_at' => null,
            ]
        );

        // Record billing customer & event for audit trail
        $customer = BillingCustomer::firstOrCreate(
            ['user_id' => $user->id],
            ['billing_email' => $user->email]
        );

        BillingEvent::create([
            'billing_customer_id' => $customer->id,
            'provider' => BillingProvider::Manual->value,
            'event_type' => 'subscription.admin_upgraded',
            'provider_event_id' => 'admin_sub_' . Str::random(16),
            'payload' => [
                'admin_id' => Auth::id(),
                'admin_email' => Auth::user()?->email,
                'user_id' => $user->id,
                'user_email' => $user->email,
                'plan_id' => $plan->id,
                'plan_slug' => $plan->slug,
                'plan_name' => $plan->name,
                'duration' => $duration,
                'duration_label' => $durationLabel,
                'starts_at' => $startsAt->toIso8601String(),
                'ends_at' => $endsAt->toIso8601String(),
                'note' => $validated['note'] ?? null,
            ],
            'processed' => true,
        ]);

        // Create an in-app notification for the user
        try {
            AppNotification::create([
                'user_id' => $user->id,
                'type' => 'subscription_upgraded',
                'title' => 'Félicitations ! Votre compte est désormais Premium ★',
                'body' => "Votre compte a été surclassé au forfait {$plan->name} ({$durationLabel}). Profitez de la génération IA sans limites, des domaines personnalisés et de tous les modèles exclusifs !",
                'data' => [
                    'plan' => $plan->slug,
                    'plan_name' => $plan->name,
                    'duration' => $duration,
                    'expires_at' => $endsAt->toIso8601String(),
                ],
            ]);
        } catch (\Throwable $e) {
            // Non-critical notification failure should not block upgrade
        }

        $message = "Le compte de '{$user->name}' a été surclassé avec succès en {$plan->name} ({$durationLabel}) !";

        if ($request->wantsJson() || $request->ajax()) {
            return response()->json([
                'success' => true,
                'message' => $message,
                'user' => [
                    'id' => $user->id,
                    'is_premium' => true,
                    'tier' => $user->fresh()->getTierLabel(),
                    'subscription' => [
                        'plan_name' => $plan->name,
                        'status' => 'active',
                        'provider' => 'manual',
                        'current_period_end' => $duration === 'lifetime' ? 'À vie' : $endsAt->format('M d, Y'),
                    ],
                ],
            ]);
        }

        return back()->with('success', $message);
    }

    /**
     * Cancel/downgrade a user's subscription back to Free.
     */
    public function cancelPremium(Request $request, User $user): RedirectResponse|JsonResponse
    {
        $freePlan = SubscriptionPlan::where('slug', 'free')->first();

        $sub = $user->subscription;
        if ($sub) {
            $sub->update([
                'status' => SubscriptionStatus::Cancelled,
                'cancelled_at' => now(),
                'current_period_end' => now(),
                'plan_id' => $freePlan?->id ?? $sub->plan_id,
            ]);
        }

        // Record audit event
        $customer = BillingCustomer::firstOrCreate(
            ['user_id' => $user->id],
            ['billing_email' => $user->email]
        );

        BillingEvent::create([
            'billing_customer_id' => $customer->id,
            'provider' => BillingProvider::Manual->value,
            'event_type' => 'subscription.admin_downgraded',
            'provider_event_id' => 'admin_down_' . Str::random(16),
            'payload' => [
                'admin_id' => Auth::id(),
                'admin_email' => Auth::user()?->email,
                'user_id' => $user->id,
                'user_email' => $user->email,
                'downgraded_at' => now()->toIso8601String(),
            ],
            'processed' => true,
        ]);

        $message = "Le statut Premium de '{$user->name}' a été révoqué. Le compte est maintenant au forfait Gratuit.";

        if ($request->wantsJson() || $request->ajax()) {
            return response()->json([
                'success' => true,
                'message' => $message,
                'user' => [
                    'id' => $user->id,
                    'is_premium' => false,
                    'tier' => 'Free',
                    'subscription' => null,
                ],
            ]);
        }

        return back()->with('success', $message);
    }
}
