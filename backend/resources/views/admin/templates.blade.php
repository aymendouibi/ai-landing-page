@extends('layouts.admin')

@section('title', 'Template Studio')
@section('page_title', 'Template Studio')
@section('breadcrumbs', 'Curated Catalog, Showcase Badges & Template Creation')

@section('topbar_actions')
    <button onclick="document.getElementById('modalImportUrl').classList.remove('hidden')" class="px-3.5 py-1.5 text-xs font-bold text-white bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 rounded-lg shadow-md shadow-emerald-600/30 transition flex items-center gap-1.5">
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path></svg>
        <span>⚡ Import from Link</span>
    </button>
    <button onclick="document.getElementById('modalConvertWebsite').classList.remove('hidden')" class="px-3.5 py-1.5 text-xs font-semibold text-white bg-slate-800 hover:bg-slate-700 rounded-lg border border-slate-700 transition flex items-center gap-1.5 shadow-sm">
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path></svg>
        <span>Convert Site to Template</span>
    </button>
    <button onclick="document.getElementById('modalNewTemplate').classList.remove('hidden')" class="px-3.5 py-1.5 text-xs font-bold text-white bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 rounded-lg transition shadow-md shadow-indigo-600/30 flex items-center gap-1.5">
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
        <span>New Template</span>
    </button>
@endsection

