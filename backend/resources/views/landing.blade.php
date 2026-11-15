<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Landing Page Builder — Build, Remix & Publish from Your Phone</title>
    <meta name="description" content="The premier mobile-first AI website builder. Design high-converting, responsive landing pages from your phone with instant Cloudflare edge hosting and custom domains.">
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%236366f1' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><polygon points='12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2'/></svg>">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'Inter', 'sans-serif'],
                        mono: ['JetBrains Mono', 'monospace'],
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
                        'pulse-glow': 'pulseGlow 4s ease-in-out infinite',
                        'float-slow': 'floatSlow 6s ease-in-out infinite',
                        'float-reverse': 'floatReverse 7s ease-in-out infinite',
                    },
                    keyframes: {
                        pulseGlow: {
                            '0%, 100%': { opacity: '0.4', transform: 'scale(1)' },
                            '50%': { opacity: '0.7', transform: 'scale(1.05)' },
                        },
                        floatSlow: {
                            '0%, 100%': { transform: 'translateY(0px)' },
                            '50%': { transform: 'translateY(-12px)' },
                        },
                        floatReverse: {
                            '0%, 100%': { transform: 'translateY(0px)' },
                            '50%': { transform: 'translateY(12px)' },
                        }
                    }
                }
            }
        }
    </script>

    <style>
        /* Custom Glowing Glass Cards */
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
            box-shadow: 0 0 40px -10px rgba(99, 102, 241, 0.2);
        }
        /* Realistic Phone Bezel Frame */
        .phone-frame {
            border-radius: 46px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7), 0 0 0 10px #1e293b, 0 0 0 12px rgba(255, 255, 255, 0.1);
            overflow: hidden;
            background: #000;
        }
        /* Dynamic Island */
        .dynamic-island {
            position: absolute;
            top: 10px;
            left: 50%;
            transform: translateX(-50%);
            width: 110px;
            height: 28px;
            background: #000;
            border-radius: 20px;
            z-index: 30;
        }
        /* Gradient Text */
        .text-gradient {
            background: linear-gradient(135deg, #FFFFFF 0%, #A5B4FC 50%, #C084FC 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .text-gradient-brand {
            background: linear-gradient(135deg, #818CF8 0%, #C084FC 50%, #F472B6 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
    </style>
</head>
<body class="bg-dark-base text-slate-100 font-sans antialiased overflow-x-hidden selection:bg-brand-500 selection:text-white">

    <!-- Ambient Mesh Glows -->
    <div class="fixed inset-0 overflow-hidden pointer-events-none -z-10">
        <div class="absolute -top-40 left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-gradient-to-tr from-brand-600/20 via-purple-600/15 to-transparent rounded-full blur-[140px] animate-pulse-glow"></div>
        <div class="absolute top-[40%] -left-60 w-[600px] h-[600px] bg-brand-500/10 rounded-full blur-[160px]"></div>
        <div class="absolute top-[70%] -right-60 w-[600px] h-[600px] bg-purple-500/10 rounded-full blur-[160px]"></div>
    </div>

    <!-- Header Navigation -->
    <header class="sticky top-0 z-50 glass-panel border-b border-white/[0.06] transition-all">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
            <!-- Brand Logo -->
            <a href="/" class="flex items-center space-x-3 group">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-brand-500 to-purple-600 p-[1px] shadow-lg shadow-brand-500/25 group-hover:scale-105 transition-transform">
                    <div class="w-full h-full bg-dark-base rounded-[11px] flex items-center justify-center">
                        <svg class="w-5 h-5 text-brand-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                        </svg>
                    </div>
                </div>
                <div>
                    <span class="text-xl font-bold tracking-tight text-white flex items-center gap-1.5">
                        LandingCraft <span class="text-xs px-2 py-0.5 rounded-full font-semibold bg-brand-500/10 text-brand-400 border border-brand-500/20">AI</span>
                    </span>
                    <span class="text-[11px] text-slate-400 block -mt-1 font-medium">Mobile Landing Page Platform</span>
                </div>
            </a>

            <!-- Nav Links (Desktop) -->
            <nav class="hidden md:flex items-center space-x-8 text-sm font-medium text-slate-300">
                <a href="#showcase" class="hover:text-white transition-colors">Live Showcase</a>
                <a href="#features" class="hover:text-white transition-colors">Features</a>
                <a href="#templates" class="hover:text-white transition-colors">Templates</a>
                <a href="#workflow" class="hover:text-white transition-colors">How It Works</a>
                <a href="#pricing" class="hover:text-white transition-colors">Pricing</a>
            </nav>

            <!-- Actions -->
            <div class="flex items-center space-x-3">
                <a href="/admin/login" class="hidden sm:inline-flex text-xs font-semibold px-3 py-2 rounded-lg text-slate-400 hover:text-white hover:bg-white/[0.04] transition-all">
                    Admin Portal
                </a>
                <a href="#showcase" class="inline-flex items-center justify-center space-x-2 text-xs font-bold uppercase tracking-wider px-4 py-2.5 rounded-xl bg-gradient-to-r from-brand-500 to-purple-600 text-white shadow-lg shadow-brand-500/20 hover:brightness-110 active:scale-95 transition-all">
                    <span>Try Live Demo</span>
                    <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <path d="M5 12h14M12 5l7 7-7 7"/>
                    </svg>
                </a>
            </div>
        </div>
    </header>

    <main>
        <!-- Hero Section -->
        <section class="relative pt-12 pb-20 md:pt-20 md:pb-32 overflow-hidden">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
                <!-- Announcement Pill -->
                <div class="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-full bg-brand-500/10 border border-brand-500/25 text-brand-300 text-xs sm:text-sm font-medium mb-8 hover:bg-brand-500/15 transition-all">
                    <span class="flex h-2 w-2 rounded-full bg-brand-400 animate-ping"></span>
                    <span>100% Free Edge Hosting · Instant Subdomain & Custom Domains</span>
                </div>

                <!-- Hero Headline -->
                <h1 class="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight max-w-4xl mx-auto leading-[1.1]">
                    Build, Remix & Publish <br class="hidden sm:inline" />
                    <span class="text-gradient">Landing Pages in Seconds.</span>
                </h1>

                <!-- Subtitle -->
                <p class="mt-6 text-lg sm:text-xl text-slate-400 max-w-2xl mx-auto leading-relaxed">
                    Designed for phones. Powered by AI. Build high-converting responsive sites, preview them live, and publish to the edge with one tap.
                </p>

                <!-- Hero CTAs -->
                <div class="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
                    <a href="#showcase" class="w-full sm:w-auto px-8 py-4 rounded-xl bg-gradient-to-r from-brand-500 via-purple-600 to-pink-500 text-white font-bold text-base shadow-xl shadow-brand-500/25 hover:shadow-brand-500/40 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-2">
                        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polygon points="5 3 19 12 5 21 5 3"/>
                        </svg>
                        <span>Explore Live Sites</span>
                    </a>
                    <a href="#mobile-app" class="w-full sm:w-auto px-8 py-4 rounded-xl glass-panel text-slate-200 hover:text-white hover:bg-white/[0.06] font-semibold text-base transition-all flex items-center justify-center gap-2">
                        <svg class="w-5 h-5 text-brand-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="5" y="2" width="14" height="20" rx="2" ry="2"/>
                            <line x1="12" y1="18" x2="12.01" y2="18"/>
                        </svg>
                        <span>Get Mobile App</span>
                    </a>
                </div>

                <!-- Trust Badges -->
                <div class="mt-12 flex flex-wrap items-center justify-center gap-6 sm:gap-10 text-xs sm:text-sm text-slate-400">
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Cloudflare Edge CDN</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Sub-second load times</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Clean HTML/Tailwind Export</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <svg class="w-4 h-4 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Free SSL On All Domains</span>
                    </div>
                </div>

                <!-- APP SCREENSHOTS 3D MOCKUP STAGE -->
                <div class="mt-16 sm:mt-24 relative max-w-5xl mx-auto">
                    <!-- Ambient Glow Behind Phones -->
                    <div class="absolute inset-0 bg-gradient-to-t from-brand-600/30 via-purple-600/20 to-transparent rounded-[60px] blur-3xl -z-10"></div>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 items-center justify-center">
                        
                        <!-- Left Mockup: Visual Canvas Editor -->
                        <div class="hidden md:block transform -rotate-3 hover:rotate-0 transition-transform duration-500 animate-float-slow">
                            <div class="phone-frame max-w-[280px] mx-auto shadow-2xl relative border-2 border-white/10">
                                <div class="dynamic-island"></div>
                                <img src="/images/app/editor_screen.png" alt="Mobile Visual Editor" class="w-full h-auto block rounded-[36px]" loading="lazy">
                                <div class="absolute bottom-4 inset-x-4 glass-panel rounded-xl p-2.5 text-left border border-white/10">
                                    <div class="text-[11px] font-bold text-white flex items-center gap-1.5">
                                        <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                                        Visual Live Canvas
                                    </div>
                                    <p class="text-[10px] text-slate-300">Direct tap-to-edit with AI prompt bar</p>
                                </div>
                            </div>
                        </div>

                        <!-- Center Mockup (Primary): Mobile App Dashboard -->
                        <div class="transform scale-105 z-20 shadow-2xl">
                            <div class="phone-frame max-w-[320px] mx-auto border-2 border-brand-500/40 relative shadow-brand-500/20 shadow-2xl">
                                <div class="dynamic-island"></div>
                                <img src="/images/app/dashboard_screen.png" alt="LandingCraft AI Mobile Dashboard" class="w-full h-auto block rounded-[36px]" loading="eager">
                                <div class="absolute bottom-4 inset-x-4 glass-panel-glow rounded-xl p-3 text-left">
                                    <div class="text-xs font-bold text-white flex items-center justify-between">
                                        <span class="flex items-center gap-1.5">
                                            <span class="w-2 h-2 rounded-full bg-brand-400 animate-pulse"></span>
                                            Mobile Dashboard
                                        </span>
                                        <span class="text-[10px] text-brand-300 font-semibold uppercase">iOS & Android</span>
                                    </div>
                                    <p class="text-[11px] text-slate-300 mt-0.5">Manage projects, 1-click publish & live URL links</p>
                                </div>
                            </div>
                        </div>

                        <!-- Right Mockup: Settings, Custom Domain & Export -->
                        <div class="hidden md:block transform rotate-3 hover:rotate-0 transition-transform duration-500 animate-float-reverse">
                            <div class="phone-frame max-w-[280px] mx-auto shadow-2xl relative border-2 border-white/10">
                                <div class="dynamic-island"></div>
                                <img src="/images/app/settings_screen.png" alt="Website Settings & Deployment" class="w-full h-auto block rounded-[36px]" loading="lazy">
                                <div class="absolute bottom-4 inset-x-4 glass-panel rounded-xl p-2.5 text-left border border-white/10">
                                    <div class="text-[11px] font-bold text-white flex items-center gap-1.5">
                                        <span class="w-2 h-2 rounded-full bg-purple-400"></span>
                                        Instant Deploy & ZIP
                                    </div>
                                    <p class="text-[10px] text-slate-300">Custom domain mapping & full code export</p>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </section>

        <!-- LIVE SHOWCASE GALLERY -->
        <section id="showcase" class="py-20 md:py-32 border-t border-white/[0.06] relative">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="text-center max-w-3xl mx-auto mb-16">
                    <span class="text-xs font-bold uppercase tracking-wider text-brand-400 px-3 py-1 rounded-full bg-brand-500/10 border border-brand-500/20">
                        Live Cloud Deployments
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        Websites Created With Our App
                    </h2>
                    <p class="mt-4 text-base sm:text-lg text-slate-400">
                        Every site below was crafted directly in our mobile application and is currently served live from Neon S3 & Cloudflare edge infrastructure.
                    </p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
                    
                    <!-- Live Showcase 1: Lumen Coffee -->
                    <div class="glass-panel rounded-3xl overflow-hidden border border-white/10 hover:border-brand-500/40 transition-all duration-300 group flex flex-col">
                        <div class="relative overflow-hidden aspect-[16/10] bg-slate-900 border-b border-white/[0.06]">
                            <img src="/images/app/lumen_site.png" alt="Lumen Specialty Coffee Live Site" class="w-full h-full object-cover object-top group-hover:scale-105 transition-transform duration-700" loading="lazy">
                            <div class="absolute inset-0 bg-gradient-to-t from-dark-base via-transparent to-transparent opacity-60"></div>
                            <span class="absolute top-4 left-4 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 backdrop-blur-md">
                                ● Live & Published
                            </span>
                        </div>
                        <div class="p-6 sm:p-8 flex-1 flex flex-col justify-between">
                            <div>
                                <div class="flex items-center justify-between text-xs text-slate-400 mb-2 font-mono">
                                    <span>Food & Beverage · Subscription Roastery</span>
                                    <span>subdomain: lumen-specialty</span>
                                </div>
                                <h3 class="text-2xl font-bold text-white group-hover:text-brand-300 transition-colors">
                                    Lumen Specialty Coffee
                                </h3>
                                <p class="text-sm text-slate-300 mt-2 leading-relaxed">
                                    Warm minimalist artisanal landing page featuring hero ordering, product grid, coffee brewing highlights, and newsletter subscriptions.
                                </p>
                            </div>
                            <div class="mt-6 pt-6 border-t border-white/[0.06] flex items-center justify-between">
                                <a href="/sites/lumen-specialty" target="_blank" class="inline-flex items-center gap-2 text-sm font-bold text-brand-400 hover:text-brand-300 transition-colors">
                                    <span>Visit Live Landing Page</span>
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
                        <div class="relative overflow-hidden aspect-[16/10] bg-slate-900 border-b border-white/[0.06]">
                            <img src="/images/app/bakery_site.png" alt="Artisan Bakery Live Site" class="w-full h-full object-cover object-top group-hover:scale-105 transition-transform duration-700" loading="lazy">
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
                                    Editorial aesthetic with custom bakery menus, daily fresh bakes schedule, order inquiries, and location maps.
                                </p>
                            </div>
                            <div class="mt-6 pt-6 border-t border-white/[0.06] flex items-center justify-between">
                                <a href="/sites/artisan-bakery" target="_blank" class="inline-flex items-center gap-2 text-sm font-bold text-brand-400 hover:text-brand-300 transition-colors">
                                    <span>Visit Live Landing Page</span>
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                                </a>
                                <button onclick="openLiveModal('/sites/artisan-bakery', 'Artisan Sourdough Bakery')" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold glass-panel text-slate-300 hover:text-white hover:bg-white/10 transition-all">
                                    Interactive Preview
                                </button>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- Showcase Bottom Bar -->
                <div class="mt-12 glass-panel rounded-2xl p-6 sm:p-8 flex flex-col sm:flex-row items-center justify-between gap-6 border border-white/10">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 rounded-xl bg-brand-500/10 border border-brand-500/20 flex items-center justify-center shrink-0">
                            <svg class="w-6 h-6 text-brand-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"/>
                                <line x1="2" y1="12" x2="22" y2="12"/>
                                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
                            </svg>
                        </div>
                        <div>
                            <h4 class="text-base font-bold text-white">Also Check Out Live Showcase Sites</h4>
                            <p class="text-xs sm:text-sm text-slate-400">Discover Studio Marlow Architecture & Kite Yoga Austin, live at custom paths.</p>
                        </div>
                    </div>
                    <div class="flex items-center gap-3 w-full sm:w-auto">
                        <a href="/sites/studiomarlow" target="_blank" class="flex-1 sm:flex-initial px-4 py-2 text-xs font-semibold rounded-lg bg-white/5 hover:bg-white/10 text-white transition-all text-center">
                            Studio Marlow →
                        </a>
                        <a href="/sites/untitled-site-qbdb" target="_blank" class="flex-1 sm:flex-initial px-4 py-2 text-xs font-semibold rounded-lg bg-white/5 hover:bg-white/10 text-white transition-all text-center">
                            Live User Test →
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <!-- APP FEATURES DEEP DIVE -->
        <section id="features" class="py-20 md:py-32 border-t border-white/[0.06] relative">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="text-center max-w-3xl mx-auto mb-20">
                    <span class="text-xs font-bold uppercase tracking-wider text-purple-400 px-3 py-1 rounded-full bg-purple-500/10 border border-purple-500/20">
                        Engineered for Mobile
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        Everything You Need In Your Pocket
                    </h2>
                    <p class="mt-4 text-base sm:text-lg text-slate-400">
                        Forget dragging heavy laptops. You have the power of modern landing page architecture in a fluid, gesture-driven native mobile UI.
                    </p>
                </div>

                <!-- Feature 1: Visual Mobile Canvas -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center mb-24">
                    <div class="order-2 lg:order-1">
                        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-lg bg-brand-500/10 text-brand-400 text-xs font-bold uppercase tracking-wider mb-4">
                            Direct Manipulation
                        </div>
                        <h3 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
                            Touch-Optimized Visual Editor
                        </h3>
                        <p class="text-slate-300 mt-4 text-base sm:text-lg leading-relaxed">
                            Tap any headline, section, or image directly on your phone canvas to edit inline. Switch smoothly between Mobile, Tablet, and Desktop viewport simulations with zero latency.
                        </p>
                        <ul class="mt-8 space-y-3.5 text-sm text-slate-300">
                            <li class="flex items-center gap-3">
                                <div class="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">✓</div>
                                <span>Realtime bidirectional bridge between Flutter UI and web canvas</span>
                            </li>
                            <li class="flex items-center gap-3">
                                <div class="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">✓</div>
                                <span>Draggable section hierarchy with 1-tap reordering</span>
                            </li>
                            <li class="flex items-center gap-3">
                                <div class="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">✓</div>
                                <span>Curated font pairings and harmonic color palette generator</span>
                            </li>
                        </ul>
                    </div>
                    <div class="order-1 lg:order-2 flex justify-center">
                        <div class="phone-frame max-w-[320px] shadow-2xl border-2 border-brand-500/30">
                            <div class="dynamic-island"></div>
                            <img src="/images/app/editor_screen.png" alt="Touch Visual Editor" class="w-full h-auto block rounded-[36px]" loading="lazy">
                        </div>
                    </div>
                </div>

                <!-- Feature 2: Dashboard & 1-Click Publishing -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center mb-24">
                    <div class="flex justify-center">
                        <div class="phone-frame max-w-[320px] shadow-2xl border-2 border-purple-500/30">
                            <div class="dynamic-island"></div>
                            <img src="/images/app/dashboard_screen.png" alt="Dashboard & Live Links" class="w-full h-auto block rounded-[36px]" loading="lazy">
                        </div>
                    </div>
                    <div>
                        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-lg bg-purple-500/10 text-purple-400 text-xs font-bold uppercase tracking-wider mb-4">
                            Instant Global Reach
                        </div>
                        <h3 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
                            Edge Publishing in a Single Tap
                        </h3>
                        <p class="text-slate-300 mt-4 text-base sm:text-lg leading-relaxed">
                            Hit "Publish" and your site is compiled into lean, standalone HTML/CSS and pushed across Cloudflare's global edge network in milliseconds.
                        </p>
                        <ul class="mt-8 space-y-3.5 text-sm text-slate-300">
                            <li class="flex items-center gap-3">
                                <div class="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">✓</div>
                                <span>Free platform subdomains (<code class="text-xs text-brand-300">ai-landing-page.xyz/sites/...</code>)</span>
                            </li>
                            <li class="flex items-center gap-3">
                                <div class="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">✓</div>
                                <span>Attach custom domain with automated SSL provisioning</span>
                            </li>
                            <li class="flex items-center gap-3">
                                <div class="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">✓</div>
                                <span>Live URL banner with 1-click clipboard copy & QR sharing</span>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- Feature 3: Full Project Independence & ZIP Export -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
                    <div>
                        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-lg bg-pink-500/10 text-pink-400 text-xs font-bold uppercase tracking-wider mb-4">
                            No Lock-in
                        </div>
                        <h3 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
                            Export Clean ZIP Code Anytime
                        </h3>
                        <p class="text-slate-300 mt-4 text-base sm:text-lg leading-relaxed">
                            You own your content and code. Export your entire landing page as a production-ready ZIP containing static HTML, CSS, JavaScript, and assets that can be hosted on GitHub Pages, Vercel, Netlify, or Apache.
                        </p>
                        <div class="mt-8 p-4 rounded-xl glass-panel border border-white/10 flex items-center gap-4">
                            <div class="w-10 h-10 rounded-lg bg-amber-500/20 text-amber-300 flex items-center justify-center shrink-0">
                                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
                            </div>
                            <div class="text-xs">
                                <span class="font-bold text-white block">Custom ZIP Ingestion Supported</span>
                                <span class="text-slate-400">Import your existing static website archives straight into the mobile editor.</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex justify-center">
                        <div class="phone-frame max-w-[320px] shadow-2xl border-2 border-pink-500/30">
                            <div class="dynamic-island"></div>
                            <img src="/images/app/settings_screen.png" alt="ZIP Export & Custom Imports" class="w-full h-auto block rounded-[36px]" loading="lazy">
                        </div>
                    </div>
                </div>

            </div>
        </section>

        <!-- HOW IT WORKS WORKFLOW -->
        <section id="workflow" class="py-20 md:py-32 border-t border-white/[0.06] bg-slate-950/40">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="text-center max-w-3xl mx-auto mb-16">
                    <span class="text-xs font-bold uppercase tracking-wider text-brand-400 px-3 py-1 rounded-full bg-brand-500/10 border border-brand-500/20">
                        Workflow
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        From Idea to Live in 3 Steps
                    </h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                    <div class="glass-panel p-8 rounded-3xl border border-white/10 relative">
                        <div class="w-12 h-12 rounded-2xl bg-brand-500/10 text-brand-400 flex items-center justify-center font-bold text-lg mb-6 border border-brand-500/20">
                            01
                        </div>
                        <h4 class="text-xl font-bold text-white mb-2">Pick or Prompt</h4>
                        <p class="text-sm text-slate-300 leading-relaxed">
                            Select from curated high-conversion templates or tell AI your business niche. Our engine crafts tailored copy, themes, and layout instantly.
                        </p>
                    </div>

                    <div class="glass-panel p-8 rounded-3xl border border-white/10 relative">
                        <div class="w-12 h-12 rounded-2xl bg-purple-500/10 text-purple-400 flex items-center justify-center font-bold text-lg mb-6 border border-purple-500/20">
                            02
                        </div>
                        <h4 class="text-xl font-bold text-white mb-2">Refine in Touch Canvas</h4>
                        <p class="text-sm text-slate-300 leading-relaxed">
                            Customize text, upload photos from your phone camera or gallery, adjust colors, and preview responsive views with zero coding.
                        </p>
                    </div>

                    <div class="glass-panel p-8 rounded-3xl border border-white/10 relative">
                        <div class="w-12 h-12 rounded-2xl bg-pink-500/10 text-pink-400 flex items-center justify-center font-bold text-lg mb-6 border border-pink-500/20">
                            03
                        </div>
                        <h4 class="text-xl font-bold text-white mb-2">Publish & Share</h4>
                        <p class="text-sm text-slate-300 leading-relaxed">
                            Publish to Cloudflare edge storage with 1 tap. Share your live link or map your branded custom domain with automated SSL.
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <!-- MOBILE APP DOWNLOAD SECTION -->
        <section id="mobile-app" class="py-20 md:py-32 border-t border-white/[0.06] relative overflow-hidden">
            <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="glass-panel-glow rounded-[40px] p-8 sm:p-14 text-center relative overflow-hidden">
                    <div class="absolute -right-20 -bottom-20 w-80 h-80 bg-brand-500/20 rounded-full blur-3xl pointer-events-none"></div>
                    <div class="absolute -left-20 -top-20 w-80 h-80 bg-purple-500/20 rounded-full blur-3xl pointer-events-none"></div>

                    <span class="text-xs font-bold uppercase tracking-wider text-brand-300 px-3 py-1 rounded-full bg-brand-500/10 border border-brand-500/25">
                        Get Started Today
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold text-white mt-4 tracking-tight">
                        Experience Mobile Web Creation
                    </h2>
                    <p class="text-slate-300 mt-4 max-w-xl mx-auto text-base sm:text-lg">
                        Available for iOS and Android. Start building high-conversion landing pages directly from your device now.
                    </p>

                    <div class="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4">
                        <a href="#showcase" class="w-full sm:w-auto px-8 py-4 rounded-xl bg-white text-slate-950 font-bold text-base hover:bg-slate-100 transition-all flex items-center justify-center gap-3 shadow-xl">
                            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.84c.66-.8 1.11-1.92.99-3.04-1 .04-2.13.66-2.8 1.45-.59.68-1.11 1.77-.97 2.87 1.11.08 2.12-.48 2.78-1.28z"/>
                            </svg>
                            <span>Download for iOS</span>
                        </a>
                        <a href="#showcase" class="w-full sm:w-auto px-8 py-4 rounded-xl bg-white/10 hover:bg-white/15 text-white font-bold text-base transition-all flex items-center justify-center gap-3 border border-white/10">
                            <svg class="w-5 h-5 text-emerald-400" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M17.523 15.3414c-.5511 0-.9993-.4486-.9993-.9997s.4482-.9993.9993-.9993c.551 0 .9993.4482.9993.9993.0001.5511-.4483.9997-.9993.9997m-11.046 0c-.5511 0-.9993-.4486-.9993-.9997s.4482-.9993.9993-.9993c.5511 0 .9993.4482.9993.9993 0 .5511-.4482.9997-.9993.9997m11.4045-6.02l1.9973-3.4592a.416.416 0 0 0-.1521-.5676.416.416 0 0 0-.5676.1521l-2.0223 3.503C15.5902 8.4116 13.8533 8.125 12 8.125c-1.8534 0-3.5902.2866-5.1368.8247L4.8409 5.4467a.4161.4161 0 0 0-.5677-.1521.4157.4157 0 0 0-.1521.5676l1.9973 3.4592C2.6889 11.1867.3432 14.6589 0 18.761h24c-.3432-4.1021-2.6889-7.5743-6.1185-9.4396"/>
                            </svg>
                            <span>Download for Android</span>
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <!-- PRICING TIERS -->
        <section id="pricing" class="py-20 md:py-32 border-t border-white/[0.06]">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="text-center max-w-3xl mx-auto mb-16">
                    <span class="text-xs font-bold uppercase tracking-wider text-emerald-400 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20">
                        Transparent Pricing
                    </span>
                    <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight mt-4 text-white">
                        Simple, Predictable Plans
                    </h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
                    <!-- Free Starter -->
                    <div class="glass-panel p-8 sm:p-10 rounded-3xl border border-white/10 flex flex-col justify-between">
                        <div>
                            <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Starter</span>
                            <div class="mt-4 flex items-baseline gap-2">
                                <span class="text-4xl sm:text-5xl font-extrabold text-white">$0</span>
                                <span class="text-sm text-slate-400">/ forever</span>
                            </div>
                            <p class="text-sm text-slate-300 mt-3">Ideal for testing ideas and launching your first portfolio.</p>
                            
                            <ul class="mt-8 space-y-3.5 text-sm text-slate-300">
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400">✓</span>
                                    <span>Unlimited visual editing & drafts</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400">✓</span>
                                    <span>Free platform subdomain hosting</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400">✓</span>
                                    <span>Global edge CDN delivery</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-emerald-400">✓</span>
                                    <span>Access to all core starter templates</span>
                                </li>
                            </ul>
                        </div>
                        <div class="mt-10">
                            <a href="#showcase" class="w-full py-3.5 rounded-xl glass-panel text-white font-semibold text-sm hover:bg-white/10 transition-all flex items-center justify-center">
                                Start Free
                            </a>
                        </div>
                    </div>

                    <!-- Pro Creator -->
                    <div class="glass-panel-glow p-8 sm:p-10 rounded-3xl border border-brand-500/30 flex flex-col justify-between relative">
                        <div class="absolute -top-3 right-8 px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-gradient-to-r from-brand-500 to-purple-600 text-white shadow-md">
                            Most Popular
                        </div>
                        <div>
                            <span class="text-xs font-bold uppercase tracking-wider text-brand-300">Pro Creator</span>
                            <div class="mt-4 flex items-baseline gap-2">
                                <span class="text-4xl sm:text-5xl font-extrabold text-white">$9.99</span>
                                <span class="text-sm text-slate-400">/ month</span>
                            </div>
                            <p class="text-sm text-slate-300 mt-3">For freelancers, agencies, and high-conversion projects.</p>
                            
                            <ul class="mt-8 space-y-3.5 text-sm text-slate-300">
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400">✓</span>
                                    <span class="font-medium text-white">Unlimited custom domain attachments</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400">✓</span>
                                    <span class="font-medium text-white">Production ZIP source code exports</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400">✓</span>
                                    <span>AI Remix Tokens & Copy generation</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400">✓</span>
                                    <span>Priority edge CDN routing</span>
                                </li>
                                <li class="flex items-center gap-3">
                                    <span class="text-brand-400">✓</span>
                                    <span>Ad-free editing experience</span>
                                </li>
                            </ul>
                        </div>
                        <div class="mt-10">
                            <a href="#showcase" class="w-full py-3.5 rounded-xl bg-gradient-to-r from-brand-500 to-purple-600 text-white font-bold text-sm shadow-lg shadow-brand-500/25 hover:brightness-110 active:scale-95 transition-all flex items-center justify-center">
                                Unlock Pro
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <footer class="border-t border-white/[0.06] bg-dark-base py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row items-center justify-between gap-6 text-sm text-slate-500">
            <div class="flex items-center space-x-3">
                <span class="text-white font-bold">LandingCraft AI</span>
                <span>·</span>
                <span>© 2026 AI Landing Page Builder. All rights reserved.</span>
            </div>
            <div class="flex items-center space-x-6 text-xs text-slate-400">
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
    </script>
</body>
</html>
