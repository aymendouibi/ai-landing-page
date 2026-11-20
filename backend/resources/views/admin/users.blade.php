@extends('layouts.admin')

@section('title', 'Utilisateurs & Créateurs')
@section('page_title', 'Gestion des Utilisateurs')
@section('breadcrumbs', 'Comptes créateurs, niveaux d\'abonnement (Premium d\'abord) & pages générées')

@section('content')
    <!-- Metric KPI Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-5 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Comptes</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Créateurs enregistrés</p>
        </div>
        <div class="bg-slate-900/60 border border-violet-500/30 p-4 rounded-2xl relative overflow-hidden bg-gradient-to-br from-violet-950/20 to-slate-900/60 shadow-lg shadow-violet-500/5">
            <div class="flex items-center justify-between">
                <p class="text-[11px] font-bold text-violet-400 uppercase tracking-wider">★ Abonnés Premium</p>
                <span class="w-2 h-2 rounded-full bg-violet-400 animate-pulse"></span>
            </div>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['premium'] }}</h3>
            <p class="text-[11px] text-violet-300/80 mt-1">Classés en tête de liste</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Créateurs Gratuits</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['free'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Tier standard gratuit</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-indigo-400 uppercase tracking-wider">Administrateurs</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['admins'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Contrôle de la plateforme</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-emerald-400 uppercase tracking-wider">Emails Vérifiés</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['verified'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Identité confirmée</p>
        </div>
    </div>

    <!-- Filters & Search Toolbar -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-900/40 p-3 rounded-2xl border border-slate-800">
        <div class="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
            <a href="{{ route('admin.users.index') }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ !request('tier') && !request('role') ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Tous ({{ $metrics['total'] }})
            </a>
            <a href="{{ route('admin.users.index', ['tier' => 'premium']) }}" class="px-3.5 py-1.5 text-xs font-bold rounded-xl {{ request('tier') === 'premium' ? 'bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-md shadow-violet-600/30' : 'text-violet-300 hover:text-white bg-violet-600/10 border border-violet-500/20' }} transition flex items-center gap-1.5">
                <span>★ Premium d'abord</span>
                <span class="px-1.5 py-0.2 rounded-full bg-violet-500/30 text-[10px]">{{ $metrics['premium'] }}</span>
            </a>
            <a href="{{ route('admin.users.index', ['tier' => 'free']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('tier') === 'free' ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Gratuits ({{ $metrics['free'] }})
            </a>
            <a href="{{ route('admin.users.index', ['role' => 'admin']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('role') === 'admin' ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Admins ({{ $metrics['admins'] }})
            </a>
        </div>
        <form action="{{ route('admin.users.index') }}" method="GET" class="w-full sm:w-72">
            @if(request('tier')) <input type="hidden" name="tier" value="{{ request('tier') }}"> @endif
            @if(request('role')) <input type="hidden" name="role" value="{{ request('role') }}"> @endif
            <div class="relative">
                <input type="text" name="search" value="{{ $search }}" placeholder="Rechercher par nom ou email..." class="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                <svg class="w-4 h-4 text-slate-500 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </div>
        </form>
    </div>

    <!-- Users Table (Ordered by Premium First) -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3.5 px-4">Utilisateur / Profil</th>
                        <th class="py-3.5 px-4">Type / Abonnement</th>
                        <th class="py-3.5 px-4">Pages Générées</th>
                        <th class="py-3.5 px-4">Statut Email</th>
                        <th class="py-3.5 px-4">Date d'Inscription</th>
                        <th class="py-3.5 px-4 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($users as $user)
                        @php
                            $isPremium = $user->isPremium();
                            $activeSub = $user->getActiveSubscription();
                            $planName = $activeSub?->plan?->name ?? 'Free';
                            $websitesCount = $user->websites_count;
                        @endphp
                        <tr class="hover:bg-slate-800/40 transition cursor-pointer group {{ $isPremium ? 'bg-violet-950/[0.08]' : '' }}" onclick="openUserModal('{{ $user->id }}')">
                            <!-- User Identity -->
                            <td class="py-3.5 px-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs shrink-0 shadow-md {{ $isPremium ? 'bg-gradient-to-tr from-violet-600 to-indigo-500 text-white shadow-violet-500/25 ring-2 ring-violet-500/30' : 'bg-slate-800 text-slate-300' }}">
                                        {{ strtoupper(substr($user->name, 0, 2)) }}
                                    </div>
                                    <div>
                                        <div class="font-bold text-white text-sm group-hover:text-indigo-400 transition flex items-center gap-1.5">
                                            <span>{{ $user->name }}</span>
                                            @if($isPremium)
                                                <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[9px] font-black bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-sm uppercase tracking-wider">
                                                    ★ PREMIUM
                                                </span>
                                            @endif
                                        </div>
                                        <div class="text-[11px] text-slate-400 font-mono">{{ $user->email }}</div>
                                    </div>
                                </div>
                            </td>

                            <!-- Subscription Tier Badge -->
                            <td class="py-3.5 px-4">
                                @if($user->role->value === 'admin')
                                    <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-indigo-500/10 text-indigo-400 border border-indigo-500/30">
                                        ★ Administrateur
                                    </span>
                                @elseif($isPremium)
                                    <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-black bg-gradient-to-r from-violet-600/20 to-indigo-600/20 text-violet-300 border border-violet-500/40 shadow-sm shadow-violet-500/10">
                                        <span class="w-1.5 h-1.5 rounded-full bg-violet-400 animate-pulse"></span>
                                        {{ $planName }}
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-slate-800/80 text-slate-400 border border-slate-700/50">
                                        Gratuit (Free)
                                    </span>
                                @endif
                            </td>

                            <!-- Generated Pages / Websites Count -->
                            <td class="py-3.5 px-4">
                                <div class="flex items-center gap-2">
                                    <span class="px-2 py-0.5 rounded-lg text-xs font-bold {{ $websitesCount > 0 ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-slate-800 text-slate-500' }}">
                                        {{ $websitesCount }} {{ Str::plural('page', $websitesCount) }}
                                    </span>
                                    @if($websitesCount > 0)
                                        <span class="text-[11px] text-indigo-400 group-hover:underline flex items-center gap-0.5">
                                            Voir &rarr;
                                        </span>
                                    @endif
                                </div>
                            </td>

                            <!-- Email Status -->
                            <td class="py-3.5 px-4">
                                @if($user->email_verified_at)
                                    <span class="text-emerald-400 font-medium text-[11px] flex items-center gap-1">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                        Vérifié
                                    </span>
                                @else
                                    <span class="text-slate-500 text-[11px]">Non vérifié</span>
                                @endif
                            </td>

                            <!-- Registered Date -->
                            <td class="py-3.5 px-4 text-slate-400 text-[11px]">
                                {{ $user->created_at->format('M d, Y') }}
                                <span class="text-slate-600 block text-[10px]">{{ $user->created_at->diffForHumans() }}</span>
                            </td>

                            <!-- Actions -->
                            <td class="py-3.5 px-4 text-right" onclick="event.stopPropagation()">
                                <div class="flex items-center justify-end gap-1.5">
                                    @if($isPremium)
                                        <button type="button" onclick="openUpgradeModal('{{ $user->id }}', '{{ addslashes($user->name) }}', '{{ addslashes($user->email) }}', true, '{{ $activeSub?->plan?->slug ?? 'pro' }}', '{{ $activeSub?->current_period_end?->format('M d, Y') ?? 'Permanent' }}')" class="px-2 py-1 rounded bg-violet-600/20 hover:bg-violet-600/30 text-violet-300 text-[10px] font-bold border border-violet-500/30 transition flex items-center gap-1" title="Gérer ou prolonger le forfait Premium">
                                            <span>★ Gérer Premium</span>
                                        </button>
                                    @else
                                        <button type="button" onclick="openUpgradeModal('{{ $user->id }}', '{{ addslashes($user->name) }}', '{{ addslashes($user->email) }}', false, 'pro', '')" class="px-2 py-1 rounded bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-[10px] font-extrabold shadow-md shadow-violet-600/20 transition flex items-center gap-1" title="Surclasser ce compte en Premium">
                                            <svg class="w-3 h-3 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                                            <span>Surclasser</span>
                                        </button>
                                    @endif

                                    <button type="button" onclick="openUserModal('{{ $user->id }}')" class="px-2.5 py-1 rounded bg-indigo-600/10 hover:bg-indigo-600/30 text-indigo-400 text-[11px] font-bold border border-indigo-500/20 transition flex items-center gap-1">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                        <span>Détails</span>
                                    </button>

                                    <form action="{{ route('admin.users.toggle_role', $user) }}" method="POST" class="inline">
                                        @csrf
                                        <button type="submit" class="px-2 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[10px] font-medium transition" title="{{ $user->role->value === 'admin' ? 'Rétrograder en utilisateur' : 'Promouvoir Admin' }}">
                                            {{ $user->role->value === 'admin' ? 'Rétrograder' : 'Admin' }}
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="py-12 text-center text-slate-500">
                                Aucun utilisateur trouvé.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($users->hasPages())
            <div class="p-4 border-t border-slate-800 bg-slate-900/40">
                {{ $users->links() }}
            </div>
        @endif
    </div>

    <!-- User Profile & Generated Pages Modal -->
    <div id="userProfileModal" class="fixed inset-0 z-50 hidden bg-black/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 transition-all">
        <div class="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-3xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <!-- Modal Header -->
            <div class="p-6 border-b border-slate-800 flex items-center justify-between bg-slate-900/80">
                <div class="flex items-center gap-3.5">
                    <div id="modalUserAvatar" class="w-12 h-12 rounded-2xl bg-gradient-to-tr from-violet-600 to-indigo-500 text-white font-black text-base flex items-center justify-center shadow-lg shadow-indigo-500/25">
                        --
                    </div>
                    <div>
                        <div class="flex items-center gap-2">
                            <h2 id="modalUserName" class="text-lg font-black text-white">Chargement...</h2>
                            <span id="modalUserTier" class="px-2 py-0.5 rounded-full text-[10px] font-extrabold uppercase bg-violet-600 text-white">...</span>
                        </div>
                        <p id="modalUserEmail" class="text-xs text-slate-400 font-mono mt-0.5">...</p>
                    </div>
                </div>
                <button type="button" onclick="closeUserModal()" class="w-8 h-8 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white flex items-center justify-center transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>

            <!-- Modal Body (Scrollable) -->
            <div class="p-6 overflow-y-auto space-y-6 flex-1 bg-slate-950/40">
                <!-- Profile & Subscription Info Grid -->
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div class="p-3.5 rounded-xl bg-slate-900/60 border border-slate-800/80 flex flex-col justify-between">
                        <div>
                            <div class="flex items-center justify-between">
                                <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Abonnement</span>
                                <span id="modalPlanBadge" class="text-[9px] font-black uppercase px-1.5 py-0.5 rounded bg-slate-800 text-slate-400">FREE</span>
                            </div>
                            <p id="modalPlanName" class="text-sm font-bold text-white mt-1">Gratuit</p>
                            <span id="modalSubPeriod" class="text-[10px] text-slate-500 block mt-0.5">Sans engagement</span>
                        </div>
                        <div id="modalSubActions" class="mt-3 pt-2.5 border-t border-slate-800/60 flex items-center gap-1.5">
                            <!-- Populated with quick Upgrade / Downgrade buttons -->
                        </div>
                    </div>
                    <div class="p-3.5 rounded-xl bg-slate-900/60 border border-slate-800/80">
                        <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Date d'inscription</span>
                        <p id="modalUserJoined" class="text-sm font-bold text-white mt-1">--</p>
                        <span id="modalEmailStatus" class="text-[10px] text-emerald-400 block mt-0.5">Email vérifié</span>
                    </div>
                    <div class="p-3.5 rounded-xl bg-slate-900/60 border border-slate-800/80">
                        <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Total Sites Créés</span>
                        <p id="modalWebsitesCount" class="text-sm font-bold text-emerald-400 mt-1">0 sites</p>
                        <span class="text-[10px] text-slate-500 block mt-0.5">Générés par IA</span>
                    </div>
                </div>

                <!-- Generated Landing Pages Section -->
                <div>
                    <div class="flex items-center justify-between mb-3">
                        <h3 class="text-xs font-bold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
                            <svg class="w-4 h-4 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                            <span>Pages & Sites Web Générés</span>
                        </h3>
                        <span id="modalBadgeWebsitesCount" class="text-[11px] text-slate-400 font-semibold"></span>
                    </div>

                    <div id="modalWebsitesList" class="space-y-2.5">
                        <!-- Populated dynamically via JS -->
                        <div class="py-8 text-center text-slate-500 text-xs">
                            Chargement des pages générées...
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal Footer -->
            <div class="p-4 border-t border-slate-800 bg-slate-900/80 flex items-center justify-between">
                <a id="modalFullProfileBtn" href="#" class="text-xs text-indigo-400 hover:text-indigo-300 font-semibold flex items-center gap-1">
                    <span>Ouvrir la page complète du profil</span>
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                </a>
                <button type="button" onclick="closeUserModal()" class="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-white font-semibold rounded-xl text-xs transition">
                    Fermer
                </button>
            </div>
        </div>
    </div>

    <!-- Upgrade User to Premium Modal -->
    <div id="upgradeUserModal" class="fixed inset-0 z-50 hidden bg-black/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 transition-all">
        <div class="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-lg shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <!-- Modal Header -->
            <div class="p-6 border-b border-slate-800 bg-gradient-to-r from-violet-950/40 via-slate-900 to-indigo-950/40 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-2xl bg-gradient-to-tr from-violet-600 to-indigo-500 text-white flex items-center justify-center shadow-lg shadow-violet-500/30">
                        <svg class="w-5 h-5 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                    </div>
                    <div>
                        <h2 id="upgradeModalTitle" class="text-base font-black text-white">Surclasser en Premium ★</h2>
                        <p id="upgradeModalSubtitle" class="text-xs text-slate-400">Activer les privilèges créateur et quotas illimités</p>
                    </div>
                </div>
                <button type="button" onclick="closeUpgradeModal()" class="w-8 h-8 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white flex items-center justify-center transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>

            <!-- Modal Form -->
            <form id="upgradeUserForm" action="" method="POST" class="p-6 space-y-4">
                @csrf
                <!-- Target User Info -->
                <div class="p-3.5 rounded-2xl bg-slate-950/60 border border-slate-800 flex items-center justify-between">
                    <div>
                        <span class="text-[10px] font-semibold text-slate-500 uppercase tracking-wider block">Compte Cible</span>
                        <h4 id="upgradeTargetUserName" class="text-sm font-bold text-white mt-0.5">...</h4>
                        <p id="upgradeTargetUserEmail" class="text-[11px] text-slate-400 font-mono">...</p>
                    </div>
                    <div id="upgradeCurrentStatusBadge" class="text-right">
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-slate-800 text-slate-400">Gratuit</span>
                    </div>
                </div>

                <!-- Plan Selection -->
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
                                    <p class="text-[10px] text-slate-400 line-clamp-2 mt-0.5">{{ $p->description ?? 'Accès complet aux fonctionnalités et modèles' }}</p>
                                </div>
                            </label>
                        @endforeach
                    </div>
                </div>

                <!-- Duration Selection -->
                <div>
                    <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2">Durée de l'Abonnement</label>
                    <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition">
                            <input type="radio" name="duration" value="1_month" class="hidden">
                            <span class="block text-xs font-bold text-white">1 Mois</span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Test court</span>
                        </label>
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition">
                            <input type="radio" name="duration" value="3_months" class="hidden">
                            <span class="block text-xs font-bold text-white">3 Mois</span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Trimestre</span>
                        </label>
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition">
                            <input type="radio" name="duration" value="6_months" class="hidden">
                            <span class="block text-xs font-bold text-white">6 Mois</span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Semestre</span>
                        </label>
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition relative">
                            <input type="radio" name="duration" value="1_year" checked class="hidden">
                            <span class="block text-xs font-black text-white">1 An</span>
                            <span class="block text-[10px] text-violet-300 mt-0.5">★ Recommandé</span>
                        </label>
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition col-span-2 sm:col-span-2">
                            <input type="radio" name="duration" value="lifetime" class="hidden">
                            <span class="block text-xs font-black text-amber-300 flex items-center justify-center gap-1">
                                <span>∞ À Vie / Permanent</span>
                            </span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Illimité sans date d'expiration</span>
                        </label>
                    </div>
                </div>

                <!-- Admin Note -->
                <div>
                    <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-1.5">Note Interne Admin (Optionnel)</label>
                    <input type="text" name="note" placeholder="Ex: Offert pour test, VIP créateur, support..." class="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 focus:border-violet-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                </div>

                <!-- Modal Actions -->
                <div class="pt-3 border-t border-slate-800 flex items-center justify-between gap-3">
                    <button type="button" onclick="closeUpgradeModal()" class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs font-semibold transition">
                        Annuler
                    </button>
                    <button type="submit" class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-xs font-black shadow-lg shadow-violet-600/30 transition flex items-center gap-2">
                        <svg class="w-4 h-4 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                        <span id="upgradeSubmitBtnText">Activer le statut Premium</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Hidden Downgrade Form -->
    <form id="downgradeUserForm" action="" method="POST" class="hidden">
        @csrf
    </form>

    <!-- Script to Fetch User Profile & Generated Pages on Click -->
    <script>
        function openUserModal(userId) {
            const modal = document.getElementById('userProfileModal');
            modal.classList.remove('hidden');

            document.getElementById('modalUserName').innerText = 'Chargement...';
            document.getElementById('modalUserEmail').innerText = '...';
            document.getElementById('modalWebsitesList').innerHTML = '<div class="py-8 text-center text-slate-500 text-xs">Chargement des pages créées...</div>';
            document.getElementById('modalFullProfileBtn').href = '/admin/users/' + userId;

            fetch('/admin/users/' + userId, {
                headers: {
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(res => res.json())
            .then(data => {
                const u = data.user;
                const sites = data.websites;

                document.getElementById('modalUserName').innerText = u.name;
                document.getElementById('modalUserEmail').innerText = u.email;
                document.getElementById('modalUserAvatar').innerText = (u.name || 'US').substring(0, 2).toUpperCase();

                const tierEl = document.getElementById('modalUserTier');
                tierEl.innerText = u.tier || 'Free';
                if (u.is_premium) {
                    tierEl.className = 'px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-md shadow-violet-500/20';
                } else if (u.role === 'admin') {
                    tierEl.className = 'px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase bg-indigo-500 text-white';
                } else {
                    tierEl.className = 'px-2 py-0.5 rounded-full text-[10px] font-semibold uppercase bg-slate-800 text-slate-300';
                }

                const planBadge = document.getElementById('modalPlanBadge');
                if (planBadge) {
                    planBadge.innerText = u.is_premium ? '★ PREMIUM' : (u.role === 'admin' ? 'ADMIN' : 'GRATUIT');
                    planBadge.className = u.is_premium ? 'text-[9px] font-black uppercase px-1.5 py-0.5 rounded bg-violet-600/30 text-violet-300 border border-violet-500/30' : 'text-[9px] font-black uppercase px-1.5 py-0.5 rounded bg-slate-800 text-slate-400';
                }

                if (u.subscription) {
                    document.getElementById('modalPlanName').innerText = u.subscription.plan_name;
                    document.getElementById('modalSubPeriod').innerText = (u.subscription.status === 'active' ? 'Actif · ' : 'Inactif · ') + (u.subscription.current_period_end ? 'Renouvellement: ' + u.subscription.current_period_end : 'Permanent');
                } else {
                    document.getElementById('modalPlanName').innerText = 'Gratuit (Free)';
                    document.getElementById('modalSubPeriod').innerText = 'Aucun abonnement payant';
                }

                // Render dynamic subscription actions in modal
                const subActions = document.getElementById('modalSubActions');
                if (subActions) {
                    const safeName = (u.name || '').replace(/'/g, "\\'");
                    const safeEmail = (u.email || '').replace(/'/g, "\\'");
                    const planSlug = (u.subscription && u.subscription.plan_slug) ? u.subscription.plan_slug : 'pro';
                    const periodEnd = (u.subscription && u.subscription.current_period_end) ? u.subscription.current_period_end : '';

                    if (u.is_premium) {
                        subActions.innerHTML = `
                            <button type="button" onclick="openUpgradeModal('${u.id}', '${safeName}', '${safeEmail}', true, '${planSlug}', '${periodEnd}')" class="flex-1 py-1 rounded-lg bg-violet-600/20 hover:bg-violet-600/30 text-violet-300 text-[10px] font-bold border border-violet-500/30 transition text-center">
                                ★ Prolonger / Modifier
                            </button>
                            <button type="button" onclick="confirmDowngrade('${u.id}', '${safeName}')" class="px-2.5 py-1 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 text-[10px] font-medium border border-rose-500/20 transition text-center">
                                Rétrograder
                            </button>
                        `;
                    } else {
                        subActions.innerHTML = `
                            <button type="button" onclick="openUpgradeModal('${u.id}', '${safeName}', '${safeEmail}', false, 'pro', '')" class="w-full py-1.5 rounded-lg bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-[11px] font-black shadow-md shadow-violet-600/20 transition flex items-center justify-center gap-1.5">
                                <svg class="w-3.5 h-3.5 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                                <span>Surclasser ce compte en Premium</span>
                            </button>
                        `;
                    }
                }

                document.getElementById('modalUserJoined').innerText = u.created_at;
                document.getElementById('modalEmailStatus').innerText = u.email_verified_at ? 'Email vérifié (' + u.email_verified_at + ')' : 'Email non vérifié';
                document.getElementById('modalEmailStatus').className = u.email_verified_at ? 'text-[10px] text-emerald-400 block mt-0.5' : 'text-[10px] text-slate-500 block mt-0.5';

                document.getElementById('modalWebsitesCount').innerText = sites.length + ' site' + (sites.length > 1 ? 's' : '');
                document.getElementById('modalBadgeWebsitesCount').innerText = sites.length + ' au total';

                const listContainer = document.getElementById('modalWebsitesList');
                if (sites.length === 0) {
                    listContainer.innerHTML = `
                        <div class="p-6 text-center rounded-2xl bg-slate-900/40 border border-slate-800/80 text-slate-500 text-xs">
                            Cet utilisateur n'a pas encore généré de page de destination.
                        </div>
                    `;
                } else {
                    listContainer.innerHTML = sites.map(s => `
                        <div class="p-4 rounded-2xl bg-slate-900/80 border border-slate-800/90 hover:border-slate-700 flex flex-col sm:flex-row sm:items-center justify-between gap-3 transition">
                            <div>
                                <div class="flex items-center gap-2">
                                    <h4 class="font-bold text-white text-sm">${s.name}</h4>
                                    <span class="px-2 py-0.5 rounded text-[10px] font-bold ${s.is_published ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30' : 'bg-slate-800 text-slate-400'}">
                                        ${s.is_published ? 'En ligne (Publié)' : 'Brouillon'}
                                    </span>
                                    <span class="text-[10px] text-slate-500 font-mono">v${s.revision_number} · ${s.sections_count} sections</span>
                                </div>
                                <div class="flex items-center gap-2 mt-1">
                                    <a href="${s.live_url}" target="_blank" class="text-xs text-indigo-400 hover:text-indigo-300 font-mono hover:underline flex items-center gap-1">
                                        <span>${s.subdomain}.ai-landing-page.xyz</span>
                                        <svg class="w-3 h-3 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
                                    </a>
                                </div>
                            </div>
                            <div class="flex items-center gap-2 shrink-0">
                                <a href="${s.preview_url}" target="_blank" class="px-3 py-1.5 rounded-lg bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 text-xs font-semibold border border-indigo-500/25 transition">
                                    Aperçu
                                </a>
                                <a href="${s.live_url}" target="_blank" class="px-3 py-1.5 rounded-lg bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-300 text-xs font-semibold border border-emerald-500/25 transition">
                                    Voir en direct
                                </a>
                            </div>
                        </div>
                    `).join('');
                }
            })
            .catch(err => {
                console.error(err);
                document.getElementById('modalWebsitesList').innerHTML = '<div class="py-6 text-center text-rose-400 text-xs">Erreur de chargement des données.</div>';
            });
        }

        function closeUserModal() {
            document.getElementById('userProfileModal').classList.add('hidden');
        }

        document.getElementById('userProfileModal').addEventListener('click', function(e) {
            if (e.target === this) closeUserModal();
        });

        // Upgrade Modal Controls
        function openUpgradeModal(userId, userName, userEmail, isPremium, planSlug, currentEnd) {
            const modal = document.getElementById('upgradeUserModal');
            const form = document.getElementById('upgradeUserForm');
            form.action = '/admin/users/' + userId + '/upgrade-premium';

            document.getElementById('upgradeTargetUserName').innerText = userName || 'Utilisateur';
            document.getElementById('upgradeTargetUserEmail').innerText = userEmail || '';

            const title = document.getElementById('upgradeModalTitle');
            const subtitle = document.getElementById('upgradeModalSubtitle');
            const submitBtn = document.getElementById('upgradeSubmitBtnText');
            const badge = document.getElementById('upgradeCurrentStatusBadge');

            if (isPremium) {
                title.innerText = 'Modifier / Prolonger Premium ★';
                subtitle.innerText = 'Étendre la durée ou changer le forfait de ce créateur';
                submitBtn.innerText = 'Mettre à jour le forfait';
                badge.innerHTML = `<span class="px-2 py-0.5 rounded text-[10px] font-black uppercase bg-violet-600/30 text-violet-300 border border-violet-500/40">Actif (${currentEnd || 'En cours'})</span>`;
            } else {
                title.innerText = 'Surclasser en Premium ★';
                subtitle.innerText = 'Attribuer des avantages et quotas illimités au créateur';
                submitBtn.innerText = 'Activer le statut Premium';
                badge.innerHTML = `<span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-slate-800 text-slate-400">Gratuit</span>`;
            }

            // Pre-select plan if matches
            if (planSlug) {
                const radio = form.querySelector(`input[name="plan_slug"][value="${planSlug}"]`);
                if (radio) radio.checked = true;
            }

            modal.classList.remove('hidden');
        }

        function closeUpgradeModal() {
            document.getElementById('upgradeUserModal').classList.add('hidden');
        }

        document.getElementById('upgradeUserModal').addEventListener('click', function(e) {
            if (e.target === this) closeUpgradeModal();
        });

        function confirmDowngrade(userId, userName) {
            if (confirm(`Êtes-vous certain de vouloir révoquer le statut Premium de "${userName}" et repasser son compte en Gratuit ?`)) {
                const form = document.getElementById('downgradeUserForm');
                form.action = '/admin/users/' + userId + '/cancel-premium';
                form.submit();
            }
        }
    </script>
@endsection
