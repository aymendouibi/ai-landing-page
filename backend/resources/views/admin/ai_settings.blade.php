@extends('layouts.admin')

@section('title', 'Configuration du Modèle OpenRouter')
@section('page_title', 'Configuration Modèle IA (OpenRouter)')
@section('breadcrumbs', 'Définir le modèle d\'intelligence artificielle utilisé pour la génération et l\'édition')

@section('content')
    <!-- Active Model Hero Banner -->
    <div class="bg-gradient-to-br from-indigo-950/40 via-slate-900/80 to-purple-950/30 border border-indigo-500/30 rounded-3xl p-6 sm:p-8 relative overflow-hidden shadow-2xl backdrop-blur-xl">
        <div class="absolute -right-20 -top-20 w-80 h-80 bg-indigo-600/15 rounded-full blur-3xl pointer-events-none"></div>

        <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 relative z-10">
            <div>
                <div class="flex items-center gap-2">
                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-black uppercase tracking-wider bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
                        <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                        Modèle Actif dans l'App
                    </span>
                    <span class="text-xs text-slate-400 font-mono">OpenRouter API</span>
                </div>

                <h1 class="text-2xl sm:text-3xl font-black text-white mt-3 font-mono tracking-tight">
                    {{ $currentGlobalModel }}
                </h1>
                <p class="text-xs text-slate-400 mt-2 max-w-2xl leading-relaxed">
                    Toutes les demandes de génération de sites, de remix et d'édition intelligente depuis l'application mobile et le dashboard utilisent actuellement ce modèle.
                </p>
            </div>

            <!-- Live Test Connection Widget -->
            <div class="bg-slate-900/90 border border-slate-800 p-4 rounded-2xl shrink-0 flex flex-col gap-3 min-w-[260px]">
                <div class="flex items-center justify-between">
                    <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Statut API</span>
                    @if($apiKeyConfigured)
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">Clé Détectée</span>
                    @else
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-rose-500/10 text-rose-400 border border-rose-500/20">Clé Manquante</span>
                    @endif
                </div>

                <div id="testResultBox" class="hidden p-3 rounded-xl text-xs font-mono"></div>

                <button id="testBtn" type="button" onclick="testModel('{{ $currentGlobalModel }}')" class="w-full py-2 px-3 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-bold shadow-md shadow-indigo-600/30 transition flex items-center justify-center gap-2">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                    <span>Tester la Connexion IA</span>
                </button>
            </div>
        </div>
    </div>

    <!-- Popular Model Presets Grid -->
    <div>
        <div class="mb-4">
            <h2 class="text-base font-bold text-white flex items-center gap-2">
                <svg class="w-5 h-5 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                <span>Sélection Rapide des Meilleurs Modèles OpenRouter</span>
            </h2>
            <p class="text-xs text-slate-400 mt-1">Cliquez sur « Activer ce Modèle » pour basculer instantanément l'ensemble de la plateforme sur ce modèle.</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            @foreach($popularModels as $pm)
                @php $isActive = ($currentGlobalModel === $pm['id']); @endphp
                <div class="bg-slate-900/70 border {{ $isActive ? 'border-indigo-500 ring-2 ring-indigo-500/20 bg-indigo-950/10' : 'border-slate-800 hover:border-slate-700' }} p-5 rounded-2xl flex flex-col justify-between transition shadow-lg relative">
                    @if($isActive)
                        <span class="absolute -top-2.5 right-4 px-2 py-0.5 rounded-full text-[9px] font-black uppercase bg-indigo-600 text-white shadow-md">
                            EN SERVICE
                        </span>
                    @endif

                    <div>
                        <div class="flex items-center justify-between gap-2">
                            <span class="text-[10px] font-bold text-slate-500 uppercase tracking-wider">{{ $pm['provider'] }}</span>
                            <span class="px-2 py-0.5 rounded text-[10px] font-bold {{ $isActive ? 'bg-indigo-500/20 text-indigo-300' : 'bg-slate-800 text-slate-400' }}">
                                {{ $pm['badge'] }}
                            </span>
                        </div>

                        <h3 class="text-base font-bold text-white mt-2">{{ $pm['name'] }}</h3>
                        <p class="text-[11px] font-mono text-indigo-400/90 break-all mt-0.5">{{ $pm['id'] }}</p>

                        <p class="text-xs text-slate-400 mt-3 leading-relaxed">
                            {{ $pm['description'] }}
                        </p>
                    </div>

                    <div class="pt-4 mt-4 border-t border-slate-800/80 flex items-center justify-between gap-2">
                        <button type="button" onclick="testModel('{{ $pm['id'] }}')" class="py-1.5 px-3 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs font-semibold transition">
                            Tester
                        </button>

                        @if($isActive)
                            <span class="text-xs font-bold text-emerald-400 flex items-center gap-1">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                Actif
                            </span>
                        @else
                            <form action="{{ route('admin.ai_settings.update') }}" method="POST">
                                @csrf
                                <input type="hidden" name="model" value="{{ $pm['id'] }}">
                                <input type="hidden" name="task" value="global">
                                <button type="submit" class="py-1.5 px-4 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-xs font-bold shadow-md shadow-indigo-600/20 transition">
                                    Activer ce Modèle
                                </button>
                            </form>
                        @endif
                    </div>
                </div>
            @endforeach
        </div>
    </div>

    <!-- Custom Model Input Form -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-xl">
        <div class="max-w-2xl">
            <h3 class="text-base font-bold text-white flex items-center gap-2">
                <svg class="w-4 h-4 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path></svg>
                <span>Définir un Modèle Personnalisé (Identifiant OpenRouter)</span>
            </h3>
            <p class="text-xs text-slate-400 mt-1">
                Vous pouvez saisir n'importe quel identifiant de modèle disponible sur <a href="https://openrouter.ai/models" target="_blank" class="text-indigo-400 hover:underline">openrouter.ai/models</a> (ex: <code class="text-indigo-300">anthropic/claude-3.7-sonnet</code>, <code class="text-indigo-300">google/gemini-2.0-flash-exp</code>, etc.).
            </p>

            <form action="{{ route('admin.ai_settings.update') }}" method="POST" class="mt-5 space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Identifiant du Modèle OpenRouter</label>
                    <input type="text" name="model" value="{{ $currentGlobalModel }}" required placeholder="ex: google/gemini-2.5-flash" class="w-full px-4 py-2.5 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white font-mono placeholder-slate-600 focus:outline-none transition">
                </div>

                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1.5">Portée de l'Application</label>
                    <select name="task" class="w-full px-4 py-2.5 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white focus:outline-none transition">
                        <option value="global">Global (Toutes les générations & éditions de l'app)</option>
                        <option value="document_generation">Génération Complète de Sites uniquement (document_generation)</option>
                        <option value="editing">Édition & Modifications IA uniquement (editing)</option>
                        <option value="remix">Remix de Styles uniquement (remix)</option>
                    </select>
                </div>

                <div class="flex items-center gap-3 pt-2">
                    <button type="submit" class="px-5 py-2.5 bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-xs font-bold rounded-xl shadow-lg shadow-indigo-600/30 transition">
                        Enregistrer et Appliquer Immédiatement
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Detailed Task Mapping Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="p-4 border-b border-slate-800">
            <h3 class="text-xs font-bold text-slate-300 uppercase tracking-wider">Modèles Résolus par Type de Tâche</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3 px-4">Tâche IA</th>
                        <th class="py-3 px-4">Description</th>
                        <th class="py-3 px-4">Modèle Actuellement Résolu</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60 font-mono">
                    @foreach($resolvedModels as $task => $model)
                        <tr class="hover:bg-slate-800/30 transition">
                            <td class="py-3 px-4 font-bold text-indigo-400">{{ $task }}</td>
                            <td class="py-3 px-4 font-sans text-slate-400 text-xs">
                                @switch($task)
                                    @case('document_generation') Génération complète du document de site @break
                                    @case('editing') Modifications chirurgicales de sections par invite @break
                                    @case('remix') Variations visuelles, typographies et palettes @break
                                    @case('business_analysis') Extraction des besoins et persona métier @break
                                    @case('website_planning') Structuration du plan de page @break
                                    @case('vision_qa') Analyse d'images et capture visuelle @break
                                    @default Pipeline IA standard @break
                                @endswitch
                            </td>
                            <td class="py-3 px-4 text-emerald-400 font-bold">{{ $model }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <!-- Script for Live Model Ping -->
    <script>
        function testModel(modelId) {
            const box = document.getElementById('testResultBox');
            box.classList.remove('hidden', 'bg-emerald-500/10', 'text-emerald-400', 'border-emerald-500/30', 'bg-rose-500/10', 'text-rose-400', 'border-rose-500/30');
            box.classList.add('bg-indigo-500/10', 'text-indigo-400', 'border', 'border-indigo-500/20');
            box.innerHTML = 'Envoi d\'une requête de test à OpenRouter pour <span class="font-bold">' + modelId + '</span>...';

            fetch('{{ route("admin.ai_settings.test") }}', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': '{{ csrf_token() }}',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ model: modelId })
            })
            .then(res => res.json().then(data => ({ ok: res.ok, data })))
            .then(res => {
                box.classList.remove('bg-indigo-500/10', 'text-indigo-400', 'border-indigo-500/20');
                if (res.ok && res.data.success) {
                    box.classList.add('bg-emerald-500/10', 'text-emerald-400', 'border', 'border-emerald-500/30');
                    box.innerHTML = '<strong>Succès !</strong> ' + res.data.message + '<br><span class="text-[10px] text-emerald-300/80">Modèle: ' + res.data.model + ' · ' + res.data.duration_ms + 'ms</span>';
                } else {
                    box.classList.add('bg-rose-500/10', 'text-rose-400', 'border', 'border-rose-500/30');
                    box.innerHTML = '<strong>Échec :</strong> ' + (res.data.error || 'Erreur inconnue') + '<br><span class="text-[10px]">Temps: ' + (res.data.duration_ms || 0) + 'ms</span>';
                }
            })
            .catch(err => {
                box.classList.remove('bg-indigo-500/10', 'text-indigo-400', 'border-indigo-500/20');
                box.classList.add('bg-rose-500/10', 'text-rose-400', 'border', 'border-rose-500/30');
                box.innerHTML = '<strong>Erreur réseau :</strong> ' + err.message;
            });
        }
    </script>
@endsection
