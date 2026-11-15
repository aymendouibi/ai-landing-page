@extends('layouts.admin')

@section('title', 'Platform Overview')
@section('page_title', 'Admin Dashboard')
@section('breadcrumbs', 'System Overview & Real-Time Metrics')

@section('topbar_actions')
    <a href="{{ route('admin.templates.index') }}" class="px-3.5 py-1.5 text-xs font-bold text-white bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 rounded-lg shadow-md shadow-indigo-600/30 transition flex items-center gap-1.5">
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
        <span>Manage Templates</span>
    </a>
@endsection

@section('content')
    <!-- KPI Metrics Grid -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Users Card -->
        <div class="bg-slate-900/60 border border-slate-800 p-5 rounded-2xl relative overflow-hidden">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Users</span>
                <span class="p-2 rounded-xl bg-blue-500/10 text-blue-400 border border-blue-500/20">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                </span>
            </div>
            <h3 class="text-2xl font-black text-white mt-3">{{ $metrics['total_users'] }}</h3>
            <div class="flex items-center gap-2 mt-1">
                <span class="text-xs text-slate-400">{{ $metrics['total_projects'] }} projects active</span>
            </div>
        </div>

        <!-- Websites Card -->
        <div class="bg-slate-900/60 border border-slate-800 p-5 rounded-2xl relative overflow-hidden">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Websites</span>
                <span class="p-2 rounded-xl bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path></svg>
                </span>
            </div>
            <h3 class="text-2xl font-black text-white mt-3">{{ $metrics['total_websites'] }}</h3>
            <div class="flex items-center gap-2 mt-1">
                <span class="text-[11px] text-emerald-400 font-semibold">{{ $metrics['published_websites'] }} Published</span>
                <span class="text-slate-600">&bull;</span>
                <span class="text-[11px] text-slate-400">{{ $metrics['draft_websites'] }} Drafts</span>
            </div>
        </div>

        <!-- Templates Card -->
        <div class="bg-slate-900/60 border border-slate-800 p-5 rounded-2xl relative overflow-hidden">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Templates</span>
                <span class="p-2 rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                </span>
            </div>
            <h3 class="text-2xl font-black text-white mt-3">{{ $metrics['total_templates'] }}</h3>
            <div class="flex items-center gap-2 mt-1">
                <span class="text-[11px] text-amber-400 font-semibold">{{ $metrics['curated_templates'] }} Curated</span>
                <span class="text-slate-600">&bull;</span>
                <span class="text-[11px] text-purple-400 font-medium">{{ $metrics['total_template_uses'] }} Uses</span>
            </div>
        </div>

        <!-- Deployments Card -->
        <div class="bg-slate-900/60 border border-slate-800 p-5 rounded-2xl relative overflow-hidden">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Deployments</span>
                <span class="p-2 rounded-xl bg-violet-500/10 text-violet-400 border border-violet-500/20">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                </span>
            </div>
            <h3 class="text-2xl font-black text-white mt-3">{{ $metrics['total_deployments'] }}</h3>
            <div class="flex items-center gap-2 mt-1">
                <span class="text-[11px] text-violet-400 font-semibold">{{ $metrics['successful_deployments'] }} Deployed</span>
                <span class="text-slate-600">&bull;</span>
                <span class="text-[11px] text-slate-400">Cloudflare Edge</span>
            </div>
        </div>
    </div>

    <!-- Quick Navigation Hub -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <a href="{{ route('admin.templates.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-indigo-500/10 text-indigo-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white">Templates Studio</p>
                <p class="text-[10px] text-slate-400">Curate & publish designs</p>
            </div>
        </a>

        <a href="{{ route('admin.websites.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-emerald-500/10 text-emerald-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white">User Websites</p>
                <p class="text-[10px] text-slate-400">Subdomains & status</p>
            </div>
        </a>

        <a href="{{ route('admin.users.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-blue-500/10 text-blue-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white">Users & Roles</p>
                <p class="text-[10px] text-slate-400">Access controls & stats</p>
            </div>
        </a>

        <a href="{{ route('admin.system.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-purple-500/10 text-purple-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white">System Health</p>
                <p class="text-[10px] text-slate-400">Node, DB & storage</p>
            </div>
        </a>
    </div>

    <!-- Main Content: Recent Websites & Top Templates -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Recent Websites (2 Columns) -->
        <div class="lg:col-span-2 bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-4">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="text-sm font-bold text-white tracking-tight">Recent Websites</h3>
                    <p class="text-xs text-slate-400">Latest sites created by platform users</p>
                </div>
                <a href="{{ route('admin.websites.index') }}" class="text-xs font-semibold text-indigo-400 hover:text-indigo-300">
                    View all &rarr;
                </a>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="border-b border-slate-800/80 text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
                            <th class="py-2.5 px-3">Website & Subdomain</th>
                            <th class="py-2.5 px-3">Owner</th>
                            <th class="py-2.5 px-3">Status</th>
                            <th class="py-2.5 px-3">Rev</th>
                            <th class="py-2.5 px-3 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-800/50 text-xs">
                        @forelse($recentWebsites as $site)
                            <tr class="hover:bg-slate-800/30 transition">
                                <td class="py-3 px-3">
                                    <div class="font-bold text-white">{{ $site->name }}</div>
                                    <div class="text-[11px] text-slate-400 font-mono">{{ $site->subdomain ?: $site->slug }}</div>
                                </td>
                                <td class="py-3 px-3">
                                    <div class="text-slate-300 font-medium">{{ $site->project?->user?->name ?? 'Unknown' }}</div>
                                    <div class="text-[10px] text-slate-500">{{ $site->project?->user?->email ?? 'N/A' }}</div>
                                </td>
                                <td class="py-3 px-3">
                                    @if($site->status->value === 'published')
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                            ● Published
                                        </span>
                                    @else
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                                            Draft
                                        </span>
                                    @endif
                                </td>
                                <td class="py-3 px-3 text-slate-400 font-mono text-[11px]">
                                    v{{ $site->revision_number ?? 1 }}
                                </td>
                                <td class="py-3 px-3 text-right">
                                    <div class="flex items-center justify-end gap-2">
                                        @if($site->status->value === 'published')
                                            <a href="/sites/{{ $site->subdomain ?: $site->slug }}" target="_blank" class="px-2 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[11px] font-medium transition" title="Preview Live Site">
                                                Preview ↗
                                            </a>
                                        @endif
                                        <form action="{{ route('admin.websites.toggle_status', $site) }}" method="POST" class="inline">
                                            @csrf
                                            <button type="submit" class="px-2 py-1 rounded {{ $site->status->value === 'published' ? 'bg-amber-500/10 text-amber-400 hover:bg-amber-500/20' : 'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20' }} text-[11px] font-semibold transition">
                                                {{ $site->status->value === 'published' ? 'Unpublish' : 'Publish' }}
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="py-6 text-center text-slate-500">No websites created yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Top Templates (1 Column) -->
        <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-4">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="text-sm font-bold text-white tracking-tight">Top Templates</h3>
                    <p class="text-xs text-slate-400">Most cloned starter designs</p>
                </div>
                <a href="{{ route('admin.templates.index') }}" class="text-xs font-semibold text-indigo-400 hover:text-indigo-300">
                    Studio &rarr;
                </a>
            </div>

            <div class="space-y-3">
                @forelse($topTemplates as $tpl)
                    <div class="p-3 rounded-xl bg-slate-950/40 border border-slate-800/80 flex items-center justify-between">
                        <div class="flex items-center gap-3 overflow-hidden">
                            @if(!empty($tpl->preview_images[0]))
                                <img src="{{ $tpl->preview_images[0] }}" alt="{{ $tpl->name }}" class="w-11 h-11 rounded-lg object-cover border border-slate-800 shrink-0">
                            @else
                                <div class="w-11 h-11 rounded-lg bg-indigo-600/20 text-indigo-400 flex items-center justify-center font-bold text-xs shrink-0">
                                    {{ substr($tpl->name, 0, 2) }}
                                </div>
                            @endif
                            <div class="truncate">
                                <h4 class="text-xs font-bold text-white truncate">{{ $tpl->name }}</h4>
                                <p class="text-[10px] text-slate-400 truncate">{{ $tpl->industry ?? 'Design' }} &bull; {{ $tpl->badge ?: 'Curated' }}</p>
                            </div>
                        </div>
                        <div class="text-right shrink-0">
                            <span class="text-xs font-bold text-indigo-400">{{ $tpl->use_count }}</span>
                            <span class="text-[10px] text-slate-500 block">uses</span>
                        </div>
                    </div>
                @empty
                    <p class="text-xs text-slate-500 py-4 text-center">No templates seeded yet.</p>
                @endforelse
            </div>

            <!-- Recent Deployments Feed -->
            <div class="pt-4 border-t border-slate-800/80">
                <div class="flex items-center justify-between mb-3">
                    <h4 class="text-xs font-bold text-white uppercase tracking-wider">Recent Deployments</h4>
                    <a href="{{ route('admin.deployments.index') }}" class="text-[11px] text-slate-400 hover:text-white">Logs &rarr;</a>
                </div>
                <div class="space-y-2">
                    @forelse($recentDeployments as $dep)
                        <div class="flex items-center justify-between text-[11px] p-2 rounded-lg bg-slate-950/30">
                            <span class="text-slate-300 font-medium truncate max-w-[140px]">{{ $dep->website?->name ?? 'Website' }}</span>
                            <span class="px-1.5 py-0.5 rounded text-[10px] font-semibold {{ $dep->status->value === 'deployed' ? 'bg-emerald-500/10 text-emerald-400' : 'bg-amber-500/10 text-amber-400' }}">
                                {{ ucfirst($dep->status->value) }}
                            </span>
                        </div>
                    @empty
                        <p class="text-[11px] text-slate-500 text-center py-2">No deployments yet.</p>
                    @endforelse
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Users Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-4">
        <div class="flex items-center justify-between">
            <div>
                <h3 class="text-sm font-bold text-white tracking-tight">Recent Registered Users</h3>
                <p class="text-xs text-slate-400">Platform creators and administrators</p>
            </div>
            <a href="{{ route('admin.users.index') }}" class="text-xs font-semibold text-indigo-400 hover:text-indigo-300">
                All Users &rarr;
            </a>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="border-b border-slate-800/80 text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
                        <th class="py-2.5 px-3">User</th>
                        <th class="py-2.5 px-3">Role</th>
                        <th class="py-2.5 px-3">Projects</th>
                        <th class="py-2.5 px-3">Joined Date</th>
                        <th class="py-2.5 px-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/50 text-xs">
                    @forelse($recentUsers as $usr)
                        <tr class="hover:bg-slate-800/30 transition">
                            <td class="py-3 px-3">
                                <div class="font-bold text-white">{{ $usr->name }}</div>
                                <div class="text-[11px] text-slate-400">{{ $usr->email }}</div>
                            </td>
                            <td class="py-3 px-3">
                                @if($usr->role->value === 'admin')
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
                                        ★ Admin
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-800 text-slate-300">
                                        Creator
                                    </span>
                                @endif
                            </td>
                            <td class="py-3 px-3 text-slate-300 font-semibold">
                                {{ $usr->projects_count }} projects
                            </td>
                            <td class="py-3 px-3 text-slate-400 text-[11px]">
                                {{ $usr->created_at->diffForHumans() }}
                            </td>
                            <td class="py-3 px-3 text-right">
                                <form action="{{ route('admin.users.toggle_role', $usr) }}" method="POST" class="inline">
                                    @csrf
                                    <button type="submit" class="px-2.5 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[11px] font-medium transition">
                                        {{ $usr->role->value === 'admin' ? 'Demote to User' : 'Promote to Admin' }}
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="py-6 text-center text-slate-500">No users found.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection

