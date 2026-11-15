@extends('layouts.admin')

@section('title', 'Users & Access Control')
@section('page_title', 'User Accounts')
@section('breadcrumbs', 'User Management, Roles & System Access')

@section('content')
    <!-- Metric KPI Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Total Accounts</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['total'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Registered creators</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-indigo-400 uppercase tracking-wider">Administrators</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['admins'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Full control access</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Creators / Users</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['users'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Standard mobile app users</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl">
            <p class="text-[11px] font-semibold text-emerald-400 uppercase tracking-wider">Verified Emails</p>
            <h3 class="text-2xl font-black text-white mt-1">{{ $metrics['verified'] }}</h3>
            <p class="text-[11px] text-slate-500 mt-1">Confirmed identity</p>
        </div>
    </div>

    <!-- Filters & Search -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-900/40 p-3 rounded-2xl border border-slate-800">
        <div class="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
            <a href="{{ route('admin.users.index') }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ !request('role') ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                All Users ({{ $metrics['total'] }})
            </a>
            <a href="{{ route('admin.users.index', ['role' => 'admin']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('role') === 'admin' ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Admins ({{ $metrics['admins'] }})
            </a>
            <a href="{{ route('admin.users.index', ['role' => 'user']) }}" class="px-3.5 py-1.5 text-xs font-semibold rounded-xl {{ request('role') === 'user' ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20' : 'text-slate-400 hover:text-white bg-slate-800/40' }} transition">
                Creators ({{ $metrics['users'] }})
            </a>
        </div>
        <form action="{{ route('admin.users.index') }}" method="GET" class="w-full sm:w-72">
            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Search name or email..." class="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 focus:border-indigo-500 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none transition">
                <svg class="w-4 h-4 text-slate-500 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </div>
        </form>
    </div>

    <!-- Users Table -->
    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 bg-slate-900/80 text-slate-400 uppercase tracking-wider font-semibold">
                        <th class="py-3.5 px-4">User</th>
                        <th class="py-3.5 px-4">Role</th>
                        <th class="py-3.5 px-4">Projects</th>
                        <th class="py-3.5 px-4">Email Status</th>
                        <th class="py-3.5 px-4">Joined Date</th>
                        <th class="py-3.5 px-4 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($users as $user)
                        <tr class="hover:bg-slate-800/30 transition">
                            <td class="py-3.5 px-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-8 h-8 rounded-lg bg-indigo-600/20 text-indigo-400 font-bold flex items-center justify-center text-xs shrink-0">
                                        {{ strtoupper(substr($user->name, 0, 2)) }}
                                    </div>
                                    <div>
                                        <div class="font-bold text-white text-sm">{{ $user->name }}</div>
                                        <div class="text-[11px] text-slate-400 font-mono">{{ $user->email }}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="py-3.5 px-4">
                                @if($user->role->value === 'admin')
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
                                        ★ Admin
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-slate-800 text-slate-300">
                                        Creator
                                    </span>
                                @endif
                            </td>
                            <td class="py-3.5 px-4 text-slate-300 font-semibold">
                                {{ $user->projects_count }} projects
                            </td>
                            <td class="py-3.5 px-4">
                                @if($user->email_verified_at)
                                    <span class="text-emerald-400 font-medium text-[11px] flex items-center gap-1">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                        Verified
                                    </span>
                                @else
                                    <span class="text-slate-500 text-[11px]">Unverified</span>
                                @endif
                            </td>
                            <td class="py-3.5 px-4 text-slate-400 text-[11px]">
                                {{ $user->created_at->format('M d, Y') }}
                                <span class="text-slate-600 block text-[10px]">{{ $user->created_at->diffForHumans() }}</span>
                            </td>
                            <td class="py-3.5 px-4 text-right">
                                <form action="{{ route('admin.users.toggle_role', $user) }}" method="POST" class="inline">
                                    @csrf
                                    <button type="submit" class="px-2.5 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-[11px] font-medium transition">
                                        {{ $user->role->value === 'admin' ? 'Demote to User' : 'Promote to Admin' }}
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="py-12 text-center text-slate-500">
                                No users found matching this filter.
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
@endsection

