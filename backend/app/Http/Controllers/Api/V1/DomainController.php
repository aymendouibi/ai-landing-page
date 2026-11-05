<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Domain;
use App\Models\Website;
use App\Services\Hosting\CloudflareHostingService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class DomainController extends Controller
{
    public function __construct(
        protected CloudflareHostingService $hostingService
    ) {}

    /**
     * List domains attached to website.
     */
    public function index(Website $website, Request $request): JsonResponse
    {
        Gate::authorize('view', $website);

        return response()->json([
            'domains' => $website->domains()->latest()->get(),
            'subdomain' => $website->subdomain,
            'subdomain_url' => "https://{$website->subdomain}." . config('app.platform_domain', 'yourplatform.com'),
        ]);
    }

    /**
     * Attach a new custom domain.
     */
    public function store(Website $website, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        $validated = $request->validate([
            'domain' => ['required', 'string', 'max:255'],
        ]);

        try {
            $domain = $this->hostingService->attachCustomDomain($website, $validated['domain']);

            return response()->json([
                'message' => 'Custom domain added. Please configure your DNS records.',
                'domain' => $domain,
                'dns_instructions' => [
                    'cname_record' => [
                        'type' => 'CNAME',
                        'name' => $domain->domain,
                        'target' => config('app.platform_cname_target', 'sites.yourplatform.com'),
                    ],
                    'txt_record' => [
                        'type' => 'TXT',
                        'name' => "_aibuilder-challenge.{$domain->domain}",
                        'value' => $domain->verification_token,
                    ],
                ],
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Failed to attach domain: ' . $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Trigger DNS verification for domain.
     */
    public function verify(Website $website, Domain $domain, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        if ($domain->website_id !== $website->id) {
            abort(404, 'Domain does not belong to this website.');
        }

        $verified = $this->hostingService->verifyCustomDomain($domain);

        if ($verified) {
            return response()->json([
                'message' => 'Domain DNS verified and SSL certificate provisioned.',
                'domain' => $domain->fresh(),
                'verified' => true,
            ]);
        }

        return response()->json([
            'message' => 'DNS records not yet propagated or incorrect. Please allow up to 24 hours for global propagation.',
            'domain' => $domain->fresh(),
            'verified' => false,
        ], 422);
    }

    /**
     * Remove custom domain.
     */
    public function destroy(Website $website, Domain $domain, Request $request): JsonResponse
    {
        Gate::authorize('update', $website);

        if ($domain->website_id !== $website->id) {
            abort(404, 'Domain does not belong to this website.');
        }

        $domain->delete();

        return response()->json([
            'message' => 'Custom domain removed successfully.',
        ]);
    }
}
