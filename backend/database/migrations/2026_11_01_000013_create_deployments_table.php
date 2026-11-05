<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('deployments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('website_id')->constrained('websites')->cascadeOnDelete();
            $table->foreignUuid('revision_id')->nullable()->constrained('website_revisions')->nullOnDelete();
            $table->string('status')->default('pending');
            $table->string('storage_path')->nullable();
            $table->jsonb('domains_deployed')->nullable();
            $table->jsonb('build_log')->nullable();
            $table->timestamp('deployed_at')->nullable();
            $table->timestamps();

            $table->index('website_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('deployments');
    }
};
