<?php

namespace Database\Seeders;

use App\Enums\TemplateStatus;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use Illuminate\Database\Seeder;

class CuratedTemplatesSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Ensure categories exist
        $weddingsCat = TemplateCategory::firstOrCreate(
            ['slug' => 'weddings'],
            ['name' => 'Weddings', 'icon' => 'heart', 'sort_order' => 14]
        );
        $startupsCat = TemplateCategory::firstOrCreate(
            ['slug' => 'startups'],
            ['name' => 'Startups', 'icon' => 'zap', 'sort_order' => 15]
        );
        $personalCat = TemplateCategory::firstOrCreate(
            ['slug' => 'personal'],
            ['name' => 'Personal', 'icon' => 'user', 'sort_order' => 16]
        );
        $businessCat = TemplateCategory::firstOrCreate(
            ['slug' => 'business'],
            ['name' => 'Business', 'icon' => 'briefcase', 'sort_order' => 17]
        );
        $creativeCat = TemplateCategory::firstOrCreate(
            ['slug' => 'creative'],
            ['name' => 'Creative', 'icon' => 'palette', 'sort_order' => 18]
        );

        // Update existing templates with proper categories
        Template::where('slug', 'ana-teo')->update(['category_id' => $weddingsCat->id]);
        Template::where('slug', 'kite-yoga')->update(['category_id' => $personalCat->id]);
        Template::where('slug', 'lumen-coffee')->update(['category_id' => $businessCat->id]);

        // 2. DevFlow Cloud (Startups)
        $devflowDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'DevFlow Cloud',
                'theme' => [
                    'colors' => [
                        'primary' => '#10B981',
                        'secondary' => '#34D399',
                        'accent' => '#6EE7B7',
                        'background' => '#0A0F1D',
                        'surface' => '#131B2E',
                        'text' => [
                            'primary' => '#F8FAFC',
                            'secondary' => '#94A3B8',
                            'inverse' => '#0A0F1D',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Plus Jakarta Sans',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'DevFlow Cloud'],
                'items' => [
                    ['label' => 'Features', 'href' => '#features'],
                    ['label' => 'Metrics', 'href' => '#metrics'],
                    ['label' => 'Pricing', 'href' => '#pricing'],
                    ['label' => 'Start Free', 'href' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_devflow_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ YC S25 LAUNCH · 200MS COLD STARTS',
                                'headline' => "Instant Preview Branches\nfor Every Git Commit.",
                                'subheadline' => 'Zero Kubernetes config. Zero staging bottlenecks. Deploy production-identical branch environments with isolated database copies in seconds.',
                                'ctaText' => 'Deploy Free with GitHub',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'View Live Interactive Demo ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'DevFlow Cloud Terminal & Preview Interface',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_devflow_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Engineered for High-Velocity Engineering',
                                'subtitle' => 'Eliminate staging bottlenecks and merge conflicts permanently.',
                                'items' => [
                                    [
                                        'icon' => '⚡',
                                        'title' => 'Branched Postgres Databases',
                                        'description' => 'Copy-on-write database clones with real anonymized schemas and instant rollbacks.',
                                    ],
                                    [
                                        'icon' => '🌐',
                                        'title' => 'Global Anycast Edge CDN',
                                        'description' => 'Sub-15ms TTFB routing across 180 global regions with automatic SSL provisioning.',
                                    ],
                                    [
                                        'icon' => '🔒',
                                        'title' => 'SOC-2 Type II Certified',
                                        'description' => 'Enterprise-grade security, automated secrets injection, and fine-grained RBAC.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_devflow_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Battle-Tested at Scale',
                                'subtitle' => 'Trusted by the world\'s fastest-growing developer teams.',
                                'items' => [
                                    ['value' => '200ms', 'label' => 'Average Cold Start'],
                                    ['value' => '4.2M+', 'label' => 'Preview Branches Deployed'],
                                    ['value' => '99.999%', 'label' => 'Production SLA Uptime'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_devflow_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Ship Software 4x Faster Today',
                                'description' => 'Connect your GitHub repository and have your first preview branch live in under 60 seconds.',
                                'buttonText' => 'Get Started Free',
                                'buttonLink' => '#start',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_devflow_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© 2026 DevFlow Cloud, Inc. Built for developers.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $devflowTmpl = Template::updateOrCreate(
            ['slug' => 'devflow'],
            [
                'category_id' => $startupsCat->id,
                'name' => 'DevFlow Cloud',
                'description' => 'Instant preview branches, zero-config staging environments, and edge CI/CD for high-velocity engineering teams.',
                'industry' => 'Startups & Developer Tools',
                'badge' => 'NEXT-GEN DEVOPS',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 118,
                'preview_images' => ['https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $devflowTmpl->id, 'version' => 1],
            [
                'document' => $devflowDoc,
                'design_tokens' => $devflowDoc['site']['theme'],
                'fonts' => ['Plus Jakarta Sans', 'Inter'],
                'is_active' => true,
            ]
        );

        // 3. Pulse Health AI (Startups)
        $pulseDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Pulse Health AI',
                'theme' => [
                    'colors' => [
                        'primary' => '#0EA5E9',
                        'secondary' => '#14B8A6',
                        'accent' => '#38BDF8',
                        'background' => '#080C14',
                        'surface' => '#0F172A',
                        'text' => [
                            'primary' => '#F8FAFC',
                            'secondary' => '#94A3B8',
                            'inverse' => '#080C14',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Plus Jakarta Sans',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Pulse Health AI'],
                'items' => [
                    ['label' => 'Science', 'href' => '#science'],
                    ['label' => 'Features', 'href' => '#features'],
                    ['label' => 'Kit', 'href' => '#pricing'],
                    ['label' => 'Order Now', 'href' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_pulse_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ CLINICAL METABOLIC INTELLIGENCE',
                                'headline' => "Metabolic Intelligence\nfor Peak Daily Focus.",
                                'subheadline' => 'Continuous interstitial glucose and autonomic biomarker sensing paired with personalized algorithmic insights to prevent energy slumps and maximize daily output.',
                                'ctaText' => 'Order Sensor Kit',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Read Clinical Studies ↗',
                                'secondaryCtaLink' => '#science',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Pulse Biosensor & Live Mobile App',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_pulse_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Precision Biology Meets Machine Learning',
                                'subtitle' => 'Transform complex physiological signals into simple daily decisions.',
                                'items' => [
                                    [
                                        'icon' => '🧬',
                                        'title' => 'Real-Time Glycemic Tracking',
                                        'description' => 'Understand your unique insulin sensitivity and avoid afternoon brain fog permanently.',
                                    ],
                                    [
                                        'icon' => '🧠',
                                        'title' => 'Autonomic Focus Predictor',
                                        'description' => 'Algorithmic recommendations on when to tackle deep strategic work based on HRV stability.',
                                    ],
                                    [
                                        'icon' => '🌙',
                                        'title' => 'Sleep Architecture Optimization',
                                        'description' => 'Targeted interventions to increase restorative slow-wave sleep and REM duration.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_pulse_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Proven Clinical Outcomes',
                                'subtitle' => 'Validated across 12,000+ member clinical trials.',
                                'items' => [
                                    ['value' => '89%', 'label' => 'Reduced Daily Fatigue'],
                                    ['value' => '3.4x', 'label' => 'Sustained Morning Focus'],
                                    ['value' => '14-Day', 'label' => 'Continuous Sensor Life'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_pulse_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Reclaim Your Biology Today',
                                'description' => 'Join 45,000+ executives, athletes, and founders who optimize their health with Pulse Health AI.',
                                'buttonText' => 'Reserve Your Kit',
                                'buttonLink' => '#kit',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_pulse_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© 2026 Pulse Health AI. Medical grade intelligence.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $pulseTmpl = Template::updateOrCreate(
            ['slug' => 'pulse-health'],
            [
                'category_id' => $startupsCat->id,
                'name' => 'Pulse Health AI',
                'description' => 'Continuous biosensing paired with autonomous intelligence to optimize metabolic energy and daily cognitive focus.',
                'industry' => 'Startups & HealthTech',
                'badge' => 'BIOMETRIC INTELLIGENCE',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 89,
                'preview_images' => ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $pulseTmpl->id, 'version' => 1],
            [
                'document' => $pulseDoc,
                'design_tokens' => $pulseDoc['site']['theme'],
                'fonts' => ['Plus Jakarta Sans', 'Inter'],
                'is_active' => true,
            ]
        );

        // 4. Dr. Marcus Vance (Personal)
        $marcusDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Dr. Marcus Vance',
                'theme' => [
                    'colors' => [
                        'primary' => '#8B5E3C',
                        'secondary' => '#60432C',
                        'accent' => '#C99757',
                        'background' => '#FAF6F0',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#1E1A17',
                            'secondary' => '#5E544B',
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
                'logo' => ['text' => 'Dr. Marcus Vance'],
                'items' => [
                    ['label' => 'Books', 'href' => '#books'],
                    ['label' => 'Keynotes', 'href' => '#keynotes'],
                    ['label' => 'Research', 'href' => '#about'],
                    ['label' => 'Inquire', 'href' => '#contact', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_marcus_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ STANFORD NEUROSCIENCE · NYT BESTSELLER',
                                'headline' => "Demystifying High-Performance\nCognition & Focus.",
                                'subheadline' => 'Bridging molecular neuroscience and executive leadership. Author of the international bestseller "The Focused Mind" read by over 500,000 decision makers.',
                                'ctaText' => 'Book Keynote Lecture',
                                'ctaLink' => '#contact',
                                'secondaryCtaText' => 'Explore Essays & Books ↗',
                                'secondaryCtaLink' => '#books',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Dr. Marcus Vance',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_marcus_keynotes',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Signature Keynote Lectures',
                                'subtitle' => 'Equipping global audiences with practical cognitive frameworks.',
                                'items' => [
                                    [
                                        'icon' => '🎯',
                                        'title' => 'Architectures of Focus',
                                        'description' => 'How attentional circuits function in the modern distractible world, and actionable protocols to trigger deep work flow states.',
                                    ],
                                    [
                                        'icon' => '⚖️',
                                        'title' => 'The Biology of High-Stakes Decisions',
                                        'description' => 'Understanding cognitive fatigue, dopamine dynamics, and emotional resilience under sustained volatility.',
                                    ],
                                    [
                                        'icon' => '💡',
                                        'title' => 'Neuroplasticity for Organizations',
                                        'description' => 'Cultivating cultures of rapid learning, psychological safety, and collective intelligence in distributed teams.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_marcus_about',
                            'component' => 'about',
                            'order' => 2,
                            'props' => [
                                'title' => 'About Dr. Vance',
                                'subtitle' => 'Over fifteen years investigating attentional mechanics.',
                                'body' => 'Marcus Vance holds a Ph.D. in Cognitive Neurobiology from Oxford and currently directs research initiatives at Stanford. His essays have appeared in Nature, Harvard Business Review, and The Atlantic. He consults regularly with Fortune 100 executives and top-tier athletics programs on human potential.',
                                'image' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1200&q=80',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_marcus_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Bring Dr. Vance to Your Next Event',
                                'description' => 'Inquire about keynote availability, executive retreats, or advisory engagements for 2026/2027.',
                                'buttonText' => 'Submit Speaker Inquiry',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_marcus_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© 2026 Dr. Marcus Vance. All rights reserved.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $marcusTmpl = Template::updateOrCreate(
            ['slug' => 'marcus-vance'],
            [
                'category_id' => $personalCat->id,
                'name' => 'Dr. Marcus Vance',
                'description' => 'Stanford neuroscientist, keynote speaker, and author of "The Focused Mind" exploring high-performance cognition.',
                'industry' => 'Personal & Thought Leadership',
                'badge' => 'BESTSELLING AUTHOR',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 77,
                'preview_images' => ['https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $marcusTmpl->id, 'version' => 1],
            [
                'document' => $marcusDoc,
                'design_tokens' => $marcusDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Inter'],
                'is_active' => true,
            ]
        );

        // 5. Kai Thorne (Personal)
        $kaiDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Kai Thorne',
                'theme' => [
                    'colors' => [
                        'primary' => '#10B981',
                        'secondary' => '#34D399',
                        'accent' => '#6EE7B7',
                        'background' => '#121316',
                        'surface' => '#1A1D24',
                        'text' => [
                            'primary' => '#F1F5F9',
                            'secondary' => '#94A3B8',
                            'inverse' => '#121316',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Inter',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'kai.thorne.dev'],
                'items' => [
                    ['label' => 'Projects', 'href' => '#projects'],
                    ['label' => 'Articles', 'href' => '#articles'],
                    ['label' => 'Stack', 'href' => '#stack'],
                    ['label' => 'GitHub ↗', 'href' => 'https://github.com', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_kai_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ STAFF ENGINEER · OPEN SOURCE CREATOR',
                                'headline' => "High-Performance Systems\nand Open Source Tools.",
                                'subheadline' => 'Ex-systems architect crafting developer-first terminal tools, high-throughput network engines, and CLI utilities in Rust and Go.',
                                'ctaText' => 'Explore GitHub Tools',
                                'ctaLink' => '#projects',
                                'secondaryCtaText' => 'Read Technical Essays ↗',
                                'secondaryCtaLink' => '#articles',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Kai Thorne coding in terminal',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_kai_projects',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Featured Open Source Projects',
                                'subtitle' => 'Downloaded over 2.4 million times across crates.io and homebrew.',
                                'items' => [
                                    [
                                        'icon' => '⚡',
                                        'title' => 'TurboTrace · Rust',
                                        'description' => 'Zero-overhead distributed tracing daemon with sub-microsecond latency and eBPF kernel hooks.',
                                    ],
                                    [
                                        'icon' => '📦',
                                        'title' => 'BytePack · Go',
                                        'description' => 'High-throughput columnar binary serialization protocol designed for edge database replication.',
                                    ],
                                    [
                                        'icon' => '🖥️',
                                        'title' => 'HyperQuery · Terminal TUI',
                                        'description' => 'Modern 60fps terminal query explorer with vim bindings, fuzzy regex matching, and instant charts.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_kai_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Community Impact',
                                'subtitle' => 'Building in public with full open source transparency.',
                                'items' => [
                                    ['value' => '250K+', 'label' => 'Active Developers'],
                                    ['value' => '14.8K', 'label' => 'GitHub Stars'],
                                    ['value' => '100%', 'label' => 'Open Source MIT'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_kai_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Sponsor or Collaborate',
                                'description' => 'Have an interesting systems challenge or want to support my open source tools? Reach out or sponsor via GitHub.',
                                'buttonText' => 'Get in Touch',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_kai_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© 2026 Kai Thorne. Open source software for all.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $kaiTmpl = Template::updateOrCreate(
            ['slug' => 'kai-thorne'],
            [
                'category_id' => $personalCat->id,
                'name' => 'Kai Thorne',
                'description' => 'Staff engineer turned independent maker. Building high-performance developer tools, terminal utilities, and open source libraries in Rust.',
                'industry' => 'Personal & Software Engineer',
                'badge' => 'INDIE CREATOR',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 93,
                'preview_images' => ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $kaiTmpl->id, 'version' => 1],
            [
                'document' => $kaiDoc,
                'design_tokens' => $kaiDoc['site']['theme'],
                'fonts' => ['Inter'],
                'is_active' => true,
            ]
        );

        // 6. Apex Capital Partners (Business)
        $apexDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Apex Capital Partners',
                'theme' => [
                    'colors' => [
                        'primary' => '#0F2027',
                        'secondary' => '#203A43',
                        'accent' => '#D4AF37',
                        'background' => '#F8FAFC',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#0F172A',
                            'secondary' => '#475569',
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
                'logo' => ['text' => 'Apex Capital Partners'],
                'items' => [
                    ['label' => 'Practices', 'href' => '#practices'],
                    ['label' => 'Track Record', 'href' => '#track-record'],
                    ['label' => 'Team', 'href' => '#team'],
                    ['label' => 'Contact', 'href' => '#contact', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_apex_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ $4.8B AUM · PRIVATE EQUITY & WEALTH ADVISORY',
                                'headline' => "Disciplined Capital.\nMulti-Generational Growth.",
                                'subheadline' => 'Institutional private equity and family office fiduciary advisory. Partnering with visionary founders and institutional funds to compound generational wealth.',
                                'ctaText' => 'Schedule Advisory Consultation',
                                'ctaLink' => '#contact',
                                'secondaryCtaText' => 'Our Investment Focus ↗',
                                'secondaryCtaLink' => '#practices',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Apex Capital Partners Corporate Headquarters',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_apex_practices',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Core Investment Practices',
                                'subtitle' => 'Decades of disciplined capital deployment across asymmetric market cycles.',
                                'items' => [
                                    [
                                        'icon' => '📊',
                                        'title' => 'Growth Private Equity',
                                        'description' => 'Minority and control equity investments into cash-flow positive enterprise software and tech-enabled logistics.',
                                    ],
                                    [
                                        'icon' => '🌐',
                                        'title' => 'Global Real Assets',
                                        'description' => 'Core-plus real estate, data center infrastructure, and sustainable energy projects with direct inflation hedging.',
                                    ],
                                    [
                                        'icon' => '🏛️',
                                        'title' => 'Family Office Fiduciary',
                                        'description' => 'Multi-generational wealth succession planning, tax optimization, and bespoke liquidity management structures.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_apex_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Proven Track Record',
                                'subtitle' => 'Demonstrated risk-adjusted performance across 18 consecutive years.',
                                'items' => [
                                    ['value' => '$4.8B+', 'label' => 'Assets Under Management'],
                                    ['value' => '22.4%', 'label' => 'Historical Net IRR'],
                                    ['value' => '18 Years', 'label' => 'Continuous Stewardship'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_apex_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Schedule a Confidential Briefing',
                                'description' => 'Our managing partners welcome inquiries from institutional allocators, single-family offices, and qualified purchasers.',
                                'buttonText' => 'Inquire for Consultation',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_apex_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© 2026 Apex Capital Partners LLP. Member FINRA / SIPC.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $apexTmpl = Template::updateOrCreate(
            ['slug' => 'apex-capital'],
            [
                'category_id' => $businessCat->id,
                'name' => 'Apex Capital Partners',
                'description' => 'Disciplined private equity and multi-generational wealth advisory managing $4.8B across North America and Europe.',
                'industry' => 'Business & Wealth Advisory',
                'badge' => 'INSTITUTIONAL EXCELLENCE',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 104,
                'preview_images' => ['https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $apexTmpl->id, 'version' => 1],
            [
                'document' => $apexDoc,
                'design_tokens' => $apexDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Inter'],
                'is_active' => true,
            ]
        );


        // Lumière Cinema (Creative & Film Production)
        $lumiere_cinemaDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Lumière Cinema',
                'theme' => [
                    'colors' => [
                        'primary' => '#DC2626',
                        'secondary' => '#EF4444',
                        'accent' => '#F87171',
                        'background' => '#0A0A0A',
                        'surface' => '#141414',
                        'text' => [
                            'primary' => '#FAFAFA',
                            'secondary' => '#A1A1AA',
                            'inverse' => '#0A0A0A',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Instrument Serif',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Lumière Cinema'],
                'items' => [
                    ['label' => 'Productions', 'href' => '#productions'],
                    ['label' => 'Awards', 'href' => '#awards'],
                    ['label' => 'Slates', 'href' => '#offerings'],
                    ['label' => 'Inquire', 'href' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_lumiere_cinema_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ CANNES 2026 SELECTION',
                                'headline' => "Stories that move\nthe world forward.",
                                'subheadline' => 'Award-winning independent cinema and auteur-driven film production. From screenplay incubation to theatrical world premieres.',
                                'ctaText' => 'Watch Showreel',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Explore More ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Lumière Cinema Visual Showcase',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_lumiere_cinema_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Auteur Filmmaking Without Compromise',
                                'subtitle' => 'From raw narrative concept to world cinema distribution.',
                                'items' => [
                            [
                                'icon' => '🎬',
                                'title' => 'Bespoke Production Slates',
                                'description' => 'Full-stack development, casting, principal photography, and master Dolby Atmos audio mixing.',
                            ],
                            [
                                'icon' => '🏆',
                                'title' => 'Festival Circuit Acclaim',
                                'description' => '23 official selections across Cannes, Venice, Sundance, and TIFF over the last 4 seasons.',
                            ],
                            [
                                'icon' => '🎞️',
                                'title' => 'Analog & 70mm Formats',
                                'description' => 'Dedicated photochemical color pipeline supporting 35mm and 70mm large-format film stocks.',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_lumiere_cinema_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Cinematic Track Record',
                                'subtitle' => 'Decades of groundbreaking independent visual storytelling.',
                                'items' => [
                            ['value' => '47', 'label' => 'Films Produced'],
                            ['value' => '23', 'label' => 'Festival Laurels'],
                            ['value' => '12', 'label' => 'Grand Jury Prizes'],
                            ['value' => '98%', 'label' => 'Rotten Tomatoes Avg'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_lumiere_cinema_products',
                            'component' => 'products',
                            'order' => 3,
                            'props' => [
                                'title' => 'Production Packages',
                                'subtitle' => 'Comprehensive production engagements for directors and distributors.',
                                'items' => [
                            [
                                'name' => 'Short Film Incubator',
                                'price' => '$35,000',
                                'description' => 'Full technical package, camera crew, post-color grading, and international festival distribution plan.',
                                'image' => 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Feature Co-Production',
                                'price' => '$180,000+',
                                'description' => 'Co-financing partnership, Tier-1 talent packaging, multi-territory tax credit management, and theatrical deliverable.',
                                'image' => 'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Commercial Brand Cinema',
                                'price' => '$60,000',
                                'description' => 'High-concept narrative commercials with auteur directing, original orchestral scoring, and global usage rights.',
                                'image' => 'https://images.unsplash.com/photo-1518134346374-184f9d21eb29?auto=format&fit=crop&w=600&q=80',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_lumiere_cinema_cta',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Bring Your Vision to the Silver Screen',
                                'description' => 'Our development committee reviews new scripts and treatment packages on a rolling monthly basis.',
                                'buttonText' => 'Submit Treatment Package',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_lumiere_cinema_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => '© 2026 Lumière Cinema Productions SAS. Paris · New York · Tokyo.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $lumiere_cinemaTmpl = Template::updateOrCreate(
            ['slug' => 'lumiere-cinema'],
            [
                'name' => 'Lumière Cinema',
                'description' => 'Bold cinematic landing page for auteur independent film studios, creative production companies, and visual directors.',
                'industry' => 'Creative & Film Production',
                'badge' => '✦ CANNES 2026 SELECTION',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'category_id' => $creativeCat->id,
                'preview_images' => ['https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $lumiere_cinemaTmpl->id, 'version' => 1],
            [
                'document' => $lumiere_cinemaDoc,
                'design_tokens' => $lumiere_cinemaDoc['site']['theme'],
                'fonts' => ['Instrument Serif', 'Inter'],
                'is_active' => true,
            ]
        );

        // Terrain Outdoors (Business & Outdoor Lifestyle)
        $terrain_outdoorsDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Terrain Outdoors',
                'theme' => [
                    'colors' => [
                        'primary' => '#2D4A3E',
                        'secondary' => '#446E5C',
                        'accent' => '#D97706',
                        'background' => '#F4EFEA',
                        'surface' => '#E8E2D9',
                        'text' => [
                            'primary' => '#1C1917',
                            'secondary' => '#57534E',
                            'inverse' => '#F4EFEA',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Space Grotesk',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Terrain Outdoors'],
                'items' => [
                    ['label' => 'Apparel', 'href' => '#products'],
                    ['label' => 'Philosophy', 'href' => '#features'],
                    ['label' => 'Field Tests', 'href' => '#stats'],
                    ['label' => 'Shop Now', 'href' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_terrain_outdoors_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ EXPEDITION GRADE',
                                'headline' => "Engineered for the\npath less taken.",
                                'subheadline' => 'Technical outdoor equipment and expedition gear designed for high-altitude survival. Tested at 6,000 meters, guaranteed for life.',
                                'ctaText' => 'Explore Expedition Gear',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Explore More ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Terrain Outdoors Visual Showcase',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_terrain_outdoors_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Built for Severe Alpine Conditions',
                                'subtitle' => 'No unnecessary features. Only redundant durability and thermal superiority.',
                                'items' => [
                            [
                                'icon' => '🏔️',
                                'title' => 'Alpine Storm Shield',
                                'description' => 'Proprietary 3-layer breathable membrane resisting 35,000mm hydrostatic head pressures in blizzard conditions.',
                            ],
                            [
                                'icon' => '♻️',
                                'title' => 'Circular Lifecycle',
                                'description' => 'Manufactured with 100% recycled polyamide and zero fluorocarbons (PFAS-free DWR finishes).',
                            ],
                            [
                                'icon' => '🛡️',
                                'title' => 'Lifetime Field Repair',
                                'description' => 'Damage your gear on the mountain? Send it to our repair ateliers and we mend it free of charge.',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_terrain_outdoors_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Tested in Extreme Elements',
                                'subtitle' => 'Validated by mountain guides and high-altitude rescue teams across 4 continents.',
                                'items' => [
                            ['value' => '6,200m', 'label' => 'Max Field Test Altitude'],
                            ['value' => '140K+', 'label' => 'Explorers Equipped'],
                            ['value' => '100%', 'label' => 'PFAS-Free Materials'],
                            ['value' => '0', 'label' => 'Landfill Waste Guarantee'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_terrain_outdoors_products',
                            'component' => 'products',
                            'order' => 3,
                            'props' => [
                                'title' => 'Featured Expedition Kit',
                                'subtitle' => 'Essential performance gear for alpine ascents and backcountry traverses.',
                                'items' => [
                            [
                                'name' => 'Summit Shell 3L Pro',
                                'price' => '$420',
                                'description' => 'Ultralight 380g stormproof shell with helmet-compatible storm hood, RECCO reflector, and YKK AquaGuard zips.',
                                'image' => 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Basecamp Down Parka',
                                'price' => '$580',
                                'description' => '900-fill power responsibly sourced hydrophobic down engineered for bivouac survival down to -35°C.',
                                'image' => 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Alpine Traverse Pack 45L',
                                'price' => '$260',
                                'description' => 'Ultra-durable Dyneema composite pack with dual ice axe loops, ski carry system, and removable framesheet.',
                                'image' => 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_terrain_outdoors_cta',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Equip Your Next Mountain Expedition',
                                'description' => 'Join our backcountry collective for early access to limited alpine drops and guided expedition masterclasses.',
                                'buttonText' => 'Get Outfitted',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_terrain_outdoors_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => '© 2026 Terrain Outdoors Co. Chamonix · Boulder · Innsbruck.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $terrain_outdoorsTmpl = Template::updateOrCreate(
            ['slug' => 'terrain-outdoors'],
            [
                'name' => 'Terrain Outdoors',
                'description' => 'Earthy premium outdoor lifestyle brand landing page for technical adventure gear and expedition apparel.',
                'industry' => 'Business & Outdoor Lifestyle',
                'badge' => '✦ EXPEDITION GRADE',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'category_id' => $businessCat->id,
                'preview_images' => ['https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $terrain_outdoorsTmpl->id, 'version' => 1],
            [
                'document' => $terrain_outdoorsDoc,
                'design_tokens' => $terrain_outdoorsDoc['site']['theme'],
                'fonts' => ['Space Grotesk', 'Inter'],
                'is_active' => true,
            ]
        );

        // Noor Atelier (Business & Luxury Jewelry)
        $noor_atelierDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Noor Atelier',
                'theme' => [
                    'colors' => [
                        'primary' => '#854D0E',
                        'secondary' => '#A16207',
                        'accent' => '#CA8A04',
                        'background' => '#FAF7F2',
                        'surface' => '#F3ECE2',
                        'text' => [
                            'primary' => '#1C1917',
                            'secondary' => '#78716C',
                            'inverse' => '#FAF7F2',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Cormorant Garamond',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Noor Atelier'],
                'items' => [
                    ['label' => 'High Jewelry', 'href' => '#products'],
                    ['label' => 'Artisanship', 'href' => '#features'],
                    ['label' => 'Provenance', 'href' => '#stats'],
                    ['label' => 'Inquire', 'href' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_noor_atelier_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ HAUTE JOAILLERIE',
                                'headline' => "Heirloom pieces,\nmodern souls.",
                                'subheadline' => 'Bespoke fine jewelry forged by master artisans in Paris and Florence. Ethically mined rare gemstones, sculptured 18K recycled gold, and timeless silhouettes.',
                                'ctaText' => 'Book Atelier Consultation',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Explore More ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Noor Atelier Visual Showcase',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_noor_atelier_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'The Art of Haute Joaillerie',
                                'subtitle' => 'Centuries-old metalworking traditions honored with contemporary architectural restraint.',
                                'items' => [
                            [
                                'icon' => '💎',
                                'title' => 'Traceable Gemstone Origins',
                                'description' => 'Every Colombian emerald, Ceylon sapphire, and diamond comes with verified blockchain provenance documentation.',
                            ],
                            [
                                'icon' => '🔨',
                                'title' => 'Lost Wax Sculpture',
                                'description' => 'Every mount is hand-carved in wax and cast in 18K or 24K fairmined gold. Never mass-stamped.',
                            ],
                            [
                                'icon' => '✨',
                                'title' => 'Bespoke Bridal & Heirloom',
                                'description' => 'Collaborate directly with our master jeweler over six weeks to create a custom one-of-a-kind legacy heirloom.',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_noor_atelier_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Heritage of Precision',
                                'subtitle' => 'Excellence measured in karats, microns, and lifelong devotions.',
                                'items' => [
                            ['value' => '18K+', 'label' => 'Recycled Fairmined Gold'],
                            ['value' => '40-120h', 'label' => 'Artisan Hours Per Piece'],
                            ['value' => '100%', 'label' => 'Conflict-Free Sourcing'],
                            ['value' => '1888', 'label' => 'Ancestral Craft Roots'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_noor_atelier_products',
                            'component' => 'products',
                            'order' => 3,
                            'props' => [
                                'title' => 'Signature Creations',
                                'subtitle' => 'One-of-a-kind pieces currently available at our Place Vendôme salon.',
                                'items' => [
                            [
                                'name' => 'Solaris Solitaire Ring',
                                'price' => '$6,400',
                                'description' => '2.4ct oval diamond mounted in a sculptural fluted 18K yellow gold setting with hidden micro-pavé band.',
                                'image' => 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Aura Diamond Choker',
                                'price' => '$9,800',
                                'description' => 'Articulated chevron collar in 18K white gold featuring 4.8ct of brilliant bezel-set natural diamonds.',
                                'image' => 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Celestial Emerald Earrings',
                                'price' => '$5,200',
                                'description' => 'Pair of matched Muzo green emerald drops framed by hand-carved yellow gold starburst accents.',
                                'image' => 'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=600&q=80',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_noor_atelier_cta',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Commission Your Legacy Heirloom',
                                'description' => 'Schedule a private consultation at our Place Vendôme salon or request our secure bespoke design concierge worldwide.',
                                'buttonText' => 'Request Private Viewing',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_noor_atelier_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => '© 2026 Noor Atelier Joaillerie. Place Vendôme, Paris · Milan · Dubai.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $noor_atelierTmpl = Template::updateOrCreate(
            ['slug' => 'noor-atelier'],
            [
                'name' => 'Noor Atelier',
                'description' => 'Warm, luminous landing page for bespoke fine jewelry ateliers, master goldsmiths, and ethical gem houses.',
                'industry' => 'Business & Luxury Jewelry',
                'badge' => '✦ HAUTE JOAILLERIE',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'category_id' => $businessCat->id,
                'preview_images' => ['https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $noor_atelierTmpl->id, 'version' => 1],
            [
                'document' => $noor_atelierDoc,
                'design_tokens' => $noor_atelierDoc['site']['theme'],
                'fonts' => ['Cormorant Garamond', 'Inter'],
                'is_active' => true,
            ]
        );

        // Vela Sailing Co. (Business & Luxury Travel)
        $vela_sailingDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Vela Sailing Co.',
                'theme' => [
                    'colors' => [
                        'primary' => '#0F2C59',
                        'secondary' => '#1E40AF',
                        'accent' => '#0284C7',
                        'background' => '#F8FAFC',
                        'surface' => '#EDF2F7',
                        'text' => [
                            'primary' => '#0F172A',
                            'secondary' => '#475569',
                            'inverse' => '#F8FAFC',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'DM Serif Display',
                        'bodyFamily' => 'DM Sans',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Vela Sailing Co.'],
                'items' => [
                    ['label' => 'Expeditions', 'href' => '#products'],
                    ['label' => 'Fleet', 'href' => '#features'],
                    ['label' => 'Experience', 'href' => '#stats'],
                    ['label' => 'Inquire', 'href' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_vela_sailing_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ MEDITERRANEAN & CARIBBEAN',
                                'headline' => "Sail beyond\nthe edge of maps.",
                                'subheadline' => 'Curated private yacht expeditions across the Cyclades, Amalfi Coast, and the Grenadines. Bespoke itineraries, master captains, and Michelin-trained onboard chefs.',
                                'ctaText' => 'Charter Your Yacht',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Explore More ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1500930287596-c1ecaa373bb2?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Vela Sailing Co. Visual Showcase',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_vela_sailing_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'The Art of Private Ocean Navigation',
                                'subtitle' => 'Unrivaled luxury and quiet anchorages far away from cruise routes.',
                                'items' => [
                            [
                                'icon' => '⛵',
                                'title' => 'Bespoke Catamarans & Sloops',
                                'description' => 'Modern 50ft to 85ft carbon-composite yachts outfitted with watermakers, solar arrays, and hydraulic swim platforms.',
                            ],
                            [
                                'icon' => '👨‍🍳',
                                'title' => 'Michelin-Trained Chefs',
                                'description' => 'Every voyage includes a dedicated private chef preparing fresh catch, local market produce, and fine organic wines.',
                            ],
                            [
                                'icon' => '⚓',
                                'title' => 'Off-Grid Island Anchorages',
                                'description' => 'Access secluded turquoise coves and marine sanctuaries only reachable under sail.',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_vela_sailing_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Maritime Excellence',
                                'subtitle' => 'Safe passages, seasoned skippers, and unforgettable ocean memories.',
                                'items' => [
                            ['value' => '32', 'label' => 'Flagship Yachts'],
                            ['value' => '1,400+', 'label' => 'Voyages Completed'],
                            ['value' => '99.4%', 'label' => 'Five-Star Reviews'],
                            ['value' => '14', 'label' => 'Archipelago Routes'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_vela_sailing_products',
                            'component' => 'products',
                            'order' => 3,
                            'props' => [
                                'title' => 'Curated Charter Itineraries',
                                'subtitle' => 'Weekly luxury charters including captain, private chef, provisions, and ocean toys.',
                                'items' => [
                            [
                                'name' => 'Cyclades Explorer (7 Days)',
                                'price' => '$14,500 / wk',
                                'description' => 'Mykonos, Delos, Paros, and Milos aboard a 54ft luxury catamaran. Secluded volcanic coves and private wine tastings.',
                                'image' => 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Amalfi Sunset Voyage (5 Days)',
                                'price' => '$11,200 / wk',
                                'description' => 'Capri, Positano, and Ravello. Sunset moorings below towering cliffs with tender transfers to cliffside restaurants.',
                                'image' => 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Grenadines Passage (10 Days)',
                                'price' => '$21,000 / wk',
                                'description' => 'St. Vincent to Grenada through the Tobago Cays turtle sanctuaries. Kite-boarding, deep diving, and coral exploration.',
                                'image' => 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=600&q=80',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_vela_sailing_cta',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Plan Your Bespoke Voyage at Sea',
                                'description' => 'Our nautical navigators design tailored passages for couples, families, and private groups. Secure summer anchorages today.',
                                'buttonText' => 'Request Voyage Proposal',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_vela_sailing_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => '© 2026 Vela Sailing Co. Port Hercule, Monaco · Athens · Road Town.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $vela_sailingTmpl = Template::updateOrCreate(
            ['slug' => 'vela-sailing'],
            [
                'name' => 'Vela Sailing Co.',
                'description' => 'Nautical luxury travel landing page for crewed yacht charters, bespoke sailing expeditions, and island voyages.',
                'industry' => 'Business & Luxury Travel',
                'badge' => '✦ MEDITERRANEAN & CARIBBEAN',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'category_id' => $businessCat->id,
                'preview_images' => ['https://images.unsplash.com/photo-1500930287596-c1ecaa373bb2?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $vela_sailingTmpl->id, 'version' => 1],
            [
                'document' => $vela_sailingDoc,
                'design_tokens' => $vela_sailingDoc['site']['theme'],
                'fonts' => ['DM Serif Display', 'DM Sans'],
                'is_active' => true,
            ]
        );

        // Ora Mindful (Startups & Digital Wellness)
        $ora_mindfulDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Ora Mindful',
                'theme' => [
                    'colors' => [
                        'primary' => '#6D28D9',
                        'secondary' => '#7C3AED',
                        'accent' => '#A855F7',
                        'background' => '#FAF5FF',
                        'surface' => '#F3E8FF',
                        'text' => [
                            'primary' => '#1E1B4B',
                            'secondary' => '#6B7280',
                            'inverse' => '#FAF5FF',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Plus Jakarta Sans',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Ora Mindful'],
                'items' => [
                    ['label' => 'Method', 'href' => '#features'],
                    ['label' => 'Clinical Proof', 'href' => '#stats'],
                    ['label' => 'Plans', 'href' => '#products'],
                    ['label' => 'Try Free', 'href' => '#cta', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_ora_mindful_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ CLINICALLY BACKED AI',
                                'headline' => "Quiet the noise.\nReclaim your focus.",
                                'subheadline' => 'The adaptive nervous-system companion powered by neural soundscapes and real-time biometric biofeedback. Measurably reduce cortisol in 10 minutes a day.',
                                'ctaText' => 'Start 14-Day Free Trial',
                                'ctaLink' => '#cta',
                                'secondaryCtaText' => 'Explore More ↗',
                                'secondaryCtaLink' => '#features',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Ora Mindful Visual Showcase',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_ora_mindful_features',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Neuroscience-Engineered Mindfulness',
                                'subtitle' => 'Dynamic sensory entrainment tailored to your autonomic nervous system state.',
                                'items' => [
                            [
                                'icon' => '🧠',
                                'title' => 'Generative Binaural Audio',
                                'description' => 'Synthesized 40Hz gamma and 7Hz theta waves that shift your brain state into deep focus or restorative recovery.',
                            ],
                            [
                                'icon' => '💓',
                                'title' => 'Apple Watch & Oura Sync',
                                'description' => 'Continuously reads HRV dips and automatically prompts 3-minute breathwork intervals before stress spikes.',
                            ],
                            [
                                'icon' => '🌙',
                                'title' => 'Circadian Sleep Architecture',
                                'description' => 'Non-verbal acoustic sleep transitions designed by neurobiologists to extend stage 3 deep restorative sleep.',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_ora_mindful_stats',
                            'component' => 'statistics',
                            'order' => 2,
                            'props' => [
                                'title' => 'Clinical Efficacy Measured',
                                'subtitle' => 'Results from double-blind studies conducted with leading neuro-psychology institutes.',
                                'items' => [
                            ['value' => '42%', 'label' => 'Salivary Cortisol Reduction'],
                            ['value' => '1.8M+', 'label' => 'Mindful Breathers'],
                            ['value' => '12', 'label' => 'Peer-Reviewed Studies'],
                            ['value' => '4.9★', 'label' => '85,000+ App Store Reviews'],
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_ora_mindful_products',
                            'component' => 'products',
                            'order' => 3,
                            'props' => [
                                'title' => 'Simple Mindful Memberships',
                                'subtitle' => 'Invest in lifelong neuro-plasticity and mental calm. Cancel anytime.',
                                'items' => [
                            [
                                'name' => 'Annual All-Access',
                                'price' => '$69.99 / yr',
                                'description' => 'Full access to neural audio engine, biometric sync, daily personalized coaching, and offline mode. 14-day free trial.',
                                'image' => 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Lifetime Sovereign Pass',
                                'price' => '$199 one-time',
                                'description' => 'Lifetime access to all future sound engines, Apple Vision Pro spatial environments, and founder community forum.',
                                'image' => 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=600&q=80',
                            ],
                            [
                                'name' => 'Teams & High-Performance',
                                'price' => '$6 / seat / mo',
                                'description' => 'For high-velocity engineering, design, and executive teams seeking burn-out resilience and focus routines.',
                                'image' => 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80',
                            ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_ora_mindful_cta',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Begin Your Nervous System Reset',
                                'description' => 'Experience deep mental clarity in under 10 minutes. Download Ora today on iOS, Android, and macOS.',
                                'buttonText' => 'Claim Your 14-Day Free Access',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_ora_mindful_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => '© 2026 Ora Mindful Technologies, Inc. San Francisco · Zurich.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $ora_mindfulTmpl = Template::updateOrCreate(
            ['slug' => 'ora-mindful'],
            [
                'name' => 'Ora Mindful',
                'description' => 'Calming digital wellness app landing page for AI meditation, nervous-system restoration, and soundscape therapy.',
                'industry' => 'Startups & Digital Wellness',
                'badge' => '✦ CLINICALLY BACKED AI',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'category_id' => $startupsCat->id,
                'preview_images' => ['https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=1200&q=80'],
            ]
        );

        TemplateVersion::updateOrCreate(
            ['template_id' => $ora_mindfulTmpl->id, 'version' => 1],
            [
                'document' => $ora_mindfulDoc,
                'design_tokens' => $ora_mindfulDoc['site']['theme'],
                'fonts' => ['Plus Jakarta Sans', 'Inter'],
                'is_active' => true,
            ]
        );
    }
}
