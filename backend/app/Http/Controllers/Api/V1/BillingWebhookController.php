<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Billing\BillingService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class BillingWebhookController extends Controller
{
    public function __construct(
        protected BillingService $billingService
    ) {}

    /**
     * Handle incoming Stripe webhook notifications.
     */
    public function stripe(Request $request): JsonResponse
    {
        $payload = $request->all();
        $signature = $request->header('Stripe-Signature');

        try {
            $result = $this->billingService->handleStripeWebhook($payload);
            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Stripe webhook processing error: ' . $e->getMessage(), ['payload' => $payload]);
            \App\Models\AppErrorLog::logPaymentError(
                'Stripe webhook processing exception: ' . $e->getMessage(),
                ['payload' => $payload],
                null,
                $e
            );
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Handle incoming RevenueCat webhook notifications.
     */
    public function revenuecat(Request $request): JsonResponse
    {
        $expectedAuth = config('services.revenuecat.webhook_authorization');
        $authHeader = $request->header('Authorization');

        if (!empty($expectedAuth) && $authHeader !== $expectedAuth) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $payload = $request->all();

        try {
            $result = $this->billingService->handleRevenueCatWebhook($payload);
            return response()->json($result);
        } catch (Exception $e) {
            Log::error('RevenueCat webhook processing error: ' . $e->getMessage(), ['payload' => $payload]);
            \App\Models\AppErrorLog::logPaymentError(
                'RevenueCat webhook processing exception: ' . $e->getMessage(),
                ['payload' => $payload],
                null,
                $e
            );
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}

