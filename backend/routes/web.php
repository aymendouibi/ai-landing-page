<?php

use App\Http\Controllers\Admin\AdminAiSettingsController;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminDeploymentController;
use App\Http\Controllers\Admin\AdminFeedbackController;
use App\Http\Controllers\Admin\AdminLogController;
use App\Http\Controllers\Admin\AdminSystemController;
use App\Http\Controllers\Admin\AdminTemplateController;
use App\Http\Controllers\Admin\AdminUserController;
use App\Http\Controllers\Admin\AdminWebsiteController;
use App\Http\Controllers\PublicSiteController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// Root homepage / Editor canvas
Route::get('/', function () {
    if (request()->has('editor') || request()->is('canvas*')) {
        $editorHtml = public_path('index.html');
        if (file_exists($editorHtml)) {
            return response()->file($editorHtml, [
                'Content-Type' => 'text/html; charset=UTF-8',
            ]);
        }
    }
    return view('landing');
});

// Dedicated editor canvas route (always serves React WebView renderer)
Route::get('/canvas', function () {
    $editorHtml = public_path('index.html');
    if (file_exists($editorHtml)) {
        return response()->file($editorHtml, [
            'Content-Type' => 'text/html; charset=UTF-8',
        ]);
    }
    abort(404, 'Editor canvas not found');
});

// App-ads.txt for Start.io and mobile ad network crawlers
Route::get('/app-ads.txt', function () {
    $file = public_path('app-ads.txt');
    if (file_exists($file)) {
        return response(file_get_contents($file), 200, [
            'Content-Type' => 'text/plain; charset=UTF-8',
        ]);
    }
    abort(404);
});

// Android Digital Asset Links (App Links)
Route::get('/.well-known/assetlinks.json', function () {
    $file = public_path('.well-known/assetlinks.json');
    if (file_exists($file)) {
        return response(file_get_contents($file), 200, [
            'Content-Type' => 'application/json',
        ]);
    }
    abort(404);
});

// Legal: Privacy Policy & Terms of Service
Route::get('/privacy', function () {
    return view('privacy');
})->name('privacy');

Route::get('/privacy-policy', function () {
    return redirect('/privacy', 301);
});

Route::get('/terms', function () {
    return view('terms');
})->name('terms');

Route::get('/terms-of-service', function () {
    return redirect('/terms', 301);
});

// Admin Guest Routes (Login, Dev Quick-Login)
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
    Route::post('/login', [AdminAuthController::class, 'login'])->middleware('throttle:5,1')->name('admin.login.submit');
    Route::get('/quick-login', [AdminAuthController::class, 'quickLogin'])->name('admin.quick_login');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');
});

