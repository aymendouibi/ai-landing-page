<?php

namespace App\Services\AI;

use App\Models\DesignRecipe;
use App\Services\AI\Prompts\PromptHelper;
use App\Services\AI\Prompts\UnifiedWebsitePrompt;
use App\Services\Documents\DefaultDocumentFactory;
use App\Services\Documents\DocumentValidator;
use Exception;
use Illuminate\Support\Str;

class AiWebsiteGenerator
{
    public function __construct(
        protected OpenRouterClient $client,
        protected ModelSelector $modelSelector,
        protected DocumentValidator $validator
    ) {}

    /**
     * Curated high-quality Unsplash image placeholders mapped by industry.
     *
     * @var array<string, string>
     */
    protected const INDUSTRY_HERO_IMAGES = [
        'technology' => 'https://images.unsplash.com/photo-1551434678-e076c223a692?auto=format&fit=crop&w=1200&q=80',
        'saas' => 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80',
        'restaurant' => 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
        'beauty' => 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=1200&q=80',
        'fitness' => 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80',
        'agency' => 'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=1200&q=80',
        'portfolio' => 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=1200&q=80',
        'architecture' => 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
        'default' => 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
    ];

    /**
     * Run high-speed staged AI generation pipeline.
     *
     * @param string $userPrompt
     * @param string|null $preferredIndustry
     * @param callable|null $progressCallback fn(int $percent, string $message)
     * @return array{document: array<string, mixed>, tokens_used: int, model_used: string}
     * @throws Exception
     */
    public function generate(
        string $userPrompt,
        ?string $preferredIndustry = null,
        ?callable $progressCallback = null
    ): array {
        @set_time_limit(180);

        $reportProgress = function (int $percent, string $msg) use ($progressCallback) {
            if ($progressCallback) {
                $progressCallback($percent, $msg);
            }
        };

        // STAGE 1: Industry tokens & design recipe matching
        $reportProgress(20, 'Matching design recipe & typography...');
        $normIndustry = strtolower($preferredIndustry ?? 'general');
        $recipe = DesignRecipe::findByIndustry($normIndustry)?->theme;

        // STAGE 2: High-speed unified generation
        $reportProgress(45, 'Generating brand copywriting, sections, and layout...');
        $primaryModel = $this->modelSelector->getModelForTask('document_generation');

        $response = $this->client->chatCompletion(
            messages: UnifiedWebsitePrompt::build($userPrompt, $preferredIndustry),
            preferredModel: $primaryModel,
            jsonMode: true
        );

        $tokensUsed = ($response['tokens_input'] ?? 0) + ($response['tokens_output'] ?? 0);
        $data = PromptHelper::extractJson($response['content']);

        $siteName = $data['business_name'] ?? 'Apex Form Studio';
        $industry = strtolower($data['industry'] ?? $preferredIndustry ?? 'general');

        // STAGE 3: Document Assembly
        $reportProgress(85, 'Assembling structured website document...');
        $document = $this->assembleDocument($siteName, $industry, $recipe, $data);

        // STAGE 4: Schema validation
        $reportProgress(95, 'Validating schema compliance...');
        $this->validator->validate($document);

        $reportProgress(100, 'Website ready!');

        return [
            'document' => $document,
            'tokens_used' => $tokensUsed,
            'model_used' => $response['model_used'] ?? $primaryModel,
            'business_analysis' => [
                'business_name' => $siteName,
                'industry' => $industry,
                'tagline' => $data['tagline'] ?? '',
            ],
        ];
    }

    /**
     * Assemble generated data into valid WebsiteDocument format.
     */
    protected function assembleDocument(
        string $siteName,
        string $industry,
        ?array $recipeTheme,
        array $data
    ): array {
        $defaultBase = DefaultDocumentFactory::createDefault($siteName);
        $theme = $recipeTheme ?? $defaultBase['site']['theme'];

        // Hero image
        $heroImage = self::INDUSTRY_HERO_IMAGES[$industry]
            ?? self::INDUSTRY_HERO_IMAGES['architecture']
            ?? self::INDUSTRY_HERO_IMAGES['default'];

        $sections = [];
        $order = 0;

        // 1. Hero Section
        $hero = $data['hero'] ?? [];
        $sections[] = [
            'id' => 'sec_hero_' . Str::random(8),
            'component' => 'hero',
            'variant' => 'centered',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'headline' => $hero['headline'] ?? "Welcome to {$siteName}",
                'subheadline' => $hero['subheadline'] ?? ($data['tagline'] ?? 'Architectural excellence and innovative design.'),
                'ctaText' => $hero['ctaText'] ?? 'Explore Projects',
                'ctaLink' => $hero['ctaLink'] ?? '#features',
                'secondaryCtaText' => $hero['secondaryCtaText'] ?? 'Contact Studio',
                'secondaryCtaLink' => $hero['secondaryCtaLink'] ?? '#contact',
                'image' => ['src' => $heroImage, 'alt' => $siteName],
            ],
            'styles' => ['background' => 'surface', 'textAlign' => 'center'],
            'responsive' => [],
        ];

