<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\TemplateStatus;
use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\Website;
use App\Models\WebsiteRevision;
use App\Enums\WebsiteStatus;
use App\Enums\RevisionSource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;

class TemplateController extends Controller
{
    /**
     * Browse published templates with filters.
     */
    public function index(Request $request): JsonResponse
    {
        $templates = Template::where('status', TemplateStatus::Published)
            ->when($request->query('category_id'), fn ($q, $cat) => $q->where('category_id', $cat))
            ->when($request->query('industry'), fn ($q, $ind) => $q->where('industry', $ind))
            ->when($request->query('search'), function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('name', 'ilike', "%{$search}%")
                        ->orWhere('description', 'ilike', "%{$search}%");
                });
            })
            ->with(['category:id,name,slug', 'activeVersion:id,template_id,version,design_tokens,fonts'])
            ->orderByDesc('use_count')
            ->paginate($request->integer('per_page', 20));

        return response()->json($templates);
    }

    /**
     * List all template categories.
     */
    public function categories(): JsonResponse
    {
        $categories = TemplateCategory::withCount(['templates' => function ($q) {
            $q->where('status', TemplateStatus::Published);
        }])
        ->orderBy('sort_order')
        ->get();

        return response()->json($categories);
    }

    /**
     * View template details with full document.
     */
    public function show(Template $template): JsonResponse
    {
        if ($template->status !== TemplateStatus::Published && !auth()->user()?->isAdmin()) {
            abort(404);
        }

        $template->load(['category', 'activeVersion']);

        return response()->json([
            'template' => $template,
        ]);
    }

    /**
     * Use a template to create a new website inside a user project.
     */
    public function use(Request $request, Template $template): JsonResponse
    {
        $validated = $request->validate([
            'project_id' => ['required', 'uuid', 'exists:projects,id'],
            'name' => ['required', 'string', 'max:255'],
        ]);

        $project = Project::findOrFail($validated['project_id']);
        Gate::authorize('update', $project);

        $version = $template->activeVersion;
        if (!$version) {
            return response()->json(['message' => 'This template does not have an active version.'], 422);
        }

        $document = $version->document;
        $document['site']['name'] = $validated['name'];

        $name = $validated['name'];
        $slug = Str::slug($name) . '-' . Str::random(5);
        $subdomain = Str::slug($name) . '-' . strtolower(Str::random(4));

        $website = DB::transaction(function () use ($project, $name, $slug, $subdomain, $document, $template, $request) {
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
                'source' => RevisionSource::Manual,
                'description' => "Created from template: {$template->name}",
                'created_by' => $request->user()->id,
            ]);

            $website->update(['current_revision_id' => $revision->id]);
            $template->incrementUseCount();

            return $website;
        });

        return response()->json([
            'message' => 'Website created successfully from template.',
            'website' => $website->fresh(['project', 'currentRevision']),
        ], 201);
    }
}
