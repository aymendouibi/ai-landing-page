<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Feedback;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FeedbackController extends Controller
{
    /**
     * Store new feedback / review sent from mobile app.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category' => ['nullable', 'string', 'max:50'],
            'message' => ['required', 'string', 'min:3', 'max:5000'],
            'rating' => ['nullable', 'integer', 'min:1', 'max:5'],
            'metadata' => ['nullable', 'array'],
        ]);

        $user = $request->user('sanctum');

        $feedback = Feedback::create([
            'user_id' => $user?->id,
            'category' => $validated['category'] ?? 'general',
            'message' => $validated['message'],
            'rating' => $validated['rating'] ?? null,
            'metadata' => array_merge($validated['metadata'] ?? [], [
                'user_email' => $user?->email,
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]),
            'status' => 'new',
        ]);

        return response()->json([
            'message' => 'Feedback submitted successfully.',
            'feedback' => $feedback,
        ], 201);
    }
}
