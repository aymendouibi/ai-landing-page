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

        // Update existing templates with proper categories
        Template::where('slug', 'ana-teo')->update(['category_id' => $weddingsCat->id]);
        Template::where('slug', 'kite-yoga')->update(['category_id' => $personalCat->id]);
        Template::where('slug', 'lumen-coffee')->update(['category_id' => $businessCat->id]);
        Template::where('slug', 'bistro-verona')->update(['category_id' => $businessCat->id]);
        Template::where('slug', 'saas-apex')->update(['category_id' => $startupsCat->id]);

        // 2. Elysian Vows (Weddings)
        $elysianDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Sophia & Julian',
                'theme' => [
                    'colors' => [
                        'primary' => '#B38E5D',
                        'secondary' => '#786C5E',
                        'accent' => '#D4AF37',
                        'background' => '#FAF8F5',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#24211E',
                            'secondary' => '#6B635B',
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
                'logo' => ['text' => 'Sophia & Julian'],
                'items' => [
                    ['label' => 'Our Story', 'href' => '#story'],
                    ['label' => 'Schedule', 'href' => '#schedule'],
                    ['label' => 'Travel', 'href' => '#travel'],
                    ['label' => 'RSVP', 'href' => '#rsvp', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_elysian_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => 'SEPTEMBER 18–20, 2026 · VILLA BALBIANELLO, LAKE COMO',
                                'headline' => "Two Lives.\nOne Timeless Evening.",
                                'subheadline' => 'We invite our nearest and dearest to join us along the shores of Lake Como to celebrate love, family, and lifelong devotion.',
                                'ctaText' => 'RSVP by May 1',
                                'ctaLink' => '#rsvp',
                                'secondaryCtaText' => 'Our Story ↗',
                                'secondaryCtaLink' => '#story',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Sophia and Julian at Lake Como',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_elysian_schedule',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Celebration Itinerary',
                                'subtitle' => 'A three-day gathering among the historic gardens and waters of Como.',
                                'items' => [
                                    [
                                        'icon' => '✦',
                                        'title' => 'Friday Welcome Prosecco',
                                        'description' => 'Sept 18, 6:00 PM · Grand Hotel Tremezzo Terrace. Sunset cocktails, antipasti, and lakeside jazz.',
                                    ],
                                    [
                                        'icon' => '✦',
                                        'title' => 'Saturday Vows & Gala',
                                        'description' => 'Sept 19, 4:30 PM · Villa Balbianello. Garden ceremony overlooking the lake followed by banquet dinner and dancing.',
                                    ],
                                    [
                                        'icon' => '✦',
                                        'title' => 'Sunday Lakeside Brunch',
                                        'description' => 'Sept 20, 11:00 AM · Bellagio Pier. Fresh pastries, espresso, and private wooden boat excursions.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_elysian_story',
                            'component' => 'about',
                            'order' => 2,
                            'props' => [
                                'title' => 'How We Met',
                                'subtitle' => 'Seven years of laughter, shared passports, and endless coffee.',
                                'body' => 'From our first spontaneous encounter in a sunlit Montmartre gallery to building a life together across three cities, every milestone has brought us closer. We cannot wait to begin this sacred next chapter surrounded by the people who mean the world to us.',
                                'image' => 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&w=1200&q=80',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_elysian_travel',
                            'component' => 'visit',
                            'order' => 3,
                            'props' => [
                                'title' => 'Travel & Accommodations',
                                'subtitle' => 'Villa Balbianello, Lenno, Lake Como, Italy',
                                'address' => 'Via Guido Monzino 1, 22016 Tremezzina CO, Italy',
                                'hours' => 'Milan Malpensa Airport (MXP) is 60 minutes away. Private ferry shuttles depart every hour from Como San Giovanni station.',
                                'ctaText' => 'View Room Blocks',
                                'ctaLink' => '#rooms',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_elysian_rsvp',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Kindly RSVP by May 1, 2026',
                                'description' => 'Please let us know if you can celebrate with us and provide dietary requirements or song requests.',
                                'buttonText' => 'Confirm Attendance',
                                'buttonLink' => '#rsvp',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_elysian_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => 'Sophia & Julian · September 2026 · Lake Como, Italy. With love.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $elysianTmpl = Template::updateOrCreate(
            ['slug' => 'elysian-vows'],
            [
                'category_id' => $weddingsCat->id,
                'name' => 'Elysian Vows',
                'description' => 'Warm candlelight, lakeside terraces, and an intimate celebration layout on Lake Como.',
                'industry' => 'Weddings & Celebrations',
                'badge' => 'EDITORIAL ROMANCE',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 64,
                'preview_images' => ['https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $elysianTmpl->id, 'version' => 1],
            [
                'document' => $elysianDoc,
                'design_tokens' => $elysianDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Inter'],
                'is_active' => true,
            ]
        );

        // 3. Botanical Romance (Weddings)
        $botanicalDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Maya & Liam',
                'theme' => [
                    'colors' => [
                        'primary' => '#2D4739',
                        'secondary' => '#4A6B56',
                        'accent' => '#D97706',
                        'background' => '#F6F7F3',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#1A241E',
                            'secondary' => '#4D5E53',
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
                'logo' => ['text' => 'Maya & Liam'],
                'items' => [
                    ['label' => 'Schedule', 'href' => '#schedule'],
                    ['label' => 'Our Story', 'href' => '#story'],
                    ['label' => 'Guest FAQ', 'href' => '#faq'],
                    ['label' => 'RSVP', 'href' => '#rsvp', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_botanical_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => 'AUGUST 14–16, 2026 · BIG SUR, CALIFORNIA',
                                'headline' => "Under the Stars,\nSurrounded by Nature.",
                                'subheadline' => 'Two paths intertwining beneath the ancient redwoods. Come share music, wine, and warm memories with us on the Pacific ridge.',
                                'ctaText' => 'RSVP by June 15',
                                'ctaLink' => '#rsvp',
                                'secondaryCtaText' => 'Weekend Schedule ↗',
                                'secondaryCtaLink' => '#schedule',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Maya and Liam outdoor wedding',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_botanical_schedule',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Weekend Gatherings',
                                'subtitle' => 'A rustic coastal celebration from dawn till dusk.',
                                'items' => [
                                    [
                                        'icon' => '🌿',
                                        'title' => 'Friday Bonfire & Tacos',
                                        'description' => 'Aug 14, 7:00 PM · Redwood Glade. Local Baja-style tacos, local craft cider, and acoustic guitar by the firepit.',
                                    ],
                                    [
                                        'icon' => '🌸',
                                        'title' => 'Saturday Forest Ceremony',
                                        'description' => 'Aug 15, 3:30 PM · The Cathedral Grove. Exchange of vows followed by family-style farm dinner under twinkle lights.',
                                    ],
                                    [
                                        'icon' => '☀️',
                                        'title' => 'Sunday Morning Coffee & Pastries',
                                        'description' => 'Aug 16, 9:30 AM · The Overlook Deck. Pour-over bar, fresh pastries, and warm hugs before journeying home.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_botanical_story',
                            'component' => 'about',
                            'order' => 2,
                            'props' => [
                                'title' => 'Our Journey Together',
                                'subtitle' => 'From trail runs in Marin to building our dream homestead.',
                                'body' => 'We met at a trail race in 2019, both reaching for the same post-run orange slice. Six years, countless mountain peaks, and one rambunctious golden retriever later, we are overjoyed to say "I do" in the place where we feel most at home: outdoors.',
                                'image' => 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=1200&q=80',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_botanical_faq',
                            'component' => 'faq',
                            'order' => 3,
                            'props' => [
                                'title' => 'Guest Information & FAQ',
                                'subtitle' => 'Everything you need to know for our mountain weekend.',
                                'items' => [
                                    [
                                        'question' => 'What is the dress code?',
                                        'answer' => 'Garden cocktail attire. Please note that the ceremony and dinner are on grassy terrain, so wedges, block heels, or flats are strongly recommended.',
                                    ],
                                    [
                                        'question' => 'How do we get to the venue?',
                                        'answer' => 'We are providing shuttles from Carmel Valley hotels. Mountain parking is limited, so we encourage taking the group shuttles.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_botanical_rsvp',
                            'component' => 'cta',
                            'order' => 4,
                            'props' => [
                                'headline' => 'Will You Join Our Celebration?',
                                'description' => 'Please let us know your RSVP by June 15, 2026 so we can finalize our farm-to-table banquet seats.',
                                'buttonText' => 'Confirm Attendance',
                                'buttonLink' => '#rsvp',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_botanical_footer',
                            'component' => 'footer',
                            'order' => 5,
                            'props' => [
                                'copyright' => 'Maya & Liam · August 2026 · Big Sur, California. Forever.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $botanicalTmpl = Template::updateOrCreate(
            ['slug' => 'botanical-vows'],
            [
                'category_id' => $weddingsCat->id,
                'name' => 'Botanical Romance',
                'description' => 'Sunlit coastal redwoods, organic wildflower florals, and outdoor dinner celebration in Big Sur.',
                'industry' => 'Weddings & Celebrations',
                'badge' => 'WILDFLOWER GARDEN',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 52,
                'preview_images' => ['https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $botanicalTmpl->id, 'version' => 1],
            [
                'document' => $botanicalDoc,
                'design_tokens' => $botanicalDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Inter'],
                'is_active' => true,
            ]
        );

        // 4. DevFlow Cloud (Startups)
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

        // 5. Pulse Health AI (Startups)
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

        // 6. Dr. Marcus Vance (Personal)
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

        // 7. Elena Rostova (Personal)
        $elenaDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Elena Rostova Architect',
                'theme' => [
                    'colors' => [
                        'primary' => '#1C1917',
                        'secondary' => '#57534E',
                        'accent' => '#A8A29E',
                        'background' => '#FAFAF9',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#1C1917',
                            'secondary' => '#78716C',
                            'inverse' => '#FAFAF9',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Space Grotesk',
                        'bodyFamily' => 'Inter',
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => 'Elena Rostova'],
                'items' => [
                    ['label' => 'Projects', 'href' => '#projects'],
                    ['label' => 'Philosophy', 'href' => '#philosophy'],
                    ['label' => 'Awards', 'href' => '#awards'],
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
                            'id' => 'sec_elena_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ AD100 2026 · ARCHITECTURAL DESIGN & INTERIORS',
                                'headline' => "Form, Silence,\nand Natural Light.",
                                'subheadline' => 'Bespoke architectural commissions that honor natural materiality, raw concrete, and the sacred balance between interior and wild exterior landscapes.',
                                'ctaText' => 'Explore Works',
                                'ctaLink' => '#projects',
                                'secondaryCtaText' => 'Design Philosophy ↗',
                                'secondaryCtaLink' => '#philosophy',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Villa Kanso in Kyoto by Elena Rostova',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_elena_projects',
                            'component' => 'features',
                            'order' => 1,
                            'props' => [
                                'title' => 'Selected Architectural Works',
                                'subtitle' => 'Monolithic residential sanctuaries completed across Europe and Asia.',
                                'items' => [
                                    [
                                        'icon' => '🏛️',
                                        'title' => 'Villa Kanso · Kyoto',
                                        'description' => 'Charred cedar yakisugi facade paired with basalt stone courtyard gardens and hidden subterranean tea chamber.',
                                    ],
                                    [
                                        'icon' => '🏔️',
                                        'title' => 'Alpine Glass Sanctuary · Vals',
                                        'description' => 'Cantilevered board-formed concrete pavilion embedded into the Swiss granite slopes with 360-degree panoramic glazing.',
                                    ],
                                    [
                                        'icon' => '🌊',
                                        'title' => 'Pavilion VII · Stockholm Archipelago',
                                        'description' => 'Zero-carbon timber dwelling featuring thermal bedrock heating and private natural harbor jetty.',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_elena_philosophy',
                            'component' => 'about',
                            'order' => 2,
                            'props' => [
                                'title' => 'Architectural Manifesto',
                                'subtitle' => 'A dialogue between permanence and ephemeral daylight.',
                                'body' => 'Architecture should not compete with nature; it should serve as a quiet frame through which the changes of season, wind, and sky are felt deeply. We work with an intentional palette of raw stone, unvarnished timber, and shadow to craft spaces that inspire reverence.',
                                'image' => 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_elena_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Initiate a Private Commission',
                                'description' => 'We accept a select number of residential and cultural architectural commissions each year.',
                                'buttonText' => 'Contact the Studio',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_elena_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© 2026 Elena Rostova Studio. Zurich · Kyoto.',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                    ],
                ],
            ],
        ];

        $elenaTmpl = Template::updateOrCreate(
            ['slug' => 'elena-rostova'],
            [
                'category_id' => $personalCat->id,
                'name' => 'Elena Rostova',
                'description' => 'Bespoke residential pavilions, private sanctuaries, and minimalist interior architecture across Kyoto and Zurich.',
                'industry' => 'Personal & Architecture Portfolio',
                'badge' => 'AD100 ARCHITECT',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 65,
                'preview_images' => ['https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $elenaTmpl->id, 'version' => 1],
            [
                'document' => $elenaDoc,
                'design_tokens' => $elenaDoc['site']['theme'],
                'fonts' => ['Space Grotesk', 'Inter'],
                'is_active' => true,
            ]
        );

        // 8. Kai Thorne (Personal)
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

        // 9. Apex Capital Partners (Business)
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

        // 10. Nordic Craft Roasters (Business)
        $nordicDoc = [
            'schema_version' => 1,
            'site' => [
                'name' => 'Nordic Craft Roasters',
                'theme' => [
                    'colors' => [
                        'primary' => '#2C1810',
                        'secondary' => '#5E3A2B',
                        'accent' => '#C5A880',
                        'background' => '#F5F2EB',
                        'surface' => '#FFFFFF',
                        'text' => [
                            'primary' => '#2C1810',
                            'secondary' => '#6B5448',
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
                'logo' => ['text' => 'Nordic Craft Roasters'],
                'items' => [
                    ['label' => 'Coffee', 'href' => '#products'],
                    ['label' => 'Sourcing', 'href' => '#about'],
                    ['label' => 'Café & Tasting', 'href' => '#visit'],
                    ['label' => 'Wholesale', 'href' => '#wholesale', 'type' => 'button'],
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'sections' => [
                        [
                            'id' => 'sec_nordic_hero',
                            'component' => 'hero',
                            'order' => 0,
                            'props' => [
                                'badge' => '✦ COPENHAGEN MICRO-ROASTERY · DIRECT TRADE',
                                'headline' => "Precision Roasting.\nUncompromised Purity.",
                                'subheadline' => 'Light, expressive Scandinavian roast profiles designed to preserve floral sweetness, vibrant citrus acidity, and authentic terroir from farm to cup.',
                                'ctaText' => 'Explore Coffee Offerings',
                                'ctaLink' => '#products',
                                'secondaryCtaText' => 'Visit Our Tasting Room ↗',
                                'secondaryCtaLink' => '#visit',
                                'image' => [
                                    'src' => 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=1200&q=80',
                                    'alt' => 'Nordic Craft Specialty Coffee Roasters',
                                ],
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_nordic_products',
                            'component' => 'products',
                            'order' => 1,
                            'props' => [
                                'title' => 'Seasonal Single-Origin Selections',
                                'subtitle' => 'Small-batch roasted every Tuesday on our zero-emission Loring S35.',
                                'items' => [
                                    [
                                        'name' => 'Guji Natural · Ethiopia',
                                        'price' => '€19.50',
                                        'description' => 'Jasmine blossom, wild strawberry, and bergamot finish.',
                                        'badge' => 'LIMITED HARVEST',
                                    ],
                                    [
                                        'name' => 'Huila Pink Bourbon · Colombia',
                                        'price' => '€22.00',
                                        'description' => 'Crisp white peach, sugarcane syrup, and honeysuckle aroma.',
                                        'badge' => 'MICRO-LOT',
                                    ],
                                    [
                                        'name' => 'Nordic Winter Espresso',
                                        'price' => '€17.00',
                                        'description' => 'Milk chocolate ganache, candied orange, and smooth body.',
                                        'badge' => 'HOUSE BLEND',
                                    ],
                                ],
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_nordic_visit',
                            'component' => 'visit',
                            'order' => 2,
                            'props' => [
                                'title' => 'Copenhagen Tasting Room',
                                'subtitle' => 'Vesterbrogade 44, 1620 København V, Denmark',
                                'address' => 'Vesterbrogade 44, 1620 København V, Denmark',
                                'hours' => "Monday – Friday: 07:30 – 17:00\nSaturday – Sunday: 08:30 – 18:00\nPublic cuppings every Saturday at 11:00 AM.",
                                'ctaText' => 'Get Directions',
                                'ctaLink' => '#directions',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                        [
                            'id' => 'sec_nordic_cta',
                            'component' => 'cta',
                            'order' => 3,
                            'props' => [
                                'headline' => 'Wholesale & Michelin Partner Program',
                                'description' => 'We provide bespoke roast profiles, commercial La Marzocco equipment, and barista training to world-class hospitality venues.',
                                'buttonText' => 'Inquire for Wholesale',
                                'buttonLink' => '#wholesale',
                            ],
                            'styles' => ['background' => 'surface'],
                        ],
                        [
                            'id' => 'sec_nordic_footer',
                            'component' => 'footer',
                            'order' => 4,
                            'props' => [
                                'copyright' => '© 2026 Nordic Craft Roasters ApS. Copenhagen, Denmark.',
                            ],
                            'styles' => ['background' => 'background'],
                        ],
                    ],
                ],
            ],
        ];

        $nordicTmpl = Template::updateOrCreate(
            ['slug' => 'nordic-craft'],
            [
                'category_id' => $businessCat->id,
                'name' => 'Nordic Craft Roasters',
                'description' => 'Direct-trade Scandinavian light roasts sourced from ethical smallholder cooperatives across Ethiopia and Colombia.',
                'industry' => 'Business & Specialty Coffee',
                'badge' => 'DIRECT TRADE ORIGIN',
                'is_featured' => true,
                'is_public' => true,
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 84,
                'preview_images' => ['https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=1200&q=80'],
            ]
        );
        TemplateVersion::updateOrCreate(
            ['template_id' => $nordicTmpl->id, 'version' => 1],
            [
                'document' => $nordicDoc,
                'design_tokens' => $nordicDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Inter'],
                'is_active' => true,
            ]
        );
    }
}
