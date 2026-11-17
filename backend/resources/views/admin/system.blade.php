@extends('layouts.admin')

@section('title', 'System Health & Diagnostics')
@section('page_title', 'System Health')
@section('breadcrumbs', 'Runtime Environment, Services & Infrastructure Status')

@section('content')
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Application Environment -->
        <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-3">
            <div class="flex items-center gap-2.5 pb-2 border-b border-slate-800/80">
                <div class="w-8 h-8 rounded-lg bg-indigo-500/10 text-indigo-400 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path></svg>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-white">Application Runtime</h3>
                    <p class="text-[11px] text-slate-400">Core software stack</p>
                </div>
            </div>
            <div class="space-y-2 text-xs">
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">PHP Version</span>
                    <span class="font-mono text-emerald-400 font-semibold">{{ $systemInfo['php_version'] }}</span>
                </div>
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Laravel Framework</span>
                    <span class="font-mono text-indigo-400 font-semibold">v{{ $systemInfo['laravel_version'] }}</span>
                </div>
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Environment</span>
                    <span class="px-2 py-0.5 rounded bg-slate-800 text-slate-200 font-medium">{{ $systemInfo['environment'] }}</span>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-slate-400">Debug Mode</span>
                    <span class="font-medium text-slate-300">{{ $systemInfo['debug_mode'] }}</span>
                </div>
            </div>
        </div>

        <!-- Database Status -->
        <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-3">
            <div class="flex items-center gap-2.5 pb-2 border-b border-slate-800/80">
                <div class="w-8 h-8 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"></path></svg>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-white">Database Service</h3>
                    <p class="text-[11px] text-slate-400">PostgreSQL Primary</p>
                </div>
            </div>
            <div class="space-y-2 text-xs">
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Connection Status</span>
                    <span class="px-2 py-0.5 rounded-full text-[10px] font-bold {{ $systemInfo['db_status'] === 'Connected' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-rose-500/10 text-rose-400' }}">
                        ● {{ $systemInfo['db_status'] }}
                    </span>
                </div>
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Driver</span>
                    <span class="font-mono text-slate-200 uppercase">{{ $systemInfo['db_driver'] }}</span>
                </div>
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Host</span>
                    <span class="font-mono text-slate-300">{{ $systemInfo['db_host'] }}</span>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-slate-400">Database Name</span>
                    <span class="font-mono text-slate-300">{{ $systemInfo['db_database'] }}</span>
                </div>
            </div>
        </div>

        <!-- Node / Site Renderer -->
        <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-3">
            <div class="flex items-center gap-2.5 pb-2 border-b border-slate-800/80">
                <div class="w-8 h-8 rounded-lg bg-purple-500/10 text-purple-400 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-white">Renderer Engine</h3>
                    <p class="text-[11px] text-slate-400">Node SSR service</p>
                </div>
            </div>
            <div class="space-y-2 text-xs">
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Health Check</span>
                    <span class="px-2 py-0.5 rounded-full text-[10px] font-bold {{ str_contains($systemInfo['renderer_status'], 'Online') ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-amber-500/10 text-amber-400' }}">
                        {{ $systemInfo['renderer_status'] }}
                    </span>
                </div>
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Service URL</span>
                    <span class="font-mono text-slate-300 text-[11px] truncate max-w-[180px]">{{ $systemInfo['renderer_url'] }}</span>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-slate-400">App URL</span>
                    <span class="font-mono text-slate-300 text-[11px] truncate max-w-[180px]">{{ $systemInfo['app_url'] }}</span>
                </div>
            </div>
        </div>

        <!-- Infrastructure & Drivers -->
        <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-3">
            <div class="flex items-center gap-2.5 pb-2 border-b border-slate-800/80">
                <div class="w-8 h-8 rounded-lg bg-amber-500/10 text-amber-400 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-white">Drivers & Queues</h3>
                    <p class="text-[11px] text-slate-400">Async processing</p>
                </div>
            </div>
            <div class="space-y-2 text-xs">
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Cache Driver</span>
                    <span class="font-mono text-slate-200">{{ $systemInfo['cache_driver'] }}</span>
                </div>
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Queue Connection</span>
                    <span class="font-mono text-slate-200">{{ $systemInfo['queue_driver'] }}</span>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-slate-400">Session Driver</span>
                    <span class="font-mono text-slate-200">{{ $systemInfo['session_driver'] }}</span>
                </div>
            </div>
        </div>

        <!-- Storage & Disks -->
        <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-3">
            <div class="flex items-center gap-2.5 pb-2 border-b border-slate-800/80">
                <div class="w-8 h-8 rounded-lg bg-blue-500/10 text-blue-400 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path></svg>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-white">Storage Capacity</h3>
                    <p class="text-[11px] text-slate-400">Server disk volume</p>
                </div>
            </div>
            <div class="space-y-2 text-xs">
                <div class="flex justify-between py-1 border-b border-slate-800/40">
                    <span class="text-slate-400">Available Free Space</span>
                    <span class="font-mono text-emerald-400 font-semibold">{{ $systemInfo['disk_free'] }}</span>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-slate-400">Total Volume Size</span>
                    <span class="font-mono text-slate-300">{{ $systemInfo['disk_total'] }}</span>
                </div>
            </div>
        </div>

        <!-- Domain & Routing -->
        <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-3">
            <div class="flex items-center gap-2.5 pb-2 border-b border-slate-800/80">
                <div class="w-8 h-8 rounded-lg bg-rose-500/10 text-rose-400 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path></svg>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-white">Platform Domain</h3>
                    <p class="text-[11px] text-slate-400">Subdomain edge delivery</p>
                </div>
            </div>
            <div class="space-y-2 text-xs">
                <div class="py-1">
                    <span class="text-slate-400 block mb-1">Configured Platform Domain:</span>
                    <span class="font-mono text-indigo-400 text-xs break-all">{{ $systemInfo['platform_domain'] }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Web Console & Artisan Runner (Free Shell Alternative) -->
    <div class="mt-6 bg-slate-900/60 border border-slate-800 rounded-2xl p-6 shadow-xl">
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between pb-4 border-b border-slate-800 gap-3">
            <div>
                <h3 class="text-base font-bold text-white flex items-center gap-2">
                    <svg class="w-5 h-5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                    Web Terminal & Artisan Console
                </h3>
                <p class="text-xs text-slate-400 mt-0.5">Run maintenance and notification commands directly without Render Pro or paid Shell</p>
            </div>
            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                100% Free • No CLI Required
            </span>
        </div>

        <form action="{{ route('admin.system.run_artisan') }}" method="POST" class="mt-4 space-y-4">
            @csrf
            <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1.5">Select or Type Artisan Command</label>
                <div class="flex flex-col sm:flex-row gap-3">
                    <select id="presetSelect" onchange="document.getElementById('cmdInput').value = this.value" class="bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl px-3 py-2 text-xs text-white focus:outline-none transition sm:w-72">
                        <option value="notifications:remind-drafts">⚡ notifications:remind-drafts (Send reminders)</option>
                        <option value="migrate:status">📋 migrate:status (Check DB migrations)</option>
                        <option value="migrate">🚀 migrate (Run pending migrations)</option>
                        <option value="cache:clear">🧹 cache:clear (Clear cache)</option>
                        <option value="config:clear">⚙️ config:clear (Clear config cache)</option>
                        <option value="route:list">🗺️ route:list (List API routes)</option>
                        <option value="about">ℹ️ about (Environment summary)</option>
                    </select>

                    <div class="flex-1 relative">
                        <input type="text" name="command" id="cmdInput" value="{{ session('command_run', 'notifications:remind-drafts') }}" required placeholder="e.g. notifications:remind-drafts" class="w-full bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl pl-8 pr-4 py-2 text-xs text-white font-mono focus:outline-none transition">
                        <span class="absolute left-3 top-2 text-slate-500 font-mono text-xs">&gt;</span>
                    </div>

                    <button type="submit" class="px-5 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl text-xs font-bold transition shadow-lg shadow-emerald-600/20 flex items-center justify-center gap-1.5 shrink-0">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        <span>Run Command</span>
                    </button>
                </div>
            </div>
        </form>

        <!-- Command Execution Output Terminal -->
        @if(session('command_output') || session('command_error'))
            <div class="mt-4 pt-4 border-t border-slate-800/80">
                <div class="flex items-center justify-between mb-2">
                    <span class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider font-mono">
                        Output: $ php artisan {{ session('command_run') }}
                    </span>
                    <span class="text-[10px] px-2 py-0.5 rounded {{ session('command_error') ? 'bg-rose-500/20 text-rose-300' : 'bg-emerald-500/20 text-emerald-300' }} font-bold">
                        {{ session('command_error') ? 'FAILED' : 'SUCCESS' }}
                    </span>
                </div>
                <pre class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-[11px] font-mono text-slate-200 overflow-x-auto max-h-96 leading-relaxed">{{ session('command_error') ?: session('command_output') }}</pre>
            </div>
        @endif
    </div>
@endsection

