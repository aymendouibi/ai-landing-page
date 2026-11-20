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
    <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        <a href="{{ route('admin.users.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-violet-500/10 text-violet-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white flex items-center gap-1">
                    <span>Créateurs</span>
                    <span class="text-[9px] px-1 rounded bg-violet-600 text-white font-black">PRO</span>
                </p>
                <p class="text-[10px] text-slate-400">Profils & pages créées</p>
            </div>
        </a>

        <a href="{{ route('admin.feedback.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-amber-500/10 text-amber-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white flex items-center gap-1.5">
                    <span>Avis Mobiles</span>
                    @php $nbFb = \App\Models\Feedback::where('status', 'new')->count(); @endphp
                    @if($nbFb > 0)
                        <span class="px-1.5 rounded-full bg-amber-500 text-slate-950 text-[9px] font-black">{{ $nbFb }}</span>
                    @endif
                </p>
                <p class="text-[10px] text-slate-400">Retours & avis clients</p>
            </div>
        </a>

        <a href="{{ route('admin.ai_settings.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-cyan-500/10 text-cyan-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white">Modèle OpenRouter</p>
                <p class="text-[10px] text-slate-400">Changer l'IA de l'app</p>
            </div>
        </a>

        <a href="{{ route('admin.logs.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-rose-500/10 text-rose-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white flex items-center gap-1.5">
                    <span>Logs Erreurs</span>
                    @php $nbLogs = \App\Models\AppErrorLog::whereNull('resolved_at')->count(); @endphp
                    @if($nbLogs > 0)
                        <span class="px-1.5 rounded-full bg-rose-500 text-white text-[9px] font-black">{{ $nbLogs }}</span>
                    @endif
                </p>
                <p class="text-[10px] text-slate-400">Paiements & pipeline</p>
            </div>
        </a>

        <a href="{{ route('admin.templates.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-indigo-500/10 text-indigo-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white">Templates</p>
                <p class="text-[10px] text-slate-400">Catalogue & styles</p>
            </div>
        </a>

        <a href="{{ route('admin.websites.index') }}" class="p-3.5 bg-slate-900/40 hover:bg-slate-800/60 border border-slate-800 rounded-xl transition flex items-center gap-3">
            <div class="p-2 rounded-lg bg-emerald-500/10 text-emerald-400">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-white">Sites Web</p>
                <p class="text-[10px] text-slate-400">Tous les sous-domaines</p>
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
                        <th class="py-2.5 px-3">Statut / Plan</th>
                        <th class="py-2.5 px-3">Projects</th>
                        <th class="py-2.5 px-3">Joined Date</th>
                        <th class="py-2.5 px-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/50 text-xs">
                    @forelse($recentUsers as $usr)
                        <tr class="hover:bg-slate-800/30 transition">
                            <td class="py-3 px-3">
                                <div class="font-bold text-white flex items-center gap-1.5">
                                    <span>{{ $usr->name }}</span>
                                    @if($usr->isPremium())
                                        <span class="text-[9px] font-black uppercase px-1 rounded bg-violet-600 text-white">PRO</span>
                                    @endif
                                </div>
                                <div class="text-[11px] text-slate-400">{{ $usr->email }}</div>
                            </td>
                            <td class="py-3 px-3">
                                @if($usr->isPremium())
                                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-black bg-gradient-to-r from-violet-600/20 to-indigo-600/20 text-violet-300 border border-violet-500/40">
                                        <span class="w-1.5 h-1.5 rounded-full bg-violet-400 animate-pulse"></span>
                                        ★ {{ $usr->subscription?->plan?->name ?? 'Premium' }}
                                    </span>
                                @elseif($usr->role->value === 'admin')
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
                                        Admin
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-800 text-slate-400">
                                        Gratuit
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
                                <div class="flex items-center justify-end gap-1.5">
                                    @if(!$usr->isPremium())
                                        <button type="button" onclick="openDashboardUpgradeModal('{{ $usr->id }}', '{{ addslashes($usr->name) }}', '{{ addslashes($usr->email) }}')" class="px-2.5 py-1 rounded bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-[10px] font-black shadow-sm shadow-violet-500/20 transition flex items-center gap-1" title="Surclasser ce compte en Premium">
                                            <svg class="w-3 h-3 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                                            <span>★ Upgrade</span>
                                        </button>
                                    @else
                                        <span class="px-2 py-0.5 rounded bg-violet-600/10 text-violet-400 text-[10px] font-bold border border-violet-500/20">
                                            Actif
                                        </span>
                                    @endif

                                    <a href="{{ route('admin.users.show', $usr) }}" class="px-2.5 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[10px] font-semibold transition">
                                        Profil
                                    </a>
                                </div>
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

    <!-- Quick Upgrade Modal for Dashboard -->
    <div id="dashboardUpgradeModal" class="fixed inset-0 z-50 hidden bg-black/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 transition-all">
        <div class="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-lg shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <div class="p-6 border-b border-slate-800 bg-gradient-to-r from-violet-950/40 via-slate-900 to-indigo-950/40 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-2xl bg-gradient-to-tr from-violet-600 to-indigo-500 text-white flex items-center justify-center shadow-lg shadow-violet-500/30">
                        <svg class="w-5 h-5 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                    </div>
                    <div>
                        <h2 class="text-base font-black text-white">Surclasser en Premium ★</h2>
                        <p class="text-xs text-slate-400">Activer les privilèges créateur et quotas illimités</p>
                    </div>
                </div>
                <button type="button" onclick="closeDashboardUpgradeModal()" class="w-8 h-8 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white flex items-center justify-center transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>

            <form id="dashUpgradeForm" action="" method="POST" class="p-6 space-y-4">
                @csrf
                <div class="p-3.5 rounded-2xl bg-slate-950/60 border border-slate-800 flex items-center justify-between">
                    <div>
                        <span class="text-[10px] font-semibold text-slate-500 uppercase tracking-wider block">Compte Cible</span>
                        <h4 id="dashUpgradeUserName" class="text-sm font-bold text-white mt-0.5">...</h4>
                        <p id="dashUpgradeUserEmail" class="text-[11px] text-slate-400 font-mono">...</p>
                    </div>
                    <div>
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-slate-800 text-slate-400">Gratuit</span>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2">Choisir le Forfait</label>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                        @foreach($plans as $p)
                            <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-3 rounded-xl flex items-start gap-2.5 transition">
                                <input type="radio" name="plan_slug" value="{{ $p->slug }}" {{ $loop->first ? 'checked' : '' }} class="mt-1 text-violet-600 focus:ring-violet-500">
                                <div class="text-xs">
                                    <div class="font-bold text-white flex items-center gap-1">
                                        <span>{{ $p->name }}</span>
                                        @if($p->price_monthly > 0)
                                            <span class="text-[10px] font-mono text-violet-300">({{ $p->price_monthly }}€)</span>
                                        @endif
                                    </div>
                                    <p class="text-[10px] text-slate-400 line-clamp-2 mt-0.5">{{ $p->description ?? 'Accès illimité aux fonctionnalités PRO' }}</p>
                                </div>
                            </label>
                        @endforeach
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2">Durée de l'Abonnement</label>
                    <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition">
                            <input type="radio" name="duration" value="1_month" class="hidden">
                            <span class="block text-xs font-bold text-white">1 Mois</span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Court</span>
                        </label>
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition">
                            <input type="radio" name="duration" value="6_months" class="hidden">
                            <span class="block text-xs font-bold text-white">6 Mois</span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Semestre</span>
                        </label>
                        <label class="cursor-pointer border border-violet-500 bg-violet-950/30 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/30 p-2.5 rounded-xl text-center transition relative">
                            <input type="radio" name="duration" value="1_year" checked class="hidden">
                            <span class="block text-xs font-black text-white">1 An</span>
                            <span class="block text-[10px] text-violet-300 mt-0.5">★ Conseillé</span>
                        </label>
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition col-span-2 sm:col-span-3">
                            <input type="radio" name="duration" value="lifetime" class="hidden">
                            <span class="block text-xs font-black text-amber-300 flex items-center justify-center gap-1">
                                <span>∞ À Vie / Permanent</span>
                            </span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Accès illimité sans expiration</span>
                        </label>
                    </div>
                </div>

                <div class="pt-3 border-t border-slate-800 flex items-center justify-between gap-3">
                    <button type="button" onclick="closeDashboardUpgradeModal()" class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs font-semibold transition">
                        Annuler
                    </button>
                    <button type="submit" class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-xs font-black shadow-lg shadow-violet-600/30 transition flex items-center gap-2">
                        <svg class="w-4 h-4 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                        <span>Activer Premium</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openDashboardUpgradeModal(userId, userName, userEmail) {
            const form = document.getElementById('dashUpgradeForm');
            form.action = '/admin/users/' + userId + '/upgrade-premium';
            document.getElementById('dashUpgradeUserName').innerText = userName || 'Utilisateur';
            document.getElementById('dashUpgradeUserEmail').innerText = userEmail || '';
            document.getElementById('dashboardUpgradeModal').classList.remove('hidden');
        }

        function closeDashboardUpgradeModal() {
            document.getElementById('dashboardUpgradeModal').classList.add('hidden');
        }

        document.getElementById('dashboardUpgradeModal').addEventListener('click', function(e) {
            if (e.target === this) closeDashboardUpgradeModal();
        });
    </script>
@endsection

