<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feedbacks', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('category')->default('general'); // feature, bug, ai, general
            $table->text('message');
            $table->unsignedTinyInteger('rating')->nullable(); // 1 to 5
            $table->string('status')->default('new'); // new, reviewed, resolved
            $table->jsonb('metadata')->nullable(); // platform, os, app_version, user_email
            $table->text('admin_notes')->nullable();
            $table->timestamps();

            $table->index(['status', 'created_at']);
            $table->index('category');
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feedbacks');
    }
};
