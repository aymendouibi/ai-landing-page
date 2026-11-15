<?php

namespace App\Http\Controllers\Admin;

use App\Enums\TemplateStatus;
use App\Enums\WebsiteStatus;
use App\Http\Controllers\Controller;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use App\Models\Website;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\View\View;

class AdminWebsiteController extends Controller
{
    /**
     * Display a listing of all user websites.
     */
    public function index(Request $request): View
    {
        $query = Website::with(['project.user', 'currentRevision', 'deployments'])
            ->when($request->query('status'), fn ($q, $status) => $q->where('status', $status))
            ->when($request->query('search'), function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('name', 'ilike', "%{$search}%")
                        ->orWhere('subdomain', 'ilike', "%{$search}%")
                        ->orWhere('slug', 'ilike', "%{$search}%");
                });
            });

        $websites = $query->orderByDesc('updated_at')->paginate(15);
        $categories = TemplateCategory::orderBy('name')->get();

        $metrics = [
            'total' => Website::count(),
            'published' => Website::where('status', WebsiteStatus::Published)->count(),
            'draft' => Website::where('status', WebsiteStatus::Draft)->count(),
            'archived' => Website::where('status', WebsiteStatus::Archived)->count(),
        ];

        return view('admin.websites', [
            'websites' => $websites,
            'categories' => $categories,
            'metrics' => $metrics,
        ]);
    }

    /**
     * Toggle the publication status of a website.
     */
    public function toggleStatus(Website $website): RedirectResponse
    {
        if ($website->status === WebsiteStatus::Published) {
            $website->update([
                'status' => WebsiteStatus::Draft,
                'published_at' => null,
            ]);
            $msg = "Website '{$website->name}' has been unpublished (Draft).";
        } else {
            $website->update([
                'status' => WebsiteStatus::Published,
                'published_at' => now(),
            ]);
            $msg = "Website '{$website->name}' is now Published and live.";
        }

        return back()->with('success', $msg);
    }

    /**
     * Convert an existing user website directly into a curated template.
     */
    public function convertToTemplate(Request $request, Website $website): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['nullable', 'uuid', 'exists:template_categories,id'],
            'industry' => ['nullable', 'string', 'max:100'],
            'badge' => ['nullable', 'string', 'max:50'],
            'description' => ['nullable', 'string', 'max:1000'],
            'is_featured' => ['nullable', 'boolean'],
            'preview_image' => ['nullable', 'url'],
        ]);

        $previewImages = !empty($validated['preview_image'])
            ? [$validated['preview_image']]
            : ['https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80'];

        $document = $website->document;
        $slug = Str::slug($validated['name']) . '-' . strtolower(Str::random(5));

        DB::transaction(function () use ($validated, $slug, $previewImages, $document, $website) {
            $template = Template::create([
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
                'author' => 'AI Builder Studio',
                'license_type' => 'internal',
                'use_count' => 0,
            ]);

            TemplateVersion::create([
                'template_id' => $template->id,
                'version' => 1,
                'document' => $document,
                'design_tokens' => $document['site']['theme'] ?? null,
                'fonts' => $document['site']['settings']['googleFonts'] ?? ['Inter'],
                'is_active' => true,
            ]);
        });

        return redirect()->route('admin.templates.index')->with('success', "Website '{$website->name}' successfully converted to template.");
    }

    /**
     * Delete a website.
     */
    public function destroy(Website $website): RedirectResponse
    {
        $name = $website->name;
        $website->delete();

        return back()->with('success', "Website '{$name}' was deleted.");
    }
}

