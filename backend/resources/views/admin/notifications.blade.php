@extends('layouts.admin')

@section('title', 'Notifications Center')
@section('page_title', 'Notifications Center')
@section('breadcrumbs', 'Send and monitor push & in-app notifications in users\' selected languages')

@section('content')
    <!-- Flash Messages -->
    @if(session('success'))
        <div class="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold flex items-center justify-between">
            <div class="flex items-center gap-2">
                <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                <span>{{ session('success') }}</span>
            </div>
        </div>
    @endif
    @if(session('error'))
        <div class="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs font-semibold flex items-center justify-between">
            <div class="flex items-center gap-2">
                <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                <span>{{ session('error') }}</span>
            </div>
        </div>
    @endif

    <!-- KPI Metrics Grid -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Sent</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ number_format($stats['total']) }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">All time notifications</p>
        </div>

        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-amber-400 uppercase tracking-wider">Unread by Users</p>
            <h3 class="text-2xl font-black text-white mt-1 flex items-center gap-2">
                {{ number_format($stats['unread']) }}
                @if($stats['unread'] > 0)
                    <span class="inline-block w-2.5 h-2.5 rounded-full bg-amber-400 animate-pulse"></span>
                @endif
            </h3>
            <p class="text-[11px] text-amber-400/80 mt-1">Awaiting open on mobile</p>
        </div>

        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-indigo-400 uppercase tracking-wider">Sent Today</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ number_format($stats['sent_today']) }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Activity past 24 hours</p>
        </div>

        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-cyan-400 uppercase tracking-wider">Users with Drafts</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ number_format($stats['draft_users_count']) }}</h3>
            <p class="text-[11px] text-cyan-400/80 mt-1">Eligible for draft reminders</p>
        </div>
    </div>

    <!-- Quick Action / Compose Card -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 shadow-xl">
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between pb-4 border-b border-slate-800 gap-3">
            <div>
                <h3 class="text-base font-bold text-white flex items-center gap-2">
                    <svg class="w-5 h-5 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path></svg>
                    Send Notification from Dashboard
                </h3>
                <p class="text-xs text-slate-400 mt-0.5">Broadcast updates, feature alerts, or remind users to finish their draft sites in their preferred language</p>
            </div>

            <!-- 1-Click Draft Reminder Button -->
            <form action="{{ route('admin.notifications.remind_drafts') }}" method="POST" onsubmit="return confirm('Send automated draft reminders to all users with unpublished websites? Each user receives the notification in their phone\'s language.');">
                @csrf
                <button type="submit" class="px-4 py-2 bg-gradient-to-r from-cyan-600 to-indigo-600 hover:from-cyan-500 hover:to-indigo-500 text-white rounded-xl text-xs font-bold transition shadow-lg shadow-cyan-600/20 flex items-center gap-2">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    <span>⚡ Remind Users with Drafts</span>
                </button>
            </form>
        </div>

        <!-- Compose Form -->
        <form action="{{ route('admin.notifications.send') }}" method="POST" class="mt-4 space-y-4">
            @csrf

            <!-- Quick Template Chips -->
            <div>
                <label class="block text-[11px] font-semibold text-slate-400 uppercase tracking-wider mb-1.5">Quick Templates</label>
                <div class="flex flex-wrap gap-2">
                    <button type="button" onclick="setTemplate('draft')" class="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-lg text-xs font-medium transition border border-slate-700/60">
                        📝 Draft Reminder
                    </button>
                    <button type="button" onclick="setTemplate('ai_update')" class="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-lg text-xs font-medium transition border border-slate-700/60">
                        ✨ AI Feature Update
                    </button>
                    <button type="button" onclick="setTemplate('pro_discount')" class="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-lg text-xs font-medium transition border border-slate-700/60">
                        💎 Pro Upgrade Offer
                    </button>
                    <button type="button" onclick="setTemplate('announcement')" class="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-lg text-xs font-medium transition border border-slate-700/60">
                        📢 Platform Announcement
                    </button>
                </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <!-- Target Recipient -->
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Audience Target</label>
                    <select name="target" id="targetSelect" onchange="toggleUserSelect()" class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl px-3 py-2 text-xs text-white focus:outline-none transition">
                        <option value="all">📢 All Users (Broadcast)</option>
                        <option value="drafts">📝 Users with Unpublished Draft Sites</option>
                        <option value="specific">👤 Specific User</option>
                    </select>
                </div>

                <!-- Specific User Select (Hidden by default) -->
                <div id="userSelectWrapper" class="hidden">
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Select User</label>
                    <select name="user_id" class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl px-3 py-2 text-xs text-white focus:outline-none transition">
                        <option value="">-- Choose User --</option>
                        @foreach($users as $user)
                            <option value="{{ $user->id }}">{{ $user->name }} ({{ $user->email }})</option>
                        @endforeach
                    </select>
                </div>

                <!-- Language Selection -->
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Delivery Language</label>
                    <select name="locale" class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl px-3 py-2 text-xs text-white focus:outline-none transition">
                        <option value="auto">🌐 Auto (User's Phone / Selected Language)</option>
                        <option value="en">🇺🇸 English</option>
                        <option value="fr">🇫🇷 Français</option>
                        <option value="es">🇪🇸 Español</option>
                        <option value="de">🇩🇪 Deutsch</option>
                        <option value="ar">🇸🇦 العربية</option>
                        <option value="zh">🇨🇳 中文</option>
                        <option value="ja">🇯🇵 日本語</option>
                        <option value="pt">🇧🇷 Português</option>
                    </select>
                </div>

                <!-- Notification Type -->
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Category</label>
                    <select name="type" class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl px-3 py-2 text-xs text-white focus:outline-none transition">
                        <option value="admin_broadcast">📢 Announcement</option>
                        <option value="draft_reminder">📝 Draft Reminder</option>
                        <option value="ai_modification">✨ AI Modification</option>
                        <option value="site_live">🚀 Site Live</option>
                    </select>
                </div>
            </div>

            <!-- Title & Action URL -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Notification Title</label>
                    <input type="text" name="title" id="notifTitle" required placeholder="e.g. Complete your website today!" class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl px-3.5 py-2 text-xs text-white focus:outline-none transition placeholder-slate-600">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Action Link / URL (Optional)</label>
                    <input type="text" name="url" id="notifUrl" placeholder="e.g. https://... or leave empty" class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl px-3.5 py-2 text-xs text-white focus:outline-none transition placeholder-slate-600">
                </div>
            </div>

            <!-- Notification Body -->
            <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1.5">Message Content</label>
                <textarea name="body" id="notifBody" rows="3" required placeholder="Type your notification message here..." class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl p-3 text-xs text-white focus:outline-none transition placeholder-slate-600"></textarea>
            </div>

            <!-- Submit Button -->
            <div class="flex justify-end">
                <button type="submit" class="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl text-xs font-bold transition shadow-lg shadow-indigo-600/30 flex items-center gap-2">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path></svg>
                    <span>Send Notification</span>
                </button>
            </div>
        </form>
    </div>

    <!-- Notifications History Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="p-4 border-b border-slate-800 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
            <div>
                <h3 class="text-sm font-bold text-white">Sent Notifications Log</h3>
                <p class="text-xs text-slate-400 mt-0.5">Real-time status of notifications dispatched across web and mobile clients</p>
            </div>

            <!-- Type Filter -->
            <div class="flex items-center gap-2">
                <a href="{{ route('admin.notifications.index') }}" class="px-3 py-1 rounded-lg text-xs font-semibold transition {{ !request('type') ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/60' }}">All</a>
                <a href="{{ route('admin.notifications.index', ['type' => 'ai_modification']) }}" class="px-3 py-1 rounded-lg text-xs font-semibold transition {{ request('type') === 'ai_modification' ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/60' }}">AI Edits</a>
                <a href="{{ route('admin.notifications.index', ['type' => 'site_live']) }}" class="px-3 py-1 rounded-lg text-xs font-semibold transition {{ request('type') === 'site_live' ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/60' }}">Site Live</a>
                <a href="{{ route('admin.notifications.index', ['type' => 'draft_reminder']) }}" class="px-3 py-1 rounded-lg text-xs font-semibold transition {{ request('type') === 'draft_reminder' ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/60' }}">Draft Reminders</a>
                <a href="{{ route('admin.notifications.index', ['type' => 'admin_broadcast']) }}" class="px-3 py-1 rounded-lg text-xs font-semibold transition {{ request('type') === 'admin_broadcast' ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/60' }}">Broadcasts</a>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3 px-4">Recipient</th>
                        <th class="py-3 px-4">Type</th>
                        <th class="py-3 px-4">Title & Message</th>
                        <th class="py-3 px-4">Lang</th>
                        <th class="py-3 px-4">Status</th>
                        <th class="py-3 px-4">Sent At</th>
                        <th class="py-3 px-4 text-right">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($notifications as $notif)
                        <tr class="hover:bg-slate-800/30 transition">
                            <td class="py-3 px-4">
                                @if($notif->user)
                                    <div class="flex items-center gap-2">
                                        <div class="w-7 h-7 rounded-full bg-slate-800 border border-slate-700 flex items-center justify-center font-bold text-white text-[10px]">
                                            {{ strtoupper(substr($notif->user->name ?? 'U', 0, 2)) }}
                                        </div>
                                        <div>
                                            <p class="font-semibold text-white">{{ $notif->user->name }}</p>
                                            <p class="text-[10px] text-slate-400">{{ $notif->user->email }}</p>
                                        </div>
                                    </div>
                                @else
                                    <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
                                        <span>📢 All Users (Broadcast)</span>
                                    </span>
                                @endif
                            </td>
                            <td class="py-3 px-4">
                                @switch($notif->type)
                                    @case('ai_modification')
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-purple-500/20 text-purple-300 border border-purple-500/30">✨ AI Edit</span>
                                        @break
                                    @case('site_live')
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">🚀 Site Live</span>
                                        @break
                                    @case('draft_reminder')
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-cyan-500/20 text-cyan-300 border border-cyan-500/30">📝 Draft Reminder</span>
                                        @break
                                    @default
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-500/20 text-amber-300 border border-amber-500/30">📢 Admin</span>
                                @endswitch
                            </td>
                            <td class="py-3 px-4 max-w-xs">
                                <p class="font-semibold text-white truncate">{{ $notif->title }}</p>
                                <p class="text-slate-400 text-[11px] line-clamp-1 mt-0.5">{{ $notif->body }}</p>
                                @if(!empty($notif->data['url']))
                                    <a href="{{ $notif->data['url'] }}" target="_blank" class="text-[10px] text-indigo-400 hover:underline mt-0.5 block truncate">{{ $notif->data['url'] }}</a>
                                @endif
                            </td>
                            <td class="py-3 px-4">
                                <span class="px-1.5 py-0.5 rounded bg-slate-800 text-slate-300 text-[10px] font-mono uppercase">{{ $notif->locale ?: 'en' }}</span>
                            </td>
                            <td class="py-3 px-4">
                                @if($notif->read_at)
                                    <span class="inline-flex items-center gap-1 text-[10px] text-emerald-400 font-medium">
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                        Read
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 text-[10px] text-amber-400 font-medium">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-400"></span>
                                        Unread
                                    </span>
                                @endif
                            </td>
                            <td class="py-3 px-4 text-slate-400 text-[11px] whitespace-nowrap">
                                {{ $notif->created_at->diffForHumans() }}
                            </td>
                            <td class="py-3 px-4 text-right">
                                <form action="{{ route('admin.notifications.destroy', $notif) }}" method="POST" onsubmit="return confirm('Remove notification log?');" class="inline-block">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="p-1 rounded-lg text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 transition" title="Delete">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="py-12 text-center text-slate-500 text-xs">
                                No notifications dispatched yet. Use the composer above to send notifications to users.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($notifications->hasPages())
            <div class="p-4 border-t border-slate-800">
                {{ $notifications->links() }}
            </div>
        @endif
    </div>

    <script>
        function toggleUserSelect() {
            const target = document.getElementById('targetSelect').value;
            const wrapper = document.getElementById('userSelectWrapper');
            if (target === 'specific') {
                wrapper.classList.remove('hidden');
            } else {
                wrapper.classList.add('hidden');
            }
        }

        function setTemplate(type) {
            const titleInput = document.getElementById('notifTitle');
            const bodyInput = document.getElementById('notifBody');

            switch(type) {
                case 'draft':
                    titleInput.value = "Complete your website 📝";
                    bodyInput.value = "Don't forget to complete your website draft! Your online presence is just a few clicks away from going live.";
                    break;
                case 'ai_update':
                    titleInput.value = "New AI Capabilities Available ✨";
                    bodyInput.value = "We just upgraded our AI website generator with smarter section layouts, faster generation, and improved color schemes.";
                    break;
                case 'pro_discount':
                    titleInput.value = "Unlock Pro: Unlimited AI Generations 💎";
                    bodyInput.value = "Upgrade to Pro today for custom domain hosting, priority AI model access, and unlimited website revisions.";
                    break;
                case 'announcement':
                    titleInput.value = "Platform Update 📢";
                    bodyInput.value = "Exciting news! We have added new responsive editor controls and instant publishing improvements.";
                    break;
            }
        }
    </script>
@endsection
