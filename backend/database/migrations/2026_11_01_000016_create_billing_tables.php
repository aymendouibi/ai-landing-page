<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->jsonb('limits');
            $table->decimal('price_monthly', 8, 2)->nullable();
            $table->decimal('price_annual', 8, 2)->nullable();
            $table->string('stripe_price_monthly_id')->nullable();
            $table->string('stripe_price_annual_id')->nullable();
            $table->string('google_play_product_id')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('billing_customers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('stripe_customer_id')->unique()->nullable();
            $table->string('google_play_token')->nullable();
            $table->timestamps();
        });

        Schema::create('subscriptions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('plan_id')->constrained('subscription_plans')->restrictOnDelete();
            $table->string('status')->default('active');
            $table->string('provider');
            $table->string('provider_subscription_id')->nullable();
            $table->timestamp('current_period_start')->nullable();
            $table->timestamp('current_period_end')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index(['status', 'provider']);
        });

        Schema::create('billing_events', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('billing_customer_id')->constrained('billing_customers')->cascadeOnDelete();
            $table->string('provider');
            $table->string('event_type');
            $table->string('provider_event_id')->unique()->nullable();
            $table->jsonb('payload')->nullable();
            $table->boolean('processed')->default(false);
            $table->timestamps();

            $table->index(['provider', 'event_type']);
            $table->index('provider_event_id');
        });

        Schema::create('usage_records', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('metric');
            $table->integer('quantity')->default(1);
            $table->string('period');
            $table->timestamps();

            $table->index(['user_id', 'metric', 'period']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('usage_records');
        Schema::dropIfExists('billing_events');
        Schema::dropIfExists('subscriptions');
        Schema::dropIfExists('billing_customers');
        Schema::dropIfExists('subscription_plans');
    }
};