// Admin Protected Dashboard Routes
Route::prefix('admin')->middleware(['web', 'admin'])->group(function () {
    // Overview
    Route::get('/', [AdminDashboardController::class, 'index'])->name('admin.dashboard');

    // Templates Studio
    Route::get('/templates', [AdminTemplateController::class, 'index'])->name('admin.templates.index');
    Route::post('/templates', [AdminTemplateController::class, 'store'])->name('admin.templates.store');
    Route::post('/templates/convert-website', [AdminTemplateController::class, 'convertFromWebsite'])->name('admin.templates.convert_website');
    Route::post('/templates/import-url', [AdminTemplateController::class, 'importUrl'])->name('admin.templates.import_url');
    Route::get('/templates/{template}', [AdminTemplateController::class, 'show'])->name('admin.templates.show');
    Route::get('/templates/{template}/preview', [AdminTemplateController::class, 'preview'])->name('admin.templates.preview');
    Route::patch('/templates/{template}', [AdminTemplateController::class, 'update'])->name('admin.templates.update');
    Route::post('/templates/{template}/toggle-feature', [AdminTemplateController::class, 'toggleFeature'])->name('admin.templates.toggle_feature');
    Route::delete('/templates/{template}', [AdminTemplateController::class, 'destroy'])->name('admin.templates.destroy');

    // Websites Management
    Route::get('/websites', [AdminWebsiteController::class, 'index'])->name('admin.websites.index');
    Route::post('/websites/{website}/toggle-status', [AdminWebsiteController::class, 'toggleStatus'])->name('admin.websites.toggle_status');
    Route::post('/websites/{website}/convert-to-template', [AdminWebsiteController::class, 'convertToTemplate'])->name('admin.websites.convert_to_template');
    Route::delete('/websites/{website}', [AdminWebsiteController::class, 'destroy'])->name('admin.websites.destroy');

    // Users Management
    Route::get('/users', [AdminUserController::class, 'index'])->name('admin.users.index');
    Route::get('/users/{user}', [AdminUserController::class, 'show'])->name('admin.users.show');
    Route::post('/users/{user}/toggle-role', [AdminUserController::class, 'toggleRole'])->name('admin.users.toggle_role');

    // Avis & Feedback from Mobile ("Envoyer les avis")
    Route::get('/feedback', [AdminFeedbackController::class, 'index'])->name('admin.feedback.index');
    Route::patch('/feedback/{feedback}', [AdminFeedbackController::class, 'updateStatus'])->name('admin.feedback.update_status');
    Route::delete('/feedback/{feedback}', [AdminFeedbackController::class, 'destroy'])->name('admin.feedback.destroy');

    // Notifications Center (Send & View Notifications)
    Route::get('/notifications', [\App\Http\Controllers\Admin\AdminNotificationController::class, 'index'])->name('admin.notifications.index');
    Route::post('/notifications/send', [\App\Http\Controllers\Admin\AdminNotificationController::class, 'send'])->name('admin.notifications.send');
    Route::post('/notifications/remind-drafts', [\App\Http\Controllers\Admin\AdminNotificationController::class, 'triggerDraftReminders'])->name('admin.notifications.remind_drafts');
    Route::delete('/notifications/{notification}', [\App\Http\Controllers\Admin\AdminNotificationController::class, 'destroy'])->name('admin.notifications.destroy');

    // Logs & Error Monitoring (Payments, AI, System)
    Route::get('/logs', [AdminLogController::class, 'index'])->name('admin.logs.index');
    Route::post('/logs/clear', [AdminLogController::class, 'clear'])->name('admin.logs.clear');
    Route::post('/logs/{log}/resolve', [AdminLogController::class, 'resolve'])->name('admin.logs.resolve');

    // AI Model & OpenRouter Configuration
    Route::get('/ai-settings', [AdminAiSettingsController::class, 'index'])->name('admin.ai_settings.index');
    Route::post('/ai-settings', [AdminAiSettingsController::class, 'update'])->name('admin.ai_settings.update');
    Route::post('/ai-settings/test', [AdminAiSettingsController::class, 'testConnection'])->name('admin.ai_settings.test');

    // Deployments History
    Route::get('/deployments', [AdminDeploymentController::class, 'index'])->name('admin.deployments.index');

    // System Health & Diagnostics
    Route::get('/system', [AdminSystemController::class, 'index'])->name('admin.system.index');
    Route::post('/system/run-artisan', [AdminSystemController::class, 'runArtisan'])->name('admin.system.run_artisan');
});

// 1. Subdomain delivery: https://{subdomain}.our-domain.com/{path?}
$platformDomain = config('app.platform_domain');
if (!empty($platformDomain) && !in_array($platformDomain, ['localhost', '127.0.0.1'], true)) {
    $reservedSubdomains = implode('|', \App\Services\Hosting\CloudflareHostingService::RESERVED_SUBDOMAINS);
    Route::domain('{subdomain}.' . $platformDomain)->group(function () use ($reservedSubdomains) {
        Route::get('/{path?}', [PublicSiteController::class, 'serve'])
            ->where('subdomain', '^(?!(' . $reservedSubdomains . ')($|\.))[a-zA-Z0-9\-]+')
            ->where('path', '.*')
            ->name('public.site.subdomain');
    });
}

// 2. Explicit path-based delivery: https://our-domain.com/sites/{subdomain}/{path?}
Route::get('/sites/{subdomain}/{path?}', [PublicSiteController::class, 'serve'])
    ->where('subdomain', '^[a-zA-Z0-9\-]+$')
    ->where('path', '.*')
    ->name('public.site.prefixed');

// 3. Root path-based delivery: https://our-domain.com/{subdomain}/{path?}
$excludedPaths = implode('|', array_unique(array_merge(\App\Services\Hosting\CloudflareHostingService::RESERVED_SUBDOMAINS, ['sanctum', 'up', '_ignition', 'storage', 'hosting', 'assets', 'favicon', 'app-ads', 'canvas', 'sites', 'privacy', 'privacy-policy', 'terms', 'terms-of-service'])));
Route::get('/{subdomain}/{path?}', [PublicSiteController::class, 'serve'])
    ->where('subdomain', '^(?!(' . $excludedPaths . ')$)[a-zA-Z0-9\-]+$')
    ->where('path', '.*')
    ->name('public.site.path');
