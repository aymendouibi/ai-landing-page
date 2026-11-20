<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Account & Data Removal — AI Landing Page</title>
    <meta name="description" content="Official account and data deletion page for AI Landing Page & AI Landing Page. Follow our in-app visual guide or submit a web deletion request.">
    <link rel="icon" type="image/png" href="/favicon.png">
    <link rel="apple-touch-icon" href="/apple-touch-icon.png">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'Inter', 'sans-serif'],
                        mono: ['"JetBrains Mono"', 'monospace'],
                    },
                    colors: {
                        brand: {
                            50: '#EEF2FF',
                            100: '#E0E7FF',
                            400: '#818CF8',
                            500: '#6366F1',
                            600: '#4F46E5',
                            700: '#4338CA',
                        },
                        dark: {
                            base: '#080C14',
                            surface: '#0F1626',
                            card: '#141D32',
                            border: 'rgba(255, 255, 255, 0.08)',
                        }
                    },
                    animation: {
                        'pulse-glow': 'pulseGlow 6s ease-in-out infinite',
                    },
                    keyframes: {
                        pulseGlow: {
                            '0%, 100%': { opacity: '0.3', transform: 'scale(1)' },
                            '50%': { opacity: '0.6', transform: 'scale(1.05)' },
                        }
                    }
                }
            }
        }
    </script>

    <style>
        .glass-panel {
            background: rgba(15, 22, 38, 0.7);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }
        .glass-panel-glow {
            background: rgba(20, 29, 50, 0.8);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(99, 102, 241, 0.25);
            box-shadow: 0 0 30px -10px rgba(99, 102, 241, 0.2);
        }
        .glass-panel-danger {
            background: rgba(35, 15, 20, 0.7);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(220, 38, 38, 0.25);
            box-shadow: 0 0 30px -10px rgba(220, 38, 38, 0.15);
        }
        .text-gradient {
            background: linear-gradient(135deg, #FFFFFF 0%, #A5B4FC 50%, #C084FC 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .phone-mockup {
            border-radius: 36px;
            box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.7), 0 0 0 6px #1e293b, 0 0 0 8px rgba(255, 255, 255, 0.08);
            overflow: hidden;
            background: #000;
        }
    </style>
