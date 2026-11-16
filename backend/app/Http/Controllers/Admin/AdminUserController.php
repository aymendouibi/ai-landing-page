<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
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

        return view('admin.users', [
            'users' => $users,
            'metrics' => $metrics,
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
                        'status' => $user->subscription->status->value,
                        'provider' => $user->subscription->provider->value ?? 'stripe',
                        'current_period_start' => $user->subscription->current_period_start?->format('M d, Y'),
                        'current_period_end' => $user->subscription->current_period_end?->format('M d, Y'),
                    ] : null,
                ],
                'websites' => $websites,
            ]);
        }

        return view('admin.user_show', [
            'user' => $user,
            'websites' => $websites,
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
}
