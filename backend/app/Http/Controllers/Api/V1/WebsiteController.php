<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\RevisionSource;
use App\Enums\WebsiteStatus;
use App\Exceptions\DocumentConflictException;
use App\Exceptions\InvalidDocumentException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Websites\StoreWebsiteRequest;
use App\Http\Requests\Websites\UpdateDocumentRequest;
use App\Http\Requests\Websites\UpdateWebsiteRequest;
use App\Models\Project;
use App\Models\Template;
use App\Models\Website;
use App\Models\WebsiteRevision;
use App\Services\Billing\SubscriptionEntitlementService;
use App\Services\Documents\DefaultDocumentFactory;
use App\Services\Documents\WebsiteDocumentService;
use App\Services\Publishing\WebsiteCompilerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;

class WebsiteController extends Controller
{
    public function __construct(
        protected WebsiteDocumentService $documentService,
        protected SubscriptionEntitlementService $entitlementService
    ) {}

    /**
     * List user websites.
     */
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $websites = Website::whereHas('project', function ($q) use ($userId) {
            $q->where('user_id', $userId);
        })
        ->when($request->query('project_id'), fn ($q, $pId) => $q->where('project_id', $pId))
        ->when($request->query('status'), fn ($q, $status) => $q->where('status', $status))
        ->with(['project:id,name', 'currentRevision:id,revision_number,source,created_at'])
        ->orderByDesc('updated_at')
        ->paginate($request->integer('per_page', 20));

