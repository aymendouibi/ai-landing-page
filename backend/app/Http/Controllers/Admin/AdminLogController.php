<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppErrorLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Illuminate\View\View;

class AdminLogController extends Controller
{
    /**
     * Display a listing of system, payment, and AI error logs.
     */
    public function index(Request $request): View
    {
        $category = $request->query('category');
        $severity = $request->query('severity');
        $search = $request->query('search');

        $query = AppErrorLog::with(['user'])
            ->when($category, fn ($q) => $q->where('category', $category))
            ->when($severity, fn ($q) => $q->where('severity', $severity))
            ->when($search, function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('message', 'ilike', "%{$search}%")
                        ->orWhere('exception_class', 'ilike', "%{$search}%")
                        ->orWhereHas('user', function ($u) use ($search) {
                            $u->where('name', 'ilike', "%{$search}%")
                              ->orWhere('email', 'ilike', "%{$search}%");
                        });
                });
            })
            ->orderByDesc('created_at');

        $logs = $query->paginate(20);

        $metrics = [
            'total' => AppErrorLog::count(),
            'payment' => AppErrorLog::where('category', 'payment')->count(),
            'ai' => AppErrorLog::where('category', 'ai')->count(),
            'auth' => AppErrorLog::where('category', 'auth')->count(),
            'system' => AppErrorLog::where('category', 'system')->count(),
            'unresolved' => AppErrorLog::whereNull('resolved_at')->count(),
        ];

        // Also check if laravel.log has recent entries for reference
        $laravelLogLines = [];
        $logPath = storage_path('logs/laravel.log');
        if (File::exists($logPath)) {
            $lines = @file($logPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
            $laravelLogLines = array_slice($lines, -30);
        }

        return view('admin.logs', [
            'logs' => $logs,
            'metrics' => $metrics,
            'currentCategory' => $category,
            'currentSeverity' => $severity,
            'search' => $search,
            'laravelLogLines' => $laravelLogLines,
        ]);
    }

    /**
     * Mark an error log as resolved.
     */
    public function resolve(AppErrorLog $log): RedirectResponse
    {
        $log->update(['resolved_at' => now()]);

        return back()->with('success', 'Error log marked as resolved.');
    }

    /**
     * Clear all error logs or resolved logs.
     */
    public function clear(Request $request): RedirectResponse
    {
        if ($request->input('mode') === 'all') {
            AppErrorLog::truncate();
            $msg = 'All error logs have been cleared.';
        } else {
            AppErrorLog::whereNotNull('resolved_at')->delete();
            $msg = 'All resolved error logs have been cleared.';
        }

        return back()->with('success', $msg);
    }
}
