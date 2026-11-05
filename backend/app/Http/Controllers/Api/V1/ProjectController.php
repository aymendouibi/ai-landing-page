<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Projects\StoreProjectRequest;
use App\Http\Requests\Projects\UpdateProjectRequest;
use App\Models\Project;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ProjectController extends Controller
{
    /**
     * List user projects.
     */
    public function index(Request $request): JsonResponse
    {
        $projects = Project::where('user_id', $request->user()->id)
            ->withCount('websites')
            ->orderByDesc('created_at')
            ->paginate($request->integer('per_page', 20));

        return response()->json($projects);
    }

    /**
     * Store a new project.
     */
    public function store(StoreProjectRequest $request): JsonResponse
    {
        $project = Project::create([
            'user_id' => $request->user()->id,
            'name' => $request->validated('name'),
            'description' => $request->validated('description'),
        ]);

        return response()->json([
            'message' => 'Project created successfully.',
            'project' => $project,
        ], 201);
    }

    /**
     * Show a specific project and its websites.
     */
    public function show(Project $project): JsonResponse
    {
        Gate::authorize('view', $project);

        $project->load(['websites' => function ($query) {
            $query->orderByDesc('updated_at');
        }]);

        return response()->json([
            'project' => $project,
        ]);
    }

    /**
     * Update project metadata.
     */
    public function update(UpdateProjectRequest $request, Project $project): JsonResponse
    {
        Gate::authorize('update', $project);

        $project->update($request->validated());

        return response()->json([
            'message' => 'Project updated successfully.',
            'project' => $project,
        ]);
    }

    /**
     * Delete a project.
     */
    public function destroy(Project $project): JsonResponse
    {
        Gate::authorize('delete', $project);

        $project->delete();

        return response()->json([
            'message' => 'Project deleted successfully.',
        ]);
    }
}

