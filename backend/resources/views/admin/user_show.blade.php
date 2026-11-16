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

            <div class="flex items-center gap-3">
                <form action="{{ route('admin.users.toggle_role', $user) }}" method="POST">
                    @csrf
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold {{ $user->role->value === 'admin' ? 'bg-rose-500/10 text-rose-400 hover:bg-rose-500/20 border border-rose-500/30' : 'bg-indigo-600 hover:bg-indigo-500 text-white shadow-md shadow-indigo-600/30' }} transition">
                        {{ $user->role->value === 'admin' ? 'Rétrograder en utilisateur standard' : 'Promouvoir Administrateur' }}
                    </button>
                </form>
            </div>
        </div>

        <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-8 pt-6 border-t border-slate-800/80">
            <div>
                <span class="text-[10px] uppercase font-bold text-slate-500 tracking-wider">Abonnement</span>
                <p class="text-sm font-bold text-white mt-0.5">{{ $user->subscription?->plan?->name ?? 'Gratuit' }}</p>
                <span class="text-[10px] text-slate-400">{{ $user->subscription?->status->value ?? 'Sans abonnement' }}</span>
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
@endsection