        return response()->json($websites);
    }

    /**
     * Create a new website under a project.
     */
    public function store(StoreWebsiteRequest $request): JsonResponse
    {
        $this->entitlementService->assertCan($request->user(), 'create_website');

        $project = Project::findOrFail($request->validated('project_id'));
        Gate::authorize('update', $project);

        $name = $request->validated('name');
        $slug = $request->validated('slug') ?? Str::slug($name) . '-' . Str::random(5);
        $subdomain = $request->validated('subdomain') ?? (Str::slug($name) . '-' . strtolower(Str::random(4)));

        // Document resolution
        $document = $request->validated('document');
        $source = RevisionSource::Manual;

        if (!$document && $request->filled('template_id')) {
            $template = Template::findOrFail($request->validated('template_id'));
            $version = $template->activeVersion;
            if ($version) {
                $document = $version->document;
                $document['site']['name'] = $name;
                $source = RevisionSource::Manual;
                $template->incrementUseCount();
            }
        }

        if (!$document) {
            $document = DefaultDocumentFactory::createDefault($name);
        }

        $website = DB::transaction(function () use ($project, $name, $slug, $subdomain, $document, $source, $request) {
            $website = Website::create([
                'project_id' => $project->id,
                'name' => $name,
                'slug' => $slug,
                'status' => WebsiteStatus::Draft,
                'document' => $document,
                'revision_number' => 1,
                'subdomain' => $subdomain,
            ]);

            $revision = WebsiteRevision::create([
                'website_id' => $website->id,
                'revision_number' => 1,
                'document' => $document,
                'source' => $source,
                'description' => 'Initial website creation',
                'created_by' => $request->user()->id,
            ]);

            $website->update(['current_revision_id' => $revision->id]);

            return $website->fresh(['project', 'currentRevision']);
        });

        return response()->json([
            'message' => 'Website created successfully.',
            'website' => $website,
        ], 201);
    }

    /**
     * Show a website with its document and metadata.
     */
    public function show(Website $website): JsonResponse
    {
        Gate::authorize('view', $website);

        $website->touch();

        $website->load(['project', 'currentRevision', 'domains', 'deployments' => function ($q) {
            $q->take(5);
        }]);

        return response()->json([
            'website' => $website,
            'is_locked' => $website->isLocked(),
        ]);
    }

    /**
     * Update website metadata (name, slug, subdomain).
     */
    public function update(UpdateWebsiteRequest $request, Website $website): JsonResponse
    {
        Gate::authorize('update', $website);

        $website->update($request->validated());

        return response()->json([
            'message' => 'Website updated successfully.',
            'website' => $website->fresh(),
        ]);
    }

    /**
     * Update website document with schema validation, optimistic locking, and revision history.
     */
    public function updateDocument(UpdateDocumentRequest $request, Website $website): JsonResponse
    {
        Gate::authorize('update', $website);

        // Check if locked by someone else
        $lockToken = $request->validated('lock_token');
        if ($website->isLocked() && $website->lock_token !== $lockToken) {
            return response()->json([
                'message' => 'Website is currently locked for editing by another session.',
            ], 423); // Locked
        }

        $source = $request->filled('source')
            ? RevisionSource::from($request->validated('source'))
            : RevisionSource::Manual;

        try {
            $updatedWebsite = $this->documentService->updateDocument(
                website: $website,
                newDocument: $request->validated('document'),
                expectedRevisionNumber: $request->validated('expected_revision_number'),
                source: $source,
                description: $request->validated('description'),
                author: $request->user()
            );
        } catch (InvalidDocumentException $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'errors' => $e->getErrors(),
            ], 422);
        } catch (DocumentConflictException $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'current_revision_number' => $website->fresh()->revision_number,
            ], 409);
        }

        return response()->json([
            'message' => 'Website document updated successfully.',
            'website' => $updatedWebsite,
        ]);
    }

    /**
     * List revisions for this website.
     */
    public function revisions(Request $request, Website $website): JsonResponse
    {
        Gate::authorize('view', $website);

        $revisions = $website->revisions()
            ->with('creator:id,name,email')
            ->paginate($request->integer('per_page', 20));

        return response()->json($revisions);
    }

    /**
     * Restore website to a prior revision.
     */
    public function restoreRevision(Website $website, WebsiteRevision $revision, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        try {
            $updatedWebsite = $this->documentService->restoreRevision(
                website: $website,
                targetRevision: $revision,
                author: $request->user()
            );
        } catch (InvalidDocumentException $e) {
            return response()->json(['message' => $e->getMessage(), 'errors' => $e->getErrors()], 422);
        } catch (DocumentConflictException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        }

        return response()->json([
            'message' => "Restored website to revision #{$revision->revision_number}.",
            'website' => $updatedWebsite,
        ]);
    }

    /**
     * Acquire editing lock token.
     */
    public function acquireLock(Request $request, Website $website): JsonResponse
    {
        Gate::authorize('update', $website);

        $token = $request->input('lock_token') ?? Str::random(32);

        if (!$website->acquireLock($token)) {
            return response()->json([
                'message' => 'Cannot acquire lock: website is already being edited.',
            ], 423);
        }

        return response()->json([
            'message' => 'Lock acquired successfully.',
            'lock_token' => $token,
            'locked_at' => $website->locked_at,
        ]);
    }

    /**
     * Release editing lock token.
     */
    public function releaseLock(Request $request, Website $website): JsonResponse
    {
        Gate::authorize('update', $website);

        $token = $request->input('lock_token');

        if (!$token || !$website->releaseLock($token)) {
            return response()->json([
                'message' => 'Invalid or mismatched lock token.',
            ], 400);
        }

        return response()->json([
            'message' => 'Lock released successfully.',
        ]);
    }

    /**
     * Export website project as a standalone ZIP archive (Premium feature only).
     */
    public function exportZip(
        Request $request,
        Website $website,
        WebsiteCompilerService $compiler
    ) {
        Gate::authorize('view', $website);

        // Strict entitlement check: Exporting projects is a Premium feature only
        $this->entitlementService->assertCan($request->user(), 'code_export');

        $document = $website->currentRevision?->document ?? $website->document ?? [];

        // Compile HTML/CSS/JS files
        $compiledFiles = $compiler->compile(
            $document,
            $website->id,
            $website->subdomain ? "https://{$website->subdomain}.sites.aibuilder.app" : null
        );

        // Include raw website document schema and README
        $compiledFiles['schema.json'] = json_encode($document, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        $compiledFiles['README.md'] = <<<MARKDOWN
# {$website->name}

Exported from AI Landing Page.

## Running Locally
You can open `index.html` directly in any web browser, or serve it using any static HTTP server:

```bash
# Python 3
python3 -m http.server 8000

# Node.js
npx serve .
```

## Structure
- `index.html` - Semantic production HTML markup with Tailwind CSS
- `assets/style.css` - Custom design preset stylesheets and utility rules
- `assets/main.js` - Interactive navigation, form submissions, and animations
- `schema.json` - Complete website document AST and component hierarchy
MARKDOWN;

        $tempZipPath = tempnam(sys_get_temp_dir(), 'export_') . '.zip';
        $zip = new \ZipArchive();

        if ($zip->open($tempZipPath, \ZipArchive::CREATE | \ZipArchive::OVERWRITE) !== true) {
            return response()->json([
                'error' => 'export_failed',
                'message' => 'Unable to generate zip archive.',
            ], 500);
        }

        foreach ($compiledFiles as $filePath => $content) {
            $zip->addFromString($filePath, $content);
        }

        $zip->close();

        $slug = $website->slug ?: Str::slug($website->name) ?: 'website';
        $fileName = "{$slug}-project.zip";

        return response()->download($tempZipPath, $fileName, [
            'Content-Type' => 'application/zip',
            'Content-Disposition' => "attachment; filename=\"{$fileName}\"",
        ])->deleteFileAfterSend(true);
    }

    /**
     * Delete a website.
     */
    public function destroy(Website $website): JsonResponse
    {
        Gate::authorize('delete', $website);

        $website->delete();

        return response()->json([
            'message' => 'Website deleted successfully.',
        ]);
    }
}

