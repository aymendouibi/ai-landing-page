<?php

namespace App\Services\Hosting;

use App\Enums\DeploymentStatus;
use App\Enums\DomainStatus;
use App\Enums\WebsiteStatus;
use App\Models\Deployment;
use App\Models\Domain;
use App\Models\Website;
use App\Services\Publishing\WebsiteCompilerService;
use Exception;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class CloudflareHostingService
{
    /**
     * Reserved subdomains that cannot be claimed by users.
     */
    public const RESERVED_SUBDOMAINS = [
        'admin', 'api', 'app', 'support', 'www', 'mail', 'billing', 'cdn',
        'static', 'auth', 'staging', 'dev', 'test', 'status', 'help', 'docs',
        'assets', 'root', 'dashboard', 'login', 'signup', 'register',
    ];

    public function __construct(
        protected WebsiteCompilerService $compiler
    ) {}

    /**
     * Publish website: compile static assets, upload to hosting storage, and update routing.
     *
     * @param Website $website
     * @return Deployment
     * @throws Exception
     */
    public function publish(Website $website): Deployment
    {
        // 1. Verify subdomain validity
        $this->validateSubdomain($website->subdomain);

        $platformDomain = config('app.platform_domain', 'yourplatform.com');
        $primaryUrl = "https://{$website->subdomain}.{$platformDomain}";

        // Collect all active custom domains
        $activeCustomDomains = $website->domains()
            ->where('status', DomainStatus::Active)
            ->pluck('domain')
            ->toArray();

        $allDomains = array_merge([$primaryUrl], $activeCustomDomains);

        // 2. Compile static site bundle
        $files = $this->compiler->compile(
            document: $website->document,
            websiteId: $website->id,
            canonicalUrl: $primaryUrl
        );

        // 3. Create Deployment record
        $deployment = Deployment::create([
            'website_id' => $website->id,
            'revision_id' => $website->latestRevision?->id,
            'status' => DeploymentStatus::Pending,
            'domains_deployed' => $allDomains,
            'build_log' => [
                'compiled_files' => array_keys($files),
                'started_at' => now()->toIso8601String(),
            ],
        ]);

        $disk = Storage::disk('hosting');
        $deploymentPath = "sites/{$website->id}/deployments/{$deployment->id}";
        $livePath = "sites/{$website->id}/live";

        try {
            // Write each file to deployment storage path and live storage path
            foreach ($files as $relativePath => $content) {
                $disk->put("{$deploymentPath}/{$relativePath}", $content);
                $disk->put("{$livePath}/{$relativePath}", $content);
            }

            // Mark deployment deployed
            $deployment->update([
                'status' => DeploymentStatus::Deployed,
                'storage_path' => $deploymentPath,
                'deployed_at' => now(),
                'build_log' => array_merge($deployment->build_log ?? [], [
                    'completed_at' => now()->toIso8601String(),
                    'status' => 'success',
                ]),
            ]);

            // Update website status
            $website->update([
                'status' => WebsiteStatus::Published,
                'published_at' => now(),
            ]);

            return $deployment->fresh();
        } catch (Exception $e) {
            $deployment->update([
                'status' => DeploymentStatus::Failed,
                'build_log' => array_merge($deployment->build_log ?? [], [
                    'error' => $e->getMessage(),
                    'failed_at' => now()->toIso8601String(),
                ]),
            ]);
            throw $e;
        }
    }

    /**
     * Unpublish website: remove live website files and update status.
     */
    public function unpublish(Website $website): void
    {
        $disk = Storage::disk('hosting');
        $livePath = "sites/{$website->id}/live";

        // Overwrite live index.html with clean 404/unavailable page
        $unavailableHtml = <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Website Unavailable</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background: #f8fafc; color: #334155; }
        .box { text-align: center; padding: 2rem; background: #fff; border-radius: 12px; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); max-width: 480px; }
        h1 { margin-bottom: 0.5rem; color: #0f172a; }
    </style>
</head>
<body>
    <div class="box">
        <h1>Website Unavailable</h1>
        <p>This website is currently unpublished or offline.</p>
    </div>
</body>
</html>
HTML;

        $disk->put("{$livePath}/index.html", $unavailableHtml);

        $website->update([
            'status' => WebsiteStatus::Draft,
            'published_at' => null,
        ]);
    }

    /**
     * Rollback website to a specific prior deployment.
     */
    public function rollback(Website $website, Deployment $targetDeployment): Deployment
    {
        if ($targetDeployment->website_id !== $website->id) {
            throw new Exception('Target deployment does not belong to this website.');
        }

        if (!$targetDeployment->isDeployed() || !$targetDeployment->storage_path) {
            throw new Exception('Target deployment is not in a deployable state.');
        }

        $disk = Storage::disk('hosting');
        $targetPath = $targetDeployment->storage_path;
        $livePath = "sites/{$website->id}/live";

        // Copy files from target deployment to live path
        $files = $disk->allFiles($targetPath);
        foreach ($files as $filePath) {
            $relativePath = Str::after($filePath, $targetPath . '/');
            $disk->put("{$livePath}/{$relativePath}", $disk->get($filePath));
        }

        // Create a new deployment record logging the rollback
        $newDeployment = Deployment::create([
            'website_id' => $website->id,
            'revision_id' => $targetDeployment->revision_id,
            'status' => DeploymentStatus::Deployed,
            'storage_path' => $targetPath,
            'domains_deployed' => $targetDeployment->domains_deployed,
            'deployed_at' => now(),
            'build_log' => [
                'action' => 'rollback',
                'rolled_back_from' => $targetDeployment->id,
                'executed_at' => now()->toIso8601String(),
            ],
        ]);

        $website->update([
            'status' => WebsiteStatus::Published,
            'published_at' => now(),
        ]);

        return $newDeployment;
    }

    /**
     * Check if a subdomain is reserved or invalid.
     *
     * @throws Exception
     */
    public function validateSubdomain(string $subdomain): void
    {
        $clean = strtolower(trim($subdomain));

        if (strlen($clean) < 3 || strlen($clean) > 63) {
            throw new Exception('Subdomain must be between 3 and 63 characters.');
        }

        if (!preg_match('/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/', $clean)) {
            throw new Exception('Subdomain may only contain lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen.');
        }

        if (in_array($clean, self::RESERVED_SUBDOMAINS, true)) {
            throw new Exception("The subdomain '{$clean}' is reserved by the platform and cannot be used.");
        }
    }

    /**
     * Attach a custom domain to a website and generate DNS verification records.
     */
    public function attachCustomDomain(Website $website, string $rawDomain): Domain
    {
        $domainName = strtolower(trim($rawDomain));
        $domainName = preg_replace('#^https?://#', '', $domainName);
        $domainName = rtrim($domainName, '/');

        if (empty($domainName) || !filter_var("http://{$domainName}", FILTER_VALIDATE_URL)) {
            throw new Exception('Invalid domain name provided.');
        }

        // Check if domain is already registered
        if (Domain::where('domain', $domainName)->exists()) {
            throw new Exception("The domain '{$domainName}' is already attached to a website.");
        }

        $token = 'aibuilder-verify-' . Str::random(24);

        return Domain::create([
            'website_id' => $website->id,
            'domain' => $domainName,
            'type' => 'custom',
            'status' => DomainStatus::Pending,
            'verification_token' => $token,
            'ssl_status' => [
                'status' => 'pending_validation',
                'cname_target' => config('app.platform_cname_target', 'sites.yourplatform.com'),
                'txt_record_name' => "_aibuilder-challenge.{$domainName}",
                'txt_record_value' => $token,
            ],
        ]);
    }

    /**
     * Verify DNS records for a custom domain.
     */
    public function verifyCustomDomain(Domain $domain): bool
    {
        if ($domain->isActive()) {
            return true;
        }

        // In testing environment or local demo, automatically succeed verification
        if (app()->environment('testing', 'local')) {
            $domain->update([
                'status' => DomainStatus::Active,
                'verified_at' => now(),
                'ssl_status' => array_merge($domain->ssl_status ?? [], [
                    'status' => 'active',
                    'issuer' => "Let's Encrypt / Cloudflare Universal SSL",
                    'issued_at' => now()->toIso8601String(),
                ]),
            ]);
            return true;
        }

        // Production DNS verification via dns_get_record
        $expectedToken = $domain->verification_token;
        $txtHost = "_aibuilder-challenge.{$domain->domain}";
        
        $records = @dns_get_record($txtHost, DNS_TXT);
        $verified = false;

        if (!empty($records)) {
            foreach ($records as $record) {
                if (isset($record['txt']) && str_contains($record['txt'], $expectedToken)) {
                    $verified = true;
                    break;
                }
            }
        }

        if ($verified) {
            $domain->update([
                'status' => DomainStatus::Active,
                'verified_at' => now(),
                'ssl_status' => array_merge($domain->ssl_status ?? [], [
                    'status' => 'active',
                    'issued_at' => now()->toIso8601String(),
                ]),
            ]);
            return true;
        }

        return false;
    }
}

