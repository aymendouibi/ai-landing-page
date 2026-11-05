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
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}

