<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Landing Page — Your Landing Page. Live in 3 Minutes.</title>
    <meta name="description" content="Describe your idea, generate your page, and publish it in minutes. AI Landing Page provides modern, elegant templates, intuitive visual editing, zero watermarks, and free edge hosting.">
    <link rel="icon" type="image/png" href="/favicon.png">
    <link rel="apple-touch-icon" href="/apple-touch-icon.png">
    
    <!-- OpenGraph / Social Sharing -->
    <meta property="og:type" content="website">
    <meta property="og:title" content="AI Landing Page — Live in 3 Minutes">
    <meta property="og:description" content="Describe your idea, generate your page, and publish it in minutes. Free forever, no watermarks, and instant edge publishing.">
    <meta property="og:url" content="https://www.ai-landing-page.xyz">
    <meta property="og:image" content="https://www.ai-landing-page.xyz/images/landing/projects_dashboard.jpg">

    <!-- Twitter -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="AI Landing Page — Live in 3 Minutes">
    <meta name="twitter:description" content="Describe your idea, generate your page, and publish it in minutes. Free forever with zero watermarks.">
    <meta name="twitter:image" content="https://www.ai-landing-page.xyz/images/landing/projects_dashboard.jpg">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'Inter', 'sans-serif'],
                        mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'monospace'],
                    },
                    colors: {
                        brand: {
                            50: '#EEF2FF',
                            100: '#E0E7FF',
                            200: '#C7D2FE',
                            300: '#A5B4FC',
                            400: '#818CF8',
                            500: '#6366F1',
                            600: '#4F46E5',
                            700: '#4338CA',
                        },
                        dark: {
                            base: '#070A12',
                            surface: '#0E1424',
                            card: '#131B30',
                            border: 'rgba(255, 255, 255, 0.08)',
                        }
                    },
                    animation: {
                        'pulse-glow': 'pulseGlow 6s ease-in-out infinite',
                        'float-slow': 'floatSlow 6s ease-in-out infinite',
                        'float-reverse': 'floatReverse 7s ease-in-out infinite',
                    },
                    keyframes: {
                        pulseGlow: {
                            '0%, 100%': { opacity: '0.35', transform: 'scale(1)' },
                            '50%': { opacity: '0.65', transform: 'scale(1.06)' },
                        },
                        floatSlow: {
                            '0%, 100%': { transform: 'translateY(0px)' },
                            '50%': { transform: 'translateY(-10px)' },
                        },
                        floatReverse: {
                            '0%, 100%': { transform: 'translateY(0px)' },
                            '50%': { transform: 'translateY(10px)' },
                        }
                    }
                }
            }
        }
    </script>

    <style>
        /* Sleek Glassmorphism Panels */
        .glass-panel {
            background: rgba(14, 20, 36, 0.72);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }
        .glass-panel-glow {
            background: rgba(19, 27, 48, 0.85);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border: 1px solid rgba(99, 102, 241, 0.35);
            box-shadow: 0 0 50px -10px rgba(99, 102, 241, 0.25);
        }
        .glass-card-hover {
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .glass-card-hover:hover {
            transform: translateY(-4px);
            border-color: rgba(129, 140, 248, 0.4);
            box-shadow: 0 20px 40px -15px rgba(99, 102, 241, 0.25);
        }

        /* Realistic Portrait Mobile Frame */
        .mobile-frame-portrait {
            position: relative;
            border-radius: 46px;
            background: #090D16;
            padding: 9px;
            box-shadow: 
                0 0 0 2px rgba(255, 255, 255, 0.12),
                0 25px 60px -15px rgba(0, 0, 0, 0.85),
                0 0 35px -5px rgba(99, 102, 241, 0.25);
            border: 3px solid #1E293B;
            transition: all 0.4s ease;
        }
        .mobile-frame-portrait:hover {
            box-shadow: 
                0 0 0 2px rgba(129, 140, 248, 0.3),
                0 30px 70px -12px rgba(0, 0, 0, 0.95),
                0 0 45px -5px rgba(99, 102, 241, 0.4);
        }

        /* Realistic Landscape Mobile Frame (for flipped site editor) */
        .mobile-frame-landscape {
            position: relative;
            border-radius: 38px;
            background: #090D16;
            padding: 9px;
            box-shadow: 
                0 0 0 2px rgba(255, 255, 255, 0.12),
                0 25px 60px -15px rgba(0, 0, 0, 0.85),
                0 0 35px -5px rgba(99, 102, 241, 0.25);
            border: 3px solid #1E293B;
            transition: all 0.4s ease;
        }
        .mobile-frame-landscape:hover {
            box-shadow: 
                0 0 0 2px rgba(129, 140, 248, 0.3),
                0 30px 70px -12px rgba(0, 0, 0, 0.95),
                0 0 45px -5px rgba(99, 102, 241, 0.4);
        }

        /* Dynamic Island / Speaker Pill */
        .dynamic-island {
            position: absolute;
            top: 14px;
            left: 50%;
            transform: translateX(-50%);
            width: 84px;
            height: 20px;
            background: #000;
            border-radius: 20px;
            z-index: 30;
            box-shadow: 0 0 2px rgba(255, 255, 255, 0.2);
        }

        /* Text Gradients */
        .text-gradient {
            background: linear-gradient(135deg, #FFFFFF 0%, #C7D2FE 50%, #A855F7 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .text-gradient-brand {
            background: linear-gradient(135deg, #818CF8 0%, #C084FC 50%, #F472B6 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* Ambient Glow Grid */
        .bg-grid-pattern {
            background-size: 40px 40px;
            background-image: 
                linear-gradient(to right, rgba(255, 255, 255, 0.03) 1px, transparent 1px),
                linear-gradient(to bottom, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
        }
    </style>
</head>
<body class="bg-dark-base text-slate-100 font-sans antialiased overflow-x-hidden selection:bg-brand-500 selection:text-white">

    <!-- Ambient Mesh Glows -->
    <div class="fixed inset-0 overflow-hidden pointer-events-none -z-10">
        <div class="absolute -top-40 left-1/2 -translate-x-1/2 w-[900px] h-[600px] bg-gradient-to-tr from-brand-600/25 via-purple-600/20 to-sky-500/10 rounded-full blur-[160px] animate-pulse-glow"></div>
        <div class="absolute top-[35%] -left-60 w-[600px] h-[600px] bg-brand-500/10 rounded-full blur-[160px]"></div>
        <div class="absolute top-[65%] -right-60 w-[700px] h-[700px] bg-purple-600/15 rounded-full blur-[180px]"></div>
    </div>

    <!-- Header Navigation -->
    <header class="sticky top-0 z-50 glass-panel border-b border-white/[0.08] transition-all">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
            <!-- Brand Logo -->
            <a href="/" class="flex items-center space-x-3 group">
                <img src="/images/logo.png" class="w-10 h-10 rounded-xl shadow-lg shadow-brand-500/30 group-hover:scale-105 transition-transform object-cover" alt="AI Landing Page Logo">
                <div>
                    <span class="text-xl font-extrabold tracking-tight text-white flex items-center gap-1.5">
                        AI Landing Page
                        <span class="text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-full font-bold bg-brand-500/20 text-brand-300 border border-brand-500/30">AI</span>
                    </span>
                    <span class="text-[11px] text-slate-400 block -mt-0.5 font-medium">Build, Remix & Publish in Minutes</span>
                </div>
            </a>

            <!-- Nav Links (Desktop) -->
            <nav class="hidden lg:flex items-center space-x-8 text-sm font-semibold text-slate-300">
                <a href="#hero" class="hover:text-white transition-colors">Overview</a>
                <a href="#editor" class="hover:text-white transition-colors">Site Editor</a>
                <a href="#templates" class="hover:text-white transition-colors">Templates</a>
                <a href="#freedom" class="hover:text-white transition-colors">No Watermarks</a>
                <a href="#showcase" class="hover:text-white transition-colors">Live Showcase</a>
                <a href="#pricing" class="hover:text-white transition-colors">Pricing</a>
            </nav>

            <!-- Actions -->
            <div class="flex items-center space-x-3">
                <a href="/admin/login" class="hidden sm:inline-flex text-xs font-semibold px-3 py-2 rounded-lg text-slate-400 hover:text-white hover:bg-white/[0.04] transition-all">
                    Admin
                </a>
                <a href="#pricing" class="hidden sm:inline-flex text-xs font-bold px-3.5 py-2 rounded-xl bg-white/[0.06] hover:bg-white/[0.1] text-brand-300 border border-brand-500/20 transition-all">
                    $4.9/mo · Pro
                </a>
                <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="inline-flex items-center justify-center space-x-2 text-xs font-bold uppercase tracking-wider px-4 py-2.5 rounded-xl bg-gradient-to-r from-brand-500 to-purple-600 text-white shadow-lg shadow-brand-500/25 hover:brightness-110 active:scale-95 transition-all">
                    <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                    <span>Get on Google Play</span>
                </a>
            </div>
        </div>
    </header>

    <main>
        <!-- ======================================================== -->
        <!-- SECTION 1: HERO SECTION                                   -->
        <!-- ======================================================== -->
        <section id="hero" class="relative pt-12 pb-20 md:pt-20 md:pb-32 overflow-hidden bg-grid-pattern">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
                
                <!-- Announcement Pill -->
                <div class="inline-flex items-center space-x-2 px-4 py-1.5 rounded-full bg-brand-500/10 border border-brand-500/30 text-brand-300 text-xs sm:text-sm font-semibold mb-8 hover:bg-brand-500/15 transition-all">
                    <span class="flex h-2 w-2 rounded-full bg-brand-400 animate-ping"></span>
                    <span>AI-Powered Landing Page Generator · Instant Edge Hosting</span>
                </div>

                <!-- Hero Headline -->
                <h1 class="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight max-w-4xl mx-auto leading-[1.08]">
                    Your Landing Page.<br />
                    <span class="text-gradient">Live in 3 Minutes.</span>
                </h1>

                <!-- Subtitle -->
                <p class="mt-6 text-lg sm:text-2xl text-slate-300 max-w-2xl mx-auto leading-relaxed font-medium">
                    Describe your idea, generate your page, and publish it in minutes.
                </p>

                <p class="mt-3 text-sm sm:text-base text-slate-400 max-w-xl mx-auto">
                    Built natively for mobile and web. Seamless visual editing, curated high-converting templates, and 1-tap Cloudflare edge deployment with zero watermarks.
                </p>

                <!-- Hero CTAs -->
                <div class="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
                    <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="w-full sm:w-auto px-8 py-4 rounded-xl bg-gradient-to-r from-brand-500 via-purple-600 to-pink-500 text-white font-bold text-base shadow-xl shadow-brand-500/30 hover:shadow-brand-500/50 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-2.5">
                        <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                        <span>Start Free on Google Play</span>
                    </a>
                    <a href="#pricing" class="w-full sm:w-auto px-8 py-4 rounded-xl glass-panel text-slate-200 hover:text-white hover:bg-white/[0.08] font-semibold text-base transition-all flex items-center justify-center gap-2 border border-white/10">
                        <span>See Plans ($4.9/mo)</span>
                        <svg class="w-4 h-4 text-brand-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            <polyline points="12 5 19 12 12 19"></polyline>
                        </svg>
                    </a>
                </div>

                <!-- Trust Badges -->
                <div class="mt-12 flex flex-wrap items-center justify-center gap-6 sm:gap-10 text-xs sm:text-sm text-slate-400">
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span class="text-slate-300 font-medium">Free Forever · Zero Watermarks</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span class="text-slate-300 font-medium">Sub-Second Global Edge CDN</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span class="text-slate-300 font-medium">Custom Domains + Free SSL</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span class="text-slate-300 font-medium">1-Click Full ZIP Export</span>
                    </div>
                </div>

                <!-- HERO MOBILE FRAME SHOWCASE (Dual Showcase: Projects Dashboard & Templates Browser) -->
                <div class="mt-16 sm:mt-24 relative max-w-5xl mx-auto">
                    <!-- Glow Behind Showcase -->
                    <div class="absolute inset-0 bg-gradient-to-t from-brand-600/30 via-purple-600/25 to-transparent rounded-[60px] blur-3xl -z-10"></div>

                    <div class="grid grid-cols-1 md:grid-cols-12 gap-8 lg:gap-10 items-center justify-center">
                        
                        <!-- Centerpiece 1: Projects Dashboard in Portrait Mobile Frame -->
                        <div class="md:col-span-6 lg:col-span-5 flex justify-center">
                            <div class="mobile-frame-portrait max-w-[320px] w-full">
                                <div class="dynamic-island"></div>
                                <div class="rounded-[36px] overflow-hidden bg-black">
                                    <img src="/images/landing/projects_dashboard.jpg" 
                                         alt="AI Landing Page Projects Dashboard - Live Published Sites" 
                                         class="w-full h-auto block" 
                                         loading="eager">
                                </div>
                                <div class="mt-3 px-3 pb-1 text-left">
                                    <div class="text-xs font-bold text-white flex items-center justify-between">
                                        <span class="flex items-center gap-1.5">
                                            <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                                            Projects Control Center
                                        </span>
                                        <span class="text-[10px] text-brand-300 font-mono">1-Tap Live URL</span>
                                    </div>
                                    <p class="text-[11px] text-slate-400 mt-0.5">Manage live deployments, copy custom URLs & track revisions</p>
                                </div>
                            </div>
                        </div>

                        <!-- Centerpiece 2: Templates Browser in Portrait Mobile Frame -->
                        <div class="md:col-span-6 lg:col-span-7 flex flex-col justify-center text-left">
                            <div class="inline-flex items-center gap-2 px-3 py-1 rounded-lg bg-brand-500/10 text-brand-300 text-xs font-bold uppercase tracking-wider mb-4 border border-brand-500/20 w-fit">
                                Curated Edit · Trending 2026
                            </div>
                            <h2 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
                                Your next idea, <br>
                                <span class="text-gradient">beautifully started.</span>
                            </h2>
                            <p class="text-slate-300 mt-3 text-sm sm:text-base leading-relaxed">
                                Distinctive designs. Ready to make your own. Deploy high-conversion websites in 60 seconds with tailored typography, animations, and responsive layout structures.
                            </p>

                            <!-- Mobile Frame Preview of Template Browser -->
                            <div class="mt-6 flex items-center gap-6">
                                <div class="mobile-frame-portrait max-w-[260px] w-full shrink-0 hidden sm:block">
                                    <div class="dynamic-island"></div>
                                    <div class="rounded-[36px] overflow-hidden bg-black">
                                        <img src="/images/landing/templates_browser.jpg" 
                                             alt="Templates Browser - Trending 2026 Nexus AI" 
                                             class="w-full h-auto block" 
                                             loading="eager">
                                    </div>
                                </div>

                                <div class="space-y-3.5 text-xs sm:text-sm text-slate-300">
                                    <div class="flex items-center gap-2.5">
                                        <div class="w-5 h-5 rounded-full bg-brand-500/20 text-brand-300 flex items-center justify-center font-bold text-xs shrink-0">✓</div>
                                        <span><strong>Nexus AI:</strong> "Linear speed. Superhuman intelligence."</span>
                                    </div>
                                    <div class="flex items-center gap-2.5">
                                        <div class="w-5 h-5 rounded-full bg-brand-500/20 text-brand-300 flex items-center justify-center font-bold text-xs shrink-0">✓</div>
                                        <span><strong>Category Filters:</strong> Startups, Business, Weddings, Personal</span>
                                    </div>
                                    <div class="flex items-center gap-2.5">
                                        <div class="w-5 h-5 rounded-full bg-brand-500/20 text-brand-300 flex items-center justify-center font-bold text-xs shrink-0">✓</div>
                                        <span><strong>1-Click Action:</strong> Deploy in 60 seconds to Cloudflare edge</span>
                                    </div>
                                    <div class="pt-2">
                                        <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-brand-500 to-purple-600 text-white font-bold text-xs uppercase tracking-wider hover:brightness-110 transition-all shadow-md">
                                            <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                                            <span>Explore Templates on Google Play</span>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </section>

        <!-- ========================================================================= -->
        <!-- SECTION 2: FLIPPED SITE EDITOR IN LANDSCAPE MOBILE FRAME                   -->
        <!-- ========================================================================= -->
        <section id="editor" class="py-20 md:py-32 border-t border-white/[0.08] relative bg-dark-surface/30">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                
                <div class="text-center max-w-3xl mx-auto mb-16">
                    <span class="text-xs font-bold uppercase tracking-wider text-brand-400 px-3.5 py-1.5 rounded-full bg-brand-500/10 border border-brand-500/20">
                        Flipped & Optimized Visual Canvas
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        Create It. Publish It. Share It.
                    </h2>
                    <p class="mt-4 text-base sm:text-lg text-slate-300">
                        Drag onto your page, or tap to add below the selection. Full visual control with direct manipulation and live responsive simulations.
                    </p>
                </div>

                <!-- Landscape Mobile Frame for Flipped Site Editor -->
                <div class="max-w-4xl mx-auto">
                    <div class="mobile-frame-landscape w-full relative">
                        <!-- Landscape Camera / Notch dot on the left -->
                        <div class="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 rounded-full bg-black/80 border border-white/20 z-30 hidden sm:block"></div>
                        
                        <div class="rounded-[28px] overflow-hidden bg-black border border-white/10">
                            <img src="/images/landing/site_editor.jpg" 
                                 alt="AI Landing Page Flipped Site Editor - Drag onto your page or tap to add below the selection" 
                                 class="w-full h-auto block" 
                                 loading="lazy">
                        </div>

                        <!-- Highlights bar below the frame -->
                        <div class="mt-4 p-3 px-4 glass-panel rounded-2xl flex flex-wrap items-center justify-between gap-4 text-xs">
                            <div class="flex items-center gap-3">
                                <span class="w-2.5 h-2.5 rounded-full bg-emerald-400"></span>
                                <span class="font-bold text-white">Live Split Canvas:</span>
                                <span class="text-slate-300">"Together is a beautiful place" · Tuscany Wedding Live Preview</span>
                            </div>
                            <div class="flex items-center gap-2 text-slate-400 font-mono">
                                <span>Tabs: Add · Edit · Layers · Design</span>
                                <span class="text-slate-600">|</span>
                                <span class="text-brand-300 font-bold">1-Tap Publish Button</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 6 Building Block Cards matching the image -->
                <div class="mt-12 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3.5 max-w-5xl mx-auto">
                    <div class="glass-panel p-4 rounded-2xl border border-white/10 text-center hover:border-brand-500/40 transition-colors">
                        <div class="w-8 h-8 rounded-lg bg-brand-500/10 text-brand-300 flex items-center justify-center mx-auto mb-2 font-bold text-xs">01</div>
                        <h4 class="text-xs font-bold text-white">Hero</h4>
                        <p class="text-[11px] text-slate-400 mt-1">Impact headlines</p>
                    </div>

                    <div class="glass-panel p-4 rounded-2xl border border-white/10 text-center hover:border-brand-500/40 transition-colors">
                        <div class="w-8 h-8 rounded-lg bg-purple-500/10 text-purple-300 flex items-center justify-center mx-auto mb-2 font-bold text-xs">02</div>
                        <h4 class="text-xs font-bold text-white">Products</h4>
                        <p class="text-[11px] text-slate-400 mt-1">Pricing & features</p>
                    </div>

                    <div class="glass-panel p-4 rounded-2xl border border-white/10 text-center hover:border-brand-500/40 transition-colors">
                        <div class="w-8 h-8 rounded-lg bg-pink-500/10 text-pink-300 flex items-center justify-center mx-auto mb-2 font-bold text-xs">03</div>
                        <h4 class="text-xs font-bold text-white">Story</h4>
                        <p class="text-[11px] text-slate-400 mt-1">Founder journey</p>
                    </div>

                    <div class="glass-panel p-4 rounded-2xl border border-white/10 text-center hover:border-brand-500/40 transition-colors">
                        <div class="w-8 h-8 rounded-lg bg-sky-500/10 text-sky-300 flex items-center justify-center mx-auto mb-2 font-bold text-xs">04</div>
                        <h4 class="text-xs font-bold text-white">Gallery</h4>
                        <p class="text-[11px] text-slate-400 mt-1">Masonry grids</p>
                    </div>

                    <div class="glass-panel p-4 rounded-2xl border border-white/10 text-center hover:border-brand-500/40 transition-colors">
                        <div class="w-8 h-8 rounded-lg bg-amber-500/10 text-amber-300 flex items-center justify-center mx-auto mb-2 font-bold text-xs">05</div>
                        <h4 class="text-xs font-bold text-white">Text</h4>
                        <p class="text-[11px] text-slate-400 mt-1">Rich editorial</p>
                    </div>

                    <div class="glass-panel p-4 rounded-2xl border border-white/10 text-center hover:border-brand-500/40 transition-colors">
                        <div class="w-8 h-8 rounded-lg bg-emerald-500/10 text-emerald-300 flex items-center justify-center mx-auto mb-2 font-bold text-xs">06</div>
                        <h4 class="text-xs font-bold text-white">Call to action</h4>
                        <p class="text-[11px] text-slate-400 mt-1">Conversion buttons</p>
                    </div>
                </div>

            </div>
        </section>

        <!-- ========================================================================= -->
        <!-- SECTION 3: TEMPLATES SHOWCASE IN PORTRAIT MOBILE FRAMES                   -->
        <!-- ========================================================================= -->
        <section id="templates" class="py-20 md:py-32 border-t border-white/[0.08] relative">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                
                <div class="text-center max-w-3xl mx-auto mb-16 sm:mb-24">
                    <span class="text-xs font-bold uppercase tracking-wider text-purple-400 px-3.5 py-1.5 rounded-full bg-purple-500/10 border border-purple-500/20">
                        Curated Editorial System
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        Modern, Elegant Templates.
                    </h2>
                    <p class="mt-4 text-base sm:text-lg text-slate-400">
                        Designed for every business. Handcrafted typography, immersive storytelling layouts, and responsive components ready to launch immediately.
                    </p>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
                    
                    <!-- Template Showcase 1: Ana & Teo Weddings -->
                    <div class="glass-panel p-8 sm:p-10 rounded-[40px] border border-white/10 flex flex-col md:flex-row gap-8 items-center glass-card-hover">
                        <div class="mobile-frame-portrait max-w-[260px] w-full shrink-0">
                            <div class="dynamic-island"></div>
                            <div class="rounded-[36px] overflow-hidden bg-black">
                                <img src="/images/landing/template_wedding.jpg" 
                                     alt="Made for Moments - Ana & Teo Weddings Template" 
                                     class="w-full h-auto block" 
                                     loading="lazy">
                            </div>
                        </div>

                        <div class="flex-1 text-left">
                            <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-pink-500/10 text-pink-300 text-[11px] font-bold uppercase tracking-wider mb-3 border border-pink-500/20">
                                ✦ Made for Moments
                            </div>
                            <h3 class="text-2xl font-extrabold text-white">
                                Ana & Teo Weddings
                            </h3>
                            <p class="text-xs text-slate-400 mt-1 font-mono">
                                Weddings & Milestone Celebrations
                            </p>
                            <p class="text-sm text-slate-300 mt-3 leading-relaxed">
                                Romantic editorial typography, love story timelines ("Eight Years of Adventures"), RSVP capture, and venue location guides.
                            </p>
                            <div class="mt-6 pt-6 border-t border-white/10 flex items-center justify-between">
                                <button onclick="openLiveModal('/sites/studiomarlow', 'Ana & Teo Wedding Experience')" class="text-xs font-bold text-brand-400 hover:text-brand-300 flex items-center gap-1.5">
                                    <span>Interactive Preview</span>
                                    <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                                </button>
                                <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/15 text-white font-bold text-xs uppercase tracking-wider transition-all">
                                    <svg class="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                                    <span>Use Template</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Template Showcase 2: Solstice Fine Dining -->
                    <div class="glass-panel p-8 sm:p-10 rounded-[40px] border border-white/10 flex flex-col md:flex-row gap-8 items-center glass-card-hover">
                        <div class="mobile-frame-portrait max-w-[260px] w-full shrink-0">
                            <div class="dynamic-island"></div>
                            <div class="rounded-[36px] overflow-hidden bg-black">
                                <img src="/images/landing/template_dining.jpg" 
                                     alt="Michelin Guide 2026 - Solstice Fine Dining Template" 
                                     class="w-full h-auto block" 
                                     loading="lazy">
                            </div>
                        </div>

                        <div class="flex-1 text-left">
                            <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-500/10 text-amber-300 text-[11px] font-bold uppercase tracking-wider mb-3 border border-amber-500/20">
                                ★ Michelin Guide 2026
                            </div>
                            <h3 class="text-2xl font-extrabold text-white">
                                Solstice Fine Dining
                            </h3>
                            <p class="text-xs text-slate-400 mt-1 font-mono">
                                Restaurant & Luxury Hospitality
                            </p>
                            <p class="text-sm text-slate-300 mt-3 leading-relaxed">
                                Dark luxury aesthetics, spring tasting menu cards, woodfire kitchen highlights, table reservations, and wine pairings.
                            </p>
                            <div class="mt-6 pt-6 border-t border-white/10 flex items-center justify-between">
                                <button onclick="openLiveModal('/sites/artisan-bakery', 'Solstice Culinary Experience')" class="text-xs font-bold text-brand-400 hover:text-brand-300 flex items-center gap-1.5">
                                    <span>Interactive Preview</span>
                                    <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                                </button>
                                <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/15 text-white font-bold text-xs uppercase tracking-wider transition-all">
                                    <svg class="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                                    <span>Use Template</span>
                                </a>
                            </div>
                        </div>
                    </div>

                </div>

            </div>
        </section>

        <!-- ========================================================================= -->
        <!-- SECTION 4: FREEDOM & NO WATERMARKS                                        -->
        <!-- ========================================================================= -->
        <section id="freedom" class="py-20 md:py-32 border-t border-white/[0.08] bg-dark-surface/60 relative overflow-hidden">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                
                <div class="max-w-4xl mx-auto text-center">
                    <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-300 text-xs font-bold uppercase tracking-wider mb-4 border border-emerald-500/20">
                        Uncompromised Ownership
                    </div>

                    <h2 class="text-3xl sm:text-6xl font-black text-white tracking-tight leading-tight">
                        Free. Forever.<br />
                        <span class="text-gradient-brand">No Watermarks.</span>
                    </h2>

                    <p class="text-lg sm:text-xl text-slate-200 mt-4 font-semibold">
                        "Together is a beautiful place." Your site should reflect your brand, not ours.
                    </p>

                    <p class="text-slate-400 mt-3 text-sm sm:text-base leading-relaxed max-w-2xl mx-auto">
                        Unlike traditional builders that inject giant "Made on..." badges or popups across your hard work, AI Landing Page keeps your published website 100% clean and unbranded on all plans.
                    </p>

                    <div class="mt-12 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-left">
                        <div class="glass-panel p-5 rounded-2xl border border-white/10">
                            <div class="text-emerald-400 font-bold text-sm flex items-center gap-2 mb-2">
                                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Zero Vendor Badges</span>
                            </div>
                            <p class="text-xs text-slate-400 leading-relaxed">No promotional banners or third-party footers forced on your visitors.</p>
                        </div>

                        <div class="glass-panel p-5 rounded-2xl border border-white/10">
                            <div class="text-emerald-400 font-bold text-sm flex items-center gap-2 mb-2">
                                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Full Code Ownership</span>
                            </div>
                            <p class="text-xs text-slate-400 leading-relaxed">Export complete, standalone HTML, CSS, JavaScript & assets in a ZIP file.</p>
                        </div>

                        <div class="glass-panel p-5 rounded-2xl border border-white/10">
                            <div class="text-emerald-400 font-bold text-sm flex items-center gap-2 mb-2">
                                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Global Edge CDN</span>
                            </div>
                            <p class="text-xs text-slate-400 leading-relaxed">High-performance edge distribution on Cloudflare with sub-second response times.</p>
                        </div>

                        <div class="glass-panel p-5 rounded-2xl border border-white/10">
                            <div class="text-emerald-400 font-bold text-sm flex items-center gap-2 mb-2">
                                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Instant Subdomains</span>
                            </div>
                            <p class="text-xs text-slate-400 leading-relaxed">Free live hosting instantly accessible at <code class="text-brand-300 font-mono">ai-landing-page.xyz/sites/...</code></p>
                        </div>
                    </div>
                </div>

            </div>
        </section>

        <!-- ========================================================================= -->
        <!-- SECTION 5: PRICING ($4.9 USD Monthly & $39.9 USD Yearly)                  -->
        <!-- ========================================================================= -->
        <section id="pricing" class="py-20 md:py-32 border-t border-white/[0.08] relative">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                
                <div class="text-center max-w-3xl mx-auto mb-12 sm:mb-16">
                    <span class="text-xs font-bold uppercase tracking-wider text-emerald-400 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20">
                        Transparent Pricing
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        Simple, Predictable Plans.
                    </h2>
                    <p class="mt-4 text-base sm:text-lg text-slate-400">
                        Get started completely free with zero watermarks. Upgrade to Pro for custom domains, full source code export, and AI generation tokens.
                    </p>

                    <!-- Monthly / Yearly Billing Toggle -->
                    <div class="mt-8 inline-flex items-center p-1.5 rounded-2xl glass-panel border border-white/10">
                        <button id="toggleMonthly" onclick="setBillingInterval('monthly')" class="px-5 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all bg-brand-500 text-white shadow-md">
                            Monthly Billing
                        </button>
                        <button id="toggleYearly" onclick="setBillingInterval('yearly')" class="px-5 py-2 rounded-xl text-xs sm:text-sm font-semibold transition-all text-slate-400 hover:text-white flex items-center gap-1.5">
                            <span>Yearly Billing</span>
                            <span class="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 font-extrabold border border-emerald-500/30">SAVE 32%</span>
                        </button>
                    </div>
                </div>

                <!-- Pricing Cards Grid -->
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 max-w-6xl mx-auto">
                    
                    <!-- Plan 1: Free Starter -->
                    <div class="glass-panel p-8 sm:p-10 rounded-3xl border border-white/10 flex flex-col justify-between glass-card-hover">
                        <div>
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Starter</span>
                                <span class="text-[11px] px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-300 font-bold border border-emerald-500/20">No Watermarks</span>
                            </div>
                            
                            <div class="mt-5 flex items-baseline gap-2">
                                <span class="text-4xl sm:text-5xl font-black text-white">$0</span>
                                <span class="text-sm text-slate-400 font-medium">/ forever</span>
                            </div>
                            <p class="text-sm text-slate-300 mt-3 leading-relaxed">
                                Perfect for testing new concepts, personal links, and clean unbranded portfolios.
                            </p>
                            
                            <ul class="mt-8 space-y-3.5 text-sm text-slate-300">
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span><strong>100% Free Forever, No Watermarks</strong></span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Unlimited visual editing & drafts</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Free platform subdomain hosting</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Cloudflare global edge CDN delivery</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Access to all core starter templates</span>
                                </li>
                                <li class="flex items-center gap-3 text-slate-500">
                                    <span>✕</span>
                                    <span>Custom domains (Pro feature)</span>
                                </li>
                            </ul>
                        </div>

                        <div class="mt-10">
                            <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="w-full py-3.5 rounded-xl glass-panel text-white font-bold text-sm hover:bg-white/10 transition-all flex items-center justify-center gap-2 border border-white/10">
                                <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                                <span>Start Free on Google Play</span>
                            </a>
                        </div>
                    </div>

                    <!-- Plan 2: Pro Monthly ($4.9 USD) -->
                    <div id="cardProMonthly" class="glass-panel p-8 sm:p-10 rounded-3xl border border-brand-500/40 flex flex-col justify-between glass-card-hover relative">
                        <div>
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold uppercase tracking-wider text-brand-300">Pro Monthly</span>
                                <span class="text-[11px] px-2.5 py-1 rounded-full bg-brand-500/10 text-brand-300 font-bold border border-brand-500/20">Flexible</span>
                            </div>

                            <div class="mt-5 flex items-baseline gap-2">
                                <span class="text-4xl sm:text-5xl font-black text-white">$4.9</span>
                                <span class="text-sm text-slate-400 font-medium">USD / month</span>
                            </div>
                            <p class="text-sm text-slate-300 mt-3 leading-relaxed">
                                Complete creative freedom with custom domains and production code export. Cancel anytime.
                            </p>

                            <ul class="mt-8 space-y-3.5 text-sm text-slate-300">
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400 font-bold">✓</span>
                                    <span class="font-semibold text-white">Custom domain mapping + free SSL</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400 font-bold">✓</span>
                                    <span class="font-semibold text-white">1-Click ZIP source code export</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400 font-bold">✓</span>
                                    <span>100 AI generation & remix tokens/mo</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400 font-bold">✓</span>
                                    <span>Ad-free editing experience</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400 font-bold">✓</span>
                                    <span>Priority edge routing & DNS speed</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400 font-bold">✓</span>
                                    <span>Up to 25 published live projects</span>
                                </li>
                            </ul>
                        </div>

                        <div class="mt-10">
                            <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="w-full py-3.5 rounded-xl bg-gradient-to-r from-brand-500 to-purple-600 text-white font-bold text-sm shadow-lg shadow-brand-500/25 hover:brightness-110 active:scale-95 transition-all flex items-center justify-center gap-2">
                                <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                                <span>Subscribe on Google Play ($4.9/mo)</span>
                            </a>
                        </div>
                    </div>

                    <!-- Plan 3: Pro Yearly ($39.9 USD - Best Value) -->
                    <div id="cardProYearly" class="glass-panel-glow p-8 sm:p-10 rounded-3xl border-2 border-brand-500/60 flex flex-col justify-between glass-card-hover relative">
                        <div class="absolute -top-3.5 right-6 px-3.5 py-1 rounded-full text-[11px] font-extrabold uppercase tracking-wider bg-gradient-to-r from-emerald-500 via-brand-500 to-purple-600 text-white shadow-xl">
                            Best Value · Save 32%
                        </div>
                        <div>
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold uppercase tracking-wider text-emerald-400">Pro Yearly</span>
                                <span class="text-[11px] px-2.5 py-1 rounded-full bg-emerald-500/20 text-emerald-300 font-extrabold border border-emerald-500/30">Just $3.32/mo</span>
                            </div>

                            <div class="mt-5 flex items-baseline gap-2">
                                <span class="text-4xl sm:text-5xl font-black text-white">$39.9</span>
                                <span class="text-sm text-slate-400 font-medium">USD / year</span>
                            </div>
                            <p class="text-sm text-emerald-300/90 mt-3 font-semibold">
                                Save $18.90 compared to monthly billing!
                            </p>

                            <ul class="mt-8 space-y-3.5 text-sm text-slate-300">
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span class="font-bold text-white">Everything in Pro Monthly</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span class="font-semibold text-white">Full 12 Months Access ($3.32/mo)</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Priority 24/7 developer support</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Early access to new trending templates</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Unlimited custom domain attachments</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400 font-bold">✓</span>
                                    <span>Full ZIP code & asset bundle exports</span>
                                </li>
                            </ul>
                        </div>

                        <div class="mt-10">
                            <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="w-full py-3.5 rounded-xl bg-gradient-to-r from-emerald-500 via-brand-500 to-purple-600 text-white font-extrabold text-sm shadow-xl shadow-brand-500/30 hover:brightness-110 active:scale-95 transition-all flex items-center justify-center gap-2">
                                <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                                <span>Subscribe on Google Play ($39.9/yr)</span>
                            </a>
                        </div>
                    </div>

                </div>

            </div>
        </section>

        <!-- ========================================================================= -->
        <!-- SECTION 6: LIVE GALLERY (Interactive Modal)                               -->
        <!-- ========================================================================= -->
        <section id="showcase" class="py-20 md:py-32 border-t border-white/[0.08] bg-dark-surface/40 relative">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                
                <div class="text-center max-w-3xl mx-auto mb-16">
                    <span class="text-xs font-bold uppercase tracking-wider text-brand-400 px-3.5 py-1.5 rounded-full bg-brand-500/10 border border-brand-500/20">
                        Live Deployments
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        Websites Created With AI Landing Page
                    </h2>
                    <p class="mt-4 text-base sm:text-lg text-slate-400">
                        Explore real websites built with our engine and served live across Cloudflare edge infrastructure. Click "Interactive Preview" to test them directly!
                    </p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
                    
                    <!-- Live Showcase 1: Lumen Specialty Coffee -->
                    <div class="glass-panel rounded-3xl overflow-hidden border border-white/10 hover:border-brand-500/40 transition-all duration-300 group flex flex-col">
                        <div class="relative overflow-hidden aspect-[16/10] bg-slate-900 border-b border-white/[0.08]">
                            <img src="/images/app/lumen_site.png" alt="Lumen Specialty Coffee Live Site" class="w-full h-full object-cover object-top group-hover:scale-105 transition-transform duration-700" loading="lazy">
                            <div class="absolute inset-0 bg-gradient-to-t from-dark-base via-transparent to-transparent opacity-60"></div>
                            <span class="absolute top-4 left-4 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 backdrop-blur-md">
                                ● Live & Published
                            </span>
                        </div>
                        <div class="p-6 sm:p-8 flex-1 flex flex-col justify-between">
                            <div>
                                <div class="flex items-center justify-between text-xs text-slate-400 mb-2 font-mono">
                                    <span>Food & Beverage · Roastery</span>
                                    <span>subdomain: lumen-specialty</span>
                                </div>
                                <h3 class="text-2xl font-bold text-white group-hover:text-brand-300 transition-colors">
                                    Lumen Specialty Coffee
                                </h3>
                                <p class="text-sm text-slate-300 mt-2 leading-relaxed">
                                    Warm minimalist artisanal landing page featuring hero ordering, product grid, coffee brewing highlights, and newsletter subscriptions.
                                </p>
                            </div>
                            <div class="mt-6 pt-6 border-t border-white/[0.08] flex items-center justify-between">
                                <a href="/sites/lumen-specialty" target="_blank" class="inline-flex items-center gap-2 text-sm font-bold text-brand-400 hover:text-brand-300 transition-colors">
                                    <span>Visit Live Site</span>
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                                </a>
                                <button onclick="openLiveModal('/sites/lumen-specialty', 'Lumen Specialty Coffee')" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold glass-panel text-slate-300 hover:text-white hover:bg-white/10 transition-all">
                                    Interactive Preview
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Live Showcase 2: Artisan Sourdough Bakery -->
                    <div class="glass-panel rounded-3xl overflow-hidden border border-white/10 hover:border-brand-500/40 transition-all duration-300 group flex flex-col">
                        <div class="relative overflow-hidden aspect-[16/10] bg-slate-900 border-b border-white/[0.08]">
                            <img src="/images/app/bakery_site.png" alt="Artisan Sourdough Bakery Live Site" class="w-full h-full object-cover object-top group-hover:scale-105 transition-transform duration-700" loading="lazy">
                            <div class="absolute inset-0 bg-gradient-to-t from-dark-base via-transparent to-transparent opacity-60"></div>
                            <span class="absolute top-4 left-4 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 backdrop-blur-md">
                                ● Live & Published
                            </span>
                        </div>
                        <div class="p-6 sm:p-8 flex-1 flex flex-col justify-between">
                            <div>
                                <div class="flex items-center justify-between text-xs text-slate-400 mb-2 font-mono">
                                    <span>Artisan Craft · Organic Sourdough</span>
                                    <span>subdomain: artisan-bakery</span>
                                </div>
                                <h3 class="text-2xl font-bold text-white group-hover:text-brand-300 transition-colors">
                                    Artisan Sourdough Bakery
                                </h3>
                                <p class="text-sm text-slate-300 mt-2 leading-relaxed">
                                    Editorial aesthetic with daily fresh bakes schedule, order inquiries, sourdough philosophy, and location maps.
                                </p>
                            </div>
                            <div class="mt-6 pt-6 border-t border-white/[0.08] flex items-center justify-between">
                                <a href="/sites/artisan-bakery" target="_blank" class="inline-flex items-center gap-2 text-sm font-bold text-brand-400 hover:text-brand-300 transition-colors">
                                    <span>Visit Live Site</span>
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                                </a>
                                <button onclick="openLiveModal('/sites/artisan-bakery', 'Artisan Sourdough Bakery')" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold glass-panel text-slate-300 hover:text-white hover:bg-white/10 transition-all">
                                    Interactive Preview
                                </button>
                            </div>
                        </div>
                    </div>

                </div>

            </div>
        </section>

        <!-- ========================================================================= -->
        <!-- FINAL CONVERSION CALL TO ACTION                                           -->
        <!-- ========================================================================= -->
        <section class="py-20 border-t border-white/[0.08] relative overflow-hidden">
            <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="glass-panel-glow rounded-[40px] p-8 sm:p-14 text-center relative overflow-hidden border-2 border-brand-500/40">
                    <div class="absolute -right-20 -bottom-20 w-80 h-80 bg-brand-500/25 rounded-full blur-3xl pointer-events-none"></div>
                    <div class="absolute -left-20 -top-20 w-80 h-80 bg-purple-500/25 rounded-full blur-3xl pointer-events-none"></div>

                    <span class="text-xs font-bold uppercase tracking-wider text-brand-300 px-3.5 py-1.5 rounded-full bg-brand-500/20 border border-brand-500/30">
                        Launch in 3 Minutes
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold text-white mt-4 tracking-tight">
                        Your Landing Page. Live Today.
                    </h2>
                    <p class="text-slate-300 mt-4 max-w-xl mx-auto text-base sm:text-lg">
                        No coding required. Free forever with zero watermarks. Upgrade to Pro for just $4.9/mo or $39.9/yr.
                    </p>

                    <div class="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4">
                        <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="w-full sm:w-auto px-8 py-4 rounded-xl bg-white text-slate-950 font-bold text-base hover:bg-slate-100 transition-all shadow-xl flex items-center justify-center gap-2.5">
                            <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24"><path d="M3.609 1.814L13.793 12 3.61 22.186a2.373 2.373 0 0 1-.61-.937V2.75c.162-.367.373-.687.61-.937zm11.233 11.234l2.584 2.584-11.83 6.74 9.246-9.324zm0-2.096L5.596 1.628l11.83 6.74-2.584 2.584zm1.485 1.048l3.69-2.102a1.353 1.353 0 0 1 0 2.37l-3.69 2.102-1.047-1.047 1.047-1.323z"/></svg>
                            <span>Start Building Now</span>
                        </a>
                        <a href="https://play.google.com/store/apps/details?id=com.douibi.landing.ai" target="_blank" rel="noopener" class="w-full sm:w-auto px-8 py-4 rounded-xl glass-panel text-white font-bold text-base hover:bg-white/10 transition-all border border-white/10 flex items-center justify-center gap-2">
                            <span>Subscribe on Google Play ($4.9/mo)</span>
                        </a>
                    </div>
                </div>
            </div>
        </section>

    </main>

    <!-- Footer -->
    <footer class="border-t border-white/[0.08] bg-dark-base py-12">
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
                <a href="/delete-account" class="hover:text-white transition-colors">Delete Account</a>
                <a href="/admin/login" class="hover:text-white transition-colors">Admin Login</a>
                <a href="/api/v1/health" target="_blank" class="hover:text-white transition-colors">API Status</a>
                <a href="#showcase" class="hover:text-white transition-colors">Live Gallery</a>
            </div>
        </div>
    </footer>

    <!-- Interactive Live Preview Modal -->
    <div id="previewModal" class="fixed inset-0 z-50 hidden bg-black/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 transition-all">
        <div class="w-full max-w-5xl h-[85vh] bg-dark-surface rounded-3xl border border-white/10 flex flex-col overflow-hidden shadow-2xl">
            <!-- Modal Header -->
            <div class="px-6 py-4 border-b border-white/[0.08] flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <span class="w-3 h-3 rounded-full bg-emerald-400 animate-pulse"></span>
                    <span id="modalTitle" class="font-bold text-white text-base">Live Preview</span>
                    <span id="modalUrl" class="text-xs font-mono text-slate-400 hidden sm:inline"></span>
                </div>
                <div class="flex items-center gap-3">
                    <a id="modalExternalLink" href="#" target="_blank" class="text-xs font-bold text-brand-400 hover:text-brand-300 flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-brand-500/10">
                        <span>Open in New Tab</span>
                        <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                    </a>
                    <button onclick="closeLiveModal()" class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors">
                        ✕
                    </button>
                </div>
            </div>
            <!-- Modal Iframe Body -->
            <div class="flex-1 bg-white relative">
                <iframe id="previewIframe" src="" class="w-full h-full border-0"></iframe>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script>
        function openLiveModal(url, title) {
            document.getElementById('modalTitle').textContent = title;
            document.getElementById('modalUrl').textContent = url;
            document.getElementById('modalExternalLink').href = url;
            document.getElementById('previewIframe').src = url;
            document.getElementById('previewModal').classList.remove('hidden');
        }

        function closeLiveModal() {
            document.getElementById('previewModal').classList.add('hidden');
            document.getElementById('previewIframe').src = '';
        }

        document.getElementById('previewModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeLiveModal();
            }
        });

        // Billing Toggle Switcher
        function setBillingInterval(interval) {
            const btnMonthly = document.getElementById('toggleMonthly');
            const btnYearly = document.getElementById('toggleYearly');
            const cardProMonthly = document.getElementById('cardProMonthly');
            const cardProYearly = document.getElementById('cardProYearly');

            if (interval === 'monthly') {
                btnMonthly.className = 'px-5 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all bg-brand-500 text-white shadow-md';
                btnYearly.className = 'px-5 py-2 rounded-xl text-xs sm:text-sm font-semibold transition-all text-slate-400 hover:text-white flex items-center gap-1.5';
                
                cardProMonthly.classList.add('border-brand-500/70', 'ring-2', 'ring-brand-500/30');
                cardProYearly.classList.remove('border-brand-500/80', 'ring-2', 'ring-brand-500/40');
            } else {
                btnYearly.className = 'px-5 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all bg-brand-500 text-white shadow-md flex items-center gap-1.5';
                btnMonthly.className = 'px-5 py-2 rounded-xl text-xs sm:text-sm font-semibold transition-all text-slate-400 hover:text-white';

                cardProYearly.classList.add('border-brand-500/80', 'ring-2', 'ring-brand-500/40');
                cardProMonthly.classList.remove('border-brand-500/70', 'ring-2', 'ring-brand-500/30');
            }
        }
    </script>
</body>
</html>
