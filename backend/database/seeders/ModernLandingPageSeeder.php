<?php

namespace Database\Seeders;

use App\Enums\TemplateStatus;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class ModernLandingPageSeeder extends Seeder
{
    public function run(): void
    {
        $saasCat = TemplateCategory::where('slug', 'saas')->first();
        $agencyCat = TemplateCategory::where('slug', 'agencies')->first() ?? TemplateCategory::where('slug', 'portfolios')->first();
        $beautyCat = TemplateCategory::where('slug', 'beauty')->first() ?? TemplateCategory::where('slug', 'ecommerce')->first();
        $restaurantCat = TemplateCategory::where('slug', 'restaurants')->first() ?? TemplateCategory::where('slug', 'local-business')->first();

        // 1. Nexus AI - Modern Dark Bento SaaS
        $nexusDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Nexus AI',
                'theme' => [
                    'colors' => [
                        'primary' => '#6366F1',
                        'secondary' => '#06B6D4',
                        'accent' => '#8B5CF6',
                        'background' => '#090D16',
                        'surface' => '#111827',
                        'text' => [
                            'primary' => '#F8FAFC',
                            'secondary' => '#94A3B8',
                            'inverse' => '#090D16',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Plus Jakarta Sans',
                        'bodyFamily' => 'Inter',
                        'scale' => [
                            'h1' => ['size' => '3.8rem', 'weight' => 800, 'lineHeight' => 1.1],
                            'h2' => ['size' => '2.5rem', 'weight' => 700, 'lineHeight' => 1.2],
                            'h3' => ['size' => '1.4rem', 'weight' => 600, 'lineHeight' => 1.3],
                            'body' => ['size' => '1.05rem', 'weight' => 400, 'lineHeight' => 1.6],
                        ],
                    ],
                    'spacing' => [
                        'containerMaxWidth' => '1200px',
                        'sectionPadding' => ['x' => '1.5rem', 'y' => '5.5rem'],
                    ],
                ],
                'settings' => [
                    'language' => 'en',
                    'googleFonts' => ['Plus Jakarta Sans', 'Inter'],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Nexus AI'],
                'items' => [
                    ['label' => 'Features', 'url' => '#features'],
                    ['label' => 'Metrics', 'url' => '#metrics'],
                    ['label' => 'Testimonials', 'url' => '#testimonials'],
                    ['label' => 'Start Free', 'url' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'description' => 'The autonomous workspace engineered for high-velocity engineering and product teams.',
                    'seo' => [
                        'title' => 'Nexus AI - Next-Gen Autonomous Workflows',
                        'description' => 'Linear-speed issue tracking, AI code synthesis, and edge orchestration.',
                        'ogImage' => 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
                    ],
                    'sections' => [
                        [
                            'id' => 'sec_nexus_hero',
                            'component' => 'hero',
                            'variant' => 'modern_showcase',
                            'order' => 0,
                            'visible' => true,
                            'props' => [
                                'badge' => '✦ INTRODUCING NEXUS 2.0 · AUTONOMOUS AGENTS',
                                'headline' => 'Linear speed.<br>Superhuman intelligence.',
                                'subheadline' => 'The workspace built for modern product teams. Synthesize feature plans, review automated PRs, and ship zero-latency software.',
                                'ctaText' => 'Deploy in 60 Seconds',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Watch Product Keynote ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Nexus AI Dark Mode Interface',
                                ],
                            ],
                        ],
                        [
                            'id' => 'sec_nexus_features',
                            'component' => 'features',
                            'variant' => 'bento_grid',
                            'order' => 1,
                            'visible' => true,
                            'props' => [
                                'title' => 'Engineered for Radical Momentum',
                                'subtitle' => 'Eliminate administrative drag and focus on craftsmanship.',
                                'items' => [
                                    ['title' => 'Sub-10ms Global Latency', 'description' => 'Replicated across 35 edge regions worldwide with instant sync.', 'icon' => 'Zap'],
                                    ['title' => 'Autonomous Code Diff Engine', 'description' => 'Inspects dependencies, writes test suites, and proposes clean visual diffs.', 'icon' => 'Sparkles'],
                                    ['title' => 'Zero-Configuration Deployments', 'description' => 'Push commits to production instantly with built-in preview environments.', 'icon' => 'Layers'],
                                    ['title' => 'SOC-2 Type II Certified', 'description' => 'Enterprise encryption in transit and at rest with isolated tenant memory.', 'icon' => 'ShieldCheck'],
                                ],
                            ],
                        ],
                        [
                            'id' => 'sec_nexus_stats',
                            'component' => 'statistics',
                            'variant' => 'metrics_bar',
                            'order' => 2,
                            'visible' => true,
                            'props' => [
                                'title' => 'Powering the World’s Fastest Engineering Teams',
                                'metrics' => [
                                    ['value' => '99.999%', 'label' => 'Edge Uptime SLA'],
                                    ['value' => '4.2x', 'label' => 'Sprint Velocity Boost'],
                                    ['value' => '85,000+', 'label' => 'Active Developers'],
                                    ['value' => '< 12ms', 'label' => 'API P99 Latency'],
                                ],
                            ],
                        ],
                        [
                            'id' => 'sec_nexus_testimonials',
                            'component' => 'testimonials',
                            'variant' => 'cards',
                            'order' => 3,
                            'visible' => true,
                            'props' => [
                                'title' => 'Loved by Leading Designers & Engineers',
                                'items' => [
                                    [
                                        'quote' => 'Nexus feels like software from 2030. The dark aesthetic, keyboard shortcuts, and instantaneous feedback loop make it irreplaceable.',
                                        'author' => 'Elena Rostova',
                                        'role' => 'VP of Engineering, CloudScale',
                                        'avatar' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                                    ],
                                    [
                                        'quote' => 'We replaced three disconnected project tools with Nexus in an afternoon. Our team ships twice as many features now.',
                                        'author' => 'Marcus Vance',
                                        'role' => 'Co-Founder, Synthetix',
                                        'avatar' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
                                    ],
                                ],
                            ],
                        ],
                        [
                            'id' => 'sec_nexus_cta',
                            'component' => 'cta',
                            'variant' => 'glowing_banner',
                            'order' => 4,
                            'visible' => true,
                            'props' => [
                                'headline' => 'Transform your team into a high-output engine.',
                                'subheadline' => 'Join thousands of developers building next-generation digital products on Nexus.',
                                'ctaText' => 'Get Started with Nexus Free',
                                'ctaLink' => '#top',
                            ],
                        ],
                        [
                            'id' => 'sec_nexus_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'visible' => true,
                            'props' => [
                                'copyright' => '© ' . date('Y') . ' Nexus Systems Inc. All rights reserved.',
                                'links' => [
                                    ['label' => 'Changelog', 'url' => '#changelog'],
                                    ['label' => 'API Docs', 'url' => '#api'],
                                    ['label' => 'Security', 'url' => '#security'],
                                    ['label' => 'Privacy', 'url' => '#privacy'],
                                ],
                            ],
                        ],
                    ],
                ],
            ],
        ];

        $nexusTemplate = Template::updateOrCreate(
            ['slug' => 'nexus-ai-modern'],
            [
                'category_id' => $saasCat?->id,
                'name' => 'Nexus AI',
                'description' => 'Award-winning dark bento-grid SaaS landing page with ambient glow and high-impact typography.',
                'industry' => 'SaaS & Tech',
                'badge' => 'TRENDING 2026',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'DeepMind Studio',
                'use_count' => 142,
                'preview_images' => ['https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $nexusTemplate->id, 'version' => 1],
            [
                'document' => $nexusDoc,
                'design_tokens' => $nexusDoc['site']['theme'],
                'fonts' => ['Plus Jakarta Sans', 'Inter'],
                'is_active' => true,
            ]
        );

        // 2. Aura Botanicals - Clean Luxury Skincare E-Commerce
        $auraDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Aura Botanicals',
                'theme' => [
                    'colors' => [
                        'primary' => '#1E3A2F',
                        'secondary' => '#5F7065',
                        'accent' => '#C98B50',
                        'background' => '#FBF9F5',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#1B2A22',
                            'secondary' => '#5C6B61',
                            'inverse' => '#FFFFFF',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Playfair Display',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'AURA BOTANICALS'],
                'items' => [
                    ['label' => 'Shop', 'url' => '#products'],
                    ['label' => 'Philosophy', 'url' => '#story'],
                    ['label' => 'Order Ritual', 'url' => '#products', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_aura_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => 'BIODYNAMIC HARVEST · 100% CERTIFIED ORGANIC',
                                'headline' => 'Pure botanical science.<br>Unfiltered radiance.',
                                'subheadline' => 'Clinical efficacy rooted in alpine biodynamic harvesting. Clean, certified organic formulations that nourish and restore your natural skin barrier.',
                                'ctaText' => 'Shop the Collection',
                                'ctaLink' => '#products',
                                'secondaryCtaText' => 'Our Sourcing Story',
                                'secondaryCtaLink' => '#story',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Aura Botanicals Glass Bottles',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_aura_products',
                            'component' => 'products',
                            'order' => 1,
                            'props' => [
                                'title' => 'The Essential Botanical Ritual',
                                'subtitle' => 'Formulated without synthetic fragrance, parabens, sulfates, or artificial fillers.',
                                'items' => [
                                    [
                                        'name' => 'Rosehip Celestial Elixir',
                                        'price' => '$68.00',
                                        'description' => 'Cold-pressed Rosa Canina, Bakuchiol 2%, and lipid restoration squalane.',
                                        'image' => 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=600&q=80',
                                    ],
                                    [
                                        'name' => 'Golden Hibiscus Hydrating Serum',
                                        'price' => '$54.00',
                                        'description' => 'Multi-weight hyaluronic acid and alpine edelweiss extract for 48-hour cellular hydration.',
                                        'image' => 'https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?auto=format&fit=crop&w=600&q=80',
                                    ],
                                    [
                                        'name' => 'Ceramide Barrier Melt Balm',
                                        'price' => '$46.00',
                                        'description' => 'Wild-foraged sea buckthorn and oat lipids to soothe and repair stressed, dry skin.',
                                        'image' => 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=80',
                                    ],
                                    [
                                        'name' => 'Midnight Jasmine Recovery Oil',
                                        'price' => '$72.00',
                                        'description' => 'Night cellular rejuvenation oil infused with blue tansy and antioxidant CoQ10.',
                                        'image' => 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_aura_features',
                            'component' => 'features',
                            'order' => 2,
                            'props' => [
                                'title' => 'The Aura Formulation Standard',
                                'subtitle' => 'Honoring nature\'s biological rhythms through ethical sourcing and cellular science.',
                                'items' => [
                                    ['icon' => '🌿', 'title' => 'High-Elevation Wildcrafted', 'description' => 'Plants harvested at peak vitality in clean Swiss alpine meadows above 1,500 meters.'],
                                    ['icon' => '✦', 'title' => 'Cold-Pressed Extraction', 'description' => 'Zero heat processing to protect fragile antioxidant vitamins, omegas, and enzymes.'],
                                    ['icon' => '✦', 'title' => 'Violet Miron Glassware', 'description' => 'Biophotonic glass vessels that block harmful light spectrums to maintain organic potency.'],
                                    ['icon' => '✦', 'title' => 'Dermatologist Tested', 'description' => 'Hypoallergenic, non-comedogenic, and clinically certified for reactive, sensitive skin.'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_aura_story',
                            'component' => 'about',
                            'order' => 3,
                            'props' => [
                                'title' => 'Rooted in Alpine Reverence',
                                'subtitle' => 'Where ancient herbal wisdom meets clean cellular biology.',
                                'body' => 'Founded by holistic biochemist Clara von Berg, Aura was created to replace multi-step synthetic routines with pure, biodynamic plant medicine. We cultivate and harvest flora in rhythm with natural seasons, producing small-batch elixirs that restore balance and radiance to modern skin.',
                                'image' => 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=1200&q=80',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_aura_cta',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Begin your botanical ritual with 15% off.',
                                'subheadline' => 'Join our circle to receive our seasonal harvest monograph, skincare guides, and private releases.',
                                'ctaText' => 'Claim Your 15% Welcome',
                                'ctaLink' => '#products',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_aura_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => '© ' . date('Y') . ' Aura Botanicals AG. Zurich · Geneva · Paris.',
                                'links' => [
                                    ['label' => 'Ingredients Glossary', 'url' => '#ingredients'],
                                    ['label' => 'Sustainability', 'url' => '#sustainability'],
                                    ['label' => 'Stockists', 'url' => '#stockists'],
                                    ['label' => 'Privacy', 'url' => '#privacy'],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $auraTemplate = Template::updateOrCreate(
            ['slug' => 'aura-botanicals-modern'],
            [
                'category_id' => $beautyCat?->id,
                'name' => 'Aura Botanicals',
                'description' => 'Luxury cold-pressed skincare & wellness e-commerce template with warm alabaster palette and serif typography.',
                'industry' => 'Beauty & Skincare',
                'badge' => 'AWARD WINNING',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'DeepMind Studio',
                'use_count' => 118,
                'preview_images' => ['https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $auraTemplate->id, 'version' => 1],
            [
                'document' => $auraDoc,
                'design_tokens' => $auraDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Inter'],
                'is_active' => true,
            ]
        );

        // 4. VaultPay - Modern Global Fintech & Treasury
        $vaultDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'VaultPay',
                'theme' => [
                    'colors' => [
                        'primary' => '#0D9488',
                        'secondary' => '#38BDF8',
                        'accent' => '#10B981',
                        'background' => '#0B1120',
                        'surface' => '#131D31',
                        'text' => [
                            'primary' => '#F8FAFC',
                            'secondary' => '#94A3B8',
                            'inverse' => '#0B1120',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Plus Jakarta Sans',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'VaultPay'],
                'items' => [
                    ['label' => 'Infrastructure', 'url' => '#features'],
                    ['label' => 'Pricing', 'url' => '#pricing'],
                    ['label' => 'Open Account', 'url' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_vault_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => 'LICENSED FINANCIAL INSTITUTION · PCI-DSS LEVEL 1',
                                'headline' => 'Global treasury.<br>Zero borders.',
                                'subheadline' => 'Move capital across 140+ currencies with institutional FX rates, programmatic corporate cards, and instantaneous treasury routing.',
                                'ctaText' => 'Open Account in 5 Mins',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Explore API Docs ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'VaultPay Global Card and Interface',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_vault_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Institutional Rails at Modern Speed',
                                'subtitle' => 'Everything high-growth internet companies need to manage global cash flows.',
                                'items' => [
                                    ['icon' => '🌐', 'title' => 'Multi-Currency Virtual IBANs', 'description' => 'Accept EUR, USD, GBP, JPY, and SGD locally without predatory foreign exchange fees.'],
                                    ['icon' => '⚡', 'title' => 'Sub-Second Global Settlement', 'description' => 'Instant payment routing across SEPA Instant, FedNow, and SWIFT gpi networks.'],
                                    ['icon' => '💳', 'title' => 'Programmatic Corporate Cards', 'description' => 'Issue unlimited virtual and physical cards with customizable spend rules and receipt matching.'],
                                    ['icon' => '🛡️', 'title' => 'Automated Tax & ERP Sync', 'description' => 'Direct two-way synchronization with NetSuite, QuickBooks, Xero, and Sage.'],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_vault_pricing',
                            'component' => 'products',
                            'order' => 2,
                            'props' => [
                                'title' => 'Transparent Global Pricing',
                                'subtitle' => 'No monthly maintenance fees, hidden markups, or minimum deposit requirements.',
                                'items' => [
                                    [
                                        'name' => 'Starter Business',
                                        'price' => '$0 / mo',
                                        'description' => 'Multi-currency IBANs, 5 virtual debit cards, 0.35% interbank FX spread.',
                                        'image' => 'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=600&q=80',
                                    ],
                                    [
                                        'name' => 'Scale Treasury',
                                        'price' => '$99 / mo',
                                        'description' => 'FedNow & SEPA Instant priority rails, unlimited virtual cards, 0.18% FX spread.',
                                        'image' => 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
                                    ],
                                    [
                                        'name' => 'Enterprise Banking',
                                        'price' => 'Custom',
                                        'description' => 'Dedicated treasury desk, custom ERP integrations, volume FX pricing under 0.08%.',
                                        'image' => 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=600&q=80',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_vault_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Modernize your global treasury today.',
                                'subheadline' => 'Open verified business accounts in under five minutes with zero paperwork.',
                                'ctaText' => 'Open Free Account',
                                'ctaLink' => '#register',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_vault_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© ' . date('Y') . ' VaultPay Financial Technologies Inc.',
                                'links' => [
                                    ['label' => 'Security', 'url' => '#security'],
                                    ['label' => 'API Docs', 'url' => '#api'],
                                    ['label' => 'Compliance', 'url' => '#compliance'],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $vaultTemplate = Template::updateOrCreate(
            ['slug' => 'vaultpay-modern'],
            [
                'category_id' => $saasCat?->id,
                'name' => 'VaultPay',
                'description' => 'High-trust fintech & enterprise banking landing page with dark navy theme and glowing emerald accents.',
                'industry' => 'Fintech & Banking',
                'badge' => 'ENTERPRISE GRADE',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'DeepMind Studio',
                'use_count' => 104,
                'preview_images' => ['https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $vaultTemplate->id, 'version' => 1],
            [
                'document' => $vaultDoc,
                'design_tokens' => $vaultDoc['site']['theme'],
                'fonts' => ['Plus Jakarta Sans', 'Inter'],
                'is_active' => true,
            ]
        );

        // 5. Mono Studio - Avant-Garde Creative Design Agency
        $monoDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Mono Studio',
                'theme' => [
                    'colors' => [
                        'primary' => '#000000',
                        'secondary' => '#52525B',
                        'accent' => '#DC2626',
                        'background' => '#FAFAFA',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#09090B',
                            'secondary' => '#71717A',
                            'inverse' => '#FFFFFF',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Space Grotesk',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'MONO STUDIO'],
                'items' => [
                    ['label' => 'Works', 'url' => '#works'],
                    ['label' => 'Capabilities', 'url' => '#capabilities'],
                    ['label' => 'Start a Project', 'url' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_mono_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => 'AWWWARDS STUDIO OF THE YEAR 2025 · NEW YORK & TOKYO',
                                'headline' => 'We craft products<br>that define categories.',
                                'subheadline' => 'Partnering with ambitious founders and visionary brands to build transcendent digital products, design systems, and brand worlds.',
                                'ctaText' => 'View Case Studies',
                                'ctaLink' => '#works',
                                'secondaryCtaText' => 'Studio Capabilities',
                                'secondaryCtaLink' => '#capabilities',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Mono Studio Visual Engineering',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_mono_capabilities',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Core Disciplines of Practice',
                                'subtitle' => 'Bridging holistic brand strategy with cutting-edge software execution.',
                                'items' => [
                                    ['icon' => '✦', 'title' => 'Brand Architecture & Systems', 'description' => 'Typographic identity design, visual design languages, motion guidelines, and strategic brand positioning.'],
                                    ['icon' => '✦', 'title' => 'Interactive 3D & Digital Platforms', 'description' => 'High-performance WebGL experiences, interactive storytelling websites, and next-gen mobile apps.'],
                                    ['icon' => '✦', 'title' => 'Design Systems at Scale', 'description' => 'Modular tokenized component libraries built for engineering scale across Figma, React, and Flutter.'],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_mono_works',
                            'component' => 'products',
                            'order' => 2,
                            'props' => [
                                'title' => 'Selected Works (2024–2026)',
                                'subtitle' => 'Recent commissions for category-defining pioneers.',
                                'items' => [
                                    [
                                        'name' => 'Chronos Health · Continuous Metabolic OS',
                                        'price' => 'Mobile & Brand Design',
                                        'description' => 'End-to-end identity, hardware packaging, and reactive mobile application for wearable health sensors.',
                                        'image' => 'https://images.unsplash.com/photo-1510519138171-cbe656418844?auto=format&fit=crop&w=600&q=80',
                                    ],
                                    [
                                        'name' => 'Hyperion GT · Electric Hypercar Experience',
                                        'price' => 'Interactive WebGL',
                                        'description' => 'Real-time 3D automotive vehicle configurator and telemetry dashboard with raytraced lighting.',
                                        'image' => 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=80',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_mono_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Have an ambitious project worth building?',
                                'subheadline' => 'Now accepting commissions and strategic partnerships for upcoming quarters.',
                                'ctaText' => 'Start a Conversation',
                                'ctaLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_mono_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© ' . date('Y') . ' Mono Design Studio LLC. New York · Tokyo · London.',
                                'links' => [
                                    ['label' => 'Careers', 'url' => '#careers'],
                                    ['label' => 'Twitter/X', 'url' => '#x'],
                                    ['label' => 'Instagram', 'url' => '#ig'],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $monoTemplate = Template::updateOrCreate(
            ['slug' => 'mono-studio-modern'],
            [
                'category_id' => $agencyCat?->id,
                'name' => 'Mono Studio',
                'description' => 'Bold avant-garde design studio & engineering portfolio with high-contrast typography and interactive showcase.',
                'industry' => 'Agency & Creative',
                'badge' => 'AVANT-GARDE',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'DeepMind Studio',
                'use_count' => 89,
                'preview_images' => ['https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $monoTemplate->id, 'version' => 1],
            [
                'document' => $monoDoc,
                'design_tokens' => $monoDoc['site']['theme'],
                'fonts' => ['Space Grotesk', 'Inter'],
                'is_active' => true,
            ]
        );

        // 6. Solstice Fine Dining - Modern Wood-Fired Tasting Counter
        $solsticeDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Solstice Fine Dining',
                'theme' => [
                    'colors' => [
                        'primary' => '#D97706',
                        'secondary' => '#A16207',
                        'accent' => '#F59E0B',
                        'background' => '#171412',
                        'surface' => '#211D1A',
                        'text' => [
                            'primary' => '#FDF8F0',
                            'secondary' => '#A89F91',
                            'inverse' => '#171412',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Playfair Display',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'SOLSTICE'],
                'items' => [
                    ['label' => 'Menu', 'url' => '#menu'],
                    ['label' => 'Philosophy', 'url' => '#about'],
                    ['label' => 'Reservations', 'url' => '#visit', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_solstice_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => 'TWO MICHELIN STARS · JAMES BEARD NOMINEE',
                                'headline' => 'Wood-fired craft.<br>Seasonal reverence.',
                                'subheadline' => 'An intimate sixteen-seat dining counter serving nightly multi-course tasting menus guided by today\'s wild foraging and coastal catch.',
                                'ctaText' => 'Reserve via Resy',
                                'ctaLink' => '#visit',
                                'secondaryCtaText' => 'Tonight\'s Tasting Menu',
                                'secondaryCtaLink' => '#menu',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Solstice Wood-Fired Hearth Dish',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_solstice_menu',
                            'component' => 'products',
                            'order' => 1,
                            'props' => [
                                'title' => 'Spring Tasting Menu Highlights',
                                'subtitle' => 'Twelve courses prepared over applewood and alder embers in our open kitchen.',
                                'items' => [
                                    [
                                        'name' => 'Ember-Roasted Copper River Salmon',
                                        'price' => '$48',
                                        'description' => 'Wild coastal salmon roasted on Japanese binchotan, elderflower glaze, and foraged spruce tips.',
                                        'image' => 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=600&q=80',
                                    ],
                                    [
                                        'name' => 'Heritage Wheat Agnolotti',
                                        'price' => '$42',
                                        'description' => 'Hand-rolled pasta filled with roasted parsnip, cultured butter emulsion, and shaved black winter truffle.',
                                        'image' => 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=600&q=80',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_solstice_visit',
                            'component' => 'visit',
                            'order' => 2,
                            'props' => [
                                'title' => 'Dining Counter & Reservations',
                                'subtitle' => 'Bookings release on the 1st of every month at 9:00 AM PST for the following month.',
                                'address' => '512 Pike Street, Downtown Seattle, WA 98101',
                                'hours' => 'Wednesday – Sunday: Two Seatings at 5:30 PM & 8:30 PM\nClosed Monday & Tuesday',
                                'phone' => '(206) 555-0144',
                                'ctaText' => 'Reserve via Resy',
                                'ctaLink' => 'https://resy.com',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_solstice_footer',
                            'component' => 'footer',
                            'order' => 3,
                            'props' => [
                                'copyright' => '© ' . date('Y') . ' Solstice Culinary Group LLC. Seattle, Washington.',
                                'links' => [
                                    ['label' => 'Tasting Menu PDF', 'url' => '#menu'],
                                    ['label' => 'Wine Cellar', 'url' => '#wine'],
                                    ['label' => 'Press', 'url' => '#press'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                    ],
                ],
            ],
        ];

        $solsticeTemplate = Template::updateOrCreate(
            ['slug' => 'solstice-culinary-modern'],
            [
                'category_id' => $restaurantCat?->id,
                'name' => 'Solstice Fine Dining',
                'description' => 'Two Michelin star tasting counter & wood-fired culinary experience landing page with dark hearth aesthetic.',
                'industry' => 'Restaurant & Hospitality',
                'badge' => 'MICHELIN GUIDE 2026',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'DeepMind Studio',
                'use_count' => 76,
                'preview_images' => ['https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $solsticeTemplate->id, 'version' => 1],
            [
                'document' => $solsticeDoc,
                'design_tokens' => $solsticeDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Inter'],
                'is_active' => true,
            ]
        );
    }
}

