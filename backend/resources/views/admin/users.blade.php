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
                                <div class="flex items-center justify-end gap-2">
                                    <button type="button" onclick="openUserModal('{{ $user->id }}')" class="px-2.5 py-1 rounded bg-indigo-600/10 hover:bg-indigo-600/30 text-indigo-400 text-[11px] font-bold border border-indigo-500/20 transition flex items-center gap-1">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                        <span>Détails & Pages</span>
                                    </button>

                                    <form action="{{ route('admin.users.toggle_role', $user) }}" method="POST" class="inline">
                                        @csrf
                                        <button type="submit" class="px-2 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[10px] font-medium transition">
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
                    <div class="p-3.5 rounded-xl bg-slate-900/60 border border-slate-800/80">
                        <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Abonnement</span>
                        <p id="modalPlanName" class="text-sm font-bold text-white mt-1">Gratuit</p>
                        <span id="modalSubPeriod" class="text-[10px] text-slate-500 block mt-0.5">Sans engagement</span>
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

                if (u.subscription) {
                    document.getElementById('modalPlanName').innerText = u.subscription.plan_name;
                    document.getElementById('modalSubPeriod').innerText = (u.subscription.status === 'active' ? 'Actif · ' : 'Inactif · ') + (u.subscription.current_period_end ? 'Renouvellement: ' + u.subscription.current_period_end : '');
                } else {
                    document.getElementById('modalPlanName').innerText = 'Gratuit (Free)';
                    document.getElementById('modalSubPeriod').innerText = 'Aucun abonnement payant';
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
    </script>
@endsection
