<!DOCTYPE html>
<html lang="en" class="h-full bg-[#090D16] text-slate-100">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Sign In - AI Website Builder</title>
    <link rel="icon" type="image/png" href="/favicon.png">
    <link rel="apple-touch-icon" href="/apple-touch-icon.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>body { font-family: 'Plus Jakarta Sans', sans-serif; }</style>
</head>
<body class="h-full flex items-center justify-center p-4 bg-[#090D16] relative overflow-hidden">
    <!-- Ambient glow -->
    <div class="absolute -top-32 -left-32 w-96 h-96 bg-indigo-600/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute -bottom-32 -right-32 w-96 h-96 bg-violet-600/10 rounded-full blur-3xl pointer-events-none"></div>

    <div class="w-full max-w-md bg-slate-900/80 border border-slate-800 rounded-3xl p-8 backdrop-blur-xl shadow-2xl relative z-10">
        <!-- Logo -->
        <div class="text-center mb-8">
            <img src="/images/logo.png" class="w-14 h-14 rounded-2xl mx-auto shadow-xl shadow-indigo-500/25 mb-3 object-cover" alt="AI Builder Admin">
            <h1 class="text-xl font-black text-white tracking-tight">AI Builder Admin</h1>
            <p class="text-xs text-slate-400 mt-1">Authenticate to access platform management</p>
        </div>

        @if(session('success'))
            <div class="mb-4 p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs flex items-center gap-2">
                <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                <span>{{ session('success') }}</span>
            </div>
        @endif

        @if(session('error') || $errors->any())
            <div class="mb-4 p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center gap-2">
                <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                <span>{{ session('error') ?? $errors->first() }}</span>
            </div>
        @endif

        <form action="{{ route('admin.login.submit') }}" method="POST" class="space-y-4">
            @csrf
            <div>
                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">Email Address</label>
                <input type="email" name="email" value="{{ old('email') }}" required autofocus
                    placeholder="admin@yourdomain.com"
                    class="w-full px-3.5 py-2.5 rounded-xl bg-slate-950/60 border border-slate-800 text-white text-sm focus:outline-none focus:border-indigo-500 transition placeholder-slate-600">
            </div>

            <div>
                <div class="flex items-center justify-between mb-1.5">
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider">Password</label>
                </div>
                <input type="password" name="password" required
                    placeholder="••••••••••••"
                    class="w-full px-3.5 py-2.5 rounded-xl bg-slate-950/60 border border-slate-800 text-white text-sm focus:outline-none focus:border-indigo-500 transition placeholder-slate-600">
            </div>

            <div class="flex items-center justify-between pt-1">
                <label class="flex items-center gap-2 text-xs text-slate-400 cursor-pointer">
                    <input type="checkbox" name="remember" class="rounded border-slate-800 bg-slate-950 text-indigo-600 focus:ring-0">
                    <span>Remember this session</span>
                </label>
            </div>

            <button type="submit" class="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white text-xs font-bold tracking-wide uppercase shadow-lg shadow-indigo-600/30 transition">
                Sign In to Dashboard
            </button>
        </form>

        @if(app()->isLocal())
            <div class="mt-6 pt-5 border-t border-slate-800/80 text-center">
                <a href="{{ route('admin.quick_login') }}" class="w-full block py-2.5 px-4 rounded-xl bg-slate-800/60 hover:bg-slate-800 border border-slate-700/60 text-slate-300 hover:text-white text-xs font-semibold transition text-center">
                    ⚡ 1-Click Dev Admin Login
                </a>
                <p class="text-[11px] text-slate-500 mt-2">Local development only</p>
            </div>
        @endif
    </div>
</body>
</html>

