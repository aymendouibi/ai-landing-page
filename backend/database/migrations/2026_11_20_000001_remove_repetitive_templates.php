<?php

use App\Models\Template;
use App\Models\TemplateVersion;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Run the migrations to remove repetitive and redundant templates.
     */
    public function up(): void
    {
        $repetitiveSlugs = [
            'nordic-craft',
            'elena-rostova',
            'elysian-vows',
            'botanical-vows',
            'kroma-studio-modern',
            'saas-apex',
            'bistro-verona',
        ];

        $templates = Template::whereIn('slug', $repetitiveSlugs)->get();
        foreach ($templates as $template) {
            TemplateVersion::where('template_id', $template->id)->delete();
            $template->forceDelete();
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Irreversible cleanup of repetitive duplicate templates.
    }
};
