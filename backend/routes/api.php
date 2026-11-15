<?php

use App\Http\Controllers\Api\V1\AiController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BillingController;
use App\Http\Controllers\Api\V1\BillingWebhookController;
use App\Http\Controllers\Api\V1\DomainController;
use App\Http\Controllers\Api\V1\FormController;
use App\Http\Controllers\Api\V1\MediaAssetController;
use App\Http\Controllers\Api\V1\ProjectController;
use App\Http\Controllers\Api\V1\PublishingController;
use App\Http\Controllers\Api\V1\TemplateController;
use App\Http\Controllers\Api\V1\TemplateIngestionController;
use App\Http\Controllers\Api\V1\VisualQaController;
use App\Http\Controllers\Api\V1\WebsiteController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // Public Authentication
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/google', [AuthController::class, 'google']);
        Route::post('/apple', [AuthController::class, 'apple']);
    });

    // Public Template Browsing
    Route::get('/templates', [TemplateController::class, 'index']);
    Route::get('/templates/categories', [TemplateController::class, 'categories']);
    Route::get('/templates/{template}', [TemplateController::class, 'show']);

    // Public Website Form Submission
    Route::post('/forms/{form}/submit', [FormController::class, 'submit'])->middleware('throttle:30,1');

    // AI Editing (open with optional Sanctum auth)
    Route::post('/ai/edit', [AiController::class, 'edit']);

    // Public Billing Webhooks
    Route::post('/billing/webhook/stripe', [BillingWebhookController::class, 'stripe']);

    // Authenticated API (Sanctum)
    Route::middleware('auth:sanctum')->group(function () {

        // User & Auth Management
        Route::prefix('auth')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::get('/me', [AuthController::class, 'me']);
            Route::post('/link', [AuthController::class, 'linkProvider']);
            Route::delete('/unlink/{provider}', [AuthController::class, 'unlinkProvider']);
        });

        // Projects
        Route::apiResource('projects', ProjectController::class);

        // Media Assets
        Route::apiResource('assets', MediaAssetController::class);

        // Websites
        Route::apiResource('websites', WebsiteController::class);
        Route::prefix('websites/{website}')->group(function () {
            Route::put('/document', [WebsiteController::class, 'updateDocument']);
            Route::post('/qa', [VisualQaController::class, 'inspect']);
            Route::get('/revisions', [WebsiteController::class, 'revisions']);
            Route::post('/revisions/{revision}/restore', [WebsiteController::class, 'restoreRevision']);
            Route::post('/lock', [WebsiteController::class, 'acquireLock']);
            Route::post('/unlock', [WebsiteController::class, 'releaseLock']);
            Route::get('/forms/{form}/submissions', [FormController::class, 'submissions']);

            // Publishing & Hosting
            Route::post('/publish', [PublishingController::class, 'publish']);
            Route::post('/unpublish', [PublishingController::class, 'unpublish']);
            Route::get('/deployments', [PublishingController::class, 'deployments']);
            Route::post('/deployments/{deployment}/rollback', [PublishingController::class, 'rollback']);

            // Custom Domains
            Route::get('/domains', [DomainController::class, 'index']);
            Route::post('/domains', [DomainController::class, 'store']);
            Route::post('/domains/{domain}/verify', [DomainController::class, 'verify']);
            Route::delete('/domains/{domain}', [DomainController::class, 'destroy']);

            // Share Website as Template
            Route::post('/share-template', [TemplateController::class, 'share']);

            // Export Project ZIP (Premium Feature)
            Route::get('/export', [WebsiteController::class, 'exportZip']);
        });

        // Admin Template Management
        Route::prefix('admin/templates')->group(function () {
            Route::get('/', [\App\Http\Controllers\Admin\AdminTemplateController::class, 'apiIndex']);
            Route::post('/', [\App\Http\Controllers\Admin\AdminTemplateController::class, 'apiStore']);
            Route::patch('/{template}', [\App\Http\Controllers\Admin\AdminTemplateController::class, 'apiUpdate']);
            Route::post('/{template}/toggle-feature', [\App\Http\Controllers\Admin\AdminTemplateController::class, 'apiToggleFeature']);
            Route::delete('/{template}', [\App\Http\Controllers\Admin\AdminTemplateController::class, 'apiDestroy']);
        });

        // Template usage and ingestion
        Route::prefix('templates')->group(function () {
            Route::post('/{template}/use', [TemplateController::class, 'use']);
            Route::post('/ingest/zip', [TemplateIngestionController::class, 'ingestZip']);
            Route::post('/ingest/url', [TemplateIngestionController::class, 'ingestUrl']);
            Route::post('/{template}/approve', [TemplateIngestionController::class, 'approve']);
        });

        // AI System
        Route::prefix('ai')->group(function () {
            Route::post('/plan', [AiController::class, 'plan']);
            Route::post('/generate', [AiController::class, 'generate']);
            Route::post('/remix', [AiController::class, 'remix']);
            Route::get('/jobs/{job}', [AiController::class, 'getJob']);
        });

        // Billing & Monetization
        Route::prefix('billing')->group(function () {
            Route::get('/plans', [BillingController::class, 'plans']);
            Route::get('/subscription', [BillingController::class, 'subscription']);
            Route::get('/history', [BillingController::class, 'history']);
            Route::post('/checkout', [BillingController::class, 'checkout']);
            Route::post('/payment-intent', [BillingController::class, 'paymentIntent']);
            Route::post('/subscribe', [BillingController::class, 'subscribe']);
            Route::post('/portal', [BillingController::class, 'portal']);
            Route::post('/google-play/verify', [BillingController::class, 'verifyGooglePlay']);
        });
    });
});
