<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Deployment;
use App\Models\Website;
use App\Services\Hosting\CloudflareHostingService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class PublishingController extends Controller
{
    public function __construct(
        protected CloudflareHostingService $hostingService
    ) {}

    /**
     * Publish website to independent CDN hosting.
     */
    public function publish(Website $website, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        try {
            $deployment = $this->hostingService->publish($website);

            $platformDomain = config('app.platform_domain', 'yourplatform.com');
            $primaryUrl = "https://{$website->subdomain}.{$platformDomain}";

            return response()->json([
                'message' => 'Website successfully published to global CDN.',
                'deployment' => $deployment,
                'live_url' => $primaryUrl,
                'website' => $website->fresh(),
            ]);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Publishing failed: ' . $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Unpublish website immediately.
     */
    public function unpublish(Website $website, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        $this->hostingService->unpublish($website);

        return response()->json([
            'message' => 'Website unpublished successfully.',
            'website' => $website->fresh(),
        ]);
    }

    /**
     * List deployment history.
     */
    public function deployments(Website $website, Request $request): JsonResponse
    {
        Gate::authorize('view', $website);

        $deployments = $website->deployments()
            ->latest()
            ->paginate(15);

        return response()->json($deployments);
    }

    /**
     * Rollback to a specific deployment.
     */
    public function rollback(Website $website, Deployment $deployment, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        try {
            $newDeployment = $this->hostingService->rollback($website, $deployment);

            return response()->json([
                'message' => 'Website rolled back successfully.',
                'deployment' => $newDeployment,
                'website' => $website->fresh(),
            ]);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Rollback failed: ' . $e->getMessage(),
            ], 422);
        }
    }
}
