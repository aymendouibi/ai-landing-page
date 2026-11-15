<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminDeploymentController;
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

// Root homepage
Route::get('/', function () {
    return view('welcome');
});

// Admin Guest Routes (Login, Dev Quick-Login)
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('admin.login.submit');
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
    Route::post('/users/{user}/toggle-role', [AdminUserController::class, 'toggleRole'])->name('admin.users.toggle_role');

    // Deployments History
    Route::get('/deployments', [AdminDeploymentController::class, 'index'])->name('admin.deployments.index');

    // System Health & Diagnostics
    Route::get('/system', [AdminSystemController::class, 'index'])->name('admin.system.index');
});

// 1. Subdomain delivery: https://{subdomain}.our-domain.com/{path?}
$platformDomain = config('app.platform_domain');
if (!empty($platformDomain) && !in_array($platformDomain, ['localhost', '127.0.0.1'], true)) {
    Route::domain('{subdomain}.' . $platformDomain)->group(function () {
        Route::get('/{path?}', [PublicSiteController::class, 'serve'])
            ->where('subdomain', '^[a-zA-Z0-9\-]+$')
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
Route::get('/{subdomain}/{path?}', [PublicSiteController::class, 'serve'])
    ->where('subdomain', '^(?!admin|api|sanctum|up|_ignition|storage|hosting)[a-zA-Z0-9\-]+$')
    ->where('path', '.*')
    ->name('public.site.path');
