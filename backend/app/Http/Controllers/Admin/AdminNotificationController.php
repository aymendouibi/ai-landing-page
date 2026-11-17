<?php

namespace App\Http\Controllers\Admin;

use App\Enums\WebsiteStatus;
use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\User;
use App\Models\Website;
use App\Services\NotificationService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminNotificationController extends Controller
{
    public function __construct(
        protected NotificationService $notificationService
    ) {}

    /**
     * Display notifications center & history.
     */
    public function index(Request $request): View
    {
        $query = AppNotification::with('user')->latest();

        if ($request->filled('type')) {
            $query->where('type', $request->input('type'));
        }

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'ilike', "%{$search}%")
                  ->orWhere('body', 'ilike', "%{$search}%");
            });
        }

        $notifications = $query->paginate(20)->withQueryString();

        $stats = [
            'total' => AppNotification::count(),
            'unread' => AppNotification::unread()->count(),
            'sent_today' => AppNotification::where('created_at', '>=', now()->startOfDay())->count(),
            'draft_users_count' => Website::where('status', WebsiteStatus::Draft)
                ->whereNotNull('project_id')
                ->distinct('project_id')
                ->count(),
        ];

        $users = User::select(['id', 'name', 'email'])->orderBy('name')->limit(100)->get();

        return view('admin.notifications', compact('notifications', 'stats', 'users'));
    }

    /**
     * Send notification from the Admin Dashboard.
     */
    public function send(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'target' => ['required', 'string', 'in:all,specific,drafts'],
            'user_id' => ['nullable', 'uuid', 'exists:users,id'],
            'title' => ['required', 'string', 'max:200'],
            'body' => ['required', 'string', 'max:2000'],
            'url' => ['nullable', 'string', 'max:500'],
            'locale' => ['nullable', 'string', 'in:auto,en,es,fr,de,ar,zh,ja,pt'],
            'type' => ['nullable', 'string', 'in:admin_broadcast,draft_reminder,ai_modification,site_live'],
        ]);

        $locale = ($validated['locale'] ?? 'auto') === 'auto' ? null : $validated['locale'];
        $type = $validated['type'] ?? 'admin_broadcast';

        if ($validated['target'] === 'drafts') {
            $sentCount = $this->notificationService->sendDraftRemindersToAll(0);
            return back()->with('success', "Draft reminder campaign sent to {$sentCount} user(s) in their preferred languages!");
        }

        if ($validated['target'] === 'specific') {
            if (empty($validated['user_id'])) {
                return back()->with('error', 'Please select a recipient user.')->withInput();
            }

            $user = User::findOrFail($validated['user_id']);
            $this->notificationService->sendAdminNotification(
                title: $validated['title'],
                body: $validated['body'],
                targetUserId: $user->id,
                url: $validated['url'] ?? null,
                locale: $locale,
                type: $type
            );

            return back()->with('success', "Notification sent successfully to {$user->name} ({$user->email})!");
        }

        // Broadcast to all users
        $created = $this->notificationService->sendAdminNotification(
            title: $validated['title'],
            body: $validated['body'],
            targetUserId: null,
            url: $validated['url'] ?? null,
            locale: $locale,
            type: $type
        );

        $count = $created->count();
        return back()->with('success', "Broadcast notification sent to all active users ({$count} delivered)!");
    }

    /**
     * Quick trigger to send draft reminders to all users with draft websites.
     */
    public function triggerDraftReminders(): RedirectResponse
    {
        $sentCount = $this->notificationService->sendDraftRemindersToAll(0);
        return back()->with('success', "Draft reminder sent to {$sentCount} creator(s) with unpublished websites!");
    }

    /**
     * Delete notification from history.
     */
    public function destroy(AppNotification $notification): RedirectResponse
    {
        $notification->delete();
        return back()->with('success', 'Notification removed from log.');
    }
}
