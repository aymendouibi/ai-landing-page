@extends('layouts.admin')

@section('title', 'Template: ' . $template->name)
@section('page_title', $template->name)
@section('breadcrumbs', 'Template Studio / Details & Interactive Preview')

@section('topbar_actions')
    <a href="{{ route('admin.templates.preview', $template) }}" target="_blank" class="px-3.5 py-1.5 text-xs font-semibold text-white bg-slate-800 hover:bg-slate-700 rounded-lg border border-slate-700 transition flex items-center gap-1.5">
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
        <span>Open in Full Tab</span>
    </a>
    <a href="{{ route('admin.templates.index') }}" class="px-3.5 py-1.5 text-xs font-medium text-slate-400 hover:text-white bg-slate-900 rounded-lg border border-slate-800 transition">
        &larr; Back to Catalog
    </a>
@endsection

@section('content')
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Left: Template Metadata & JSON Schema -->
        <div class="space-y-6">
            <!-- Overview Card -->
            <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-4">
                <div class="flex items-center justify-between">
                    <h3 class="text-sm font-bold text-white tracking-tight">Template Info</h3>
                    @if($template->is_featured)
                        <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-amber-400/10 text-amber-300 border border-amber-400/30">
                            ✦ {{ $template->badge ?: "EDITOR'S PICK" }}
                        </span>
                    @endif
                </div>

                <div class="space-y-2 text-xs">
                    <div class="flex justify-between py-1 border-b border-slate-800/60">
                        <span class="text-slate-400">Slug:</span>
                        <span class="font-mono text-slate-200">{{ $template->slug }}</span>
                    </div>
                    <div class="flex justify-between py-1 border-b border-slate-800/60">
                        <span class="text-slate-400">Industry:</span>
                        <span class="text-slate-200 font-medium">{{ $template->industry ?: 'General' }}</span>
                    </div>
                    <div class="flex justify-between py-1 border-b border-slate-800/60">
                        <span class="text-slate-400">Category:</span>
                        <span class="text-slate-200">{{ $template->category?->name ?: 'Uncategorized' }}</span>
                    </div>
                    <div class="flex justify-between py-1 border-b border-slate-800/60">
                        <span class="text-slate-400">Author:</span>
                        <span class="text-slate-200">{{ $template->author ?: ($template->user?->name ?? 'System') }}</span>
                    </div>
                    <div class="flex justify-between py-1 border-b border-slate-800/60">
                        <span class="text-slate-400">Total Uses:</span>
                        <span class="font-bold text-indigo-400">{{ $template->use_count }}</span>
                    </div>
                    <div class="flex justify-between py-1 border-b border-slate-800/60">
                        <span class="text-slate-400">Status:</span>
                        <span class="text-emerald-400 font-semibold">{{ ucfirst($template->status->value) }}</span>
                    </div>
                </div>

                <!-- Update Form -->
                <form action="{{ route('admin.templates.update', $template) }}" method="POST" class="pt-2 space-y-3">
                    @csrf
                    @method('PATCH')
                    <div>
                        <label class="block text-[11px] font-semibold text-slate-300 mb-1">Badge Tag</label>
                        <input type="text" name="badge" value="{{ $template->badge }}" placeholder="e.g. EDITOR'S PICK, NEW" class="w-full px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-xs text-white">
                    </div>
                    <div>
                        <label class="block text-[11px] font-semibold text-slate-300 mb-1">Industry</label>
                        <input type="text" name="industry" value="{{ $template->industry }}" class="w-full px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-xs text-white">
                    </div>
                    <button type="submit" class="w-full py-1.5 bg-slate-800 hover:bg-slate-700 text-white rounded-lg text-xs font-semibold transition">
                        Update Settings
                    </button>
                </form>
            </div>

            <!-- JSON Schema Viewer -->
            <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 space-y-3">
                <div class="flex items-center justify-between">
                    <h3 class="text-sm font-bold text-white">Document Schema</h3>
                    <span class="text-[10px] font-mono text-slate-500">v{{ $template->activeVersion?->version ?? 1 }}</span>
                </div>
                <div class="max-h-96 overflow-y-auto rounded-xl bg-slate-950 p-3 border border-slate-800">
                    <pre class="text-[11px] text-slate-300 font-mono leading-relaxed whitespace-pre-wrap">{{ json_encode($template->activeVersion?->document, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) }}</pre>
                </div>
            </div>
        </div>

        <!-- Right: Live Interactive HTML Preview (2 Columns) -->
        <div class="lg:col-span-2 bg-slate-900/60 border border-slate-800 rounded-2xl p-5 flex flex-col space-y-3">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <span class="w-3 h-3 rounded-full bg-emerald-500 animate-pulse"></span>
                    <h3 class="text-sm font-bold text-white">Live Compiled Preview</h3>
                </div>
                <div class="flex items-center gap-2">
                    <span class="text-[11px] text-slate-400">Desktop View</span>
                </div>
            </div>

            <!-- Preview Iframe -->
            <div class="flex-1 w-full min-h-[640px] bg-white rounded-xl overflow-hidden border border-slate-700 shadow-inner">
                <iframe src="{{ route('admin.templates.preview', $template) }}" class="w-full h-full min-h-[640px] border-0" title="Template Preview"></iframe>
            </div>
        </div>
    </div>
@endsection

