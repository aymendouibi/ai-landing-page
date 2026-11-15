<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('templates', function (Blueprint $table) {
            $table->foreignUuid('user_id')->nullable()->after('id')->constrained('users')->nullOnDelete();
            $table->string('badge')->nullable()->after('industry');
            $table->boolean('is_featured')->default(false)->after('badge');
            $table->boolean('is_public')->default(true)->after('is_featured');
            $table->foreignUuid('source_website_id')->nullable()->after('is_public')->constrained('websites')->nullOnDelete();

            $table->index('is_featured');
            $table->index('is_public');
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::table('templates', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropForeign(['source_website_id']);
            $table->dropColumn(['user_id', 'badge', 'is_featured', 'is_public', 'source_website_id']);
        });
    }
};

