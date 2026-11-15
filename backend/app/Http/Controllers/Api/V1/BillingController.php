<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use App\Services\Billing\BillingService;
use App\Services\Billing\SubscriptionEntitlementService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BillingController extends Controller
{
    public function __construct(
        protected BillingService $billingService,
        protected SubscriptionEntitlementService $entitlementService
    ) {}

    /**
     * List all available subscription plans.
     */
    public function plans(): JsonResponse
    {
        $plans = SubscriptionPlan::where('is_active', true)
            ->orderBy('sort_order')
            ->get();

        return response()->json(['plans' => $plans]);
    }

    /**
     * Get current user's subscription, limits, and real-time usage summary.
     */
    public function subscription(Request $request): JsonResponse
    {
        $user = $request->user();
        $summary = $this->entitlementService->getSummary($user);

        return response()->json($summary);
    }

    /**
     * Create Stripe checkout session for web subscription.
     */
    public function checkout(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'plan_slug' => ['required', 'string', 'exists:subscription_plans,slug'],
            'interval' => ['nullable', 'string', 'in:monthly,annual'],
        ]);

        $plan = SubscriptionPlan::where('slug', $validated['plan_slug'])->firstOrFail();

        try {
            $session = $this->billingService->createStripeCheckoutSession(
                user: $request->user(),
                plan: $plan,
                interval: $validated['interval'] ?? 'monthly'
            );

            return response()->json($session);
        } catch (Exception $e) {
            return response()->json(['message' => 'Checkout failed: ' . $e->getMessage()], 422);
        }
    }

    /**
     * Create Stripe billing portal session.
     */
    public function portal(Request $request): JsonResponse
    {
        try {
            $portal = $this->billingService->createStripePortalSession($request->user());
            return response()->json($portal);
        } catch (Exception $e) {
            return response()->json(['message' => 'Portal creation failed: ' . $e->getMessage()], 422);
        }
    }

    /**
     * Create Stripe PaymentIntent for native mobile app PaymentSheet.
     */
    public function paymentIntent(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'interval' => ['nullable', 'string', 'in:monthly,yearly,annual'],
        ]);

        try {
            $intent = $this->billingService->createStripePaymentIntent(
                user: $request->user(),
                interval: $validated['interval'] ?? 'monthly'
            );

            return response()->json($intent);
        } catch (Exception $e) {
            return response()->json(['message' => 'Payment intent creation failed: ' . $e->getMessage()], 422);
        }
    }

    /**
     * Subscribe or switch plan directly (in-app subscription / plan switch).
     */
    public function subscribe(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'plan_slug' => ['required', 'string', 'in:free,pro'],
            'interval' => ['nullable', 'string', 'in:monthly,yearly,annual'],
            'provider' => ['nullable', 'string', 'in:stripe,google_play,in_app,manual'],
            'payment_intent_id' => ['nullable', 'string', 'max:255'],
        ]);

        $user = $request->user();
        $plan = SubscriptionPlan::where('slug', $validated['plan_slug'])->firstOrFail();
        $interval = $validated['interval'] ?? 'monthly';
        $providerName = $validated['provider'] ?? (!empty($validated['payment_intent_id']) ? 'stripe' : 'in_app');
        $providerEnum = \App\Enums\BillingProvider::tryFrom($providerName) ?? \App\Enums\BillingProvider::InApp;

        if ($plan->slug === 'free') {
            $user->subscription()?->update([
                'status' => \App\Enums\SubscriptionStatus::Cancelled,
                'cancelled_at' => now(),
            ]);
        } else {
            $periodEnd = ($interval === 'yearly' || $interval === 'annual')
                ? now()->addYear()
                : now()->addMonth();

            \App\Models\Subscription::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'plan_id' => $plan->id,
                    'status' => \App\Enums\SubscriptionStatus::Active,
                    'provider' => $providerEnum,
                    'provider_subscription_id' => $validated['payment_intent_id'] ?? null,
                    'current_period_start' => now(),
                    'current_period_end' => $periodEnd,
                    'cancelled_at' => null,
                ]
            );

            // Record BillingEvent for this user
            $customer = $this->billingService->getOrCreateStripeCustomer($user);
            \App\Models\BillingEvent::create([
                'billing_customer_id' => $customer->id,
                'provider' => $providerEnum->value,
                'event_type' => 'subscription.activated',
                'provider_event_id' => $validated['payment_intent_id'] ?? ('sub_direct_' . \Illuminate\Support\Str::random(16)),
                'payload' => [
                    'plan' => $plan->slug,
                    'interval' => $interval,
                    'payment_intent_id' => $validated['payment_intent_id'] ?? null,
                    'activated_at' => now()->toIso8601String(),
                ],
                'processed' => true,
            ]);
        }

        return response()->json([
            'message' => "Successfully switched to {$plan->name} plan.",
            'summary' => $this->entitlementService->getSummary($user),
        ]);
    }

    /**
     * Verify Google Play Billing purchase token from Android app.
     */
    public function verifyGooglePlay(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => ['required', 'string', 'max:255'],
            'purchase_token' => ['required', 'string', 'max:2000'],
        ]);

        try {
            $subscription = $this->billingService->verifyGooglePlayPurchase(
                user: $request->user(),
                productId: $validated['product_id'],
                purchaseToken: $validated['purchase_token']
            );

            return response()->json([
                'message' => 'Google Play subscription verified and active.',
                'subscription' => $subscription->load('plan'),
            ]);
        } catch (Exception $e) {
            return response()->json(['message' => 'Verification failed: ' . $e->getMessage()], 422);
        }
    }

    /**
     * Get complete billing and payment history for authenticated user.
     */
    public function history(Request $request): JsonResponse
    {
        $history = $this->billingService->getUserBillingHistory($request->user());

        return response()->json([
            'history' => $history,
        ]);
    }
}

