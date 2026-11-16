<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Feedback;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminFeedbackController extends Controller
{
    /**
     * Display a listing of feedback / reviews sent from mobile.
     */
    public function index(Request $request): View
    {
        $status = $request->query('status');
        $category = $request->query('category');
        $search = $request->query('search');

        $query = Feedback::with(['user.subscription.plan'])
            ->when($status, fn ($q) => $q->where('status', $status))
            ->when($category, fn ($q) => $q->where('category', $category))
            ->when($search, function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('message', 'ilike', "%{$search}%")
                        ->orWhereHas('user', function ($u) use ($search) {
                            $u->where('name', 'ilike', "%{$search}%")
                              ->orWhere('email', 'ilike', "%{$search}%");
                        });
                });
            })
            ->orderByDesc('created_at');

        $feedbacks = $query->paginate(15);

        $metrics = [
            'total' => Feedback::count(),
            'new' => Feedback::where('status', 'new')->count(),
            'reviewed' => Feedback::where('status', 'reviewed')->count(),
            'resolved' => Feedback::where('status', 'resolved')->count(),
            'features' => Feedback::where('category', 'feature')->count(),
            'bugs' => Feedback::where('category', 'bug')->count(),
            'ai_quality' => Feedback::where('category', 'ai_quality')->count(),
        ];

        return view('admin.feedback', [
            'feedbacks' => $feedbacks,
            'metrics' => $metrics,
            'currentStatus' => $status,
            'currentCategory' => $category,
            'search' => $search,
        ]);
    }

    /**
     * Update the review status of feedback.
     */
    public function updateStatus(Request $request, Feedback $feedback): RedirectResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:new,reviewed,resolved'],
            'admin_notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $feedback->update($validated);

        return back()->with('success', "Avis #{$feedback->id} mis à jour avec le statut '{$feedback->status}'.");
    }

    /**
     * Remove feedback record.
     */
    public function destroy(Feedback $feedback): RedirectResponse
    {
        $feedback->delete();

        return back()->with('success', 'Avis supprimé avec succès.');
    }
}
