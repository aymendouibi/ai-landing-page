<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('design_recipes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('industry')->nullable();
            $table->text('description')->nullable();
            $table->jsonb('theme');
            $table->jsonb('layout_rules')->nullable();
            $table->jsonb('component_recommendations')->nullable();
            $table->jsonb('image_direction')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('industry');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('design_recipes');
    }
};