        // 2. Features Section
        $features = $data['features'] ?? [];
        $featureItems = $features['items'] ?? [
            ['icon' => 'zap', 'title' => 'Innovative Design', 'description' => 'Forward-thinking architectural solutions.'],
            ['icon' => 'shield', 'title' => 'Sustainable Execution', 'description' => 'Committed to environmental longevity.'],
            ['icon' => 'sparkles', 'title' => 'Urban Context', 'description' => 'Harmonizing spaces with civic identity.'],
        ];
        $sections[] = [
            'id' => 'sec_feat_' . Str::random(8),
            'component' => 'features',
            'variant' => 'grid_3col',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'title' => $features['title'] ?? 'Our Disciplines',
                'subtitle' => $features['subtitle'] ?? 'Holistic architecture engineered for human experience.',
                'items' => $featureItems,
            ],
            'styles' => ['background' => 'default'],
            'responsive' => [],
        ];

        // 3. About Section
        $about = $data['about'] ?? [];
        $sections[] = [
            'id' => 'sec_about_' . Str::random(8),
            'component' => 'about',
            'variant' => 'split_text',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'headline' => $about['headline'] ?? "About {$siteName}",
                'description' => $about['description'] ?? "We craft visionary buildings and urban spaces that balance functional pragmatism with striking architectural aesthetics.",
                'highlights' => $about['highlights'] ?? ['Sustainable design', 'Urban precision', 'Award-winning masterplanning'],
            ],
            'styles' => ['background' => 'surface'],
            'responsive' => [],
        ];

        // 4. Statistics Section
        $statistics = $data['statistics'] ?? [];
        $statItems = $statistics['items'] ?? [
            ['value' => '120+', 'label' => 'Projects Realized'],
            ['value' => '15', 'label' => 'Design Accolades'],
            ['value' => '100%', 'label' => 'Sustainable Standards'],
        ];
        $sections[] = [
            'id' => 'sec_stat_' . Str::random(8),
            'component' => 'statistics',
            'variant' => 'counters_3col',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'items' => $statItems,
            ],
            'styles' => ['background' => 'default'],
            'responsive' => [],
        ];

        // 5. Testimonials Section
        $testimonials = $data['testimonials'] ?? [];
        $testItems = $testimonials['items'] ?? [
            ['quote' => 'Apex Form Studio transformed our urban development vision into an iconic architectural reality.', 'author' => 'David Sterling', 'role' => 'Principal Developer'],
            ['quote' => 'Uncompromising precision, ecological awareness, and profound aesthetic judgment.', 'author' => 'Sarah Lin', 'role' => 'Civic Planning Director'],
        ];
        $sections[] = [
            'id' => 'sec_test_' . Str::random(8),
            'component' => 'testimonials',
            'variant' => 'cards_grid',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'title' => 'Client Endorsements',
                'subtitle' => 'Trusted by leading urban developers and private patrons worldwide.',
                'items' => $testItems,
            ],
            'styles' => ['background' => 'surface'],
            'responsive' => [],
        ];

        // 6. CTA Section
        $cta = $data['cta'] ?? [];
        $sections[] = [
            'id' => 'sec_cta_' . Str::random(8),
            'component' => 'cta',
            'variant' => 'centered',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'headline' => $cta['headline'] ?? 'Ready to shape the future of space?',
                'description' => $cta['description'] ?? 'Connect with our team to initiate your next project monograph.',
                'buttonText' => $cta['buttonText'] ?? 'Initiate Consultation',
                'buttonLink' => $cta['buttonLink'] ?? '#contact',
            ],
            'styles' => ['background' => 'surface'],
            'responsive' => [],
        ];

        // 7. Contact Section
        $contact = $data['contact'] ?? [];
        $sections[] = [
            'id' => 'sec_contact_' . Str::random(8),
            'component' => 'contact',
            'variant' => 'form_split',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'title' => $contact['title'] ?? 'Inquire With Our Studio',
                'description' => $contact['description'] ?? 'Discuss project feasibility or collaborate on urban research.',
            ],
            'styles' => ['background' => 'default'],
            'responsive' => [],
        ];

        // 8. Footer Section
        $sections[] = [
            'id' => 'sec_footer_' . Str::random(8),
            'component' => 'footer',
            'variant' => 'simple',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'copyright' => "© " . date('Y') . " {$siteName}. All rights reserved.",
                'links' => [
                    ['label' => 'Privacy', 'href' => '#'],
                    ['label' => 'Terms', 'href' => '#'],
                ],
            ],
            'styles' => ['background' => 'surface'],
            'responsive' => [],
        ];

        // SEO
        $seo = $data['seo'] ?? [];
        $seoTitle = $seo['title'] ?? "{$siteName} - Official Website";
        $seoDesc = $seo['description'] ?? ($data['tagline'] ?? "Discover {$siteName}. Quality, reliability, and excellence.");

        return [
            'schema_version' => 1,
            'site' => [
                'name' => $siteName,
                'theme' => $theme,
                'settings' => [
                    'language' => 'en',
                    'direction' => 'ltr',
                    'googleFonts' => [$theme['typography']['headingFamily'] ?? 'Inter', $theme['typography']['bodyFamily'] ?? 'Inter'],
                    'customCss' => null,
                ],
            ],
            'pages' => [
                [
                    'id' => 'page_home',
                    'slug' => '/',
                    'title' => 'Home',
                    'description' => "Welcome to {$siteName}",
                    'seo' => [
                        'title' => $seoTitle,
                        'description' => $seoDesc,
                        'ogImage' => $heroImage,
                        'noIndex' => false,
                    ],
                    'sections' => $sections,
                ],
            ],
            'navigation' => [
                'logo' => ['text' => $siteName],
                'items' => [
                    ['label' => 'Home', 'href' => '#', 'type' => 'link'],
                    ['label' => 'Disciplines', 'href' => '#features', 'type' => 'link'],
                    ['label' => 'About', 'href' => '#about', 'type' => 'link'],
                    ['label' => 'Consultation', 'href' => '#contact', 'type' => 'button'],
                ],
                'style' => 'transparent',
            ],
        ];
    }
}