@section('content')
    <!-- Metric KPI Cards -->
    <div class="grid grid-cols-2 lg:grid-cols-5 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Templates</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Available in catalog</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl relative overflow-hidden">
            <div class="absolute -right-2 -bottom-2 w-16 h-16 bg-amber-500/5 rounded-full blur-xl pointer-events-none"></div>
            <p class="text-[11px] font-semibold text-amber-400 uppercase tracking-wider">Curated Showcases</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['curated'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Featured with badges</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-indigo-400 uppercase tracking-wider">Community Shared</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['community'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Shared by user accounts</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-emerald-400 uppercase tracking-wider">Published</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['published'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Live in mobile feed</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-purple-400 uppercase tracking-wider">Total Generations</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total_uses'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Cloned websites created</p>
        </div>
    </div>

    <!-- Filter & Search Bar -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-900/40 p-3 rounded-2xl border border-slate-800">
        <div class="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
            <a href="/admin/templates" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ !request('featured') && !request('community') && !request('status') ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                All ({{ $metrics['total'] }})
            </a>
            <a href="/admin/templates?featured=1" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('featured') ? 'bg-amber-500 text-black shadow-md shadow-amber-500/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition flex items-center gap-1">
                <span>✦</span> Curated ({{ $metrics['curated'] }})
            </a>
            <a href="/admin/templates?community=1" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('community') ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Community ({{ $metrics['community'] }})
            </a>
            <a href="/admin/templates?status=published" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('status') === 'published' ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Live Catalog ({{ $metrics['published'] }})
            </a>
        </div>
        <form action="/admin/templates" method="GET" class="w-full sm:w-72">
            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Search templates, badges..." class="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                <svg class="w-4 h-4 text-slate-500 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </div>
        </form>
    </div>

    <!-- Templates Data Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3.5 px-4">Design</th>
                        <th class="py-3.5 px-4">Badge / Highlight</th>
                        <th class="py-3.5 px-4">Category & Industry</th>
                        <th class="py-3.5 px-4">Author</th>
                        <th class="py-3.5 px-4 text-center">Uses</th>
                        <th class="py-3.5 px-4 text-center">Status</th>
                        <th class="py-3.5 px-4 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($templates as $tpl)
                        <tr class="hover:bg-slate-800/30 transition group">
                            <!-- Design Thumbnail & Name -->
                            <td class="py-3.5 px-4">
                                <div class="flex items-center space-x-3.5">
                                    <div class="w-16 h-12 rounded-xl overflow-hidden bg-slate-800 flex-shrink-0 border border-slate-700/60 relative">
                                        @if(!empty($tpl->preview_images) && is_array($tpl->preview_images))
                                            <img src="{{ $tpl->preview_images[0] }}" alt="{{ $tpl->name }}" class="w-full h-full object-cover">
                                        @else
                                            <div class="w-full h-full flex items-center justify-center text-slate-600 text-[10px]">No img</div>
                                        @endif
                                        @if($tpl->is_featured)
                                            <div class="absolute top-1 left-1 w-2.5 h-2.5 rounded-full bg-amber-400 ring-2 ring-slate-900"></div>
                                        @endif
                                    </div>
                                    <div>
                                        <a href="{{ route('admin.templates.show', $tpl) }}" class="font-bold text-white text-sm hover:text-indigo-400 transition">{{ $tpl->name }}</a>
                                        <div class="text-slate-400 text-[11px] truncate max-w-xs">{{ $tpl->description ?: 'No description provided.' }}</div>
                                    </div>
                                </div>
                            </td>

                            <!-- Badge Tag -->
                            <td class="py-3.5 px-4">
                                @if($tpl->badge)
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md font-bold text-[10px] tracking-wide {{ $tpl->is_featured ? 'bg-amber-400/10 text-amber-300 border border-amber-400/30' : 'bg-slate-800 text-slate-300 border border-slate-700' }}">
                                        <span>✦</span> {{ $tpl->badge }}
                                    </span>
                                @else
                                    <span class="text-slate-600 italic">None</span>
                                @endif
                            </td>

                            <!-- Category & Industry -->
                            <td class="py-3.5 px-4">
                                <span class="font-medium text-slate-200">{{ $tpl->industry ?: 'General' }}</span>
                                <div class="text-[11px] text-slate-500">{{ $tpl->category?->name ?: 'Uncategorized' }}</div>
                            </td>

                            <!-- Author -->
                            <td class="py-3.5 px-4">
                                @if($tpl->user)
                                    <div class="flex items-center gap-1.5">
                                        <span class="w-5 h-5 rounded-full bg-indigo-500/20 text-indigo-400 flex items-center justify-center font-bold text-[9px]">U</span>
                                        <span class="font-medium text-slate-200">{{ $tpl->user->name }}</span>
                                    </div>
                                    <span class="text-[10px] text-slate-500">Community shared</span>
                                @else
                                    <span class="font-semibold text-slate-300">{{ $tpl->author ?: 'System' }}</span>
                                    <div class="text-[10px] text-slate-500">Official preset</div>
                                @endif
                            </td>

                            <!-- Uses Count -->
                            <td class="py-3.5 px-4 text-center">
                                <span class="font-bold text-slate-100 bg-slate-800/80 px-2 py-0.5 rounded-md">{{ $tpl->use_count }}</span>
                            </td>

                            <!-- Status -->
                            <td class="py-3.5 px-4 text-center">
                                @if($tpl->status->value === 'published')
                                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> Live
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-800 text-slate-400">
                                        {{ ucfirst($tpl->status->value) }}
                                    </span>
                                @endif
                            </td>

                            <!-- Actions -->
                            <td class="py-3.5 px-4 text-right">
                                <div class="flex items-center justify-end space-x-2">
                                    <!-- Live Preview Iframe Link -->
                                    <a href="{{ route('admin.templates.preview', $tpl) }}" target="_blank" title="Live Preview Template" class="p-1.5 rounded-lg bg-slate-800/80 border border-slate-700 text-slate-400 hover:text-white hover:bg-slate-700 transition">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                    </a>

                                    <!-- Details Inspector -->
                                    <a href="{{ route('admin.templates.show', $tpl) }}" title="View Schema & Details" class="p-1.5 rounded-lg bg-slate-800/80 border border-slate-700 text-slate-400 hover:text-indigo-400 hover:bg-indigo-500/10 transition">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path></svg>
                                    </a>

                                    <!-- Feature / Unfeature Button -->
                                    <form action="{{ route('admin.templates.toggle_feature', $tpl) }}" method="POST">
                                        @csrf
                                        <button type="submit" title="{{ $tpl->is_featured ? 'Remove from Curated' : 'Feature as Editor Pick' }}" class="p-1.5 rounded-lg border {{ $tpl->is_featured ? 'bg-amber-400/20 border-amber-400/40 text-amber-300' : 'bg-slate-800/80 border-slate-700 text-slate-400 hover:text-white hover:bg-slate-700' }} transition">
                                            <svg class="w-4 h-4" fill="{{ $tpl->is_featured ? 'currentColor' : 'none' }}" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"></path></svg>
                                        </button>
                                    </form>

                                    <!-- Delete Button -->
                                    <form action="{{ route('admin.templates.destroy', $tpl) }}" method="POST" onsubmit="return confirm('Delete template {{ addslashes($tpl->name) }}?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1.5 rounded-lg bg-slate-800/80 border border-slate-700 text-slate-400 hover:text-red-400 hover:bg-red-500/10 hover:border-red-500/30 transition">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="py-12 text-center text-slate-500">
                                No templates found matching this view.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        @if($templates->hasPages())
            <div class="p-4 border-t border-slate-800 bg-slate-900/40">
                {{ $templates->links() }}
            </div>
        @endif
    </div>

    <!-- Modal: New Template -->
    <div id="modalNewTemplate" class="fixed inset-0 z-50 bg-black/75 backdrop-blur-sm hidden flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 space-y-5 shadow-2xl">
            <div class="flex items-center justify-between border-b border-slate-800 pb-4">
                <h3 class="text-base font-bold text-white">Create New Template</h3>
                <button onclick="document.getElementById('modalNewTemplate').classList.add('hidden')" class="text-slate-400 hover:text-white">&times;</button>
            </div>
            <form action="{{ route('admin.templates.store') }}" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Template Name</label>
                    <input type="text" name="name" required placeholder="e.g. Haven Studio" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-semibold text-slate-300 mb-1">Industry</label>
                        <input type="text" name="industry" placeholder="e.g. Food & drink, Architecture" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                    </div>
                    <div>
                        <label class="block text-xs font-semibold text-slate-300 mb-1">Badge Tag</label>
                        <input type="text" name="badge" placeholder="e.g. EDITOR'S PICK, NEW" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
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
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Preview Cover Image URL</label>
                    <input type="url" name="preview_image" placeholder="https://images.unsplash.com/..." class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Description / Tagline</label>
                    <textarea name="description" rows="2" placeholder="Warm tones and rich storytelling..." class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500"></textarea>
                </div>
                <div class="flex items-center gap-2 pt-1">
                    <input type="checkbox" name="is_featured" value="1" id="is_featured_chk" class="rounded bg-slate-950 border-slate-800 text-indigo-600 focus:ring-0">
                    <label for="is_featured_chk" class="text-xs text-slate-300">Feature this template as Curated showcase</label>
                </div>
                <div class="flex justify-end gap-3 pt-3 border-t border-slate-800">
                    <button type="button" onclick="document.getElementById('modalNewTemplate').classList.add('hidden')" class="px-4 py-2 text-xs font-semibold text-slate-400 hover:text-white bg-slate-800 rounded-xl">Cancel</button>
                    <button type="submit" class="px-4 py-2 text-xs font-bold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-md shadow-indigo-600/30">Create Template</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal: Convert User Website to Template -->
    <div id="modalConvertWebsite" class="fixed inset-0 z-50 bg-black/75 backdrop-blur-sm hidden flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 space-y-5 shadow-2xl">
            <div class="flex items-center justify-between border-b border-slate-800 pb-4">
                <h3 class="text-base font-bold text-white">Convert User Site to Curated Template</h3>
                <button onclick="document.getElementById('modalConvertWebsite').classList.add('hidden')" class="text-slate-400 hover:text-white">&times;</button>
            </div>
            <form action="{{ route('admin.templates.convert_website') }}" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Source Website</label>
                    <select name="website_id" required class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                        @foreach($recentWebsites as $site)
                            <option value="{{ $site->id }}">
                                {{ $site->name }} ({{ $site->subdomain ?: $site->slug }}) &bull; {{ $site->project?->user?->name ?? 'User' }}
                            </option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Template Name</label>
                    <input type="text" name="name" required placeholder="e.g. Modern Architecture Portfolio" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-semibold text-slate-300 mb-1">Industry</label>
                        <input type="text" name="industry" placeholder="e.g. Creative, Agency" class="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-indigo-500">
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
                    <input type="checkbox" name="is_featured" value="1" checked id="convert_featured_chk" class="rounded bg-slate-950 border-slate-800 text-indigo-600 focus:ring-0">
                    <label for="convert_featured_chk" class="text-xs text-slate-300">Feature immediately in Curated Edit</label>
                </div>
                <div class="flex justify-end gap-3 pt-3 border-t border-slate-800">
                    <button type="button" onclick="document.getElementById('modalConvertWebsite').classList.add('hidden')" class="px-4 py-2 text-xs font-semibold text-slate-400 hover:text-white bg-slate-800 rounded-xl">Cancel</button>
                    <button type="submit" class="px-4 py-2 text-xs font-bold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-md shadow-indigo-600/30">Convert to Template</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal: Import from Link / Modern Landing Page URL -->
    <div id="modalImportUrl" class="fixed inset-0 z-50 bg-black/75 backdrop-blur-sm hidden flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 space-y-5 shadow-2xl">
            <div class="flex items-center justify-between border-b border-slate-800 pb-4">
                <div class="flex items-center gap-2">
                    <span class="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse"></span>
                    <h3 class="text-base font-bold text-white">Import from Live Website Link</h3>
                </div>
                <button onclick="document.getElementById('modalImportUrl').classList.add('hidden')" class="text-slate-400 hover:text-white">&times;</button>
            </div>
            <p class="text-xs text-slate-400">
                Paste any live URL (e.g. <span class="text-indigo-400 font-mono">https://linear.app</span>, an agency portfolio, or any modern landing page). Our engine automatically extracts the typography, color scheme, hero section, bento grid, and images into a native template.
            </p>
            <form action="{{ route('admin.templates.import_url') }}" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Target Website URL *</label>
                    <input type="url" name="url" required placeholder="https://example.com/modern-landing-page" class="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-600 focus:outline-none focus:border-emerald-500 font-mono">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Template Name (Optional - auto-extracted from title)</label>
                    <input type="text" name="name" placeholder="e.g. Nexus Dark SaaS" class="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-600 focus:outline-none focus:border-emerald-500">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-semibold text-slate-300 mb-1">Industry</label>
                        <input type="text" name="industry" placeholder="e.g. SaaS & Tech, Agency" class="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-600 focus:outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-semibold text-slate-300 mb-1">Badge Tag</label>
                        <input type="text" name="badge" value="MODERN 2026" class="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-600 focus:outline-none focus:border-emerald-500">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 mb-1">Category</label>
                    <select name="category_id" class="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white focus:outline-none focus:border-emerald-500">
                        <option value="">Auto-categorize</option>
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="flex items-center gap-2 pt-1">
                    <input type="checkbox" name="is_featured" value="1" checked id="import_featured_chk" class="rounded bg-slate-950 border-slate-800 text-emerald-600 focus:ring-0">
                    <label for="import_featured_chk" class="text-xs text-slate-300">Feature immediately in Curated Edit showcases</label>
                </div>
                <div class="flex justify-end gap-3 pt-3 border-t border-slate-800">
                    <button type="button" onclick="document.getElementById('modalImportUrl').classList.add('hidden')" class="px-4 py-2 text-xs font-semibold text-slate-400 hover:text-white bg-slate-800 rounded-xl">Cancel</button>
                    <button type="submit" class="px-5 py-2 text-xs font-bold text-white bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 rounded-xl shadow-md shadow-emerald-600/30 flex items-center gap-1.5">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"></path></svg>
                        <span>Import & Reconstruct</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
@endsection
