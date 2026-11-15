<?php

namespace App\Http\Controllers;

use App\Enums\WebsiteStatus;
use App\Models\Website;
use App\Services\Hosting\CloudflareHostingService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class PublicSiteController extends Controller
{
    /**
     * Serve a published website's static files.
     *
     * Supports both path-based routing (/sites/{subdomain} or /{subdomain})
     * and subdomain routing ({subdomain}.our-domain.com).
     */
    public function serve(Request $request, string $subdomain, ?string $path = null): Response|BinaryFileResponse
    {
        // 1. Guard against reserved platform subdomains / routes
        if (in_array(strtolower($subdomain), CloudflareHostingService::RESERVED_SUBDOMAINS, true)) {
            abort(404);
        }

        // 2. Find published website by subdomain or slug
        $website = Website::where(function ($query) use ($subdomain) {
            $query->where('subdomain', $subdomain)
                  ->orWhere('slug', $subdomain);
        })->where('status', WebsiteStatus::Published)->first();

        if (!$website) {
            abort(404, 'Website not found or unpublished.');
        }

        $disk = Storage::disk('hosting');
        $liveBasePath = "sites/{$website->id}/live";

        // Determine target file inside the site's live directory
        $targetFile = empty($path) ? 'index.html' : ltrim($path, '/');
        $storagePath = "{$liveBasePath}/{$targetFile}";

        // If file not found, try serving 404.html from the compiled bundle
        if (!$disk->exists($storagePath)) {
            if ($disk->exists("{$liveBasePath}/404.html")) {
                return response($disk->get("{$liveBasePath}/404.html"), 404, [
                    'Content-Type' => 'text/html; charset=UTF-8',
                ]);
            }
            abort(404, 'File not found');
        }

        $extension = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
        $mimeType = match ($extension) {
            'html', 'htm' => 'text/html; charset=UTF-8',
            'css' => 'text/css; charset=UTF-8',
            'js' => 'application/javascript; charset=UTF-8',
            'json' => 'application/json',
            'svg' => 'image/svg+xml',
            'png' => 'image/png',
            'jpg', 'jpeg' => 'image/jpeg',
            'webp' => 'image/webp',
            'ico' => 'image/x-icon',
            'woff2' => 'font/woff2',
            'woff' => 'font/woff',
            'ttf' => 'font/ttf',
            default => $disk->mimeType($storagePath) ?? 'application/octet-stream',
        };

        $content = $disk->get($storagePath);

        // For path-based delivery (e.g. /sites/lumen-coffee or /lumen-coffee),
        // inject <base href="..."> into HTML so relative assets (assets/style.css) resolve correctly.
        if (in_array($extension, ['html', 'htm'], true)) {
            $baseHref = $request->is('sites/*') ? "/sites/{$subdomain}/" : "/{$subdomain}/";
            if (!str_contains($content, '<base ')) {
                $content = preg_replace('/<head>/i', "<head>\n    <base href=\"{$baseHref}\">", $content, 1);
            }
        }

        return response($content, 200, [
            'Content-Type' => $mimeType,
            'Cache-Control' => 'public, max-age=3600',
        ]);
    }
}
