<?php

use App\Models\SubscriptionPlan;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        $pro = SubscriptionPlan::where('slug', 'pro')->first();
        if ($pro) {
            $limits = $pro->limits ?? [];
            $limits['max_websites'] = 100;
            $limits['max_published'] = 25;
            $limits['custom_domains'] = 10;
            $limits['storage_mb'] = 5120;
            $limits['ai_generations_monthly'] = 100;
            $pro->update(['limits' => $limits]);
        }

        $business = SubscriptionPlan::where('slug', 'business')->first();
        if ($business) {
            $limits = $business->limits ?? [];
            $limits['max_websites'] = 500;
            $limits['max_published'] = 100;
            $limits['custom_domains'] = 50;
            $limits['storage_mb'] = 20480;
            $business->update(['limits' => $limits]);
        }
    }

    public function down(): void
    {
        $pro = SubscriptionPlan::where('slug', 'pro')->first();
        if ($pro) {
            $limits = $pro->limits ?? [];
            $limits['max_websites'] = 15;
            $limits['max_published'] = 5;
            $limits['custom_domains'] = 5;
            $limits['storage_mb'] = 2048;
            $limits['ai_generations_monthly'] = 90;
            $pro->update(['limits' => $limits]);
        }
    }
};

