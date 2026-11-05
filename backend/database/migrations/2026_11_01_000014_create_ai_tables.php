<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_model_configs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('task');
            $table->string('provider')->default('openrouter');
            $table->string('model');
            $table->jsonb('capabilities')->nullable();
            $table->jsonb('parameters')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('priority')->default(0);
            $table->timestamps();

            $table->index(['task', 'is_active']);
        });

        Schema::create('ai_jobs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('website_id')->nullable()->constrained('websites')->nullOnDelete();
            $table->string('type');
            $table->string('status')->default('pending');
            $table->jsonb('input')->nullable();
            $table->jsonb('result')->nullable();
            $table->string('model_used')->nullable();
            $table->integer('tokens_input')->default(0);
            $table->integer('tokens_output')->default(0);
            $table->decimal('cost', 8, 6)->default(0);
            $table->integer('progress')->default(0);
            $table->text('error')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('website_id');
            $table->index(['status', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_jobs');
        Schema::dropIfExists('ai_model_configs');
    }
};
