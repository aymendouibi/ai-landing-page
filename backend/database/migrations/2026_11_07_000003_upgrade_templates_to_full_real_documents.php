<?php

use App\Models\Template;
use App\Models\TemplateVersion;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        $templatesData = [
            'lumen-coffee' => [
                'schema_version' => 1,
                'site' => [
                    'name' => 'Lumen Coffee',
                    'theme' => [
                        'colors' => [
                            'primary' => '#9E4B28',
                            'secondary' => '#6B5E55',
                            'accent' => '#C97D5D',
                            'background' => '#FAF7F2',
                            'surface' => '#FFFFFF',
                            'text' => [
                                'primary' => '#2C241E',
                                'secondary' => '#786C64',
                                'inverse' => '#FFFFFF',
                            ],
                        ],
                        'typography' => [
                            'headingFamily' => 'Playfair Display',
                            'bodyFamily' => 'Inter',
                        ],
                    ],
                    'settings' => [
                        'language' => 'en',
                        'direction' => 'ltr',
                        'googleFonts' => ['Playfair Display', 'Inter'],
                    ],
                ],
                'navigation' => [
                    'logo' => ['text' => 'Lumen Coffee'],
                    'items' => [
                        ['label' => 'Menu', 'href' => '#products', 'type' => 'link'],
                        ['label' => 'Our Story', 'href' => '#story', 'type' => 'link'],
                        ['label' => 'Visit Us', 'href' => '#visit', 'type' => 'button'],
                    ],
                ],
                'pages' => [
                    [
                        'id' => 'page_home',
                        'slug' => '/',
                        'title' => 'Home',
                        'sections' => [
                            [
                                'id' => 'sec_lumen_hero',
                                'component' => 'hero',
                                'order' => 0,
                                'props' => [
                                    'badge' => "EDITOR'S PICK · SPECIALTY ROASTERS",
                                    'headline' => "Good coffee.\nBetter mornings.",
                                    'subheadline' => 'Single-origin beans from farms we visit, roasted in small batches in our shop and shipped same day.',
                                    'ctaText' => 'Explore our coffee',
                                    'ctaLink' => '#products',
                                    'secondaryCtaText' => 'Visit the Café',
                                    'secondaryCtaLink' => '#visit',
                                    'image' => [
                                        'src' => 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=1200&q=80',
                                        'alt' => 'Lumen Coffee Hand-Poured Latte',
                                    ],
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_lumen_products',
                                'component' => 'products',
                                'order' => 1,
                                'props' => [
                                    'title' => 'Signature Single-Origin Roasts',
                                    'subtitle' => 'Roasted on our 1968 cast-iron Probat roaster every Tuesday and Friday.',
                                    'items' => [
                                        [
                                            'name' => 'Crema Espresso Blend',
                                            'price' => '$19.50',
                                            'description' => 'Rich dark chocolate, hazelnut, and sweet caramel finish.',
                                            'image' => 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=600&q=80',
                                        ],
                                        [
                                            'name' => 'Ethiopia Yirgacheffe G1',
                                            'price' => '$22.00',
                                            'description' => 'Bergamot jasmine, ripe peach, and sparkling bright floral notes.',
                                            'image' => 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=600&q=80',
                                        ],
                                        [
                                            'name' => 'Guatemala Antigua Valley',
                                            'price' => '$21.00',
                                            'description' => 'Brown sugar, red apple crisp, and silky milk chocolate body.',
                                            'image' => 'https://images.unsplash.com/photo-1587734195503-904fca47e0e9?auto=format&fit=crop&w=600&q=80',
                                        ],
                                        [
                                            'name' => 'Cold Brew Reserve',
                                            'price' => '$18.00',
                                            'description' => '18-hour slow-steeped concentrate with cacao nib sweetness.',
                                            'image' => 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80',
                                        ],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_lumen_story',
                                'component' => 'about',
                                'order' => 2,
                                'props' => [
                                    'title' => 'From Farm to Cup: A Decade of Craft',
                                    'subtitle' => 'We believe coffee should taste of the soil it grew in and the hands that harvested it.',
                                    'body' => 'In 2016, we started roasting in an old brick garage in Portland with a simple commitment: visit every farm, pay fair direct prices, and celebrate each harvest\'s unique terroir. Today, Lumen is a community living room where neighbors gather over slow-poured Chemex brews and sourdough pastries.',
                                    'image' => 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=1200&q=80',
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_lumen_visit',
                                'component' => 'visit',
                                'order' => 3,
                                'props' => [
                                    'title' => 'Visit Our Roastery & Café',
                                    'subtitle' => 'Stop by for a flight, warm pastries, or whole beans for home.',
                                    'address' => '842 Pearl Street, Pearl District, Portland, OR 97209',
                                    'hours' => "Mon – Fri: 7:00 AM – 5:30 PM\nSat – Sun: 8:00 AM – 6:00 PM",
                                    'phone' => '(503) 555-0192',
                                    'ctaText' => 'Get Directions',
                                    'ctaLink' => 'https://maps.google.com',
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_lumen_cta',
                                'component' => 'cta',
                                'order' => 4,
                                'props' => [
                                    'headline' => 'Fresh beans roasted and delivered weekly',
                                    'description' => 'Join our monthly coffee club for 15% off and complimentary doorstep delivery.',
                                    'buttonText' => 'Subscribe & Save 15%',
                                    'buttonLink' => '#subscribe',
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_lumen_footer',
                                'component' => 'footer',
                                'order' => 5,
                                'props' => [
                                    'copyright' => '© 2026 Lumen Coffee Roasters LLC. Crafted in Portland, Oregon.',
                                    'links' => [
                                        ['label' => 'Shipping & Returns', 'href' => '#shipping'],
                                        ['label' => 'Privacy Policy', 'href' => '#privacy'],
                                        ['label' => 'Wholesale', 'href' => '#wholesale'],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                        ],
                    ],
                ],
            ],

            'studio-marlow' => [
                'schema_version' => 1,
                'site' => [
                    'name' => 'Studio Marlow',
                    'theme' => [
                        'colors' => [
                            'primary' => '#111827',
                            'secondary' => '#6B7280',
                            'accent' => '#0284C7',
                            'background' => '#FFFFFF',
                            'surface' => '#F9FAFB',
                            'text' => [
                                'primary' => '#111827',
                                'secondary' => '#4B5563',
                                'inverse' => '#FFFFFF',
                            ],
                        ],
                        'typography' => [
                            'headingFamily' => 'Plus Jakarta Sans',
                            'bodyFamily' => 'Inter',
                        ],
                    ],
                    'settings' => [
                        'language' => 'en',
                        'direction' => 'ltr',
                        'googleFonts' => ['Plus Jakarta Sans', 'Inter'],
                    ],
                ],
                'navigation' => [
                    'logo' => ['text' => 'Studio Marlow'],
                    'items' => [
                        ['label' => 'Works', 'href' => '#works', 'type' => 'link'],
                        ['label' => 'Practice', 'href' => '#practice', 'type' => 'link'],
                        ['label' => 'Inquiries', 'href' => '#contact', 'type' => 'button'],
                    ],
                ],
                'pages' => [
                    [
                        'id' => 'page_home',
                        'slug' => '/',
                        'title' => 'Home',
                        'sections' => [
                            [
                                'id' => 'sec_marlow_hero',
                                'component' => 'hero',
                                'order' => 0,
                                'props' => [
                                    'badge' => 'ARCHITECTURE & INTERIORS · COPENHAGEN',
                                    'headline' => "Spaces for\nthe everyday.",
                                    'subheadline' => 'Homes, libraries, and small civic spaces, designed in quiet harmony with the people who inhabit them.',
                                    'ctaText' => 'View our work',
                                    'ctaLink' => '#works',
                                    'secondaryCtaText' => 'About Practice',
                                    'secondaryCtaLink' => '#practice',
                                    'image' => [
                                        'src' => 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=1200&q=80',
                                        'alt' => 'Studio Marlow Courtyard Residence',
                                    ],
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_marlow_works',
                                'component' => 'features',
                                'order' => 1,
                                'props' => [
                                    'title' => 'Selected Works (2024–2026)',
                                    'subtitle' => 'Architecture grounded in natural light, tactile materiality, and enduring proportion.',
                                    'items' => [
                                        [
                                            'icon' => 'home',
                                            'title' => 'Villa Sora · Lake Como',
                                            'description' => 'Monolithic limestone villa framing alpine views, featuring internal courtyards and passive geothermal cooling.',
                                        ],
                                        [
                                            'icon' => 'book-open',
                                            'title' => 'The Oakhaven Reading Pavilion',
                                            'description' => 'Light-timber public pavilion in Copenhagen constructed with local larch and acoustic clay plaster.',
                                        ],
                                        [
                                            'icon' => 'compass',
                                            'title' => 'Nordic Atelier Residence',
                                            'description' => 'Sculptor studio with double-height northern clerestory windows and minimalist concrete living quarters.',
                                        ],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_marlow_story',
                                'component' => 'about',
                                'order' => 2,
                                'props' => [
                                    'title' => 'Quietly Bold Design Philosophy',
                                    'subtitle' => 'A studio founded on clarity, daylight, and deliberate restraint.',
                                    'body' => 'Studio Marlow was founded by Henrik Marlow and Clara Jensen with a core conviction: architecture should quiet the senses and elevate daily rituals. We collaborate with regional craftsmen, utilizing local limestones and lime washes to shape timeless spaces.',
                                    'image' => 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_marlow_stats',
                                'component' => 'statistics',
                                'order' => 3,
                                'props' => [
                                    'items' => [
                                        ['number' => '48', 'label' => 'Built Works in Europe'],
                                        ['number' => '14', 'label' => 'Design & Craft Awards'],
                                        ['number' => '100%', 'label' => 'Sustainably Sourced Wood'],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_marlow_contact',
                                'component' => 'contact',
                                'order' => 4,
                                'props' => [
                                    'title' => 'Start a Conversation',
                                    'subtitle' => 'We accept a limited number of residential and cultural commissions annually.',
                                    'email' => 'commissions@studiomarlow.arch',
                                    'phone' => '+45 32 94 88 10',
                                    'address' => 'Bredgade 42, 1260 København K, Denmark',
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_marlow_footer',
                                'component' => 'footer',
                                'order' => 5,
                                'props' => [
                                    'copyright' => '© 2026 Studio Marlow Architects ApS. Copenhagen · Zurich.',
                                    'links' => [
                                        ['label' => 'Instagram', 'href' => '#instagram'],
                                        ['label' => 'Monographs', 'href' => '#monographs'],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                        ],
                    ],
                ],
            ],

            'kite-yoga' => [
                'schema_version' => 1,
                'site' => [
                    'name' => 'Kite Yoga',
                    'theme' => [
                        'colors' => [
                            'primary' => '#5D6B50',
                            'secondary' => '#8C9B81',
                            'accent' => '#C48B71',
                            'background' => '#FAF8F4',
                            'surface' => '#FFFFFF',
                            'text' => [
                                'primary' => '#2D3428',
                                'secondary' => '#6B7465',
                                'inverse' => '#FFFFFF',
                            ],
                        ],
                        'typography' => [
                            'headingFamily' => 'Inter',
                            'bodyFamily' => 'Inter',
                        ],
                    ],
                    'settings' => [
                        'language' => 'en',
                        'direction' => 'ltr',
                        'googleFonts' => ['Inter'],
                    ],
                ],
                'navigation' => [
                    'logo' => ['text' => 'Kite Yoga'],
                    'items' => [
                        ['label' => 'Classes', 'href' => '#classes', 'type' => 'link'],
                        ['label' => 'Pricing', 'href' => '#pricing', 'type' => 'link'],
                        ['label' => 'Find a Class', 'href' => '#classes', 'type' => 'button'],
                    ],
                ],
                'pages' => [
                    [
                        'id' => 'page_home',
                        'slug' => '/',
                        'title' => 'Home',
                        'sections' => [
                            [
                                'id' => 'sec_kite_hero',
                                'component' => 'hero',
                                'order' => 0,
                                'props' => [
                                    'badge' => 'HOLISTIC MOVEMENT & MINDFULNESS',
                                    'headline' => "Find your\nkind of balance.",
                                    'subheadline' => 'Small mindful classes in a sunlit sanctuary. A little space to breathe, restore, and connect with your breath.',
                                    'ctaText' => 'Find a class',
                                    'ctaLink' => '#classes',
                                    'secondaryCtaText' => 'View Passes',
                                    'secondaryCtaLink' => '#pricing',
                                    'image' => [
                                        'src' => 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1200&q=80',
                                        'alt' => 'Kite Yoga Sunlit Studio',
                                    ],
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_kite_classes',
                                'component' => 'features',
                                'order' => 1,
                                'props' => [
                                    'title' => 'Mindful Practices for Every Body',
                                    'subtitle' => 'Led by certified somatic and Ashtanga teachers with over a decade of personal study.',
                                    'items' => [
                                        [
                                            'icon' => 'sun',
                                            'title' => 'Morning Vinyasa Flow',
                                            'description' => 'Dynamic sequences linking breath with movement to energize your focus and awaken physical vitality.',
                                        ],
                                        [
                                            'icon' => 'moon',
                                            'title' => 'Restorative Yin & Sound',
                                            'description' => 'Supported floor postures with singing bowls and gentle hands-on assists to release tension.',
                                        ],
                                        [
                                            'icon' => 'activity',
                                            'title' => 'Pranayama & Meditation',
                                            'description' => 'Ancient breathing exercises and guided stillness to balance the nervous system.',
                                        ],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_kite_pricing',
                                'component' => 'products',
                                'order' => 2,
                                'props' => [
                                    'title' => 'Class Passes & Memberships',
                                    'subtitle' => 'No contracts, no cancellation fees. Complimentary Manduka mat rental and herbal tea.',
                                    'items' => [
                                        [
                                            'name' => 'Single Drop-in',
                                            'price' => '$25',
                                            'description' => 'Access to any 60 or 75-minute studio class. Includes mat rental.',
                                            'image' => 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=600&q=80',
                                        ],
                                        [
                                            'name' => '10-Class Pack',
                                            'price' => '$210',
                                            'description' => 'Valid for 6 months across all styles. Shareable with a guest.',
                                            'image' => 'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=600&q=80',
                                        ],
                                        [
                                            'name' => 'Monthly Unlimited',
                                            'price' => '$165/mo',
                                            'description' => 'Unlimited daily classes, 15% off workshops, and access to online library.',
                                            'image' => 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&q=80',
                                        ],
                                    ],
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_kite_story',
                                'component' => 'about',
                                'order' => 3,
                                'props' => [
                                    'title' => 'Room to Breathe',
                                    'subtitle' => 'A non-competitive space nestled above the trees.',
                                    'body' => 'We founded Kite Yoga because the modern world has enough hurry. Here, the floorboards are reclaimed cedar, natural light filters through linen shades, and phones stay in cubbies. Whether you have practiced for twenty years or twenty minutes, you are welcome here.',
                                    'image' => 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=1200&q=80',
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_kite_visit',
                                'component' => 'visit',
                                'order' => 4,
                                'props' => [
                                    'title' => 'Studio Location & Hours',
                                    'address' => '214 Pine Street, 2nd Floor, Austin, TX 78701',
                                    'hours' => "Mon – Fri: 6:30 AM – 8:30 PM\nSat – Sun: 8:00 AM – 6:00 PM",
                                    'phone' => '(512) 555-0184',
                                    'ctaText' => 'Studio Directions',
                                    'ctaLink' => 'https://maps.google.com',
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_kite_footer',
                                'component' => 'footer',
                                'order' => 5,
                                'props' => [
                                    'copyright' => '© 2026 Kite Yoga Studio LLC. Austin, Texas.',
                                    'links' => [
                                        ['label' => 'Teacher Training', 'href' => '#training'],
                                        ['label' => 'Community FAQ', 'href' => '#faq'],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                        ],
                    ],
                ],
            ],

            'ana-teo' => [
                'schema_version' => 1,
                'site' => [
                    'name' => 'Ana & Teo',
                    'theme' => [
                        'colors' => [
                            'primary' => '#4A1525',
                            'secondary' => '#8C5967',
                            'accent' => '#C9975D',
                            'background' => '#FDFBF7',
                            'surface' => '#FFFFFF',
                            'text' => [
                                'primary' => '#331B22',
                                'secondary' => '#73565F',
                                'inverse' => '#FFFFFF',
                            ],
                        ],
                        'typography' => [
                            'headingFamily' => 'Playfair Display',
                            'bodyFamily' => 'Inter',
                        ],
                    ],
                    'settings' => [
                        'language' => 'en',
                        'direction' => 'ltr',
                        'googleFonts' => ['Playfair Display', 'Inter'],
                    ],
                ],
                'navigation' => [
                    'logo' => ['text' => 'Ana & Teo'],
                    'items' => [
                        ['label' => 'Our Story', 'href' => '#story', 'type' => 'link'],
                        ['label' => 'The Weekend', 'href' => '#schedule', 'type' => 'link'],
                        ['label' => 'RSVP', 'href' => '#rsvp', 'type' => 'button'],
                    ],
                ],
                'pages' => [
                    [
                        'id' => 'page_home',
                        'slug' => '/',
                        'title' => 'Home',
                        'sections' => [
                            [
                                'id' => 'sec_ana_hero',
                                'component' => 'hero',
                                'order' => 0,
                                'props' => [
                                    'badge' => 'JUNE 12–14, 2026 · FIESOLE, TUSCANY',
                                    'headline' => "Together is\na beautiful place.",
                                    'subheadline' => 'Join us under the olive groves of Tuscany as we exchange our vows and celebrate love, friendship, and family.',
                                    'ctaText' => 'Our story',
                                    'ctaLink' => '#story',
                                    'secondaryCtaText' => 'RSVP by April 15',
                                    'secondaryCtaLink' => '#rsvp',
                                    'image' => [
                                        'src' => 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80',
                                        'alt' => 'Ana and Teo in Tuscany',
                                    ],
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_ana_schedule',
                                'component' => 'features',
                                'order' => 1,
                                'props' => [
                                    'title' => 'The Wedding Weekend Itinerary',
                                    'subtitle' => 'Three days of festivities in the sunlit hills overlooking Florence.',
                                    'items' => [
                                        [
                                            'icon' => 'wine',
                                            'title' => 'Friday Welcome Aperitivo',
                                            'description' => 'June 12, 6:30 PM · Trattoria al Poggio. Tuscan wines, woodfired pizza, and live acoustic music under the stars.',
                                        ],
                                        [
                                            'icon' => 'heart',
                                            'title' => 'Saturday Ceremony & Banquet',
                                            'description' => 'June 13, 4:00 PM · Villa San Michele. Vows under ancient cypress trees followed by a courtyard feast and dancing.',
                                        ],
                                        [
                                            'icon' => 'coffee',
                                            'title' => 'Sunday Farewell Brunch',
                                            'description' => 'June 14, 10:30 AM · Poolside Terrace. Fresh espresso, pastries, fruit, and warm send-offs.',
                                        ],
                                    ],
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_ana_story',
                                'component' => 'about',
                                'order' => 2,
                                'props' => [
                                    'title' => 'Eight Years of Adventures',
                                    'subtitle' => 'From a rainy coffee shop in Brooklyn to the cobblestones of Florence.',
                                    'body' => 'We first locked eyes on a wet Tuesday afternoon at a Brooklyn bookstore. Five apartments, two adopted rescue dogs, twenty-four stamps in our passports, and hundreds of bowls of pasta later, Teo proposed at sunrise overlooking the Arno river. We cannot wait to celebrate our next chapter with everyone we cherish most.',
                                    'image' => 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=1200&q=80',
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_ana_travel',
                                'component' => 'visit',
                                'order' => 3,
                                'props' => [
                                    'title' => 'Travel & Accommodations',
                                    'subtitle' => 'Villa San Michele, Fiesole (Firenze), Italy.',
                                    'address' => 'Via Doccia 4, 50014 Fiesole (Firenze), Italy',
                                    'hours' => "Airport: Florence Peretola (FLR) 25 mins · Pisa (PSA) 75 mins\nComplimentary shuttles from Florence Santa Maria Novella station.",
                                    'ctaText' => 'View Lodging Details',
                                    'ctaLink' => '#lodging',
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                            [
                                'id' => 'sec_ana_rsvp',
                                'component' => 'cta',
                                'order' => 4,
                                'props' => [
                                    'headline' => 'Kindly RSVP by April 15, 2026',
                                    'description' => 'Please confirm your attendance and let us know about any dietary preferences or shuttle requests.',
                                    'buttonText' => 'Submit Your RSVP',
                                    'buttonLink' => '#rsvp',
                                ],
                                'styles' => ['background' => 'background'],
                            ],
                            [
                                'id' => 'sec_ana_footer',
                                'component' => 'footer',
                                'order' => 5,
                                'props' => [
                                    'copyright' => 'Ana & Teo · June 12–14, 2026 · Fiesole, Tuscany. With love.',
                                ],
                                'styles' => ['background' => 'surface'],
                            ],
                        ],
                    ],
                ],
            ],
        ];

        foreach ($templatesData as $slug => $doc) {
            $template = Template::where('slug', $slug)->first();
            if ($template) {
                // Update active version document
                $activeVersion = $template->activeVersion;
                if ($activeVersion) {
                    $activeVersion->update([
                        'document' => $doc,
                        'design_tokens' => $doc['site']['theme'],
                        'fonts' => $doc['site']['settings']['googleFonts'] ?? ['Inter'],
                    ]);
                } else {
                    TemplateVersion::create([
                        'template_id' => $template->id,
                        'version' => 1,
                        'document' => $doc,
                        'design_tokens' => $doc['site']['theme'],
                        'fonts' => $doc['site']['settings']['googleFonts'] ?? ['Inter'],
                        'is_active' => true,
                    ]);
                }
            }
        }
    }

    public function down(): void
    {
        // No-op
    }
};

