@extends('layouts.admin')

@section('title', 'Deployments Log')
@section('page_title', 'System Deployments')
@section('breadcrumbs', 'Edge Build History, Cloudflare Routing & Audit Logs')

@section('content')
    <!-- Metric KPI Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Deployments</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Historical builds</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-emerald-400 uppercase tracking-wider">Successful</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['deployed'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Live on edge</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-rose-400 uppercase tracking-wider">Failed Builds</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['failed'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Requires inspection</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-amber-400 uppercase tracking-wider">Pending / Queued</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['pending'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">In build pipeline</p>
        </div>
    </div>

    <!-- Filters & Search -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-900/40 p-3 rounded-2xl border border-slate-800">
        <div class="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
            <a href="{{ route('admin.deployments.index') }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ !request('status') ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                All ({{ $metrics['total'] }})
            </a>
            <a href="{{ route('admin.deployments.index', ['status' => 'deployed']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('status') === 'deployed' ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Deployed ({{ $metrics['deployed'] }})
            </a>
            <a href="{{ route('admin.deployments.index', ['status' => 'failed']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('status') === 'failed' ? 'bg-rose-600 text-white shadow-md shadow-rose-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Failed ({{ $metrics['failed'] }})
            </a>
        </div>
        <form action="{{ route('admin.deployments.index') }}" method="GET" class="w-full sm:w-72">
            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Search site or subdomain..." class="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                <svg class="w-4 h-4 text-slate-500 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </div>
        </form>
    </div>

    <!-- Deployments Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3.5 px-4">Website</th>
                        <th class="py-3.5 px-4">Status</th>
                        <th class="py-3.5 px-4">Storage Path</th>
                        <th class="py-3.5 px-4">Domains Deployed</th>
                        <th class="py-3.5 px-4">Deployed At</th>
                        <th class="py-3.5 px-4 text-right">Preview</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($deployments as $dep)
                        <tr class="hover:bg-slate-800/30 transition">
                            <td class="py-3.5 px-4">
                                <div class="font-bold text-white text-sm">{{ $dep->website?->name ?? 'Deleted Website' }}</div>
                                <div class="text-[11px] text-slate-400 font-mono">{{ $dep->website?->subdomain ?: $dep->website?->slug }}</div>
                            </td>
                            <td class="py-3.5 px-4">
                                @if($dep->status->value === 'deployed')
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> Deployed
                                    </span>
                                @elseif($dep->status->value === 'failed')
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                        Failed
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                                        {{ ucfirst($dep->status->value) }}
                                    </span>
                                @endif
                            </td>
                            <td class="py-3.5 px-4 font-mono text-slate-400 text-[11px]">
                                {{ $dep->storage_path ?: 'sites/' . $dep->website_id . '/live' }}
                            </td>
                            <td class="py-3.5 px-4 text-slate-300">
                                @if(!empty($dep->domains_deployed) && is_array($dep->domains_deployed))
                                    {{ implode(', ', $dep->domains_deployed) }}
                                @else
                                    <span class="text-slate-500">Default Subdomain</span>
                                @endif
                            </td>
                            <td class="py-3.5 px-4 text-slate-400 text-[11px]">
                                {{ $dep->deployed_at ? $dep->deployed_at->diffForHumans() : $dep->created_at->diffForHumans() }}
                            </td>
                            <td class="py-3.5 px-4 text-right">
                                @if($dep->website)
                                    <a href="/sites/{{ $dep->website->subdomain ?: $dep->website->slug }}" target="_blank" class="px-2.5 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[11px] font-medium transition">
                                        Live ↗
                                    </a>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="py-12 text-center text-slate-500">
                                No deployments found matching your filter.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($deployments->hasPages())
            <div class="p-4 border-t border-slate-800 bg-slate-900/40">
                {{ $deployments->links() }}
            </div>
        @endif
    </div>
@endsection

