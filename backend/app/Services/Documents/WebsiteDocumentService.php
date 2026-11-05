<?php

namespace App\Services\Documents;

use App\Enums\RevisionSource;
use App\Exceptions\DocumentConflictException;
use App\Exceptions\InvalidDocumentException;
use App\Models\User;
use App\Models\Website;
use App\Models\WebsiteRevision;
use Illuminate\Support\Facades\DB;

class WebsiteDocumentService
{
    public function __construct(
        protected DocumentValidator $validator
    ) {}

    /**
     * Update the website document, enforcing schema validation, optimistic locking, and revision logging.
     *
     * @param Website $website
     * @param array<string, mixed> $newDocument
     * @param int|null $expectedRevisionNumber If provided, checks optimistic lock
     * @param RevisionSource $source
     * @param string|null $description
     * @param User|null $author
     * @return Website
     * @throws InvalidDocumentException
     * @throws DocumentConflictException
     */
    public function updateDocument(
        Website $website,
        array $newDocument,
        ?int $expectedRevisionNumber = null,
        RevisionSource $source = RevisionSource::Manual,
        ?string $description = null,
        ?User $author = null
    ): Website {
        // 1. Validate structure & stable IDs
        $this->validator->validate($newDocument);

        return DB::transaction(function () use ($website, $newDocument, $expectedRevisionNumber, $source, $description, $author) {
            // Lock row for update
            /** @var Website $freshWebsite */
            $freshWebsite = Website::where('id', $website->id)->lockForUpdate()->firstOrFail();

            // Optimistic lock check
            if ($expectedRevisionNumber !== null && $freshWebsite->revision_number !== $expectedRevisionNumber) {
                throw new DocumentConflictException(
                    "Revision conflict: document is at revision {$freshWebsite->revision_number}, but expected {$expectedRevisionNumber}."
                );
            }

            $nextRevisionNumber = $freshWebsite->revision_number + 1;

            // Create revision record
            $revision = WebsiteRevision::create([
                'website_id' => $freshWebsite->id,
                'revision_number' => $nextRevisionNumber,
                'document' => $newDocument,
                'source' => $source,
                'description' => $description ?? "Updated document via {$source->value}",
                'created_by' => $author?->id,
            ]);

            // Update website
            $freshWebsite->update([
                'document' => $newDocument,
                'revision_number' => $nextRevisionNumber,
                'current_revision_id' => $revision->id,
            ]);

            return $freshWebsite->fresh(['currentRevision']);
        });
    }

    /**
     * Restore a website to a specific prior revision.
     *
     * @param Website $website
     * @param WebsiteRevision $targetRevision
     * @param User|null $author
     * @return Website
     * @throws InvalidDocumentException
     * @throws DocumentConflictException
     */
    public function restoreRevision(Website $website, WebsiteRevision $targetRevision, ?User $author = null): Website
    {
        if ($targetRevision->website_id !== $website->id) {
            throw new \InvalidArgumentException('Revision does not belong to this website.');
        }

        return $this->updateDocument(
            website: $website,
            newDocument: $targetRevision->document,
            expectedRevisionNumber: null,
            source: RevisionSource::Restore,
            description: "Restored from revision #{$targetRevision->revision_number}",
            author: $author
        );
    }
}
