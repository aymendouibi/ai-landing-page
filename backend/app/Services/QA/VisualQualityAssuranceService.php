<?php

namespace App\Services\QA;

use App\Services\Documents\DocumentValidator;
use Exception;
use Illuminate\Support\Str;

class VisualQualityAssuranceService
{
    public function __construct(
        protected DocumentValidator $validator
    ) {}

    /**
     * Inspect a website document for visual, structural, contrast, and SEO quality issues.
     *
     * @param array $document
     * @param bool $autoFix Whether to automatically fix fixable issues
     * @return array
     */
    public function inspect(array $document, bool $autoFix = false): array
    {
        $issues = [];

        // 1. Contrast & Color Tokens Check
        $contrastIssues = $this->checkColorContrast($document);
        $issues = array_merge($issues, $contrastIssues);

        // 2. Structural & Section Completeness Check
        $structuralIssues = $this->checkSectionStructure($document);
        $issues = array_merge($issues, $structuralIssues);

        // 3. SEO & Metadata Check
        $seoIssues = $this->checkSeoMetadata($document);
        $issues = array_merge($issues, $seoIssues);

        // 4. Compute overall quality score (0 - 100)
        $errorsCount = count(array_filter($issues, fn($i) => $i['severity'] === 'error'));
        $warningsCount = count(array_filter($issues, fn($i) => $i['severity'] === 'warning'));
        $deductions = ($errorsCount * 20) + ($warningsCount * 5);
        $score = max(0, min(100, 100 - $deductions));

        $autoFixed = false;
        $fixedDocument = $document;

        if ($autoFix && !empty($issues)) {
            $fixedDocument = $this->applyAutoFixes($document, $issues);
            $autoFixed = true;
        }

        return [
            'passed' => $errorsCount === 0,
            'score' => $score,
            'issues_count' => count($issues),
            'errors_count' => $errorsCount,
            'warnings_count' => $warningsCount,
            'issues' => $issues,
            'auto_fixed' => $autoFixed,
            'document' => $fixedDocument,
        ];
    }

    /**
     * Check color contrast according to WCAG 2.1 AA standards (minimum 4.5:1 ratio).
     */
    protected function checkColorContrast(array $document): array
    {
        $issues = [];
        $theme = $document['site']['theme'] ?? [];
        $colors = $theme['colors'] ?? [];

        $primary = $colors['primary'] ?? '#0f172a';
        $background = $colors['background'] ?? '#ffffff';
        $surface = $colors['surface'] ?? '#f8fafc';
        
        $rawText = $colors['text'] ?? '#0f172a';
        $text = is_array($rawText) ? ($rawText['primary'] ?? '#0f172a') : $rawText;

        // Check text vs background
        $ratioTextBg = $this->calculateContrastRatio($text, $background);
        if ($ratioTextBg < 4.5) {
            $issues[] = [
                'type' => 'contrast',
                'severity' => 'error',
                'message' => "Insufficient contrast between text ({$text}) and background ({$background}): ratio {$ratioTextBg}:1 (WCAG AA requires >= 4.5:1).",
                'field' => 'site.theme.colors.text',
                'auto_fixable' => true,
            ];
        }

        // Check primary button vs surface / background
        $ratioPrimaryBg = $this->calculateContrastRatio($primary, $background);
        if ($ratioPrimaryBg < 3.0) {
            $issues[] = [
                'type' => 'contrast',
                'severity' => 'warning',
                'message' => "Low contrast for primary accent ({$primary}) on background ({$background}): ratio {$ratioPrimaryBg}:1 (recommended >= 3.0:1).",
                'field' => 'site.theme.colors.primary',
                'auto_fixable' => true,
            ];
        }

        return $issues;
    }

