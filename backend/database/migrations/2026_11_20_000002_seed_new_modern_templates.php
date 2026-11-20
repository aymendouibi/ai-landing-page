<?php

use Illuminate\Database\Migrations\Migration;
use Database\Seeders\CuratedTemplatesSeeder;

return new class extends Migration
{
    public function up(): void
    {
        (new CuratedTemplatesSeeder)->run();
    }

    public function down(): void
    {
        \App\Models\Template::whereIn('slug', [
            'lumiere-cinema',
            'terrain-outdoors',
            'noor-atelier',
            'vela-sailing',
            'ora-mindful',
        ])->each(function ($t) {
            $t->versions()->delete();
            $t->delete();
        });
    }
};
