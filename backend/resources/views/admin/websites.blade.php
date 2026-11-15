@extends('layouts.admin')

@section('title', 'Websites Management')
@section('page_title', 'User Websites')
@section('breadcrumbs', 'Subdomains, Deployments & Publication Status')

@section('topbar_actions')
    <a href="{{ route('admin.templates.index') }}" class="px-3.5 py-1.5 text-xs font-semibold text-white bg-slate-800 hover:bg-slate-700 rounded-lg border border-slate-700 transition flex items-center gap-1.5 shadow-sm">
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
        <span>Template Studio</span>
    </a>
@endsection

@section('content')
    <!-- Metric KPI Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Sites</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Across all projects</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-emerald-400 uppercase tracking-wider">Published & Live</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['published'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Edge hosted</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-amber-400 uppercase tracking-wider">In Progress (Draft)</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['draft'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Under mobile editing</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Archived</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['archived'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Decommissioned</p>
        </div>
    </div>

    <!-- Filters & Search -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-900/40 p-3 rounded-2xl border border-slate-800">
        <div class="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
            <a href="{{ route('admin.websites.index') }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ !request('status') ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                All ({{ $metrics['total'] }})
            </a>
            <a href="{{ route('admin.websites.index', ['status' => 'published']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('status') === 'published' ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Published ({{ $metrics['published'] }})
            </a>
            <a href="{{ route('admin.websites.index', ['status' => 'draft']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('status') === 'draft' ? 'bg-amber-500 text-black shadow-md shadow-amber-500/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Drafts ({{ $metrics['draft'] }})
            </a>
        </div>
        <form action="{{ route('admin.websites.index') }}" method="GET" class="w-full sm:w-72">
            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Search site or subdomain..." class="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                <svg class="w-4 h-4 text-slate-500 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </div>
        </form>
    </div>

    <!-- Websites Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3.5 px-4">Website & Subdomain</th>
                        <th class="py-3.5 px-4">Owner & Project</th>
                        <th class="py-3.5 px-4">Status</th>
                        <th class="py-3.5 px-4">Revisions</th>
                        <th class="py-3.5 px-4">Last Updated</th>
                        <th class="py-3.5 px-4 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($websites as $site)
                        <tr class="hover:bg-slate-800/30 transition">
                            <td class="py-3.5 px-4">
                                <div class="font-bold text-white text-sm">{{ $site->name }}</div>
                                <div class="text-[11px] text-indigo-400 font-mono flex items-center gap-1 mt-0.5">
                                    <span>/sites/{{ $site->subdomain ?: $site->slug }}</span>
                                </div>
                            </td>
                            <td class="py-3.5 px-4">
                                <div class="font-medium text-slate-200">{{ $site->project?->user?->name ?? 'Unknown User' }}</div>
                                <div class="text-[11px] text-slate-500">{{ $site->project?->name ?? 'Default Project' }}</div>
                            </td>
                            <td class="py-3.5 px-4">
                                @if($site->status->value === 'published')
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> Published
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                                        Draft
                                    </span>
                                @endif
                            </td>
                            <td class="py-3.5 px-4 font-mono text-slate-300">
                                v{{ $site->revision_number ?? 1 }}
                            </td>
                            <td class="py-3.5 px-4 text-slate-400 text-[11px]">
                                {{ $site->updated_at->diffForHumans() }}
                            </td>
                            <td class="py-3.5 px-4 text-right">
                                <div class="flex items-center justify-end space-x-2">
                                    <!-- Live Site Preview -->
                                    @if($site->status->value === 'published')
                                        <a href="/sites/{{ $site->subdomain ?: $site->slug }}" target="_blank" class="px-2.5 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-200 hover:text-white text-[11px] font-medium transition" title="Preview Published Site">
                                            Live Site ↗
                                        </a>
                                    @endif

                                    <!-- Convert to Template Button -->
                                    <button onclick="openConvertModal('{{ $site->id }}', '{{ addslashes($site->name) }}')" class="px-2.5 py-1 rounded bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 text-[11px] font-semibold transition flex items-center gap-1">
                                        <span>✦</span> Template
                                    </button>

                                    <!-- Status Toggle -->
                                    <form action="{{ route('admin.websites.toggle_status', $site) }}" method="POST" class="inline">
                                        @csrf
                                        <button type="submit" class="px-2.5 py-1 rounded {{ $site->status->value === 'published' ? 'bg-amber-500/10 text-amber-400 hover:bg-amber-500/20' : 'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20' }} text-[11px] font-semibold transition">
                                            {{ $site->status->value === 'published' ? 'Unpublish' : 'Publish' }}
                                        </button>
                                    </form>

                                    <!-- Delete Website -->
                                    <form action="{{ route('admin.websites.destroy', $site) }}" method="POST" onsubmit="return confirm('Delete website {{ addslashes($site->name) }}?')" class="inline">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1 rounded bg-slate-800 hover:bg-rose-500/20 text-slate-400 hover:text-rose-400 transition" title="Delete">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="py-12 text-center text-slate-500">
                                No websites found matching your filter.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($websites->hasPages())
            <div class="p-4 border-t border-slate-800 bg-slate-900/40">
                {{ $websites->links() }}
            </div>
        @endif
    </div>

    <!-- Convert to Template Modal -->
    <div id="modalConvertDirect" class="fixed inset-0 z-50 bg-black/75 backdrop-blur-sm hidden flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 space-y-4 shadow-2xl">
            <div class="flex items-center justify-between border-b border-slate-800 pb-3">
                <h3 class="text-sm font-bold text-white">Convert Website to Curated Template</h3>
                <button onclick="document.getElementById('modalConvertDirect').classList.add('hidden')" class="text-slate-400 hover:text-white">&times;</button>
            </div>
            <form id="convertDirectForm" method="POST" class="space-y-3">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Template Name</label>
                    <input type="text" name="name" id="convertSiteNameInput" required class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-semibold text-slate-300 mb-1">Industry</label>
                        <input type="text" name="industry" placeholder="e.g. Portfolio, SaaS" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                    </div>
                    <div>
                        <label class="block text-xs font-semibold text-slate-300 mb-1">Badge Tag</label>
                        <input type="text" name="badge" value="EDITOR'S PICK" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Category</label>
                    <select name="category_id" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                        <option value="">Uncategorized</option>
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="flex items-center gap-2 pt-1">
                    <input type="checkbox" name="is_featured" value="1" checked id="direct_featured_chk" class="rounded bg-slate-950 border-slate-800 text-indigo-600 focus:ring-0">
                    <label for="direct_featured_chk" class="text-xs text-slate-300">Feature this template as Curated showcase</label>
                </div>
                <div class="flex justify-end gap-3 pt-3 border-t border-slate-800">
                    <button type="button" onclick="document.getElementById('modalConvertDirect').classList.add('hidden')" class="px-4 py-2 text-xs font-semibold text-slate-400 hover:text-white bg-slate-800 rounded-xl">Cancel</button>
                    <button type="submit" class="px-4 py-2 text-xs font-bold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-md shadow-indigo-600/30">Convert to Template</button>
                </div>
            </form>
        </div>
    </div>
@endsection

@section('scripts')
<script>
    function openConvertModal(websiteId, siteName) {
        const form = document.getElementById('convertDirectForm');
        form.action = `/admin/websites/${websiteId}/convert-to-template`;
        document.getElementById('convertSiteNameInput').value = siteName + ' Theme';
        document.getElementById('modalConvertDirect').classList.remove('hidden');
    }
</script>
@endsection

