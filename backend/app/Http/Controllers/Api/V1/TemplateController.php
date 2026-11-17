<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\TemplateStatus;
use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use App\Models\Website;
use App\Models\WebsiteRevision;
use App\Enums\WebsiteStatus;
use App\Enums\RevisionSource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;
use App\Services\Billing\SubscriptionEntitlementService;

class TemplateController extends Controller
{
    public function __construct(
        protected SubscriptionEntitlementService $entitlementService
    ) {}
    /**
     * Browse published templates with filters.
     */
    public function index(Request $request): JsonResponse
    {
        $tab = $request->query('tab', 'for_you');
        $search = $request->query('search');

        $query = Template::where('status', TemplateStatus::Published)
            ->where('is_public', true);

        // Tab category filtering
        if ($tab === 'startups') {
            $query->where(function ($q) {
                $q->whereIn('industry', ['SaaS', 'Startups', 'Startups & AI Platform', 'Startups & Developer Tools', 'Startups & HealthTech', 'Startups & FinTech', 'Technology', 'SaaS & AI Platform'])
                  ->orWhereHas('category', fn ($c) => $c->whereIn('slug', ['saas', 'startups']));
            });
        } elseif ($tab === 'business') {
            $query->where(function ($q) {
                $q->whereIn('industry', ['SaaS', 'Food & drink', 'Restaurant', 'Portfolio · Architecture', 'Real Estate', 'Local Businesses', 'Agencies', 'Business & Specialty Coffee', 'Business & Luxury Skincare', 'Business & Wealth Advisory', 'Business & Fine Dining', 'Finance', 'Business'])
                  ->orWhereHas('category', fn ($c) => $c->whereIn('slug', ['saas', 'restaurants', 'real-estate', 'local-business', 'agencies', 'business', 'ecommerce']));
            });
        } elseif ($tab === 'weddings') {
            $query->where(function ($q) {
                $q->whereIn('industry', ['Weddings', 'Weddings & Celebrations', 'Weddings & Receptions', 'Weddings & Gatherings'])
                  ->orWhereHas('category', fn ($c) => $c->whereIn('slug', ['weddings', 'events']));
            });
        } elseif ($tab === 'creative') {
            $query->where(function ($q) {
                $q->whereIn('industry', ['Portfolio · Architecture', 'Portfolios', 'Photography', 'Art', 'Creative', 'Creative & Architectural Design', 'Creative & Visual Identity'])
                  ->orWhereHas('category', fn ($c) => $c->whereIn('slug', ['portfolios', 'photography', 'agencies', 'creative']));
            });
        } elseif ($tab === 'personal') {
            $query->where(function ($q) {
                $q->whereIn('industry', ['Wellness', 'Personal', 'Personal & Thought Leadership', 'Personal & Architecture Portfolio', 'Personal & Software Engineer', 'Personal & Movement Coach', 'Health & Fitness', 'Education'])
                  ->orWhereHas('category', fn ($c) => $c->whereIn('slug', ['fitness', 'events', 'education', 'personal', 'portfolios']));
            });
        } elseif ($tab === 'community') {
            $query->whereNotNull('user_id');
        } elseif ($tab === 'my_templates' && $request->user()) {
            // Include user's own templates even if unpublished
            $query = Template::where('user_id', $request->user()->id);
        }

        if ($request->boolean('featured_only')) {
            $query->where('is_featured', true);
        }

        if ($request->query('category_id')) {
            $query->where('category_id', $request->query('category_id'));
        }

        if ($request->query('industry')) {
            $query->where('industry', $request->query('industry'));
        }

        if (!empty($search)) {
            $query->where(function ($sub) use ($search) {
                $sub->where('name', 'ilike', "%{$search}%")
                    ->orWhere('description', 'ilike', "%{$search}%")
                    ->orWhere('industry', 'ilike', "%{$search}%")
                    ->orWhere('badge', 'ilike', "%{$search}%");
            });
        }

        $templates = $query->with([
                'category:id,name,slug',
                'user:id,name',
                'activeVersion:id,template_id,version,document,design_tokens,fonts',
            ])
            ->orderByDesc('is_featured')
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

        if ($template->is_premium || $template->badge === 'PRO') {
            $this->entitlementService->assertCan($request->user(), 'premium_template');
        }

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

    /**
     * Share a user website as a public or community template.
     */
    public function share(Request $request, Website $website): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:1000'],
            'industry' => ['nullable', 'string', 'max:100'],
            'badge' => ['nullable', 'string', 'max:50'],
            'category_id' => ['nullable', 'uuid', 'exists:template_categories,id'],
            'is_public' => ['nullable', 'boolean'],
        ]);

        $project = $website->project;
        if ($project && $project->user_id !== $request->user()->id && !$request->user()->isAdmin()) {
            abort(403, 'Unauthorized to share this website as template.');
        }

        $document = $website->document;
        if (empty($document)) {
            return response()->json(['message' => 'Website has no document content to create template.'], 422);
        }

        // Extract hero image for preview thumbnail
        $previewImages = [];
        $pages = $document['pages'] ?? [];
        if (!empty($pages)) {
            $sections = $pages[0]['sections'] ?? [];
            foreach ($sections as $sec) {
                $img = $sec['props']['image'] ?? $sec['props']['imageUrl'] ?? $sec['props']['url'] ?? null;
                if (is_array($img) && !empty($img['src'])) {
                    $previewImages[] = $img['src'];
                    break;
                } elseif (is_string($img) && str_starts_with($img, 'http')) {
                    $previewImages[] = $img;
                    break;
                }
            }
        }
        if (empty($previewImages)) {
            $previewImages = ['https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80'];
        }

        $slug = Str::slug($validated['name']) . '-' . strtolower(Str::random(5));

        $template = DB::transaction(function () use ($request, $website, $validated, $slug, $previewImages, $document) {
            $tpl = Template::create([
                'user_id' => $request->user()->id,
                'category_id' => $validated['category_id'] ?? null,
                'name' => $validated['name'],
                'slug' => $slug,
                'description' => $validated['description'] ?? 'Shared community template created by ' . $request->user()->name,
                'industry' => $validated['industry'] ?? 'Community',
                'badge' => $validated['badge'] ?? 'COMMUNITY',
                'is_featured' => false,
                'is_public' => $validated['is_public'] ?? true,
                'source_website_id' => $website->id,
                'preview_images' => $previewImages,
                'status' => TemplateStatus::Published,
                'author' => $request->user()->name,
                'license_type' => 'community',
                'use_count' => 0,
            ]);

            TemplateVersion::create([
                'template_id' => $tpl->id,
                'version' => 1,
                'document' => $document,
                'design_tokens' => $document['site']['theme'] ?? null,
                'fonts' => $document['site']['settings']['googleFonts'] ?? ['Inter'],
                'is_active' => true,
            ]);

            return $tpl;
        });

        return response()->json([
            'message' => 'Website successfully shared as a template.',
            'template' => $template->load(['category', 'activeVersion', 'user:id,name']),
        ], 201);
    }
}

