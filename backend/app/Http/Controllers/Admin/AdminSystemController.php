<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\View\View;

class AdminSystemController extends Controller
{
    /**
     * Display system diagnostic and environment info.
     */
    public function index(Request $request): View
    {
        $dbStatus = 'Connected';
        $dbError = null;
        try {
            DB::connection()->getPdo();
        } catch (\Throwable $e) {
            $dbStatus = 'Disconnected';
            $dbError = $e->getMessage();
        }

        $rendererUrl = config('services.renderer.url', 'http://127.0.0.1:3000');
        $rendererStatus = 'Unknown';
        try {
            $res = Http::timeout(2)->get("{$rendererUrl}/health");
            $rendererStatus = $res->successful() ? 'Online' : 'Warning: HTTP ' . $res->status();
        } catch (\Throwable) {
            $rendererStatus = 'Offline or Unreachable';
        }

        $diskFree = @disk_free_space(base_path());
        $diskTotal = @disk_total_space(base_path());
        $diskFreeFormatted = $diskFree !== false ? round($diskFree / (1024 * 1024 * 1024), 2) . ' GB' : 'N/A';
        $diskTotalFormatted = $diskTotal !== false ? round($diskTotal / (1024 * 1024 * 1024), 2) . ' GB' : 'N/A';

        $systemInfo = [
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
            'environment' => app()->environment(),
            'debug_mode' => config('app.debug') ? 'Enabled (True)' : 'Disabled (False)',
            'platform_domain' => config('app.platform_domain') ?: 'Not configured (using path-based /sites/{subdomain})',
            'app_url' => config('app.url'),
            'renderer_url' => $rendererUrl,
            'renderer_status' => $rendererStatus,
            'db_driver' => config('database.default'),
            'db_host' => config('database.connections.' . config('database.default') . '.host', '127.0.0.1'),
            'db_database' => config('database.connections.' . config('database.default') . '.database', 'forge'),
            'db_status' => $dbStatus,
            'db_error' => $dbError,
            'cache_driver' => config('cache.default'),
            'queue_driver' => config('queue.default'),
            'session_driver' => config('session.driver'),
            'disk_free' => $diskFreeFormatted,
            'disk_total' => $diskTotalFormatted,
        ];

        return view('admin.system', compact('systemInfo'));
    }
}

