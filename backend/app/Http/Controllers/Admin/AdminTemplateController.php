<?php

namespace App\Http\Controllers\Admin;

use App\Enums\TemplateStatus;
use App\Http\Controllers\Controller;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use App\Models\Website;
use App\Services\Publishing\WebsiteCompilerService;
use App\Services\Templates\UrlReferenceIngestionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\View\View;

class AdminTemplateController extends Controller
{
    /**
     * Web view for the Admin Templates Dashboard.
     */
    public function index(Request $request): View|JsonResponse
    {
        $query = Template::with(['category', 'user', 'activeVersion', 'sourceWebsite'])
            ->when($request->query('status'), fn ($q, $status) => $q->where('status', $status))
            ->when($request->query('featured'), fn ($q) => $q->where('is_featured', true))
            ->when($request->query('community'), fn ($q) => $q->whereNotNull('user_id'))
            ->when($request->query('search'), function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('name', 'ilike', "%{$search}%")
                        ->orWhere('description', 'ilike', "%{$search}%")
                        ->orWhere('industry', 'ilike', "%{$search}%")
                        ->orWhere('badge', 'ilike', "%{$search}%")
                        ->orWhere('author', 'ilike', "%{$search}%");
                });
            });

        $templates = $query->orderByDesc('is_featured')
            ->orderByDesc('created_at')
            ->paginate(25);

        $metrics = [
            'total' => Template::count(),
            'curated' => Template::where('is_featured', true)->count(),
            'community' => Template::whereNotNull('user_id')->count(),
            'published' => Template::where('status', TemplateStatus::Published)->count(),
            'total_uses' => Template::sum('use_count'),
        ];

        $categories = TemplateCategory::orderBy('name')->get();
        $recentWebsites = Website::with('project.user')->orderByDesc('updated_at')->take(15)->get();

        if ($request->wantsJson()) {
            return response()->json([
                'metrics' => $metrics,
                'templates' => $templates,
                'categories' => $categories,
            ]);
        }

        return view('admin.templates', [
            'metrics' => $metrics,
            'templates' => $templates,
            'categories' => $categories,
            'recentWebsites' => $recentWebsites,
        ]);
    }

    /**
     * Create a new template directly from the Admin Dashboard.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['nullable', 'uuid', 'exists:template_categories,id'],
            'industry' => ['nullable', 'string', 'max:100'],
            'badge' => ['nullable', 'string', 'max:50'],
            'is_featured' => ['nullable', 'boolean'],
            'description' => ['nullable', 'string', 'max:1000'],
            'preview_image' => ['nullable', 'url'],
            'source_website_id' => ['nullable', 'uuid', 'exists:websites,id'],
        ]);

        $previewImages = !empty($validated['preview_image'])
            ? [$validated['preview_image']]
            : ['https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80'];

        $document = null;
        if (!empty($validated['source_website_id'])) {
            $sourceSite = Website::find($validated['source_website_id']);
            $document = $sourceSite?->document;
        }

        if (empty($document)) {
            $document = [
                'schema_version' => 1,
                'site' => [
                    'name' => $validated['name'],
                    'theme' => [
                        'colors' => [
                            'primary' => '#0F172A',
                            'secondary' => '#64748B',
                            'accent' => '#3B82F6',
                            'background' => '#FFFFFF',
                            'surface' => '#F8FAFC',
                            'text' => [
                                'primary' => '#0F172A',
                                'secondary' => '#64748B',
                                'inverse' => '#FFFFFF',
                            ],
                        ],
                        'typography' => [
                            'headingFamily' => 'Inter',
                            'bodyFamily' => 'Inter',
                        ],
                    ],
                    'settings' => [
                        'language' => 'en',
                        'googleFonts' => ['Inter'],
                    ],
                ],
                'navigation' => [
                    'logo' => ['text' => $validated['name']],
                    'items' => [
                        ['label' => 'Overview', 'url' => '#overview'],
                        ['label' => 'Features', 'url' => '#features'],
                        ['label' => 'Contact', 'url' => '#contact'],
                    ],
                ],
                'pages' => [
                    [
                        'id' => 'page_home',
                        'slug' => '/',
                        'title' => 'Home',
                        'sections' => [
                            [
                                'id' => 'sec_hero',
                                'component' => 'hero',
                                'props' => [
                                    'headline' => $validated['name'],
                                    'subheadline' => $validated['description'] ?? 'Crafted with precision for optimal engagement.',
                                    'ctaText' => 'Get Started',
                                    'image' => [
                                        'src' => $previewImages[0],
                                        'alt' => $validated['name'],
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
            ];
        }

        $slug = Str::slug($validated['name']) . '-' . strtolower(Str::random(5));

        $template = DB::transaction(function () use ($validated, $slug, $previewImages, $document) {
            $tpl = Template::create([
                'category_id' => $validated['category_id'] ?? null,
                'name' => $validated['name'],
                'slug' => $slug,
                'description' => $validated['description'] ?? '',
                'industry' => $validated['industry'] ?? 'General',
                'badge' => $validated['badge'] ?? null,
                'is_featured' => !empty($validated['is_featured']),
                'is_public' => true,
                'source_website_id' => $validated['source_website_id'] ?? null,
                'preview_images' => $previewImages,
                'status' => TemplateStatus::Published,
                'author' => 'AI Landing Page Team',
                'license_type' => 'internal',
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

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Template created successfully.',
                'template' => $template->load(['category', 'activeVersion']),
            ], 201);
        }

        return redirect()->back()->with('success', "Template '{$template->name}' created successfully.");
    }

    /**
     * Update template details (badge, feature status, publish status).
     */
    public function update(Request $request, Template $template)
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'badge' => ['nullable', 'string', 'max:50'],
            'is_featured' => ['sometimes', 'boolean'],
            'is_public' => ['sometimes', 'boolean'],
            'status' => ['sometimes', 'string'],
            'industry' => ['nullable', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:1000'],
        ]);

        if (isset($validated['status'])) {
            $validated['status'] = TemplateStatus::tryFrom($validated['status']) ?? TemplateStatus::Published;
        }

        $template->update($validated);

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Template updated successfully.',
                'template' => $template->fresh(['category', 'activeVersion', 'user']),
            ]);
        }

        return redirect()->back()->with('success', "Template '{$template->name}' updated.");
    }

    /**
     * Toggle featured badge / status on a template.
     */
    public function toggleFeature(Request $request, Template $template)
    {
        $badge = $request->input('badge', "EDITOR'S PICK");
        $newFeatured = !$template->is_featured;

        $template->update([
            'is_featured' => $newFeatured,
            'badge' => $newFeatured ? ($template->badge ?: $badge) : null,
        ]);

        if ($request->wantsJson()) {
            return response()->json([
                'message' => $newFeatured ? 'Template marked as featured.' : 'Template removed from featured.',
                'template' => $template->fresh(),
            ]);
        }

        return redirect()->back()->with('success', $newFeatured ? "Template '{$template->name}' is now featured." : "Template '{$template->name}' removed from featured.");
    }

    /**
     * Delete a template.
     */
    public function destroy(Request $request, Template $template)
    {
        $name = $template->name;
        $template->delete();

        if ($request->wantsJson()) {
            return response()->json(['message' => "Template '{$name}' deleted successfully."]);
        }

        return redirect()->back()->with('success', "Template '{$name}' deleted.");
    }

    /**
     * View detailed template info & JSON document.
     */
    public function show(Template $template): View
    {
        $template->load(['category', 'user', 'activeVersion', 'versions', 'sourceWebsite']);
        return view('admin.template_show', compact('template'));
    }

    /**
     * Standalone live preview of the template compiled as HTML.
     */
    public function preview(Template $template, WebsiteCompilerService $compiler)
    {
        $version = $template->activeVersion ?? $template->versions()->latest('version')->first();
        if (!$version || empty($version->document)) {
            return response('No template document available for preview.', 404);
        }

        try {
            $bundle = $compiler->compile($version->document);
            $html = $bundle['index.html'] ?? '<h1>Template Render Error</h1>';
            $css = $bundle['assets/style.css'] ?? '';
            $js = $bundle['assets/main.js'] ?? '';

            // Inject compiled CSS and JS inline so iframe renders immediately with zero external file dependencies
            if (!empty($css)) {
                $html = str_replace('</head>', "<style>\n{$css}\n</style>\n</head>", $html);
            }
            if (!empty($js)) {
                $html = str_replace('</body>', "<script>\n{$js}\n</script>\n</body>", $html);
            }

            return response($html, 200, ['Content-Type' => 'text/html; charset=UTF-8']);
        } catch (\Throwable $e) {
            return response("Error previewing template: " . htmlspecialchars($e->getMessage()), 500);
        }
    }

    /**
     * Convert any user website into a template from the template studio.
     */
    public function convertFromWebsite(Request $request)
    {
        $validated = $request->validate([
            'website_id' => ['required', 'uuid', 'exists:websites,id'],
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['nullable', 'uuid', 'exists:template_categories,id'],
            'industry' => ['nullable', 'string', 'max:100'],
            'badge' => ['nullable', 'string', 'max:50'],
            'description' => ['nullable', 'string', 'max:1000'],
            'is_featured' => ['nullable', 'boolean'],
            'preview_image' => ['nullable', 'url'],
        ]);

        $website = Website::findOrFail($validated['website_id']);
        $previewImages = !empty($validated['preview_image'])
            ? [$validated['preview_image']]
            : ['https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80'];

        $document = $website->document;
        $slug = Str::slug($validated['name']) . '-' . strtolower(Str::random(5));

        $template = DB::transaction(function () use ($validated, $slug, $previewImages, $document, $website) {
            $tpl = Template::create([
                'category_id' => $validated['category_id'] ?? null,
                'name' => $validated['name'],
                'slug' => $slug,
                'description' => $validated['description'] ?? "Curated template created from {$website->name}.",
                'industry' => $validated['industry'] ?? 'General',
                'badge' => $validated['badge'] ?? "EDITOR'S PICK",
                'is_featured' => !empty($validated['is_featured']),
                'is_public' => true,
                'source_website_id' => $website->id,
                'preview_images' => $previewImages,
                'status' => TemplateStatus::Published,
                'author' => 'AI Landing Page Studio',
                'license_type' => 'internal',
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

        return redirect()->route('admin.templates.index')->with('success', "Website '{$website->name}' converted to template '{$template->name}'.");
    }

    /**
     * Import a live modern website from a public URL and turn it into a template.
     */
    public function importUrl(Request $request, UrlReferenceIngestionService $service)
    {
        $validated = $request->validate([
            'url' => ['required', 'url'],
            'name' => ['nullable', 'string', 'max:255'],
            'category_id' => ['nullable', 'uuid', 'exists:template_categories,id'],
            'industry' => ['nullable', 'string', 'max:100'],
            'badge' => ['nullable', 'string', 'max:50'],
            'is_featured' => ['nullable', 'boolean'],
        ]);

        try {
            $template = $service->ingestFromUrl(
                $validated['url'],
                !empty($validated['name']) ? $validated['name'] : null,
                $validated['category_id'] ?? null
            );

            $updateData = [
                'status' => TemplateStatus::Published,
                'is_featured' => !empty($validated['is_featured']),
                'badge' => $validated['badge'] ?? "MODERN IMPORT",
                'is_public' => true,
            ];
            if (!empty($validated['industry'])) {
                $updateData['industry'] = $validated['industry'];
            }
            $template->update($updateData);

            return redirect()->route('admin.templates.index')->with('success', "Modern landing page from '{$validated['url']}' successfully converted into template '{$template->name}'!");
        } catch (\Throwable $e) {
            return back()->with('error', "Import failed: " . $e->getMessage());
        }
    }

    // JSON API aliases for Sanctum API routing
    public function apiIndex(Request $request): JsonResponse { return $this->index($request); }
    public function apiStore(Request $request): JsonResponse { return $this->store($request); }
    public function apiUpdate(Request $request, Template $template): JsonResponse { return $this->update($request, $template); }
    public function apiToggleFeature(Request $request, Template $template): JsonResponse { return $this->toggleFeature($request, $template); }
    public function apiDestroy(Request $request, Template $template): JsonResponse { return $this->destroy($request, $template); }
}

