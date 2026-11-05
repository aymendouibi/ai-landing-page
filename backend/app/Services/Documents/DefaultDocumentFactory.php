<?php

namespace App\Services\Documents;

use Illuminate\Support\Str;

class DefaultDocumentFactory
{
    /**
     * Create a standard default website document.
     *
     * @param string $siteName
     * @param array<string, mixed> $customTheme
     * @return array<string, mixed>
     */
    public static function createDefault(string $siteName = 'My Website', array $customTheme = []): array
    {
        $heroId = 'sec_hero_' . Str::random(8);
        $featuresId = 'sec_feat_' . Str::random(8);
        $ctaId = 'sec_cta_' . Str::random(8);
        $footerId = 'sec_foot_' . Str::random(8);

        return [
            'schema_version' => 1,
            'site' => [
                'name' => $siteName,
                'theme' => array_replace_recursive([
                    'colors' => [
                        'primary' => '#2563EB',
                        'secondary' => '#7C3AED',
                        'accent' => '#F59E0B',
                        'background' => '#FFFFFF',
                        'surface' => '#F8FAFC',
                        'text' => [
                            'primary' => '#0F172A',
                            'secondary' => '#475569',
                            'inverse' => '#FFFFFF',
                        ],
                    ],
                    'typography' => [
                        'headingFamily' => 'Inter',
                        'bodyFamily' => 'Inter',
                        'scale' => [
                            'h1' => ['size' => '3.5rem', 'weight' => 700, 'lineHeight' => 1.1],
                            'h2' => ['size' => '2.25rem', 'weight' => 700, 'lineHeight' => 1.2],
                            'h3' => ['size' => '1.5rem', 'weight' => 600, 'lineHeight' => 1.3],
                            'body' => ['size' => '1rem', 'weight' => 400, 'lineHeight' => 1.6],
                            'small' => ['size' => '0.875rem', 'weight' => 400, 'lineHeight' => 1.5],
                        ],
                    ],
                    'spacing' => [
                        'sectionPadding' => ['x' => '1.5rem', 'y' => '5rem'],
                        'containerMaxWidth' => '1200px',
                        'borderRadius' => [
                            'small' => '0.375rem',
                            'medium' => '0.75rem',
                            'large' => '1rem',
                            'full' => '9999px',
                        ],
                    ],
                    'buttons' => [
                        'primary' => ['bg' => 'primary', 'text' => 'inverse', 'radius' => 'medium', 'padding' => '0.75rem 1.5rem'],
                        'secondary' => ['bg' => 'transparent', 'text' => 'primary', 'border' => 'primary', 'radius' => 'medium'],
                    ],
                ], $customTheme),
                'settings' => [
                    'language' => 'en',
                    'direction' => 'ltr',
                    'googleFonts' => ['Inter'],
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
                        'title' => "{$siteName} - Welcome",
                        'description' => "Official website for {$siteName}",
                        'ogImage' => null,
                        'noIndex' => false,
                    ],
                    'sections' => [
                        [
                            'id' => $heroId,
                            'component' => 'hero',
                            'variant' => 'centered',
                            'order' => 0,
                            'visible' => true,
                            'props' => [
                                'headline' => "Welcome to {$siteName}",
                                'subheadline' => 'Designed with elegance and built for high conversion.',
                                'ctaText' => 'Get Started',
                                'ctaLink' => '#features',
                                'secondaryCtaText' => 'Learn More',
                                'secondaryCtaLink' => '#about',
                            ],
                            'styles' => [
                                'background' => 'surface',
                                'textAlign' => 'center',
                            ],
                            'responsive' => [],
                        ],
                        [
                            'id' => $featuresId,
                            'component' => 'features',
                            'variant' => 'grid_3col',
                            'order' => 1,
                            'visible' => true,
                            'props' => [
                                'title' => 'Core Capabilities',
                                'subtitle' => 'Everything you need to grow your digital presence',
                                'items' => [
                                    ['icon' => 'zap', 'title' => 'Lightning Fast', 'description' => 'Optimized for peak performance on all modern mobile and desktop screens.'],
                                    ['icon' => 'shield', 'title' => 'Secure by Default', 'description' => 'Built with rigorous enterprise-grade security and isolated execution.'],
                                    ['icon' => 'sparkles', 'title' => 'AI Assisted', 'description' => 'Intelligent workflow and seamless content generation at your fingertips.'],
                                ],
                            ],
                            'styles' => [
                                'background' => 'background',
                            ],
                            'responsive' => [],
                        ],
                        [
                            'id' => $ctaId,
                            'component' => 'cta',
                            'variant' => 'centered',
                            'order' => 2,
                            'visible' => true,
                            'props' => [
                                'headline' => 'Ready to build your digital future?',
                                'description' => 'Get started today and experience the difference.',
                                'buttonText' => 'Contact Us',
                                'buttonLink' => '#contact',
                            ],
                            'styles' => [
                                'background' => 'surface',
                            ],
                            'responsive' => [],
                        ],
                        [
                            'id' => $footerId,
                            'component' => 'footer',
                            'variant' => 'simple',
                            'order' => 3,
                            'visible' => true,
                            'props' => [
                                'copyright' => "© " . date('Y') . " {$siteName}. All rights reserved.",
                                'links' => [
                                    ['label' => 'Privacy Policy', 'href' => '#privacy'],
                                    ['label' => 'Terms of Service', 'href' => '#terms'],
                                ],
                            ],
                            'styles' => [
                                'background' => 'background',
                            ],
                            'responsive' => [],
                        ],
                    ],
                ],
            ],
            'navigation' => [
                'logo' => ['text' => $siteName],
                'items' => [
                    ['label' => 'Home', 'href' => '/', 'type' => 'link'],
                    ['label' => 'Features', 'href' => '#features', 'type' => 'link'],
                    ['label' => 'Contact', 'href' => '#contact', 'type' => 'button'],
                ],
                'style' => 'transparent',
            ],
        ];
    }
}
