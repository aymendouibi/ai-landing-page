@extends('layouts.admin')

@section('title', 'Avis & Retours Clients')
@section('page_title', 'Avis & Retours Clients')
@section('breadcrumbs', 'Commentaires et évaluations envoyés depuis l\'application mobile')

@section('content')
    <!-- KPI Metrics Grid -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Avis Reçus</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Depuis mobile (iOS & Android)</p>
        </div>

        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-amber-400 uppercase tracking-wider">Nouveaux / Non Traités</p>
            <h3 class="text-2xl font-black text-white mt-1 flex items-center gap-2">
                {{ $metrics['new'] }}
                @if($metrics['new'] > 0)
                    <span class="inline-block w-2.5 h-2.5 rounded-full bg-amber-400 animate-ping"></span>
                @endif
            </h3>
            <p class="text-[11px] text-amber-400/80 mt-1">Nécessitent votre attention</p>
        </div>

        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-violet-400 uppercase tracking-wider">Demandes de Fonctions</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['features'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Idées d'améliorations</p>
        </div>

        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <p class="text-[11px] font-semibold text-rose-400 uppercase tracking-wider">Bugs & Problèmes</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['bugs'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Rapports d'anomalies</p>
        </div>
    </div>

    <!-- Filters & Search Toolbar -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-900/40 p-3 rounded-2xl border border-slate-800">
        <!-- Status Tabs -->
        <div class="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
            <a href="{{ route('admin.feedback.index') }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ empty($currentStatus) && empty($currentCategory) ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Tous ({{ $metrics['total'] }})
            </a>
            <a href="{{ route('admin.feedback.index', ['status' => 'new']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ $currentStatus === 'new' ? 'bg-amber-500 text-slate-950 font-bold' : 'text-amber-400 hover:text-white bg-amber-500/10 border border-amber-500/20' }} transition">
                Nouveaux ({{ $metrics['new'] }})
            </a>
            <a href="{{ route('admin.feedback.index', ['category' => 'feature']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ $currentCategory === 'feature' ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Fonctionnalités ({{ $metrics['features'] }})
            </a>
            <a href="{{ route('admin.feedback.index', ['category' => 'bug']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ $currentCategory === 'bug' ? 'bg-rose-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Bugs ({{ $metrics['bugs'] }})
            </a>
            <a href="{{ route('admin.feedback.index', ['category' => 'ai_quality']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ $currentCategory === 'ai_quality' ? 'bg-purple-600 text-white' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Qualité IA ({{ $metrics['ai_quality'] }})
            </a>
        </div>

        <!-- Search Bar -->
        <form action="{{ route('admin.feedback.index') }}" method="GET" class="w-full sm:w-72">
            @if($currentStatus) <input type="hidden" name="status" value="{{ $currentStatus }}"> @endif
            @if($currentCategory) <input type="hidden" name="category" value="{{ $currentCategory }}"> @endif
            <div class="relative">
                <input type="text" name="search" value="{{ $search }}" placeholder="Rechercher avis ou auteur..." class="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                <svg class="w-4 h-4 text-slate-500 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </div>
        </form>
    </div>

    <!-- Feedbacks Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3.5 px-4">Utilisateur / Auteur</th>
                        <th class="py-3.5 px-4">Catégorie</th>
                        <th class="py-3.5 px-4 w-2/5">Message / Avis</th>
                        <th class="py-3.5 px-4">Statut</th>
                        <th class="py-3.5 px-4">Date de Réception</th>
                        <th class="py-3.5 px-4 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($feedbacks as $fb)
                        <tr class="hover:bg-slate-800/30 transition {{ $fb->status === 'new' ? 'bg-amber-500/[0.03]' : '' }}">
                            <!-- Author Cell -->
                            <td class="py-3.5 px-4 align-top">
                                @if($fb->user)
                                    <div class="flex items-center gap-3">
                                        <div class="w-8 h-8 rounded-lg bg-indigo-600/20 text-indigo-400 font-bold flex items-center justify-center text-xs shrink-0">
                                            {{ strtoupper(substr($fb->user->name, 0, 2)) }}
                                        </div>
                                        <div>
                                            <div class="font-bold text-white text-sm flex items-center gap-1.5">
                                                <span>{{ $fb->user->name }}</span>
                                                @if($fb->user->isPremium())
                                                    <span class="px-1.5 py-0.2 rounded text-[9px] font-extrabold bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-sm">PRO</span>
                                                @endif
                                            </div>
                                            <div class="text-[11px] text-slate-400 font-mono">{{ $fb->user->email }}</div>
                                        </div>
                                    </div>
                                @else
                                    <div class="flex items-center gap-3">
                                        <div class="w-8 h-8 rounded-lg bg-slate-800 text-slate-400 font-bold flex items-center justify-center text-xs shrink-0">
                                            MB
                                        </div>
                                        <div>
                                            <div class="font-bold text-slate-300 text-sm">Utilisateur Mobile</div>
                                            <div class="text-[11px] text-slate-500 font-mono">{{ $fb->metadata['user_email'] ?? 'Sans compte' }}</div>
                                        </div>
                                    </div>
                                @endif

                                @if(!empty($fb->metadata['platform']))
                                    <span class="inline-flex items-center gap-1 mt-1 text-[10px] text-slate-500">
                                        <svg class="w-3 h-3 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                                        {{ $fb->metadata['platform'] }}
                                    </span>
                                @endif
                            </td>

                            <!-- Category Cell -->
                            <td class="py-3.5 px-4 align-top">
                                @switch($fb->category)
                                    @case('feature')
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
                                            Fonctionnalité
                                        </span>
                                        @break
                                    @case('bug')
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                            Bug / Problème
                                        </span>
                                        @break
                                    @case('ai_quality')
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-purple-500/10 text-purple-400 border border-purple-500/20">
                                            Qualité IA
                                        </span>
                                        @break
                                    @default
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-slate-800 text-slate-300">
                                            Général
                                        </span>
                                @endswitch

                                @if($fb->rating)
                                    <div class="flex items-center gap-0.5 mt-1 text-amber-400">
                                        @for($i = 1; $i <= 5; $i++)
                                            <span class="text-xs">{{ $i <= $fb->rating ? '★' : '☆' }}</span>
                                        @endfor
                                    </div>
                                @endif
                            </td>

                            <!-- Message Cell -->
                            <td class="py-3.5 px-4 align-top">
                                <p class="text-slate-200 text-xs font-normal leading-relaxed whitespace-pre-wrap bg-slate-950/40 p-3 rounded-xl border border-slate-800/80">{{ $fb->message }}</p>
                            </td>

                            <!-- Status Cell -->
                            <td class="py-3.5 px-4 align-top">
                                @if($fb->status === 'new')
                                    <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-400"></span>
                                        Nouveau
                                    </span>
                                @elseif($fb->status === 'reviewed')
                                    <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-blue-500/10 text-blue-400 border border-blue-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-blue-400"></span>
                                        Examiné
                                    </span>
                                @elseif($fb->status === 'resolved')
                                    <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                                        Résolu
                                    </span>
                                @endif
                            </td>

                            <!-- Date Cell -->
                            <td class="py-3.5 px-4 align-top text-slate-400 text-[11px]">
                                {{ $fb->created_at->format('M d, Y H:i') }}
                                <span class="text-slate-600 block text-[10px]">{{ $fb->created_at->diffForHumans() }}</span>
                            </td>

                            <!-- Actions Cell -->
                            <td class="py-3.5 px-4 align-top text-right space-x-1.5 whitespace-nowrap">
                                @if($fb->status !== 'reviewed')
                                    <form action="{{ route('admin.feedback.update_status', $fb) }}" method="POST" class="inline">
                                        @csrf
                                        @method('PATCH')
                                        <input type="hidden" name="status" value="reviewed">
                                        <button type="submit" title="Marquer comme examiné" class="px-2.5 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[11px] font-medium transition">
                                            Examiner
                                        </button>
                                    </form>
                                @endif

                                @if($fb->status !== 'resolved')
                                    <form action="{{ route('admin.feedback.update_status', $fb) }}" method="POST" class="inline">
                                        @csrf
                                        @method('PATCH')
                                        <input type="hidden" name="status" value="resolved">
                                        <button type="submit" title="Marquer comme résolu" class="px-2.5 py-1 rounded bg-emerald-600/20 hover:bg-emerald-600/40 text-emerald-400 text-[11px] font-semibold border border-emerald-500/30 transition">
                                            Résolu
                                        </button>
                                    </form>
                                @endif

                                <form action="{{ route('admin.feedback.destroy', $fb) }}" method="POST" class="inline" onsubmit="return confirm('Supprimer cet avis ?');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" title="Supprimer" class="p-1 rounded text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 transition">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="py-16 text-center text-slate-500">
                                <svg class="w-10 h-10 text-slate-600 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"></path></svg>
                                <p class="text-sm font-semibold text-slate-400">Aucun avis trouvé</p>
                                <p class="text-xs text-slate-600 mt-1">Les avis envoyés depuis l'application mobile apparaîtront automatiquement ici.</p>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($feedbacks->hasPages())
            <div class="p-4 border-t border-slate-800 bg-slate-900/40">
                {{ $feedbacks->links() }}
            </div>
        @endif
    </div>
@endsection
