@extends('layouts.admin')

@section('title', 'Profil de ' . $user->name)
@section('page_title', $user->name)
@section('breadcrumbs', 'Détails du compte créateur & pages générées')

@section('topbar_actions')
    <a href="{{ route('admin.users.index') }}" class="px-3.5 py-1.5 text-xs font-bold text-slate-300 hover:text-white bg-slate-800 hover:bg-slate-700 rounded-lg transition flex items-center gap-1.5">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
        <span>Retour aux utilisateurs</span>
    </a>
@endsection

@section('content')
    <!-- User Overview Hero -->
    <div class="bg-slate-900/80 border border-slate-800 rounded-3xl p-6 sm:p-8 backdrop-blur-xl relative overflow-hidden shadow-2xl">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
            <div class="flex items-center gap-5">
                <div class="w-16 h-16 rounded-2xl flex items-center justify-center font-black text-xl shadow-xl {{ $user->isPremium() ? 'bg-gradient-to-tr from-violet-600 to-indigo-500 text-white shadow-violet-500/25 ring-4 ring-violet-500/20' : 'bg-slate-800 text-slate-300' }}">
                    {{ strtoupper(substr($user->name, 0, 2)) }}
                </div>
                <div>
                    <div class="flex items-center gap-3">
                        <h1 class="text-xl sm:text-2xl font-black text-white">{{ $user->name }}</h1>
                        @if($user->isPremium())
                            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-md shadow-violet-500/25">
                                ★ PREMIUM
                            </span>
                        @elseif($user->role->value === 'admin')
                            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase bg-indigo-500 text-white">
                                ★ ADMIN
                            </span>
                        @else
                            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-semibold uppercase bg-slate-800 text-slate-400 border border-slate-700">
                                GRATUIT
                            </span>
                        @endif
                    </div>
                    <p class="text-xs text-slate-400 font-mono mt-1">{{ $user->email }}</p>
                </div>
            </div>

            <div class="flex items-center gap-2.5 flex-wrap">
                @if(!$user->isPremium())
                    <button type="button" onclick="openUpgradeModal()" class="px-4 py-2 rounded-xl text-xs font-black bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white shadow-lg shadow-violet-600/30 transition flex items-center gap-1.5">
                        <svg class="w-4 h-4 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                        <span>Surclasser en Premium ★</span>
                    </button>
                @else
                    <button type="button" onclick="openUpgradeModal()" class="px-3.5 py-2 rounded-xl text-xs font-bold bg-violet-600/20 hover:bg-violet-600/30 text-violet-300 border border-violet-500/30 transition flex items-center gap-1.5">
                        <span>★ Prolonger / Modifier Premium</span>
                    </button>
                    <button type="button" onclick="confirmDowngrade()" class="px-3.5 py-2 rounded-xl text-xs font-medium bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/30 transition">
                        <span>Rétrograder en Gratuit</span>
                    </button>
                @endif

                <form action="{{ route('admin.users.toggle_role', $user) }}" method="POST">
                    @csrf
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold {{ $user->role->value === 'admin' ? 'bg-rose-500/10 text-rose-400 hover:bg-rose-500/20 border border-rose-500/30' : 'bg-slate-800 hover:bg-slate-700 text-slate-200' }} transition">
                        {{ $user->role->value === 'admin' ? 'Rétrograder en standard' : 'Promouvoir Admin' }}
                    </button>
                </form>
            </div>
        </div>

        <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-8 pt-6 border-t border-slate-800/80">
            <div>
                <span class="text-[10px] uppercase font-bold text-slate-500 tracking-wider">Abonnement</span>
                <p class="text-sm font-bold {{ $user->isPremium() ? 'text-violet-300' : 'text-white' }} mt-0.5 flex items-center gap-1.5">
                    @if($user->isPremium())
                        <span class="w-2 h-2 rounded-full bg-violet-400 animate-pulse"></span>
                    @endif
                    <span>{{ $user->subscription?->plan?->name ?? 'Gratuit' }}</span>
                </p>
                <span class="text-[10px] text-slate-400 block mt-0.5">
                    @if($user->isPremium())
                        {{ $user->subscription?->current_period_end ? 'Expire le ' . $user->subscription->current_period_end->format('M d, Y') : 'Accès à vie / Permanent' }}
                    @else
                        Sans abonnement payant
                    @endif
                </span>
            </div>
            <div>
                <span class="text-[10px] uppercase font-bold text-slate-500 tracking-wider">Date d'inscription</span>
                <p class="text-sm font-bold text-white mt-0.5">{{ $user->created_at->format('M d, Y') }}</p>
                <span class="text-[10px] text-slate-400">{{ $user->created_at->diffForHumans() }}</span>
            </div>
            <div>
                <span class="text-[10px] uppercase font-bold text-slate-500 tracking-wider">Vérification Email</span>
                <p class="text-sm font-bold {{ $user->email_verified_at ? 'text-emerald-400' : 'text-slate-400' }} mt-0.5">
                    {{ $user->email_verified_at ? 'Vérifié' : 'Non vérifié' }}
                </p>
                <span class="text-[10px] text-slate-400">{{ $user->email_verified_at?->format('M d, Y') ?? 'En attente' }}</span>
            </div>
            <div>
                <span class="text-[10px] uppercase font-bold text-slate-500 tracking-wider">Pages Générées</span>
                <p class="text-sm font-bold text-emerald-400 mt-0.5">{{ count($websites) }} sites</p>
                <span class="text-[10px] text-slate-400">Total projets créés</span>
            </div>
        </div>
    </div>

    <!-- Generated Websites & Landing Pages Section -->
    <div class="space-y-4">
        <div class="flex items-center justify-between">
            <h2 class="text-base font-bold text-white flex items-center gap-2">
                <svg class="w-5 h-5 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                <span>Landing Pages Générées par ce Créateur ({{ count($websites) }})</span>
            </h2>
        </div>

        @if(count($websites) === 0)
            <div class="p-12 text-center rounded-3xl bg-slate-900/40 border border-slate-800 text-slate-500">
                <svg class="w-12 h-12 text-slate-600 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path></svg>
                <p class="text-sm font-semibold text-slate-400">Aucune page générée pour le moment</p>
                <p class="text-xs text-slate-600 mt-1">Dès que l'utilisateur crée ou génère un site avec l'IA, il apparaîtra ici avec son URL en direct.</p>
            </div>
        @else
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                @foreach($websites as $site)
                    <div class="bg-slate-900/70 border border-slate-800 hover:border-slate-700 p-5 rounded-2xl transition shadow-lg flex flex-col justify-between">
                        <div>
                            <div class="flex items-center justify-between gap-3">
                                <h3 class="text-base font-bold text-white">{{ $site['name'] }}</h3>
                                <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold {{ $site['is_published'] ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30' : 'bg-slate-800 text-slate-400 border border-slate-700' }}">
                                    {{ $site['is_published'] ? 'Publié' : 'Brouillon' }}
                                </span>
                            </div>

                            <a href="{{ $site['live_url'] }}" target="_blank" class="text-xs text-indigo-400 hover:text-indigo-300 font-mono mt-1.5 flex items-center gap-1">
                                <span>{{ $site['subdomain'] }}.ai-landing-page.xyz</span>
                                <svg class="w-3.5 h-3.5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
                            </a>

                            <div class="flex items-center gap-4 text-[11px] text-slate-500 mt-4">
                                <span>Révision v{{ $site['revision_number'] }}</span>
                                <span>&bull;</span>
                                <span>{{ $site['sections_count'] }} sections</span>
                                <span>&bull;</span>
                                <span>Mis à jour {{ $site['updated_at'] }}</span>
                            </div>
                        </div>

                        <div class="flex items-center gap-2 pt-4 mt-4 border-t border-slate-800/80">
                            <a href="{{ $site['preview_url'] }}" target="_blank" class="flex-1 text-center py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold transition">
                                Aperçu Local
                            </a>
                            <a href="{{ $site['live_url'] }}" target="_blank" class="flex-1 text-center py-2 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-xs font-bold shadow-md shadow-indigo-600/20 transition">
                                Voir en Direct
                            </a>
                        </div>
                    </div>
                @endforeach
            </div>
        @endif
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
                        <h2 class="text-base font-black text-white">{{ $user->isPremium() ? 'Modifier / Prolonger Premium ★' : 'Surclasser en Premium ★' }}</h2>
                        <p class="text-xs text-slate-400">Attribution des accès illimités, templates PRO et quotas IA</p>
                    </div>
                </div>
                <button type="button" onclick="closeUpgradeModal()" class="w-8 h-8 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white flex items-center justify-center transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>

            <!-- Modal Form -->
            <form action="{{ route('admin.users.upgrade_premium', $user) }}" method="POST" class="p-6 space-y-4">
                @csrf
                <!-- User Target Info -->
                <div class="p-3.5 rounded-2xl bg-slate-950/60 border border-slate-800 flex items-center justify-between">
                    <div>
                        <span class="text-[10px] font-semibold text-slate-500 uppercase tracking-wider block">Compte Utilisateur</span>
                        <h4 class="text-sm font-bold text-white mt-0.5">{{ $user->name }}</h4>
                        <p class="text-[11px] text-slate-400 font-mono">{{ $user->email }}</p>
                    </div>
                    <div class="text-right">
                        @if($user->isPremium())
                            <span class="px-2 py-0.5 rounded text-[10px] font-black uppercase bg-violet-600/30 text-violet-300 border border-violet-500/40">Actif ({{ $user->subscription?->plan?->name }})</span>
                        @else
                            <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-slate-800 text-slate-400">Gratuit</span>
                        @endif
                    </div>
                </div>

                <!-- Plan Selection -->
                <div>
                    <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2">Choisir le Forfait</label>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                        @foreach($plans as $p)
                            @php
                                $isCurrentPlan = $user->subscription?->plan_id === $p->id || ($user->subscription?->plan?->slug === $p->slug);
                            @endphp
                            <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-3 rounded-xl flex items-start gap-2.5 transition">
                                <input type="radio" name="plan_slug" value="{{ $p->slug }}" {{ ($isCurrentPlan || $loop->first) ? 'checked' : '' }} class="mt-1 text-violet-600 focus:ring-violet-500">
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

                <!-- Duration Selection -->
                <div>
                    <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2">Durée de l'Abonnement</label>
                    <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition">
                            <input type="radio" name="duration" value="1_month" class="hidden">
                            <span class="block text-xs font-bold text-white">1 Mois</span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Test rapide</span>
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
                        <label class="cursor-pointer border border-violet-500 bg-violet-950/30 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/30 p-2.5 rounded-xl text-center transition relative">
                            <input type="radio" name="duration" value="1_year" checked class="hidden">
                            <span class="block text-xs font-black text-white">1 An</span>
                            <span class="block text-[10px] text-violet-300 mt-0.5">★ Recommandé</span>
                        </label>
                        <label class="cursor-pointer border border-slate-800 hover:border-violet-500/50 bg-slate-950/40 has-[:checked]:border-violet-500 has-[:checked]:bg-violet-950/20 p-2.5 rounded-xl text-center transition col-span-2 sm:col-span-2">
                            <input type="radio" name="duration" value="lifetime" class="hidden">
                            <span class="block text-xs font-black text-amber-300 flex items-center justify-center gap-1">
                                <span>∞ À Vie / Permanent</span>
                            </span>
                            <span class="block text-[10px] text-slate-400 mt-0.5">Accès illimité sans expiration</span>
                        </label>
                    </div>
                </div>

                <!-- Admin Note -->
                <div>
                    <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-1.5">Note Interne Admin (Optionnel)</label>
                    <input type="text" name="note" placeholder="Ex: Surclassement offert, client fidèle, code créateur..." class="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 focus:border-violet-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                </div>

                <!-- Modal Actions -->
                <div class="pt-3 border-t border-slate-800 flex items-center justify-between gap-3">
                    <button type="button" onclick="closeUpgradeModal()" class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs font-semibold transition">
                        Annuler
                    </button>
                    <button type="submit" class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-xs font-black shadow-lg shadow-violet-600/30 transition flex items-center gap-2">
                        <svg class="w-4 h-4 text-amber-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                        <span>{{ $user->isPremium() ? 'Mettre à jour le forfait' : 'Activer le statut Premium' }}</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Hidden Downgrade Form -->
    <form id="downgradeUserForm" action="{{ route('admin.users.cancel_premium', $user) }}" method="POST" class="hidden">
        @csrf
    </form>

    <script>
        function openUpgradeModal() {
            document.getElementById('upgradeUserModal').classList.remove('hidden');
        }

        function closeUpgradeModal() {
            document.getElementById('upgradeUserModal').classList.add('hidden');
        }

        document.getElementById('upgradeUserModal').addEventListener('click', function(e) {
            if (e.target === this) closeUpgradeModal();
        });

        function confirmDowngrade() {
            if (confirm("Êtes-vous certain de vouloir révoquer le statut Premium de {{ addslashes($user->name) }} et repasser son compte au forfait Gratuit ?")) {
                document.getElementById('downgradeUserForm').submit();
            }
        }
    </script>
@endsection