    /**
     * Check section contents for emptiness, missing headings, or incomplete components.
     */
    protected function checkSectionStructure(array $document): array
    {
        $issues = [];
        $pages = $document['pages'] ?? [];

        if (empty($pages)) {
            $issues[] = [
                'type' => 'structure',
                'severity' => 'error',
                'message' => 'Website contains no pages.',
                'auto_fixable' => false,
            ];
            return $issues;
        }

        foreach ($pages as $page) {
            $sections = $page['sections'] ?? [];

            if (empty($sections)) {
                $issues[] = [
                    'type' => 'empty_page',
                    'severity' => 'error',
                    'page_id' => $page['id'] ?? null,
                    'message' => "Page '{$page['title']}' has no sections.",
                    'auto_fixable' => false,
                ];
                continue;
            }

            $hasHero = false;
            foreach ($sections as $section) {
                $id = $section['id'] ?? 'unknown';
                $component = $section['component'] ?? '';
                $props = $section['props'] ?? [];

                if ($component === 'hero') {
                    $hasHero = true;
                    if (empty($props['headline']) || trim($props['headline']) === '') {
                        $issues[] = [
                            'type' => 'empty_heading',
                            'severity' => 'error',
                            'section_id' => $id,
                            'message' => 'Hero section has an empty headline.',
                            'auto_fixable' => true,
                        ];
                    }
                }

                if ($component === 'features') {
                    $items = $props['items'] ?? [];
                    if (empty($items)) {
                        $issues[] = [
                            'type' => 'empty_features',
                            'severity' => 'warning',
                            'section_id' => $id,
                            'message' => 'Features section has no feature items.',
                            'auto_fixable' => true,
                        ];
                    }
                }

                if ($component === 'cta') {
                    if (empty($props['headline']) || trim($props['headline']) === '') {
                        $issues[] = [
                            'type' => 'empty_cta',
                            'severity' => 'warning',
                            'section_id' => $id,
                            'message' => 'Call to action section is missing headline.',
                            'auto_fixable' => true,
                        ];
                    }
                }
            }

            if (!$hasHero && ($page['slug'] ?? '') === '/') {
                $issues[] = [
                    'type' => 'missing_hero',
                    'severity' => 'warning',
                    'page_id' => $page['id'],
                    'message' => 'Home page is missing a Hero banner section.',
                    'auto_fixable' => false,
                ];
            }
        }

        return $issues;
    }

    /**
     * Check SEO metadata completeness.
     */
    protected function checkSeoMetadata(array $document): array
    {
        $issues = [];
        $pages = $document['pages'] ?? [];

        foreach ($pages as $page) {
            $seo = $page['seo'] ?? [];
            $title = $seo['title'] ?? null;
            $description = $seo['description'] ?? null;

            if (empty($title) || trim($title) === '') {
                $issues[] = [
                    'type' => 'seo_title',
                    'severity' => 'warning',
                    'page_id' => $page['id'] ?? null,
                    'message' => "Page '{$page['title']}' is missing an SEO title.",
                    'auto_fixable' => true,
                ];
            }

            if (empty($description) || trim($description) === '') {
                $issues[] = [
                    'type' => 'seo_description',
                    'severity' => 'warning',
                    'page_id' => $page['id'] ?? null,
                    'message' => "Page '{$page['title']}' is missing an SEO meta description.",
                    'auto_fixable' => true,
                ];
            }
        }

        return $issues;
    }

