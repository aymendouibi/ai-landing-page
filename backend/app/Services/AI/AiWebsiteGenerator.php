<?php

namespace App\Services\AI;

use App\Models\DesignRecipe;
use App\Services\AI\Prompts\BusinessAnalysisPrompt;
use App\Services\AI\Prompts\ContentGenerationPrompt;
use App\Services\AI\Prompts\DesignBriefPrompt;
use App\Services\AI\Prompts\PromptHelper;
use App\Services\AI\Prompts\WebsitePlanPrompt;
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
        'default' => 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
    ];

    /**
     * Run the staged AI generation pipeline.
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
        $totalTokens = 0;
        $primaryModel = $this->modelSelector->getModelForTask('document_generation');

        $reportProgress = function (int $percent, string $msg) use ($progressCallback) {
            if ($progressCallback) {
                $progressCallback($percent, $msg);
            }
        };

        // STAGE 1: Understand the business
        $reportProgress(15, 'Analyzing business & audience...');
        $stage1Res = $this->client->chatCompletion(
            messages: BusinessAnalysisPrompt::build($userPrompt),
            preferredModel: $this->modelSelector->getModelForTask('business_analysis'),
            jsonMode: true
        );
        $totalTokens += $stage1Res['tokens_input'] + $stage1Res['tokens_output'];
        $businessInfo = PromptHelper::extractJson($stage1Res['content']);

        $industry = strtolower($preferredIndustry ?? $businessInfo['industry'] ?? 'general');
        $siteName = $businessInfo['business_name'] ?? 'My Business';

        // STAGE 2: Design brief & recipe matching
        $reportProgress(35, 'Selecting design tokens & typography...');
        $recipe = DesignRecipe::findByIndustry($industry)?->theme;

        $stage2Res = $this->client->chatCompletion(
            messages: DesignBriefPrompt::build($businessInfo, $recipe),
            preferredModel: $this->modelSelector->getModelForTask('design_planning'),
            jsonMode: true
        );
        $totalTokens += $stage2Res['tokens_input'] + $stage2Res['tokens_output'];
        $designBrief = PromptHelper::extractJson($stage2Res['content']);

        // STAGE 3: Architecture & section planning
        $reportProgress(55, 'Planning conversion architecture...');
        $stage3Res = $this->client->chatCompletion(
            messages: WebsitePlanPrompt::build($businessInfo),
            preferredModel: $this->modelSelector->getModelForTask('website_planning'),
            jsonMode: true
        );
        $totalTokens += $stage3Res['tokens_input'] + $stage3Res['tokens_output'];
        $plan = PromptHelper::extractJson($stage3Res['content']);

        // STAGE 4: Copywriting & Content generation
        $reportProgress(75, 'Crafting professional copy & benefits...');
        $stage4Res = $this->client->chatCompletion(
            messages: ContentGenerationPrompt::build($businessInfo, $plan),
            preferredModel: $this->modelSelector->getModelForTask('content_generation'),
            jsonMode: true
        );
        $totalTokens += $stage4Res['tokens_input'] + $stage4Res['tokens_output'];
        $content = PromptHelper::extractJson($stage4Res['content']);

        // STAGE 5: Document Assembly & Media Mapping
        $reportProgress(90, 'Assembling structured website document...');
        $document = $this->assembleDocument($siteName, $industry, $designBrief, $plan, $content);

        // STAGE 6: Quality Assurance & Validation
        $this->validator->validate($document);
        $reportProgress(100, 'Website ready!');

        return [
            'document' => $document,
            'tokens_used' => $totalTokens,
            'model_used' => $primaryModel,
            'business_analysis' => $businessInfo,
        ];
    }

    /**
     * Assemble all generated pieces into the formal platform document.
     */
    protected function assembleDocument(
        string $siteName,
        string $industry,
        array $designBrief,
        array $plan,
        array $content
    ): array {
        $defaultBase = DefaultDocumentFactory::createDefault($siteName);

        // Theme integration
        $theme = $designBrief['theme'] ?? $defaultBase['site']['theme'];

        // Hero image selection
        $heroImage = self::INDUSTRY_HERO_IMAGES[$industry] ?? self::INDUSTRY_HERO_IMAGES['default'];

        // Navigation
        $navItems = $plan['navigation_items'] ?? $defaultBase['navigation']['items'];

        // Build Sections
        $sections = [];
        $plannedSections = $plan['sections'] ?? [];
        $sectionsContent = $content['sections_content'] ?? [];

        // Index content by component
        $contentByComp = [];
        foreach ($sectionsContent as $sc) {
            if (isset($sc['component'])) {
                $contentByComp[$sc['component']] = $sc['props'] ?? [];
            }
        }

        $order = 0;
        foreach ($plannedSections as $pSec) {
            $component = $pSec['component'] ?? 'features';
            if (!in_array($component, DocumentValidator::SUPPORTED_COMPONENTS, true)) {
                continue; // Skip invalid components
            }

            $props = $contentByComp[$component] ?? [];

            // Add hero image if hero section
            if ($component === 'hero' && !isset($props['image'])) {
                $props['image'] = ['src' => $heroImage, 'alt' => $siteName];
            }

            $sections[] = [
                'id' => 'sec_' . substr($component, 0, 4) . '_' . Str::random(6),
                'component' => $component,
                'variant' => $pSec['variant'] ?? 'centered',
                'order' => $order++,
                'visible' => true,
                'props' => $props,
                'styles' => [
                    'background' => $pSec['background'] ?? 'default',
                ],
                'responsive' => [],
            ];
        }

        // Ensure at least hero and footer exist if AI produced an empty section list
        if (empty($sections)) {
            $sections = $defaultBase['pages'][0]['sections'];
        }

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
                        'title' => "{$siteName} - Official Website",
                        'description' => "Discover {$siteName}. Quality, reliability, and excellence.",
                        'ogImage' => $heroImage,
                        'noIndex' => false,
                    ],
                    'sections' => $sections,
                ],
            ],
            'navigation' => [
                'logo' => ['text' => $siteName],
                'items' => $navItems,
                'style' => 'transparent',
            ],
        ];
    }
}
