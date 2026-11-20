<?php

namespace App\Http\Controllers\Admin;

use App\Enums\DeploymentStatus;
use App\Enums\WebsiteStatus;
use App\Http\Controllers\Controller;
use App\Models\Deployment;
use App\Models\Project;
use App\Models\SubscriptionPlan;
use App\Models\Template;
use App\Models\User;
use App\Models\Website;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminDashboardController extends Controller
{
    /**
     * Display the Admin Dashboard overview.
     */
    public function index(Request $request): View
    {
        $metrics = [
            'total_users' => User::count(),
            'total_projects' => Project::count(),
            'total_websites' => Website::count(),
            'published_websites' => Website::where('status', WebsiteStatus::Published)->count(),
            'draft_websites' => Website::where('status', WebsiteStatus::Draft)->count(),
            'total_deployments' => Deployment::count(),
            'successful_deployments' => Deployment::where('status', DeploymentStatus::Deployed)->count(),
            'total_templates' => Template::count(),
            'curated_templates' => Template::where('is_featured', true)->count(),
            'total_template_uses' => (int) Template::sum('use_count'),
        ];

        $recentWebsites = Website::with(['project.user', 'currentRevision'])
            ->latest('updated_at')
            ->take(8)
            ->get();

        $recentUsers = User::withCount(['projects'])
            ->with(['subscription.plan'])
            ->latest('created_at')
            ->take(6)
            ->get();

        $plans = SubscriptionPlan::where('slug', '!=', 'free')
            ->orderBy('sort_order')
            ->get();

        $recentDeployments = Deployment::with(['website'])
            ->latest('created_at')
            ->take(6)
            ->get();

        $topTemplates = Template::with(['category'])
            ->orderByDesc('use_count')
            ->take(4)
            ->get();

        return view('admin.dashboard', [
            'metrics' => $metrics,
            'recentWebsites' => $recentWebsites,
            'recentUsers' => $recentUsers,
            'plans' => $plans,
            'recentDeployments' => $recentDeployments,
            'topTemplates' => $topTemplates,
        ]);
    }
}

