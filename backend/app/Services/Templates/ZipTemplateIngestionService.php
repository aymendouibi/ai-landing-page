<?php

namespace App\Services\Templates;

use App\Enums\TemplateStatus;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use App\Services\Documents\DefaultDocumentFactory;
use App\Services\Documents\DocumentValidator;
use DOMDocument;
use DOMXPath;
use Exception;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use ZipArchive;

class ZipTemplateIngestionService
{
    public function __construct(
        protected DocumentValidator $validator
    ) {}

    /**
     * Safely ingest and convert a ZIP archive of an authorized website into a native Template.
     *
     * @param UploadedFile $zipFile
     * @param string $templateName
     * @param string|null $categoryId
     * @param string|null $author
     * @return Template
     * @throws Exception
     */
    public function ingest(
        UploadedFile $zipFile,
        string $templateName,
        ?string $categoryId = null,
        ?string $author = null
    ): Template {
        $tempDir = storage_path('app/temp_ingest/' . Str::uuid());
        File::makeDirectory($tempDir, 0755, true);

        try {
            $zip = new ZipArchive();
            if ($zip->open($zipFile->getRealPath()) !== true) {
                throw new Exception('Failed to open uploaded ZIP file.');
            }

            // Safe extraction: prevent Zip Slip (path traversal) vulnerability
            for ($i = 0; $i < $zip->numFiles; $i++) {
                $filename = $zip->getNameIndex($i);

                // Disallow paths with '..' or absolute paths
                if (str_contains($filename, '..') || str_starts_with($filename, '/') || str_starts_with($filename, '\\')) {
                    throw new Exception("ZIP archive contains unsafe entry: {$filename}");
                }
            }

            $zip->extractTo($tempDir);
            $zip->close();

            // Find index.html or main html file
            $htmlFile = $this->findMainHtmlFile($tempDir);
            if (!$htmlFile) {
                throw new Exception('No index.html or primary HTML file found in ZIP archive.');
            }

            $htmlContent = File::get($htmlFile);

            // Reconstruct WebsiteDocument from HTML
            $document = $this->convertHtmlToDocument($htmlContent, $templateName);

            // Validate against schema
            $this->validator->validate($document);

            // Create template record in "review" status
            $category = $categoryId ? TemplateCategory::find($categoryId) : TemplateCategory::first();

            $slug = Str::slug($templateName) . '-' . Str::random(5);
            $template = Template::create([
                'category_id' => $category?->id,
                'name' => $templateName,
                'slug' => $slug,
                'description' => "Ingested template from source package: {$templateName}",
                'industry' => 'General',
                'status' => TemplateStatus::Review, // Needs administrative review before published
                'license_type' => 'user_submitted',
                'author' => $author ?? 'Package Importer',
            ]);

            TemplateVersion::create([
                'template_id' => $template->id,
                'version' => 1,
                'document' => $document,
                'design_tokens' => $document['site']['theme'],
                'is_active' => true,
            ]);

            return $template->fresh(['category', 'activeVersion']);
        } finally {
            // Clean up temporary extracted directory safely
            File::deleteDirectory($tempDir);
        }
    }

    protected function findMainHtmlFile(string $dir): ?string
    {
        $directIndex = $dir . '/index.html';
        if (File::exists($directIndex)) return $directIndex;

        $files = File::allFiles($dir);
        foreach ($files as $file) {
            if (strtolower($file->getFilename()) === 'index.html') {
                return $file->getRealPath();
            }
        }

        foreach ($files as $file) {
            if ($file->getExtension() === 'html' || $file->getExtension() === 'htm') {
                return $file->getRealPath();
            }
        }

        return null;
    }

    /**
     * Parse HTML DOM and reconstruct native sections.
     */
    protected function convertHtmlToDocument(string $html, string $siteName): array
    {
        $doc = new DOMDocument();
        // Suppress warnings from HTML5 elements
        @$doc->loadHTML(mb_convert_encoding($html, 'HTML-ENTITIES', 'UTF-8'), LIBXML_NOERROR | LIBXML_NOWARNING);
        $xpath = new DOMXPath($doc);

        $sections = [];
        $order = 0;

        // 1. Extract Hero
        $h1Node = $xpath->query('//h1')->item(0);
        $headline = $h1Node ? trim($h1Node->textContent) : "Welcome to {$siteName}";

        $leadNode = $xpath->query('//p[contains(@class, "lead") or contains(@class, "subtitle") or contains(@class, "description")]')->item(0);
        $subheadline = $leadNode ? trim($leadNode->textContent) : null;

        $sections[] = [
            'id' => 'sec_hero_' . Str::random(8),
            'component' => 'hero',
            'variant' => 'centered',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'headline' => $headline,
                'subheadline' => $subheadline ?? 'Crafted with elegance and purpose.',
                'ctaText' => 'Get Started',
                'ctaLink' => '#contact',
            ],
            'styles' => ['background' => 'surface'],
            'responsive' => [],
        ];

        // 2. Extract Features / Grid
        $h2Nodes = $xpath->query('//h2');
        $featureItems = [];
        foreach ($h2Nodes as $i => $h2) {
            if ($i > 0 && $i <= 3) {
                $featureItems[] = [
                    'icon' => 'sparkles',
                    'title' => trim($h2->textContent),
                    'description' => 'Designed with performance and clarity in mind.',
                ];
            }
        }

        if (empty($featureItems)) {
            $featureItems = [
                ['icon' => 'zap', 'title' => 'Fast Performance', 'description' => 'Speed and responsiveness optimized.'],
                ['icon' => 'shield', 'title' => 'Reliable & Secure', 'description' => 'Rock-solid execution.'],
                ['icon' => 'sparkles', 'title' => 'Refined Aesthetics', 'description' => 'Clean typography and balance.'],
            ];
        }

        $sections[] = [
            'id' => 'sec_features_' . Str::random(8),
            'component' => 'features',
            'variant' => 'grid_3col',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'title' => 'Features & Capabilities',
                'subtitle' => 'Everything engineered for peak effectiveness.',
                'items' => $featureItems,
            ],
            'styles' => ['background' => 'default'],
            'responsive' => [],
        ];

        // 3. CTA
        $sections[] = [
            'id' => 'sec_cta_' . Str::random(8),
            'component' => 'cta',
            'variant' => 'centered',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'headline' => 'Experience the difference today',
                'description' => 'Connect with our team or get started immediately.',
                'buttonText' => 'Contact Us',
                'buttonLink' => '#contact',
            ],
            'styles' => ['background' => 'surface'],
            'responsive' => [],
        ];

        // 4. Contact
        $sections[] = [
            'id' => 'sec_contact_' . Str::random(8),
            'component' => 'contact',
            'variant' => 'form_split',
            'order' => $order++,
            'visible' => true,
            'props' => [
                'title' => 'Get in Touch',
                'description' => 'Send us a message and we will respond promptly.',
            ],
            'styles' => ['background' => 'default'],
            'responsive' => [],
        ];

        // 5. Footer
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

        $base = DefaultDocumentFactory::createDefault($siteName);
        $base['pages'][0]['sections'] = $sections;

        return $base;
    }
}

