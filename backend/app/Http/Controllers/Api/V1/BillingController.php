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
}

