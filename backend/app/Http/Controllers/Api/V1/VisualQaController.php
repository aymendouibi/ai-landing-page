<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Website;
use App\Services\Documents\WebsiteDocumentService;
use App\Services\QA\VisualQualityAssuranceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class VisualQaController extends Controller
{
    public function __construct(
        protected VisualQualityAssuranceService $qaService,
        protected WebsiteDocumentService $documentService
    ) {}

    /**
     * Inspect website document for visual, structural, and contrast issues.
     */
    public function inspect(Website $website, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        $autoFix = $request->boolean('auto_fix', false);

        $result = $this->qaService->inspect($website->document, $autoFix);

        if ($autoFix && $result['auto_fixed']) {
            $updatedWebsite = $this->documentService->updateDocument(
                website: $website,
                newDocument: $result['document'],
                expectedRevisionNumber: $website->revision_number,
                description: 'Applied automated Visual QA improvements',
                author: $request->user()
            );

            return response()->json([
                'message' => 'Visual QA inspection complete with auto-fix applied.',
                'qa_report' => [
                    'passed' => $result['passed'],
                    'score' => $result['score'],
                    'issues_count' => $result['issues_count'],
                    'errors_count' => $result['errors_count'],
                    'warnings_count' => $result['warnings_count'],
                    'issues' => $result['issues'],
                    'auto_fixed' => true,
                ],
                'website' => $updatedWebsite->fresh(['revisions']),
            ]);
        }

        return response()->json([
            'message' => 'Visual QA inspection completed.',
            'qa_report' => [
                'passed' => $result['passed'],
                'score' => $result['score'],
                'issues_count' => $result['issues_count'],
                'errors_count' => $result['errors_count'],
                'warnings_count' => $result['warnings_count'],
                'issues' => $result['issues'],
                'auto_fixed' => false,
            ],
            'website' => $website,
        ]);
    }
}
