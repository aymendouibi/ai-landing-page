<?php

namespace Database\Seeders;

use App\Enums\TemplateStatus;
use App\Enums\UserRole;
use App\Models\DesignRecipe;
use App\Models\Project;
use App\Models\SubscriptionPlan;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use App\Models\User;
use App\Services\Documents\DefaultDocumentFactory;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Users
        $admin = User::firstOrCreate(
            ['email' => 'admin@aibuilder.local'],
            [
                'name' => 'System Administrator',
                'password' => Hash::make('AdminSecret123!'),
                'role' => UserRole::Admin,
                'email_verified_at' => now(),
            ]
        );

        $demoUser = User::firstOrCreate(
            ['email' => 'user@aibuilder.local'],
            [
                'name' => 'Demo Creator',
                'password' => Hash::make('UserSecret123!'),
                'role' => UserRole::User,
                'email_verified_at' => now(),
            ]
        );

        // Demo Project
        $demoProject = Project::firstOrCreate(
            ['user_id' => $demoUser->id, 'name' => 'My First Brand'],
            ['description' => 'Demo workspace for testing websites']
        );

        // 2. Subscription Plans
        $freePlan = SubscriptionPlan::firstOrCreate(
            ['slug' => 'free'],
            [
                'name' => 'Free',
                'description' => 'Ad-supported free tier with 4 monthly AI generations, platform subdomain, and community templates.',
                'limits' => [
                    'max_websites' => 3,
                    'max_published' => 1,
                    'ai_generations_monthly' => 4,
                    'ai_edits_monthly' => 20,
                    'storage_mb' => 100,
                    'custom_domains' => 0,
                    'has_ads' => true,
                    'all_templates' => false,
                    'premium_templates' => false,
                    'ssl_enabled' => false,
                    'code_export' => false,
                ],
                'price_monthly' => 0,
                'price_annual' => 0,
                'is_active' => true,
                'sort_order' => 0,
            ]
        );

        $proPlan = SubscriptionPlan::firstOrCreate(
            ['slug' => 'pro'],
            [
                'name' => 'Premium',
                'description' => '100 AI generations, ad-free experience, custom domains with SSL, and all templates.',
                'limits' => [
                    'max_websites' => 100,
                    'max_published' => 25,
                    'ai_generations_monthly' => 100,
                    'ai_edits_monthly' => 500,
                    'storage_mb' => 5120,
                    'custom_domains' => 10,
                    'has_ads' => false,
                    'all_templates' => true,
                    'premium_templates' => true,
                    'ssl_enabled' => true,
                    'code_export' => true,
                ],
                'price_monthly' => 9.99,
                'price_annual' => 99.00,
                'is_active' => true,
                'sort_order' => 1,
            ]
        );

        $agencyPlan = SubscriptionPlan::firstOrCreate(
            ['slug' => 'business'],
            [
                'name' => 'Business & Agency',
                'description' => 'Maximum scale, team access, priority AI pipeline and unlimited domains.',
                'limits' => [
                    'max_websites' => 500,
                    'max_published' => 100,
                    'ai_generations_monthly' => 1000,
                    'ai_edits_monthly' => 5000,
                    'storage_mb' => 20480,
                    'custom_domains' => 50,
                    'premium_templates' => true,
                    'code_export' => true,
                ],
                'price_monthly' => 29.99,
                'price_annual' => 299.00,
                'is_active' => true,
                'sort_order' => 2,
            ]
        );

        // 3. Template Categories
        $categoriesData = [
            ['name' => 'SaaS & Apps', 'slug' => 'saas', 'icon' => 'server', 'sort_order' => 1],
            ['name' => 'Restaurants & Cafes', 'slug' => 'restaurants', 'icon' => 'utensils', 'sort_order' => 2],
            ['name' => 'Beauty & Skincare', 'slug' => 'beauty', 'icon' => 'sparkles', 'sort_order' => 3],
            ['name' => 'Health & Fitness', 'slug' => 'fitness', 'icon' => 'activity', 'sort_order' => 4],
            ['name' => 'Real Estate', 'slug' => 'real-estate', 'icon' => 'home', 'sort_order' => 5],
            ['name' => 'Portfolios', 'slug' => 'portfolios', 'icon' => 'briefcase', 'sort_order' => 6],
            ['name' => 'Photography', 'slug' => 'photography', 'icon' => 'camera', 'sort_order' => 7],
            ['name' => 'Agencies', 'slug' => 'agencies', 'icon' => 'layers', 'sort_order' => 8],
            ['name' => 'E-commerce Landing', 'slug' => 'ecommerce', 'icon' => 'shopping-bag', 'sort_order' => 9],
            ['name' => 'Local Businesses', 'slug' => 'local-business', 'icon' => 'map-pin', 'sort_order' => 10],
            ['name' => 'Professional Services', 'slug' => 'professional-services', 'icon' => 'check-circle', 'sort_order' => 11],
            ['name' => 'Events', 'slug' => 'events', 'icon' => 'calendar', 'sort_order' => 12],
            ['name' => 'Education', 'slug' => 'education', 'icon' => 'book-open', 'sort_order' => 13],
        ];

        $categoryModels = [];
        foreach ($categoriesData as $cat) {
            $categoryModels[$cat['slug']] = TemplateCategory::firstOrCreate(
                ['slug' => $cat['slug']],
                $cat
            );
        }

        // 4. Starter Templates
        $saasTemplate = Template::firstOrCreate(
            ['slug' => 'saas-apex'],
            [
                'category_id' => $categoryModels['saas']->id,
                'name' => 'Apex Cloud SaaS',
                'description' => 'Modern, high-converting tech landing page with hero split image, feature matrix, and clean pricing.',
                'industry' => 'SaaS',
                'preview_images' => ['https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=800&q=80'],
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 142,
                'is_premium' => false,
            ]
        );

        $saasDoc = DefaultDocumentFactory::createDefault('Apex Cloud', [
            'colors' => [
                'primary' => '#4F46E5',
                'secondary' => '#06B6D4',
                'accent' => '#10B981',
                'background' => '#0B0F19',
                'surface' => '#111827',
                'text' => [
                    'primary' => '#F9FAFB',
                    'secondary' => '#9CA3AF',
                    'inverse' => '#0B0F19',
                ],
            ],
        ]);

        TemplateVersion::firstOrCreate(
            ['template_id' => $saasTemplate->id, 'version' => 1],
            [
                'document' => $saasDoc,
                'design_tokens' => $saasDoc['site']['theme'],
                'fonts' => ['Inter'],
                'is_active' => true,
            ]
        );

        $restaurantTemplate = Template::firstOrCreate(
            ['slug' => 'bistro-verona'],
            [
                'category_id' => $categoryModels['restaurants']->id,
                'name' => 'Bistro Verona',
                'description' => 'Warm Italian bistro atmosphere with menu highlights, opening hours, and reservation CTA.',
                'industry' => 'Restaurant',
                'preview_images' => ['https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80'],
                'status' => TemplateStatus::Published,
                'license_type' => 'internal',
                'author' => 'AI Builder Studio',
                'use_count' => 88,
                'is_premium' => false,
            ]
        );

        $restaurantDoc = DefaultDocumentFactory::createDefault('Bistro Verona', [
            'colors' => [
                'primary' => '#B45309',
                'secondary' => '#78350F',
                'accent' => '#D97706',
                'background' => '#FFFBEB',
                'surface' => '#FEF3C7',
                'text' => [
                    'primary' => '#451A03',
                    'secondary' => '#78350F',
                    'inverse' => '#FFFFFF',
                ],
            ],
            'typography' => [
                'headingFamily' => 'Playfair Display',
                'bodyFamily' => 'Lora',
            ],
        ]);

        TemplateVersion::firstOrCreate(
            ['template_id' => $restaurantTemplate->id, 'version' => 1],
            [
                'document' => $restaurantDoc,
                'design_tokens' => $restaurantDoc['site']['theme'],
                'fonts' => ['Playfair Display', 'Lora'],
                'is_active' => true,
            ]
        );

        // 5. Design Recipes
        DesignRecipe::firstOrCreate(
            ['slug' => 'saas-modern'],
            [
                'name' => 'SaaS Modern Tech',
                'slug' => 'saas-modern',
                'industry' => 'SaaS',
                'description' => 'High contrast modern tech aesthetic with dark mode and cyan/indigo accents.',
                'theme' => [
                    'colors' => [
                        'primary' => '#4F46E5',
                        'secondary' => '#06B6D4',
                        'accent' => '#10B981',
                        'background' => '#0F172A',
                        'surface' => '#1E293B',
                    ],
                    'typography' => ['heading' => 'Inter', 'body' => 'Inter'],
                ],
                'layout_rules' => [
                    'containerMaxWidth' => '1200px',
                    'sectionPadding' => '5rem 1.5rem',
                ],
                'component_recommendations' => ['hero', 'features', 'statistics', 'pricing', 'testimonials', 'faq', 'cta'],
                'image_direction' => ['style' => 'minimal_mockups', 'mood' => 'professional_tech'],
                'is_active' => true,
            ]
        );

        DesignRecipe::firstOrCreate(
            ['slug' => 'skincare-luxury'],
            [
                'name' => 'Luxury Skincare & Wellness',
                'slug' => 'skincare-luxury',
                'industry' => 'Beauty',
                'description' => 'Editorial layout, elegant serif typography, warm cream backgrounds, and dark brown text.',
                'theme' => [
                    'colors' => [
                        'primary' => '#78350F',
                        'secondary' => '#92400E',
                        'accent' => '#D97706',
                        'background' => '#FAFAF9',
                        'surface' => '#F5F5F4',
                    ],
                    'typography' => ['heading' => 'Playfair Display', 'body' => 'Plus Jakarta Sans'],
                ],
                'layout_rules' => [
                    'containerMaxWidth' => '1100px',
                    'sectionPadding' => '6rem 2rem',
                ],
                'component_recommendations' => ['hero', 'about', 'benefits', 'products', 'testimonials', 'newsletter'],
                'image_direction' => ['style' => 'high_end_photography', 'mood' => 'calm_editorial'],
                'is_active' => true,
            ]
        );
    }
}
