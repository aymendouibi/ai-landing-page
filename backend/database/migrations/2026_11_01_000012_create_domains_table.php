<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('domains', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('website_id')->constrained('websites')->cascadeOnDelete();
            $table->string('domain')->unique();
            $table->string('type')->default('custom');
            $table->string('status')->default('pending');
            $table->string('verification_token')->nullable();
            $table->string('provider_hostname_id')->nullable();
            $table->jsonb('ssl_status')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();

            $table->index('website_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('domains');
    }
};
