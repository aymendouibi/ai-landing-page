<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\JsonResponse;

class SubscriptionLimitExceededException extends Exception
{
    public function __construct(
        string $message,
        protected string $metric,
        protected int $limit,
        protected int $current,
        protected string $suggestedPlan = 'pro'
    ) {
        parent::__construct($message, 403);
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'error' => 'subscription_limit_exceeded',
            'message' => $this->getMessage(),
            'entitlement' => [
                'metric' => $this->metric,
                'limit' => $this->limit,
                'current' => $this->current,
                'upgrade_required' => true,
                'suggested_plan' => $this->suggestedPlan,
            ],
        ], 403);
    }
}
