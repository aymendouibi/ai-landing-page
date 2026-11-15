<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AdminUserController extends Controller
{
    /**
     * Display a listing of all users.
     */
    public function index(Request $request): View
    {
        $query = User::withCount(['projects'])
            ->when($request->query('role'), fn ($q, $role) => $q->where('role', $role))
            ->when($request->query('search'), function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('name', 'ilike', "%{$search}%")
                        ->orWhere('email', 'ilike', "%{$search}%");
                });
            });

        $users = $query->orderByDesc('created_at')->paginate(15);

        $metrics = [
            'total' => User::count(),
            'admins' => User::where('role', UserRole::Admin)->count(),
            'users' => User::where('role', UserRole::User)->count(),
            'verified' => User::whereNotNull('email_verified_at')->count(),
        ];

        return view('admin.users', [
            'users' => $users,
            'metrics' => $metrics,
        ]);
    }

    /**
     * Toggle a user's role between Admin and standard User.
     */
    public function toggleRole(User $user): RedirectResponse
    {
        if ($user->role === UserRole::Admin) {
            // Safety guard: prevent demoting oneself
            if (Auth::id() === $user->id) {
                return back()->with('error', 'You cannot demote your own administrator account.');
            }

            // Safety guard: ensure at least one admin remains
            $adminCount = User::where('role', UserRole::Admin)->count();
            if ($adminCount <= 1) {
                return back()->with('error', 'Cannot demote the last administrator in the system.');
            }

            $user->update(['role' => UserRole::User]);
            $msg = "User '{$user->name}' demoted to standard user.";
        } else {
            $user->update(['role' => UserRole::Admin]);
            $msg = "User '{$user->name}' promoted to Administrator.";
        }

        return back()->with('success', $msg);
    }
}

