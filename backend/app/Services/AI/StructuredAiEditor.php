<?php

namespace App\Services\AI;

use App\Enums\RevisionSource;
use App\Models\User;
use App\Models\Website;
use App\Services\Documents\DocumentValidator;
use App\Services\Documents\WebsiteDocumentService;
use Exception;
use Illuminate\Support\Str;

class StructuredAiEditor
{
    public function __construct(
        protected WebsiteDocumentService $documentService,
        protected DocumentValidator $validator
    ) {}

    /**
     * Apply a list of structured operations atomically to a website.
     *
     * @param Website $website
     * @param array<array<string, mixed>> $operations
     * @param string|null $summary
     * @param User|null $author
     * @return Website
     * @throws Exception
     */
    public function applyOperations(
        Website $website,
        array $operations,
        ?string $summary = null,
        ?User $author = null
    ): Website {
        $doc = $website->document;

        foreach ($operations as $op) {
            $type = $op['type'] ?? '';
            $doc = match ($type) {
                'update_component' => $this->applyUpdateComponent($doc, $op),
                'add_component' => $this->applyAddComponent($doc, $op),
                'remove_component' => $this->applyRemoveComponent($doc, $op),
                'move_component' => $this->applyMoveComponent($doc, $op),
                'duplicate_component' => $this->applyDuplicateComponent($doc, $op),
                'update_design_token' => $this->applyUpdateDesignToken($doc, $op),
                'update_seo' => $this->applyUpdateSeo($doc, $op),
                default => throw new Exception("Unsupported AI operation type: {$type}"),
            };
        }

        // Validate final document structure
        $this->validator->validate($doc);

        return $this->documentService->updateDocument(
            website: $website,
            newDocument: $doc,
            expectedRevisionNumber: $website->revision_number,
            source: RevisionSource::AiEdit,
            description: $summary ?? 'AI Structured Edit applied',
            author: $author
        );
    }

    protected function applyUpdateComponent(array $doc, array $op): array
    {
        $sectionId = $op['section_id'] ?? throw new Exception('update_component requires section_id');

        foreach ($doc['pages'] as &$page) {
            foreach ($page['sections'] as &$sec) {
                if (($sec['id'] ?? '') === $sectionId) {
                    if (isset($op['props']) && is_array($op['props'])) {
                        $sec['props'] = array_merge($sec['props'] ?? [], $op['props']);
                    }
                    if (isset($op['styles']) && is_array($op['styles'])) {
                        $sec['styles'] = array_merge($sec['styles'] ?? [], $op['styles']);
                    }
                    if (isset($op['variant']) && is_string($op['variant'])) {
                        $sec['variant'] = $op['variant'];
                    }
                    return $doc;
                }
            }
        }

        throw new Exception("Section ID '{$sectionId}' not found in document.");
    }

    protected function applyAddComponent(array $doc, array $op): array
    {
        $pageId = $op['page_id'] ?? $doc['pages'][0]['id'];
        $newSec = $op['section'] ?? throw new Exception('add_component requires section');

        if (empty($newSec['id'])) {
            $newSec['id'] = 'sec_' . Str::random(8);
        }

        foreach ($doc['pages'] as &$page) {
            if ($page['id'] === $pageId) {
                $order = $op['order'] ?? count($page['sections']);
                $newSec['order'] = $order;
                $page['sections'][] = $newSec;
                // Re-sort orders
                usort($page['sections'], fn ($a, $b) => ($a['order'] ?? 0) <=> ($b['order'] ?? 0));
                return $doc;
            }
        }

        throw new Exception("Page ID '{$pageId}' not found.");
    }

    protected function applyRemoveComponent(array $doc, array $op): array
    {
        $sectionId = $op['section_id'] ?? throw new Exception('remove_component requires section_id');

        foreach ($doc['pages'] as &$page) {
            $initialCount = count($page['sections']);
            $page['sections'] = array_values(array_filter(
                $page['sections'],
                fn ($sec) => ($sec['id'] ?? '') !== $sectionId
            ));

            if (count($page['sections']) < $initialCount) {
                return $doc;
            }
        }

        throw new Exception("Section ID '{$sectionId}' not found for removal.");
    }

    protected function applyMoveComponent(array $doc, array $op): array
    {
        $sectionId = $op['section_id'] ?? throw new Exception('move_component requires section_id');
        $newOrder = (int) ($op['new_order'] ?? 0);

        foreach ($doc['pages'] as &$page) {
            foreach ($page['sections'] as &$sec) {
                if (($sec['id'] ?? '') === $sectionId) {
                    $sec['order'] = $newOrder;
                    usort($page['sections'], fn ($a, $b) => ($a['order'] ?? 0) <=> ($b['order'] ?? 0));
                    return $doc;
                }
            }
        }

        throw new Exception("Section ID '{$sectionId}' not found to move.");
    }

    protected function applyDuplicateComponent(array $doc, array $op): array
    {
        $sectionId = $op['section_id'] ?? throw new Exception('duplicate_component requires section_id');

        foreach ($doc['pages'] as &$page) {
            foreach ($page['sections'] as $idx => $sec) {
                if (($sec['id'] ?? '') === $sectionId) {
                    $dup = $sec;
                    $dup['id'] = 'sec_' . Str::random(8);
                    $dup['order'] = ($sec['order'] ?? 0) + 1;
                    array_splice($page['sections'], $idx + 1, 0, [$dup]);
                    return $doc;
                }
            }
        }

        throw new Exception("Section ID '{$sectionId}' not found to duplicate.");
    }

    protected function applyUpdateDesignToken(array $doc, array $op): array
    {
        $path = $op['path'] ?? throw new Exception('update_design_token requires path');
        $value = $op['value'] ?? throw new Exception('update_design_token requires value');

        // e.g. path = "colors.primary"
        $keys = explode('.', $path);
        $target = &$doc['site']['theme'];

        foreach ($keys as $i => $key) {
            if ($i === count($keys) - 1) {
                $target[$key] = $value;
            } else {
                if (!isset($target[$key]) || !is_array($target[$key])) {
                    $target[$key] = [];
                }
                $target = &$target[$key];
            }
        }

        return $doc;
    }

    protected function applyUpdateSeo(array $doc, array $op): array
    {
        $pageId = $op['page_id'] ?? $doc['pages'][0]['id'];
        $seo = $op['seo'] ?? [];

        foreach ($doc['pages'] as &$page) {
            if ($page['id'] === $pageId) {
                $page['seo'] = array_merge($page['seo'] ?? [], $seo);
                return $doc;
            }
        }

        return $doc;
    }
}
