<?php

namespace App\Services\Documents;

use App\Exceptions\InvalidDocumentException;

class DocumentValidator
{
    /**
     * Supported standard component types.
     *
     * @var array<string>
     */
    public const SUPPORTED_COMPONENTS = [
        'navigation',
        'hero',
        'features',
        'benefits',
        'products',
        'gallery',
        'galleries',
        'video',
        'story',
        'about',
        'statistics',
        'testimonials',
        'reviews',
        'pricing',
        'comparison',
        'team',
        'faq',
        'contact',
        'visit',
        'forms',
        'newsletter',
        'text',
        'cta',
        'footer',
        'image',
    ];

    /**
     * Validate the given document structure.
     *
     * @param array<string, mixed> $document
     * @throws InvalidDocumentException
     */
    public function validate(array $document): void
    {
        $errors = [];

        // 1. Root structure
        if (!isset($document['schema_version']) || !is_int($document['schema_version']) || $document['schema_version'] < 1) {
            $errors[] = 'Root "schema_version" must be an integer >= 1.';
        }

        if (!isset($document['site']) || !is_array($document['site'])) {
            $errors[] = 'Root "site" object is required.';
        } else {
            $this->validateSite($document['site'], $errors);
        }

        if (!isset($document['pages']) || !is_array($document['pages']) || empty($document['pages'])) {
            $errors[] = 'Root "pages" array must be non-empty.';
        } else {
            $this->validatePages($document['pages'], $errors);
        }

        // Optional navigation validation
        if (isset($document['navigation']) && !is_array($document['navigation'])) {
            $errors[] = '"navigation" must be an object/array if provided.';
        }

        if (!empty($errors)) {
            throw new InvalidDocumentException($errors);
        }
    }

    /**
     * Validate the site settings and theme.
     *
     * @param array<string, mixed> $site
     * @param array<string> $errors
     */
    protected function validateSite(array $site, array &$errors): void
    {
        if (empty($site['name']) || !is_string($site['name'])) {
            $errors[] = 'Site "name" is required and must be a string.';
        }

        if (!isset($site['theme']) || !is_array($site['theme'])) {
            $errors[] = 'Site "theme" must be an object.';
        } else {
            $theme = $site['theme'];
            if (isset($theme['colors']) && !is_array($theme['colors'])) {
                $errors[] = 'Theme "colors" must be an object.';
            }
            if (isset($theme['typography']) && !is_array($theme['typography'])) {
                $errors[] = 'Theme "typography" must be an object.';
            }
        }
    }

    /**
     * Validate all pages and ensure stable unique IDs.
     *
     * @param array<mixed> $pages
     * @param array<string> $errors
     */
    protected function validatePages(array $pages, array &$errors): void
    {
        $pageIds = [];
        $pageSlugs = [];
        $allSectionIds = [];

        foreach ($pages as $index => $page) {
            if (!is_array($page)) {
                $errors[] = "Page at index {$index} must be an object.";
                continue;
            }

            // Page ID
            if (empty($page['id']) || !is_string($page['id'])) {
                $errors[] = "Page at index {$index} must have a non-empty string \"id\".";
            } else {
                if (in_array($page['id'], $pageIds, true)) {
                    $errors[] = "Duplicate page ID \"{$page['id']}\" detected.";
                }
                $pageIds[] = $page['id'];
            }

            // Page Slug
            if (!isset($page['slug']) || !is_string($page['slug']) || !str_starts_with($page['slug'], '/')) {
                $errors[] = "Page at index {$index} must have a valid \"slug\" starting with \"/\".";
            } else {
                if (in_array($page['slug'], $pageSlugs, true)) {
                    $errors[] = "Duplicate page slug \"{$page['slug']}\" detected.";
                }
                $pageSlugs[] = $page['slug'];
            }

            // Page Title
            if (empty($page['title']) || !is_string($page['title'])) {
                $errors[] = "Page at index {$index} must have a non-empty string \"title\".";
            }

            // Sections
            if (!isset($page['sections']) || !is_array($page['sections'])) {
                $errors[] = "Page at index {$index} must have a \"sections\" array.";
            } else {
                $this->validateSections($page['sections'], $page['id'] ?? "page_{$index}", $allSectionIds, $errors);
            }
        }
    }

    /**
     * Validate sections in a page.
     *
     * @param array<mixed> $sections
     * @param string $pageId
     * @param array<string> $allSectionIds
     * @param array<string> $errors
     */
    protected function validateSections(array $sections, string $pageId, array &$allSectionIds, array &$errors): void
    {
        foreach ($sections as $sIndex => $section) {
            if (!is_array($section)) {
                $errors[] = "Section at index {$sIndex} in page \"{$pageId}\" must be an object.";
                continue;
            }

            // Section ID
            if (empty($section['id']) || !is_string($section['id'])) {
                $errors[] = "Section at index {$sIndex} in page \"{$pageId}\" must have a string \"id\".";
            } else {
                if (in_array($section['id'], $allSectionIds, true)) {
                    $errors[] = "Duplicate section ID \"{$section['id']}\" detected across document.";
                }
                $allSectionIds[] = $section['id'];
            }

            // Component Type
            if (empty($section['component']) || !is_string($section['component'])) {
                $errors[] = "Section at index {$sIndex} in page \"{$pageId}\" must define a \"component\" string.";
            } elseif (!in_array($section['component'], self::SUPPORTED_COMPONENTS, true)) {
                $errors[] = "Section component \"{$section['component']}\" is not supported.";
            }

            // Variant (optional, must be string if provided)
            if (isset($section['variant']) && !is_string($section['variant'])) {
                $errors[] = "Section at index {$sIndex} in page \"{$pageId}\" must define a string \"variant\".";
            }

            // Props
            if (!isset($section['props']) || !is_array($section['props'])) {
                $errors[] = "Section at index {$sIndex} in page \"{$pageId}\" must have a \"props\" object.";
            }
        }
    }
}

