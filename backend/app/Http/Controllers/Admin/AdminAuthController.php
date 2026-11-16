<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class AdminAuthController extends Controller
{
    /**
     * Display the admin login view.
     */
    public function showLogin(): View|RedirectResponse
    {
        if (Auth::check() && Auth::user()->isAdmin()) {
            return redirect()->route('admin.dashboard');
        }

        return view('admin.login');
    }

    /**
     * Handle an admin login attempt.
     */
    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $remember = $request->boolean('remember');

        if (!Auth::attempt($credentials, $remember)) {
            return back()->withErrors([
                'email' => 'The provided credentials do not match our records.',
            ])->onlyInput('email');
        }

        /** @var User $user */
        $user = Auth::user();

        if (!$user->isAdmin()) {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return back()->withErrors([
                'email' => 'Your account does not have administrator privileges.',
            ])->onlyInput('email');
        }

        $request->session()->regenerate();

        return redirect()->intended(route('admin.dashboard'))->with('success', 'Welcome back to the Admin Dashboard!');
    }

    /**
     * Quick 1-click dev login as administrator.
     */
    public function quickLogin(Request $request): RedirectResponse
    {
        if (!app()->isLocal()) {
            abort(403, '1-Click developer login is disabled in production.');
        }

        $admin = User::firstOrCreate(
            ['email' => 'admin@aibuilder.local'],
            [
                'name' => 'System Administrator',
                'password' => Hash::make('AdminSecret123!'),
                'role' => UserRole::Admin,
                'email_verified_at' => now(),
            ]
        );

        if ($admin->role !== UserRole::Admin) {
            $admin->update(['role' => UserRole::Admin]);
        }

        Auth::login($admin, true);
        $request->session()->regenerate();

        return redirect()->route('admin.dashboard')->with('success', 'Signed in as System Administrator (1-click dev login).');
    }

    /**
     * Log out of the admin session.
     */
    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login')->with('success', 'You have been signed out successfully.');
    }
}

