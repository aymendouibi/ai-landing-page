<?php

namespace App\Http\Controllers\Admin;

use App\Enums\DeploymentStatus;
use App\Http\Controllers\Controller;
use App\Models\Deployment;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminDeploymentController extends Controller
{
    /**
     * Display a listing of system deployments.
     */
    public function index(Request $request): View
    {
        $query = Deployment::with(['website.project.user', 'revision'])
            ->when($request->query('status'), fn ($q, $status) => $q->where('status', $status))
            ->when($request->query('search'), function ($q, $search) {
                $q->whereHas('website', function ($sub) use ($search) {
                    $sub->where('name', 'ilike', "%{$search}%")
                        ->orWhere('subdomain', 'ilike', "%{$search}%");
                });
            });

        $deployments = $query->orderByDesc('created_at')->paginate(20);

        $metrics = [
            'total' => Deployment::count(),
            'deployed' => Deployment::where('status', DeploymentStatus::Deployed)->count(),
            'failed' => Deployment::where('status', DeploymentStatus::Failed)->count(),
            'pending' => Deployment::whereIn('status', [DeploymentStatus::Pending, DeploymentStatus::Building, DeploymentStatus::Deploying])->count(),
        ];

        return view('admin.deployments', [
            'deployments' => $deployments,
            'metrics' => $metrics,
        ]);
    }
}

