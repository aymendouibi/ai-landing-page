<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(
        protected NotificationService $notificationService
    ) {}

    /**
     * Get list of notifications for the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $notifications = AppNotification::forUser($user?->id)
            ->latest()
            ->paginate($request->integer('per_page', 25));

        $unreadCount = AppNotification::forUser($user?->id)
            ->unread()
            ->count();

        return response()->json([
            'data' => $notifications->items(),
            'unread_count' => $unreadCount,
            'current_page' => $notifications->currentPage(),
            'last_page' => $notifications->lastPage(),
            'total' => $notifications->total(),
            'locale' => $this->notificationService->resolveUserLocale($user),
        ]);
    }

    /**
     * Mark a single notification as read.
     */
    public function markAsRead(string $id, Request $request): JsonResponse
    {
        $user = $request->user();

        $notification = AppNotification::forUser($user?->id)
            ->where('id', $id)
            ->firstOrFail();

        $notification->markAsRead();

        return response()->json([
            'message' => 'Notification marked as read.',
            'notification' => $notification->fresh(),
        ]);
    }

    /**
     * Mark all notifications as read.
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();

        AppNotification::forUser($user?->id)
            ->unread()
            ->update(['read_at' => now()]);

        return response()->json([
            'message' => 'All notifications marked as read.',
            'unread_count' => 0,
        ]);
    }

    /**
     * Delete a notification.
     */
    public function destroy(string $id, Request $request): JsonResponse
    {
        $user = $request->user();

        $notification = AppNotification::forUser($user?->id)
            ->where('id', $id)
            ->firstOrFail();

        $notification->delete();

        return response()->json([
            'message' => 'Notification deleted successfully.',
        ]);
    }

    /**
     * Update user device & language/theme notification preferences.
     */
    public function updatePreferences(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'locale' => ['nullable', 'string', 'max:10'],
            'theme_mode' => ['nullable', 'string', 'in:system,dark,light'],
            'device_token' => ['nullable', 'string', 'max:500'],
        ]);

        $user = $request->user();
        if ($user) {
            $prefs = $user->preferences ?? [];

            if (!empty($validated['locale'])) {
                $prefs['locale'] = $validated['locale'];
            }
            if (!empty($validated['theme_mode'])) {
                $prefs['theme_mode'] = $validated['theme_mode'];
            }
            if (!empty($validated['device_token'])) {
                $prefs['device_token'] = $validated['device_token'];
            }

            $user->update(['preferences' => $prefs]);
        }

        return response()->json([
            'message' => 'Notification preferences updated.',
            'preferences' => $user?->preferences ?? [],
            'resolved_locale' => $this->notificationService->resolveUserLocale($user),
        ]);
    }
}
