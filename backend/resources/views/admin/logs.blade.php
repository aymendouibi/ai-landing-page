@extends('layouts.admin')

@section('title', 'Journal des Erreurs & Monitoring')
@section('page_title', 'Logs d\'Erreurs & Diagnostics')
@section('breadcrumbs', 'Surveillance des paiements Stripe, pipeline IA et exceptions système')

@section('topbar_actions')
    <form action="{{ route('admin.logs.clear') }}" method="POST" onsubmit="return confirm('Effacer tous les logs d\'erreurs résolus ?');">
        @csrf
        <button type="submit" class="px-3.5 py-1.5 text-xs font-semibold text-slate-300 hover:text-white bg-slate-800 hover:bg-slate-700 rounded-lg transition flex items-center gap-1.5">
            <svg class="w-3.5 h-3.5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
            <span>Nettoyer les Résolus</span>
        </button>
    </form>
@endsection

@section('content')
    <!-- KPI Metrics Grid -->
    <div class="grid grid-cols-2 sm:grid-cols-5 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Erreurs</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Événements enregistrés</p>
        </div>

        <div class="bg-slate-900/60 border border-emerald-500/30 p-4 rounded-2xl relative overflow-hidden bg-gradient-to-br from-emerald-950/20 to-slate-900/60 shadow-lg shadow-emerald-500/5">
            <div class="flex items-center justify-between">
                <p class="text-[11px] font-bold text-emerald-400 uppercase tracking-wider">Erreurs Paiements</p>
                <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
            </div>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['payment'] }}</h3>
            <p class="text-[11px] text-emerald-400/80 mt-1">Stripe & Facturation</p>
        </div>

        <div class="bg-slate-900/60 border border-cyan-500/30 p-4 rounded-2xl relative overflow-hidden bg-gradient-to-br from-cyan-950/20 to-slate-900/60 shadow-lg shadow-cyan-500/5">
            <div class="flex items-center justify-between">
                <p class="text-[11px] font-bold text-cyan-400 uppercase tracking-wider">Erreurs IA / Pipeline</p>
                <svg class="w-4 h-4 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
            </div>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['ai'] }}</h3>
            <p class="text-[11px] text-cyan-400/80 mt-1">OpenRouter & Modèles</p>
        </div>

        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Erreurs Système</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['system'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Serveur & Base de données</p>
        </div>

        <div class="bg-slate-900/60 border border-rose-500/30 p-4 rounded-2xl relative overflow-hidden bg-gradient-to-br from-rose-950/20 to-slate-900/60 shadow-lg shadow-rose-500/5">
            <p class="text-[11px] font-bold text-rose-400 uppercase tracking-wider">Non Résolues</p>
            <h3 class="text-2xl font-black text-white mt-1 flex items-center gap-2">
                {{ $metrics['unresolved'] }}
                @if($metrics['unresolved'] > 0)
                    <span class="w-2.5 h-2.5 rounded-full bg-rose-400 animate-pulse"></span>
                @endif
            </h3>
            <p class="text-[11px] text-rose-400/80 mt-1">À investiguer</p>
        </div>
    </div>

    <!-- Filters & Search Toolbar -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-900/40 p-3 rounded-2xl border border-slate-800">
        <div class="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
            <a href="{{ route('admin.logs.index') }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ empty($currentCategory) ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Tous les Logs ({{ $metrics['total'] }})
            </a>
            <a href="{{ route('admin.logs.index', ['category' => 'payment']) }}" class="px-3.5 py-1.5 text-xs font-bold rounded-xl {{ $currentCategory === 'payment' ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/30' : 'text-emerald-400 hover:text-white bg-emerald-500/10 border border-emerald-500/20' }} transition flex items-center gap-1.5">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
                <span>Paiements Stripe ({{ $metrics['payment'] }})</span>
            </a>
            <a href="{{ route('admin.logs.index', ['category' => 'ai']) }}" class="px-3.5 py-1.5 text-xs font-bold rounded-xl {{ $currentCategory === 'ai' ? 'bg-cyan-600 text-white shadow-md shadow-cyan-600/30' : 'text-cyan-400 hover:text-white bg-cyan-500/10 border border-cyan-500/20' }} transition flex items-center gap-1.5">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                <span>Pipeline IA ({{ $metrics['ai'] }})</span>
            </a>
            <a href="{{ route('admin.logs.index', ['category' => 'system']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ $currentCategory === 'system' ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Système ({{ $metrics['system'] }})
            </a>
        </div>

        <form action="{{ route('admin.logs.index') }}" method="GET" class="w-full sm:w-72">
            @if($currentCategory) <input type="hidden" name="category" value="{{ $currentCategory }}"> @endif
            <div class="relative">
                <input type="text" name="search" value="{{ $search }}" placeholder="Rechercher message ou utilisateur..." class="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                <svg class="w-4 h-4 text-slate-500 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </div>
        </form>
    </div>

    <!-- Error Logs Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3.5 px-4">Sévérité / Domaine</th>
                        <th class="py-3.5 px-4 w-2/5">Message d'Erreur</th>
                        <th class="py-3.5 px-4">Utilisateur Impacté</th>
                        <th class="py-3.5 px-4">Date & Heure</th>
                        <th class="py-3.5 px-4">Statut</th>
                        <th class="py-3.5 px-4 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($logs as $log)
                        <tr class="hover:bg-slate-800/30 transition {{ is_null($log->resolved_at) ? 'bg-rose-950/[0.04]' : '' }}">
                            <!-- Category & Severity Badge -->
                            <td class="py-3.5 px-4 align-top">
                                <div class="flex flex-col gap-1 items-start">
                                    @if($log->category === 'payment')
                                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
                                            PAIEMENT
                                        </span>
                                    @elseif($log->category === 'ai')
                                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-cyan-500/10 text-cyan-400 border border-cyan-500/30">
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                                            PIPELINE IA
                                        </span>
                                    @else
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-slate-800 text-slate-300">
                                            SYSTÈME
                                        </span>
                                    @endif

                                    <span class="text-[10px] uppercase font-bold {{ $log->severity === 'critical' ? 'text-rose-400' : 'text-slate-400' }}">
                                        {{ $log->severity }}
                                    </span>
                                </div>
                            </td>

                            <!-- Message & Context Preview -->
                            <td class="py-3.5 px-4 align-top">
                                <p class="text-rose-200 text-xs font-semibold font-mono leading-relaxed bg-slate-950/60 p-2.5 rounded-xl border border-slate-800/80 select-all">
                                    {{ $log->message }}
                                </p>
                                @if($log->exception_class)
                                    <span class="text-[10px] text-slate-500 font-mono block mt-1">Class: {{ $log->exception_class }}</span>
                                @endif

                                @if(!empty($log->context))
                                    <details class="mt-2 text-[10px]">
                                        <summary class="cursor-pointer text-indigo-400 hover:text-indigo-300 font-semibold select-none">
                                            Voir le contexte JSON
                                        </summary>
                                        <pre class="mt-1 p-2 rounded bg-slate-950 text-slate-400 font-mono text-[10px] overflow-x-auto max-h-40 border border-slate-800">{{ json_encode($log->context, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) }}</pre>
                                    </details>
                                @endif

                                @if(!empty($log->stack_trace))
                                    <details class="mt-1 text-[10px]">
                                        <summary class="cursor-pointer text-slate-500 hover:text-slate-400 select-none">
                                            Stack trace
                                        </summary>
                                        <pre class="mt-1 p-2 rounded bg-slate-950 text-slate-500 font-mono text-[9px] overflow-x-auto max-h-36 border border-slate-800">{{ $log->stack_trace }}</pre>
                                    </details>
                                @endif
                            </td>

                            <!-- User Impacted -->
                            <td class="py-3.5 px-4 align-top">
                                @if($log->user)
                                    <a href="{{ route('admin.users.show', $log->user) }}" class="font-bold text-white hover:text-indigo-400 transition block">
                                        {{ $log->user->name }}
                                    </a>
                                    <span class="text-[11px] text-slate-400 font-mono">{{ $log->user->email }}</span>
                                    @if($log->user->isPremium())
                                        <span class="inline-block px-1.5 py-0.2 rounded text-[9px] font-black bg-violet-600 text-white mt-1">PREMIUM</span>
                                    @endif
                                @else
                                    <span class="text-slate-500 text-[11px]">Système / Visiteur</span>
                                @endif
                            </td>

                            <!-- Date -->
                            <td class="py-3.5 px-4 align-top text-slate-400 text-[11px] whitespace-nowrap">
                                {{ $log->created_at->format('M d, Y H:i:s') }}
                                <span class="text-slate-600 block text-[10px]">{{ $log->created_at->diffForHumans() }}</span>
                            </td>

                            <!-- Status -->
                            <td class="py-3.5 px-4 align-top">
                                @if($log->resolved_at)
                                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                        Résolu
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-rose-400"></span>
                                        Non résolu
                                    </span>
                                @endif
                            </td>

                            <!-- Actions -->
                            <td class="py-3.5 px-4 align-top text-right whitespace-nowrap">
                                @if(is_null($log->resolved_at))
                                    <form action="{{ route('admin.logs.resolve', $log) }}" method="POST" class="inline">
                                        @csrf
                                        <button type="submit" class="px-2.5 py-1 rounded bg-slate-800 hover:bg-emerald-600/30 text-slate-300 hover:text-emerald-400 text-[11px] font-semibold transition border border-slate-700 hover:border-emerald-500/40">
                                            Marquer résolu
                                        </button>
                                    </form>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="py-16 text-center text-slate-500">
                                <svg class="w-10 h-10 text-slate-600 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                <p class="text-sm font-semibold text-slate-400">Aucune erreur enregistrée</p>
                                <p class="text-xs text-slate-600 mt-1">Tous les services (paiements Stripe, pipeline IA, serveur) fonctionnent normalement.</p>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($logs->hasPages())
            <div class="p-4 border-t border-slate-800 bg-slate-900/40">
                {{ $logs->links() }}
            </div>
        @endif
    </div>

    <!-- Raw Laravel Storage Log Tab (Diagnostics) -->
    @if(!empty($laravelLogLines))
        <div class="mt-8 bg-slate-900/40 border border-slate-800 rounded-3xl p-6">
            <h3 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-3 flex items-center gap-2">
                <svg class="w-4 h-4 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                <span>Dernières Lignes Brutes de storage/logs/laravel.log</span>
            </h3>
            <pre class="p-4 rounded-2xl bg-slate-950 text-slate-400 font-mono text-[11px] leading-relaxed overflow-x-auto max-h-64 border border-slate-800/80">{{ implode("\n", $laravelLogLines) }}</pre>
        </div>
    @endif
@endsection
