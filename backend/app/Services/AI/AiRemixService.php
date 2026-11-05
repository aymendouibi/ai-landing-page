<?php

namespace App\Services\AI;

use App\Enums\RevisionSource;
use App\Models\Template;
use App\Models\User;
use App\Models\Website;
use App\Services\AI\Prompts\PromptHelper;
use App\Services\AI\Prompts\RemixPrompt;
use App\Services\Documents\DocumentValidator;
use App\Services\Documents\WebsiteDocumentService;
use Exception;

class AiRemixService
{
    public function __construct(
        protected OpenRouterClient $client,
        protected ModelSelector $modelSelector,
        protected DocumentValidator $validator,
        protected WebsiteDocumentService $documentService
    ) {}

    /**
     * Remix an existing website or template with new business branding and copy.
     *
     * @param Website $website
     * @param array<string, mixed> $businessInfo Name, description, brand colors, goal
     * @param User|null $author
     * @return Website
     * @throws Exception
     */
    public function remix(Website $website, array $businessInfo, ?User $author = null): Website
    {
        $currentDoc = $website->document;
        $goal = $businessInfo['goal'] ?? 'Adapt to my business';

        $model = $this->modelSelector->getModelForTask('remix');

        $response = $this->client->chatCompletion(
            messages: RemixPrompt::build($currentDoc, $businessInfo, $goal),
            preferredModel: $model,
            jsonMode: true
        );

        $remixedDoc = PromptHelper::extractJson($response['content']);

        // Verify and enforce stable section IDs from the original document
        $this->preserveStableIds($currentDoc, $remixedDoc);

        // Validate complete schema
        $this->validator->validate($remixedDoc);

        return $this->documentService->updateDocument(
            website: $website,
            newDocument: $remixedDoc,
            expectedRevisionNumber: $website->revision_number,
            source: RevisionSource::AiRemix,
            description: "AI Remix: {$goal}",
            author: $author
        );
    }

    /**
     * Ensure remixed document preserves the stable component IDs of the original document.
     */
    protected function preserveStableIds(array $originalDoc, array &$remixedDoc): void
    {
        $originalSections = $originalDoc['pages'][0]['sections'] ?? [];
        $remixedSections = &$remixedDoc['pages'][0]['sections'] ?? [];

        foreach ($remixedSections as $i => &$rSec) {
            if (isset($originalSections[$i]['id']) && empty($rSec['id'])) {
                $rSec['id'] = $originalSections[$i]['id'];
            }
        }
    }
}
