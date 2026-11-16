<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('app_error_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('category')->default('system'); // payment, ai, system, auth
            $table->string('severity')->default('error'); // error, warning, critical, info
            $table->foreignUuid('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->text('message');
            $table->string('exception_class')->nullable();
            $table->jsonb('context')->nullable();
            $table->text('stack_trace')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['category', 'created_at']);
            $table->index('severity');
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('app_error_logs');
    }
};
