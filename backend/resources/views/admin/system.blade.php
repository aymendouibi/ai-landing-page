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
@endsection

