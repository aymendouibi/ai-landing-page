<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\FormSubmission;
use App\Models\Website;
use App\Models\WebsiteForm;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class FormController extends Controller
{
    /**
     * Submit a form (public endpoint from published sites).
     */
    public function submit(Request $request, WebsiteForm $form): JsonResponse
    {
        if (!$form->is_active) {
            return response()->json(['message' => 'This form is currently inactive.'], 403);
        }

        $submission = FormSubmission::create([
            'form_id' => $form->id,
            'data' => $request->all(),
            'ip_address' => $request->ip(),
            'user_agent' => substr((string) $request->userAgent(), 0, 500),
        ]);

        return response()->json([
            'message' => 'Form submitted successfully.',
            'submission_id' => $submission->id,
        ], 201);
    }

    /**
     * View form submissions (authenticated site owner).
     */
    public function submissions(Request $request, Website $website, WebsiteForm $form): JsonResponse
    {
        Gate::authorize('view', $website);

        if ($form->website_id !== $website->id) {
            abort(404);
        }

        $submissions = $form->submissions()
            ->orderByDesc('created_at')
            ->paginate($request->integer('per_page', 20));

        return response()->json($submissions);
    }
}

