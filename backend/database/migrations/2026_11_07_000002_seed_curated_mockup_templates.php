<?php

use App\Enums\TemplateStatus;
use App\Models\Template;
use App\Models\TemplateCategory;
use App\Models\TemplateVersion;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        $catRestaurant = TemplateCategory::where('slug', 'restaurants')->first();
        $catPortfolio = TemplateCategory::where('slug', 'portfolios')->first();
        $catFitness = TemplateCategory::where('slug', 'fitness')->first();
        $catEvents = TemplateCategory::where('slug', 'events')->first();

        $templates = [
            [
                'name' => 'Lumen Coffee',
                'slug' => 'lumen-coffee',
                'category_id' => $catRestaurant?->id,
                'industry' => 'Food & drink',
                'badge' => "EDITOR'S PICK",
                'is_featured' => true,
                'description' => "Warm tones and rich storytelling for your neighborhood's next favorite.",
                'author' => 'AI Builder Studio',
                'preview_images' => ['https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=1200&q=80'],
                'headline' => 'Good coffee. Better mornings.',
                'subheadline' => 'Single-origin beans from farms we visit, roasted in our shop and shipped same day.',
                'ctaText' => 'Explore our coffee',
                'primaryColor' => '#9E4B28',
                'bgColor' => '#FAF7F2',
                'textColor' => '#2C241E',
                'font' => 'Playfair Display',
            ],
            [
                'name' => 'Studio Marlow',
                'slug' => 'studio-marlow',
                'category_id' => $catPortfolio?->id,
                'industry' => 'Portfolio · Architecture',
                'badge' => 'QUIETLY BOLD',
                'is_featured' => true,
                'description' => 'An understated canvas that lets your work do the talking.',
                'author' => 'Marlow Arch',
                'preview_images' => ['https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=1200&q=80'],
                'headline' => 'Spaces for the everyday.',
                'subheadline' => 'Homes, libraries and small civic spaces, designed with the people who use them.',
                'ctaText' => 'View our work',
                'primaryColor' => '#111827',
                'bgColor' => '#FFFFFF',
                'textColor' => '#111827',
                'font' => 'Plus Jakarta Sans',
            ],
            [
                'name' => 'Kite Yoga',
                'slug' => 'kite-yoga',
                'category_id' => $catFitness?->id,
                'industry' => 'Wellness',
                'badge' => 'ROOM TO BREATHE',
                'is_featured' => true,
                'description' => 'Earthy, open and easy to explore. A little space to breathe.',
                'author' => 'Kite Studio',
                'preview_images' => ['https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1200&q=80'],
                'headline' => 'Find your kind of balance.',
                'subheadline' => 'Small classes in a sunlit studio, timers to daily practice.',
                'ctaText' => 'Find a class',
                'primaryColor' => '#5D6B50',
                'bgColor' => '#FAF8F4',
                'textColor' => '#2D3428',
                'font' => 'Inter',
            ],
            [
                'name' => 'Ana & Teo',
                'slug' => 'ana-teo',
                'category_id' => $catEvents?->id,
                'industry' => 'Weddings',
                'badge' => 'MADE FOR MOMENTS',
                'is_featured' => true,
                'description' => 'Romantic details and a story-led layout for your once-in-a-lifetime day.',
                'author' => 'Atelier Moments',
                'preview_images' => ['https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80'],
                'headline' => 'Together is a beautiful place.',
                'subheadline' => 'Join us under the olive trees in Tuscany to celebrate our wedding with family and friends.',
                'ctaText' => 'Our story',
                'primaryColor' => '#4A1525',
                'bgColor' => '#FDFBF7',
                'textColor' => '#331B22',
                'font' => 'Playfair Display',
            ],
        ];

        foreach ($templates as $item) {
            $template = Template::firstOrCreate(
                ['slug' => $item['slug']],
                [
                    'name' => $item['name'],
                    'category_id' => $item['category_id'],
                    'industry' => $item['industry'],
                    'badge' => $item['badge'],
                    'is_featured' => $item['is_featured'],
                    'is_public' => true,
                    'description' => $item['description'],
                    'author' => $item['author'],
                    'preview_images' => $item['preview_images'],
                    'status' => TemplateStatus::Published,
                    'use_count' => rand(15, 68),
                ]
            );

            // Document creation
            $doc = [
                'schema_version' => 1,
                'site' => [
                    'name' => $item['name'],
                    'theme' => [
                        'colors' => [
                            'primary' => $item['primaryColor'],
                            'secondary' => '#64748B',
                            'accent' => $item['primaryColor'],
                            'background' => $item['bgColor'],
                            'surface' => $item['bgColor'],
                            'text' => [
                                'primary' => $item['textColor'],
                                'secondary' => '#64748B',
                                'inverse' => '#FFFFFF',
                            ],
                        ],
                        'typography' => [
                            'headingFamily' => $item['font'],
                            'bodyFamily' => 'Inter',
                        ],
                    ],
                    'settings' => [
                        'language' => 'en',
                        'googleFonts' => [$item['font'], 'Inter'],
                    ],
                ],
                'navigation' => [
                    'logo' => ['text' => $item['name']],
                    'items' => [
                        ['label' => 'About', 'url' => '#about'],
                        ['label' => 'Highlights', 'url' => '#highlights'],
                        ['label' => 'Contact', 'url' => '#contact'],
                    ],
                ],
                'pages' => [
                    [
                        'id' => 'page_home',
                        'slug' => '/',
                        'title' => 'Home',
                        'sections' => [
                            [
                                'id' => 'sec_hero',
                                'component' => 'hero',
                                'props' => [
                                    'headline' => $item['headline'],
                                    'subheadline' => $item['subheadline'],
                                    'ctaText' => $item['ctaText'],
                                    'image' => [
                                        'src' => $item['preview_images'][0],
                                        'alt' => $item['name'],
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
            ];

            TemplateVersion::firstOrCreate(
                ['template_id' => $template->id, 'version' => 1],
                [
                    'document' => $doc,
                    'design_tokens' => $doc['site']['theme'],
                    'fonts' => [$item['font'], 'Inter'],
                    'is_active' => true,
                ]
            );
        }
    }

    public function down(): void
    {
        Template::whereIn('slug', ['lumen-coffee', 'studio-marlow', 'kite-yoga', 'ana-teo'])->forceDelete();
    }
};