</head>
<body class="bg-dark-base text-slate-100 font-sans antialiased overflow-x-hidden selection:bg-rose-500 selection:text-white">

    <!-- Ambient Mesh Glows -->
    <div class="fixed inset-0 overflow-hidden pointer-events-none -z-10">
        <div class="absolute -top-40 left-1/2 -translate-x-1/2 w-[700px] h-[450px] bg-gradient-to-tr from-rose-600/15 via-brand-600/15 to-transparent rounded-full blur-[140px] animate-pulse-glow"></div>
        <div class="absolute top-[40%] -left-60 w-[500px] h-[500px] bg-brand-500/10 rounded-full blur-[160px]"></div>
        <div class="absolute top-[70%] -right-60 w-[500px] h-[500px] bg-rose-500/10 rounded-full blur-[160px]"></div>
    </div>

    <!-- Header Navigation -->
    <header class="sticky top-0 z-50 glass-panel border-b border-white/[0.06] transition-all">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
            <!-- Brand Logo -->
            <a href="/" class="flex items-center space-x-3 group">
                <img src="/images/logo.png" class="w-10 h-10 rounded-xl shadow-lg shadow-brand-500/25 group-hover:scale-105 transition-transform object-cover" alt="AI Landing Page Logo">
                <div>
                    <span class="text-xl font-bold tracking-tight text-white flex items-center gap-1.5">
                        AI Landing Page <span class="text-xs px-2 py-0.5 rounded-full font-semibold bg-brand-500/10 text-brand-400 border border-brand-500/20">AI</span>
                    </span>
                    <span class="text-[11px] text-slate-400 block -mt-1 font-medium">Mobile Landing Page Platform</span>
                </div>
            </a>

            <!-- Nav Links (Desktop) -->
            <nav class="hidden md:flex items-center space-x-8 text-sm font-medium text-slate-300">
                <a href="/" class="hover:text-white transition-colors">Home</a>
                <a href="/privacy" class="hover:text-white transition-colors">Privacy Policy</a>
                <a href="/terms" class="hover:text-white transition-colors">Terms of Service</a>
                <a href="/delete-account" class="text-rose-400 font-semibold flex items-center gap-1.5">
                    <span class="w-1.5 h-1.5 rounded-full bg-rose-400"></span>
                    Delete Account
                </a>
            </nav>

            <!-- Actions -->
            <div class="flex items-center space-x-3">
                <a href="/" class="hidden sm:inline-flex text-xs font-semibold px-3 py-2 rounded-lg text-slate-400 hover:text-white hover:bg-white/[0.04] transition-all">
                    Back to Home
                </a>
                <a href="/privacy" class="inline-flex items-center justify-center space-x-2 text-xs font-bold uppercase tracking-wider px-4 py-2.5 rounded-xl glass-panel text-slate-200 hover:text-white hover:bg-white/[0.06] transition-all">
                    <span>Privacy Policy</span>
                </a>
            </div>
        </div>
    </header>

    <main class="relative py-12 md:py-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            
            <!-- Breadcrumbs -->
            <div class="flex items-center gap-2 text-xs text-slate-400 mb-8">
                <a href="/" class="hover:text-white transition-colors">Home</a>
                <span>/</span>
                <span class="text-slate-500">Legal</span>
                <span>/</span>
                <span class="text-rose-400 font-medium">Account & Data Deletion</span>
            </div>

            <!-- Page Title Hero -->
            <div class="relative glass-panel rounded-3xl p-6 sm:p-10 md:p-12 mb-12 overflow-hidden border border-white/[0.08]">
                <div class="absolute -right-20 -bottom-20 w-80 h-80 bg-rose-500/10 rounded-full blur-3xl pointer-events-none"></div>

                <div class="max-w-3xl relative z-10">
                    <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-rose-500/10 border border-rose-500/25 text-rose-300 text-xs font-semibold mb-4">
                        <svg class="w-3.5 h-3.5 text-rose-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                        </svg>
                        <span>Data Subject Rights · Google Play Policy Compliant</span>
                    </div>
                    <h1 class="text-3xl sm:text-5xl font-extrabold tracking-tight text-white leading-tight">
                        Delete Your Account <br class="hidden sm:inline" />
                        <span class="text-gradient">&amp; Associated Data</span>
                    </h1>
                    <p class="mt-4 text-sm sm:text-base text-slate-300 leading-relaxed">
                        We believe in complete user ownership and data portability. You can delete your AI Landing Page account directly inside the mobile app in just three taps, or submit a web deletion request below.
                    </p>
                    <div class="mt-6 flex flex-wrap items-center gap-4 text-xs font-medium text-slate-400">
                        <span class="flex items-center gap-1.5 text-emerald-400 font-semibold">
                            <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                            Permanent &amp; Irreversible
                        </span>
                        <span>•</span>
                        <span>In-App: Instant Deletion</span>
                        <span>•</span>
                        <span>Web Requests: Processed &lt; 48h</span>
                    </div>
                </div>
            </div>

            <!-- Notification Banner for Web Submission -->
            @if(session('success_message'))
                <div class="mb-10 p-5 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-200 flex items-start gap-3 shadow-lg">
                    <svg class="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                        <polyline points="22 4 12 14.01 9 11.01"/>
                    </svg>
                    <div class="text-sm leading-relaxed">
                        <strong class="font-bold text-white block mb-0.5">Request Received Successfully</strong>
                        {{ session('success_message') }}
                    </div>
                </div>
            @endif

            <!-- Method 1: In-App Visual Deletion Guide (With Screenshots) -->
            <section class="mb-16">
                <div class="flex items-center gap-3 mb-6">
                    <div class="w-9 h-9 rounded-xl bg-brand-500/10 border border-brand-500/20 flex items-center justify-center text-brand-400 font-bold text-sm font-mono">
                        01
                    </div>
                    <div>
                        <h2 class="text-xl sm:text-2xl font-bold text-white">How to Delete Your Account in the Mobile App</h2>
                        <p class="text-xs sm:text-sm text-slate-400 mt-0.5">The fastest way to purge your account and instantly erase all data</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                    
                    <!-- Step 1 Card -->
                    <div class="glass-panel rounded-3xl p-6 border border-white/[0.08] flex flex-col justify-between group hover:border-white/[0.15] transition-all">
                        <div>
                            <div class="flex items-center justify-between mb-4">
                                <span class="px-2.5 py-1 rounded-lg bg-white/[0.05] text-[11px] font-bold uppercase tracking-wider text-brand-300">Step 1</span>
                                <span class="text-xs text-slate-400 font-medium">Bottom Navigation</span>
                            </div>
                            <h3 class="text-base font-bold text-white mb-2">Tap "Profile" in Navigation</h3>
                            <p class="text-xs sm:text-sm text-slate-300 leading-relaxed mb-5">
                                Open the mobile app. On the bottom navigation bar at the bottom right of the screen, tap the <strong>Profile</strong> tab icon.
                            </p>
                        </div>
                        
                        <!-- Screenshot 1 Container -->
                        <div class="phone-mockup relative mx-auto w-full max-w-[260px] aspect-[9/19] overflow-hidden bg-slate-900 border border-white/10 group-hover:scale-[1.02] transition-transform">
                            <img src="/images/account-deletion/step1-navigate.jpg" alt="Step 1: Projects screen with bottom navigation showing Profile" class="w-full h-full object-cover object-top" loading="lazy">
                            <div class="absolute bottom-2 right-2 px-2 py-1 rounded-md bg-brand-500/90 text-[10px] font-bold text-white shadow-md">
                                Profile Tab
                            </div>
                        </div>
                    </div>

                    <!-- Step 2 Card -->
                    <div class="glass-panel rounded-3xl p-6 border border-white/[0.08] flex flex-col justify-between group hover:border-white/[0.15] transition-all">
                        <div>
                            <div class="flex items-center justify-between mb-4">
                                <span class="px-2.5 py-1 rounded-lg bg-white/[0.05] text-[11px] font-bold uppercase tracking-wider text-brand-300">Step 2</span>
                                <span class="text-xs text-slate-400 font-medium">Account Details</span>
                            </div>
                            <h3 class="text-base font-bold text-white mb-2">Tap "Edit profile"</h3>
                            <p class="text-xs sm:text-sm text-slate-300 leading-relaxed mb-5">
                                On your Profile screen, tap the <strong>Edit profile &gt;</strong> row located immediately underneath your name and email address.
                            </p>
                        </div>
                        
                        <!-- Screenshot 2 Container -->
                        <div class="phone-mockup relative mx-auto w-full max-w-[260px] aspect-[9/19] overflow-hidden bg-slate-900 border border-white/10 group-hover:scale-[1.02] transition-transform">
                            <img src="/images/account-deletion/step2-profile.jpg" alt="Step 2: Profile screen with Edit profile row" class="w-full h-full object-cover object-top" loading="lazy">
                            <div class="absolute top-28 right-4 px-2 py-1 rounded-md bg-brand-500/90 text-[10px] font-bold text-white shadow-md">
                                Edit profile &gt;
                            </div>
                        </div>
                    </div>

                    <!-- Step 3 Card -->
                    <div class="glass-panel rounded-3xl p-6 border border-rose-500/20 flex flex-col justify-between group hover:border-rose-500/40 transition-all bg-rose-950/10">
                        <div>
                            <div class="flex items-center justify-between mb-4">
                                <span class="px-2.5 py-1 rounded-lg bg-rose-500/20 text-[11px] font-bold uppercase tracking-wider text-rose-300">Step 3 &amp; 4</span>
                                <span class="text-xs text-rose-300 font-medium">Final Confirmation</span>
                            </div>
                            <h3 class="text-base font-bold text-white mb-2">Tap "Delete account"</h3>
                            <p class="text-xs sm:text-sm text-slate-300 leading-relaxed mb-5">
                                Scroll to the bottom of the "Edit profile" sheet, tap the red <strong>Delete account</strong> button with the trash icon, and confirm the permanent deletion prompt.
                            </p>
                        </div>
                        
                        <!-- Screenshot 3 Container -->
                        <div class="phone-mockup relative mx-auto w-full max-w-[260px] aspect-[9/19] overflow-hidden bg-slate-900 border border-rose-500/30 group-hover:scale-[1.02] transition-transform">
                            <img src="/images/account-deletion/step3-delete-button.png" alt="Step 3: Edit profile modal with red Delete account button" class="w-full h-full object-cover object-top" loading="lazy">
                            <div class="absolute bottom-6 left-1/2 -translate-x-1/2 px-3 py-1 rounded-md bg-rose-600 text-[10px] font-bold text-white shadow-lg animate-pulse">
                                🗑️ Delete account
                            </div>
                        </div>
                    </div>

                </div>
            </section>

            <!-- Method 2: Web-Based Account Deletion Request Form -->
            <section class="mb-16">
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                    
                    <div class="lg:col-span-5 space-y-6">
                        <div class="flex items-center gap-3">
                            <div class="w-9 h-9 rounded-xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center text-rose-400 font-bold text-sm font-mono">
                                02
                            </div>
                            <div>
                                <h2 class="text-xl sm:text-2xl font-bold text-white">Web Deletion Request</h2>
                                <p class="text-xs sm:text-sm text-slate-400 mt-0.5">For users who uninstalled the app or cannot log in</p>
                            </div>
                        </div>

                        <p class="text-sm text-slate-300 leading-relaxed">
                            If you no longer have the mobile app installed, or signed up with an email you can no longer access from your phone, submit your registered email address below.
                        </p>

                        <div class="space-y-3">
                            <div class="p-4 rounded-2xl bg-white/[0.02] border border-white/[0.05] flex items-start gap-3">
                                <div class="w-7 h-7 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                </div>
                                <div>
                                    <h4 class="text-xs font-bold text-white uppercase tracking-wider">Automated Verification</h4>
                                    <p class="text-xs text-slate-400 mt-0.5">A verification receipt is sent to the registered address to prevent unauthorized requests.</p>
                                </div>
                            </div>

                            <div class="p-4 rounded-2xl bg-white/[0.02] border border-white/[0.05] flex items-start gap-3">
                                <div class="w-7 h-7 rounded-lg bg-indigo-500/10 text-indigo-400 flex items-center justify-center shrink-0 mt-0.5">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 14 14"/></svg>
                                </div>
                                <div>
                                    <h4 class="text-xs font-bold text-white uppercase tracking-wider">Fast Turnaround</h4>
                                    <p class="text-xs text-slate-400 mt-0.5">All websites, assets, drafts, and records are purged within 24 to 48 hours.</p>
                                </div>
                            </div>
                        </div>

                        <div class="p-4 rounded-2xl bg-brand-500/5 border border-brand-500/20 text-xs text-slate-300">
                            <strong>Direct Contact:</strong> You can also email our Data Protection Officer directly at <a href="mailto:privacy@aibuilder.app" class="text-brand-300 underline font-semibold">privacy@aibuilder.app</a> with the subject line <em>"Account Deletion Request"</em>.
                        </div>
                    </div>

                    <!-- Web Deletion Request Form -->
                    <div class="lg:col-span-7">
                        <div class="glass-panel rounded-3xl p-6 sm:p-8 border border-white/[0.08]">
                            <h3 class="text-lg font-bold text-white mb-1">Submit Deletion Form</h3>
                            <p class="text-xs sm:text-sm text-slate-400 mb-6">Enter your account details to initiate permanent removal</p>

                            @if ($errors->any())
                                <div class="mb-6 p-4 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs">
                                    <ul class="list-disc list-inside space-y-1">
                                        @foreach ($errors->all() as $error)
                                            <li>{{ $error }}</li>
                                        @endforeach
                                    </ul>
                                </div>
                            @endif

                            <form action="/delete-account" method="POST" class="space-y-5">
                                @csrf
                                
                                <div>
                                    <label for="email" class="block text-xs font-bold uppercase tracking-wider text-slate-300 mb-2">
                                        Registered Account Email <span class="text-rose-400">*</span>
                                    </label>
                                    <input 
                                        type="email" 
                                        id="email" 
                                        name="email" 
                                        value="{{ old('email') }}"
                                        required 
                                        placeholder="e.g. malekdouibi09@gmail.com" 
                                        class="w-full px-4 py-3.5 rounded-xl bg-dark-base border border-white/10 text-white placeholder-slate-500 text-sm focus:outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500 transition-all font-mono"
                                    >
                                    <span class="text-[11px] text-slate-400 block mt-1.5">Enter the exact email used for Google Sign-In, Apple ID, or Email authentication.</span>
                                </div>

                                <div>
                                    <label for="reason" class="block text-xs font-bold uppercase tracking-wider text-slate-300 mb-2">
                                        Reason for Deletion <span class="text-slate-500 font-normal">(Optional)</span>
                                    </label>
                                    <textarea 
                                        id="reason" 
                                        name="reason" 
                                        rows="3" 
                                        placeholder="Let us know why you are deleting your account (e.g. no longer needed, testing, privacy preference)..." 
                                        class="w-full px-4 py-3 rounded-xl bg-dark-base border border-white/10 text-white placeholder-slate-500 text-sm focus:outline-none focus:border-rose-500 focus:ring-1 focus:ring-rose-500 transition-all resize-none"
                                    >{{ old('reason') }}</textarea>
                                </div>

                                <div class="pt-2">
                                    <label class="flex items-start gap-3 cursor-pointer group">
                                        <input 
                                            type="checkbox" 
                                            name="confirm_deletion" 
                                            value="1" 
                                            required
                                            class="w-4 h-4 mt-1 rounded bg-dark-base border-white/20 text-rose-500 focus:ring-rose-500 focus:ring-offset-dark-base shrink-0 cursor-pointer"
                                        >
                                        <span class="text-xs text-slate-300 group-hover:text-white transition-colors leading-relaxed">
                                            I understand and confirm that submitting this request will <strong>permanently and irreversibly erase</strong> my account, all created websites, published edge subdomains, uploaded media assets, and AI generation history.
                                        </span>
                                    </label>
                                </div>

                                <div class="pt-3">
                                    <button 
                                        type="submit" 
                                        class="w-full py-4 rounded-xl bg-rose-600 hover:bg-rose-500 text-white font-bold text-sm uppercase tracking-wider shadow-lg shadow-rose-600/25 active:scale-[0.99] transition-all flex items-center justify-center gap-2"
                                    >
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                            <polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                                        </svg>
                                        <span>Request Permanent Deletion</span>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                </div>
            </section>

            <!-- Data Safety Breakdown: What is Deleted vs Retained -->
            <section class="mb-16">
                <div class="glass-panel rounded-3xl p-6 sm:p-10 border border-white/[0.08]">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-9 h-9 rounded-xl bg-brand-500/10 border border-brand-500/20 flex items-center justify-center text-brand-400 font-bold text-sm font-mono">
                            03
                        </div>
                        <div>
                            <h2 class="text-xl sm:text-2xl font-bold text-white">Data Retention &amp; Safety Specification</h2>
                            <p class="text-xs sm:text-sm text-slate-400 mt-0.5">In compliance with Google Play Store User Data &amp; Account Deletion policies</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        
                        <!-- Permanently Deleted -->
                        <div class="p-6 rounded-2xl bg-rose-500/5 border border-rose-500/20">
                            <div class="flex items-center gap-2.5 text-rose-400 font-bold text-sm mb-4">
                                <svg class="w-5 h-5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                <span>Data Permanently Purged</span>
                            </div>
                            <ul class="space-y-3 text-xs sm:text-sm text-slate-300">
                                <li class="flex items-start gap-2">
                                    <span class="text-rose-400 font-bold shrink-0">•</span>
                                    <span><strong>Account Profile:</strong> Name, email address, password hashes, and OAuth linkings (Google/Apple).</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="text-rose-400 font-bold shrink-0">•</span>
                                    <span><strong>Websites &amp; Drafts:</strong> All page configurations, HTML/CSS layouts, drafts, and version history.</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="text-rose-400 font-bold shrink-0">•</span>
                                    <span><strong>Published Deployments:</strong> Live subdomains on <code>*.ai-landing-page.xyz</code> and custom DNS mappings.</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="text-rose-400 font-bold shrink-0">•</span>
                                    <span><strong>Media Assets:</strong> All uploaded photos, logos, branding assets stored on cloud buckets.</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="text-rose-400 font-bold shrink-0">•</span>
                                    <span><strong>AI Generations:</strong> Prompt history, remix sessions, and generation parameters.</span>
                                </li>
                            </ul>
                        </div>

                        <!-- Legally Retained -->
                        <div class="p-6 rounded-2xl bg-white/[0.02] border border-white/[0.05]">
                            <div class="flex items-center gap-2.5 text-slate-300 font-bold text-sm mb-4">
                                <svg class="w-5 h-5 text-indigo-400 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect width="18" height="18" x="3" y="3" rx="2"/><line x1="3" x2="21" y1="9"/><line x1="9" x2="9" y1="21"/></svg>
                                <span>Statutory Retention Requirements</span>
                            </div>
                            <ul class="space-y-3 text-xs sm:text-sm text-slate-300">
                                <li class="flex items-start gap-2">
                                    <span class="text-indigo-400 font-bold shrink-0">•</span>
                                    <span><strong>Billing &amp; Tax Records:</strong> Invoices and transaction identifiers processed via Stripe are retained solely to comply with statutory accounting and tax regulations.</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="text-indigo-400 font-bold shrink-0">•</span>
                                    <span><strong>Fraud Prevention:</strong> Historical chargeback dispute logs are kept securely in isolated audit storage for the duration mandated by financial authorities.</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="text-indigo-400 font-bold shrink-0">•</span>
                                    <span><strong>Zero Marketing Retainage:</strong> Your email and contact details are completely expunged from all active communication pipelines.</span>
                                </li>
                            </ul>
                        </div>

                    </div>
                </div>
            </section>

            <!-- FAQ Section -->
            <section class="mb-12">
                <div class="glass-panel rounded-3xl p-6 sm:p-8 border border-white/[0.08]">
                    <h3 class="text-lg font-bold text-white mb-6">Frequently Asked Questions</h3>
                    <div class="space-y-6 text-xs sm:text-sm">
                        <div>
                            <h4 class="font-bold text-white mb-1.5">Can I recover my websites after deleting my account?</h4>
                            <p class="text-slate-400 leading-relaxed">No. Once deleted, all websites, code, and uploaded assets are permanently destroyed and cannot be restored. If you wish to save your sites, we recommend exporting your static HTML/CSS code from the mobile editor prior to initiating deletion.</p>
                        </div>
                        <div class="pt-4 border-t border-white/[0.04]">
                            <h4 class="font-bold text-white mb-1.5">What happens to my active paid subscription?</h4>
                            <p class="text-slate-400 leading-relaxed">Deleting your account immediately terminates any active Pro or Premium subscription and prevents future billing cycles. If you have an active Apple App Store or Google Play subscription, ensure you also cancel the auto-renewing subscription in your Apple ID or Google Play Subscriptions settings.</p>
                        </div>
                        <div class="pt-4 border-t border-white/[0.04]">
                            <h4 class="font-bold text-white mb-1.5">Who can I contact if I have questions?</h4>
                            <p class="text-slate-400 leading-relaxed">You can reach our Data Protection team at <a href="mailto:privacy@aibuilder.app" class="text-brand-300 underline font-semibold">privacy@aibuilder.app</a> anytime.</p>
                        </div>
                    </div>
                </div>
            </section>

        </div>
    </main>

    <!-- Footer -->
    <footer class="border-t border-white/[0.06] bg-dark-base py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row items-center justify-between gap-6 text-sm text-slate-500">
            <div class="flex items-center space-x-3">
                <img src="/images/logo.png" class="w-6 h-6 rounded-lg object-cover" alt="AI Landing Page">
                <span class="text-white font-bold">AI Landing Page</span>
                <span>·</span>
                <span>© 2026 AI Landing Page. All rights reserved.</span>
            </div>
            <div class="flex flex-wrap items-center gap-x-6 gap-y-2 text-xs text-slate-400">
                <a href="/privacy" class="hover:text-white transition-colors">Privacy Policy</a>
                <a href="/terms" class="hover:text-white transition-colors">Terms of Service</a>
                <a href="/delete-account" class="text-rose-400 font-semibold hover:text-white transition-colors">Delete Account</a>
                <a href="/admin/login" class="hover:text-white transition-colors">Admin Login</a>
                <a href="/api/v1/health" target="_blank" class="hover:text-white transition-colors">API Status</a>
            </div>
        </div>
    </footer>
</body>
</html>
