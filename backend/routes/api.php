<?php

use App\Http\Controllers\Api\V1\AiController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\FormController;
use App\Http\Controllers\Api\V1\ProjectController;
use App\Http\Controllers\Api\V1\TemplateController;
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

        // Websites
        Route::apiResource('websites', WebsiteController::class);
        Route::prefix('websites/{website}')->group(function () {
            Route::put('/document', [WebsiteController::class, 'updateDocument']);
            Route::get('/revisions', [WebsiteController::class, 'revisions']);
            Route::post('/revisions/{revision}/restore', [WebsiteController::class, 'restoreRevision']);
            Route::post('/lock', [WebsiteController::class, 'acquireLock']);
            Route::post('/unlock', [WebsiteController::class, 'releaseLock']);
            Route::get('/forms/{form}/submissions', [FormController::class, 'submissions']);
        });

        // Template usage
        Route::post('/templates/{template}/use', [TemplateController::class, 'use']);

        // AI System
        Route::prefix('ai')->group(function () {
            Route::post('/plan', [AiController::class, 'plan']);
            Route::post('/generate', [AiController::class, 'generate']);
            Route::post('/remix', [AiController::class, 'remix']);
            Route::post('/edit', [AiController::class, 'edit']);
            Route::get('/jobs/{job}', [AiController::class, 'getJob']);
        });
    });
});
