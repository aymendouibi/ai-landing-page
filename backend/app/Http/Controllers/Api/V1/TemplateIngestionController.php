<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\TemplateStatus;
use App\Http\Controllers\Controller;
use App\Models\Template;
use App\Services\Templates\UrlReferenceIngestionService;
use App\Services\Templates\ZipTemplateIngestionService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TemplateIngestionController extends Controller
{
    public function __construct(
        protected ZipTemplateIngestionService $zipService,
        protected UrlReferenceIngestionService $urlService
    ) {}

    /**
     * Ingest an authorized template ZIP package.
     */
    public function ingestZip(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'file' => ['required', 'file', 'mimes:zip', 'max:20480'], // max 20MB
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['nullable', 'uuid', 'exists:template_categories,id'],
        ]);

        try {
            $template = $this->zipService->ingest(
                zipFile: $validated['file'],
                templateName: $validated['name'],
                categoryId: $validated['category_id'] ?? null,
                author: $request->user()->name
            );

            return response()->json([
                'message' => 'Template package successfully ingested and queued for review.',
                'template' => $template,
            ], 201);
        } catch (Exception $e) {
            return response()->json(['message' => 'Template ingestion failed: ' . $e->getMessage()], 422);
        }
    }

    /**
     * Ingest an authorized reference website URL.
     */
    public function ingestUrl(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'url' => ['required', 'url', 'max:1000'],
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['nullable', 'uuid', 'exists:template_categories,id'],
        ]);

        try {
            $template = $this->urlService->ingestFromUrl(
                url: $validated['url'],
                templateName: $validated['name'],
                categoryId: $validated['category_id'] ?? null
            );

            return response()->json([
                'message' => 'Website URL successfully analyzed and converted to template.',
                'template' => $template,
            ], 201);
        } catch (Exception $e) {
            return response()->json(['message' => 'URL conversion failed: ' . $e->getMessage()], 422);
        }
    }

    /**
     * Administratively approve a template for public marketplace listing.
     */
    public function approve(Template $template, Request $request): JsonResponse
    {
        if (!$request->user()->isAdmin()) {
            abort(403, 'Only administrators can approve templates.');
        }

        $template->update(['status' => TemplateStatus::Published]);

        return response()->json([
            'message' => 'Template approved and published to marketplace.',
            'template' => $template->fresh(),
        ]);
    }
}

