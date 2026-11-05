<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_assets', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('website_id')->nullable()->constrained('websites')->nullOnDelete();
            $table->string('original_filename');
            $table->string('filename');
            $table->string('mime_type');
            $table->integer('file_size');
            $table->string('storage_path');
            $table->string('storage_disk')->default('local');
            $table->string('url')->nullable();
            $table->jsonb('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('website_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_assets');
    }
};
