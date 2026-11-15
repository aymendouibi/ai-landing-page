<?php

namespace App\Http\Middleware;

use App\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!auth()->check()) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json(['message' => 'Unauthenticated.'], 401);
            }

            return redirect()->route('admin.login')->with('error', 'Please sign in with administrator credentials to access the admin dashboard.');
        }

        if (auth()->user()->role !== UserRole::Admin) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json(['message' => 'Forbidden. Admin privileges required.'], 403);
            }

            abort(403, 'Unauthorized access: administrator privileges required.');
        }

        return $next($request);
    }
}