    /**
     * Automatically repair fixable quality defects.
     */
    protected function applyAutoFixes(array $document, array $issues): array
    {
        $fixed = $document;
        $siteName = $document['site']['name'] ?? 'Modern Site';

        foreach ($issues as $issue) {
            if (empty($issue['auto_fixable'])) continue;

            $type = $issue['type'];

            if ($type === 'contrast') {
                // Ensure text is dark and legible if on light background, or vice versa
                $bg = $fixed['site']['theme']['colors']['background'] ?? '#ffffff';
                $isLightBg = $this->calculateRelativeLuminance($bg) > 0.5;

                if (($issue['field'] ?? '') === 'site.theme.colors.text') {
                    $newHex = $isLightBg ? '#0f172a' : '#f8fafc';
                    if (is_array($fixed['site']['theme']['colors']['text'] ?? null)) {
                        $fixed['site']['theme']['colors']['text']['primary'] = $newHex;
                    } else {
                        $fixed['site']['theme']['colors']['text'] = $newHex;
                    }
                }

                if (($issue['field'] ?? '') === 'site.theme.colors.primary') {
                    $fixed['site']['theme']['colors']['primary'] = $isLightBg ? '#2563eb' : '#60a5fa';
                }
            }

            if ($type === 'empty_heading') {
                $sectionId = $issue['section_id'] ?? null;
                foreach ($fixed['pages'] as &$page) {
                    foreach ($page['sections'] as &$section) {
                        if (($section['id'] ?? '') === $sectionId) {
                            $section['props']['headline'] = "Welcome to {$siteName}";
                            if (empty($section['props']['subheadline'])) {
                                $section['props']['subheadline'] = 'Discover our premier services and solutions.';
                            }
                        }
                    }
                }
            }

            if ($type === 'empty_features') {
                $sectionId = $issue['section_id'] ?? null;
                foreach ($fixed['pages'] as &$page) {
                    foreach ($page['sections'] as &$section) {
                        if (($section['id'] ?? '') === $sectionId) {
                            $section['props']['items'] = [
                                ['icon' => 'zap', 'title' => 'High Performance', 'description' => 'Engineered for speed and efficiency.'],
                                ['icon' => 'shield', 'title' => 'Enterprise Security', 'description' => 'Bank-grade safety and reliability.'],
                                ['icon' => 'sparkles', 'title' => 'Smart Experience', 'description' => 'Modern aesthetics with effortless usability.'],
                            ];
                        }
                    }
                }
            }

            if ($type === 'empty_cta') {
                $sectionId = $issue['section_id'] ?? null;
                foreach ($fixed['pages'] as &$page) {
                    foreach ($page['sections'] as &$section) {
                        if (($section['id'] ?? '') === $sectionId) {
                            $section['props']['headline'] = 'Ready to elevate your experience?';
                            $section['props']['buttonText'] = 'Get Started Today';
                        }
                    }
                }
            }

            if ($type === 'seo_title' || $type === 'seo_description') {
                $pageId = $issue['page_id'] ?? null;
                foreach ($fixed['pages'] as &$page) {
                    if (($page['id'] ?? '') === $pageId) {
                        if (empty($page['seo']['title'])) {
                            $page['seo']['title'] = "{$page['title']} | {$siteName}";
                        }
                        if (empty($page['seo']['description'])) {
                            $page['seo']['description'] = "Welcome to {$page['title']} on {$siteName}. Discover professional excellence.";
                        }
                    }
                }
            }
        }

        // Validate that auto-fixed document complies with schema
        $this->validator->validate($fixed);

        return $fixed;
    }

    /**
     * Compute WCAG 2.1 contrast ratio between two hex colors.
     */
    public function calculateContrastRatio(string $hex1, string $hex2): float
    {
        $lum1 = $this->calculateRelativeLuminance($hex1);
        $lum2 = $this->calculateRelativeLuminance($hex2);

        $lighter = max($lum1, $lum2);
        $darker = min($lum1, $lum2);

        $ratio = ($lighter + 0.05) / ($darker + 0.05);

        return round($ratio, 2);
    }

    /**
     * Calculate relative luminance according to WCAG 2.1 formula.
     */
    public function calculateRelativeLuminance(string $hex): float
    {
        $hex = ltrim($hex, '#');

        if (strlen($hex) === 3) {
            $hex = $hex[0] . $hex[0] . $hex[1] . $hex[1] . $hex[2] . $hex[2];
        }

        if (strlen($hex) !== 6) {
            return 0.5; // fallback neutral
        }

        $r = hexdec(substr($hex, 0, 2)) / 255;
        $g = hexdec(substr($hex, 2, 2)) / 255;
        $b = hexdec(substr($hex, 4, 2)) / 255;

        $rLum = ($r <= 0.04045) ? $r / 12.92 : pow(($r + 0.055) / 1.055, 2.4);
        $gLum = ($g <= 0.04045) ? $g / 12.92 : pow(($g + 0.055) / 1.055, 2.4);
        $bLum = ($b <= 0.04045) ? $b / 12.92 : pow(($b + 0.055) / 1.055, 2.4);

        return (0.2126 * $rLum) + (0.7152 * $gLum) + (0.0722 * $bLum);
    }
}
