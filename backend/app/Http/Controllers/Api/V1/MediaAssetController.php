<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MediaAssetController extends Controller
{
    /**
     * List user media assets.
     */
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $assets = MediaAsset::where('user_id', $userId)
            ->when($request->query('website_id'), fn ($q, $wId) => $q->where('website_id', $wId))
            ->when($request->query('search'), function ($q, $search) {
                $q->where(function ($sub) use ($search) {
                    $sub->where('original_filename', 'like', "%{$search}%")
                        ->orWhere('filename', 'like', "%{$search}%");
                });
            })
            ->with('website:id,name,slug')
            ->orderByDesc('created_at')
            ->paginate($request->integer('per_page', 30));

        return response()->json($assets);
    }

    /**
     * Store/upload a new media asset.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'website_id' => 'nullable|uuid|exists:websites,id',
            'file' => 'nullable|file|max:20480',
            'url' => 'nullable|url|max:2048',
            'filename' => 'nullable|string|max:255',
            'mime_type' => 'nullable|string|max:100',
            'file_size' => 'nullable|integer',
            'metadata' => 'nullable|array',
        ]);

        $userId = $request->user()->id;

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $originalFilename = $file->getClientOriginalName();
            $path = $file->store("media/{$userId}", 'public');
            $url = "/storage/{$path}";
            $mimeType = $file->getClientMimeType() ?? 'image/jpeg';
            $fileSize = $file->getSize();
        } else {
            $url = $validated['url'] ?? '';
            $originalFilename = $validated['filename'] ?? (basename(parse_url($url, PHP_URL_PATH) ?? '') ?: 'asset.jpg');
            $mimeType = $validated['mime_type'] ?? 'image/jpeg';
            $fileSize = $validated['file_size'] ?? 1024000;
            $path = $url;
        }

        $asset = MediaAsset::create([
            'user_id' => $userId,
            'website_id' => $validated['website_id'] ?? null,
            'original_filename' => $originalFilename,
            'filename' => $originalFilename,
            'mime_type' => $mimeType,
            'file_size' => $fileSize,
            'storage_path' => $path,
            'storage_disk' => 'public',
            'url' => $url,
            'metadata' => $validated['metadata'] ?? [],
        ]);

        return response()->json([
            'message' => 'Asset uploaded successfully.',
            'asset' => $asset,
        ], 201);
    }

    /**
     * Show a specific media asset.
     */
    public function show(Request $request, MediaAsset $asset): JsonResponse
    {
        if ($asset->user_id !== $request->user()->id) {
            abort(403, 'Unauthorized');
        }

        return response()->json($asset->load('website:id,name,slug'));
    }

    /**
     * Delete a media asset.
     */
    public function destroy(Request $request, MediaAsset $asset): JsonResponse
    {
        if ($asset->user_id !== $request->user()->id) {
            abort(403, 'Unauthorized');
        }

        $asset->delete();

        return response()->json([
            'message' => 'Asset deleted successfully.',
        ]);
    }
}

