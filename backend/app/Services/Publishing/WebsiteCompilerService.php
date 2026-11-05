<?php

namespace App\Services\Publishing;

use App\Services\Documents\DocumentValidator;
use Exception;

class WebsiteCompilerService
{
    public function __construct(
        protected DocumentValidator $validator
    ) {}

    /**
     * Compile a website document into a self-contained static site bundle.
     *
     * @param array $document
     * @param string|null $websiteId
     * @param string|null $canonicalUrl
     * @return array<string, string> File path => content
     * @throws Exception
     */
    public function compile(array $document, ?string $websiteId = null, ?string $canonicalUrl = null): array
    {
        // 1. Ensure valid document schema
        $this->validator->validate($document);

        $site = $document['site'] ?? [];
        $siteName = htmlspecialchars($site['name'] ?? 'Website', ENT_QUOTES, 'UTF-8');
        $theme = $site['theme'] ?? [];
        $page = $document['pages'][0] ?? []; // Home page
        $sections = $page['sections'] ?? [];
        $seo = $page['seo'] ?? [];

        $title = htmlspecialchars(!empty($seo['title']) ? $seo['title'] : "{$siteName}", ENT_QUOTES, 'UTF-8');
        $description = htmlspecialchars(!empty($seo['description']) ? $seo['description'] : "Welcome to {$siteName}", ENT_QUOTES, 'UTF-8');
        $googleFonts = $site['settings']['googleFonts'] ?? ['Inter'];

        // Build CSS
        $css = $this->compileCss($theme);

        // Build JS
        $js = $this->compileJs($websiteId);

        // Build Sections HTML
        $sectionsHtml = '';
        foreach ($sections as $section) {
            if (isset($section['visible']) && !$section['visible']) {
                continue;
            }
            $sectionsHtml .= $this->renderSection($section, $siteName, $websiteId);
        }

        // Build Navigation HTML
        $navHtml = $this->renderNavigation($document['navigation'] ?? [], $siteName);

        // Build Font Links
        $fontLinks = '';
        if (!empty($googleFonts)) {
            $families = implode('&family=', array_map(fn($f) => urlencode($f) . ':wght@400;500;600;700', $googleFonts));
            $fontLinks = '<link rel="preconnect" href="https://fonts.googleapis.com">' . "\n"
                . '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>' . "\n"
                . '<link href="https://fonts.googleapis.com/css2?family=' . $families . '&display=swap" rel="stylesheet">';
        }

        $canonicalTag = $canonicalUrl ? '<link rel="canonical" href="' . htmlspecialchars($canonicalUrl, ENT_QUOTES, 'UTF-8') . '">' : '';

        // Complete HTML
        $indexHtml = <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$title}</title>
    <meta name="description" content="{$description}">
    {$canonicalTag}
    <meta property="og:title" content="{$title}">
    <meta property="og:description" content="{$description}">
    <meta property="og:type" content="website">
    <meta name="twitter:card" content="summary_large_image">
    {$fontLinks}
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
    {$navHtml}
    <main>
        {$sectionsHtml}
    </main>
    <script src="assets/main.js"></script>
</body>
</html>
HTML;

        $notFoundHtml = <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found | {$siteName}</title>
    <link rel="stylesheet" href="assets/style.css">
    <style>
        .error-wrapper { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 80vh; text-align: center; padding: 2rem; }
        .error-code { font-size: 6rem; font-weight: 800; color: var(--primary); margin: 0; }
        .error-msg { font-size: 1.5rem; margin: 1rem 0 2rem; color: var(--text-secondary); }
    </style>
</head>
<body>
    <div class="error-wrapper">
        <h1 class="error-code">404</h1>
        <p class="error-msg">The page or website you are looking for is currently unavailable or has been moved.</p>
        <a href="/" class="btn-primary">Return Home</a>
    </div>
</body>
</html>
HTML;

        return [
            'index.html' => $indexHtml,
            '404.html' => $notFoundHtml,
            'assets/style.css' => $css,
            'assets/main.js' => $js,
        ];
    }

    /**
     * Generate CSS styling with CSS variables derived from design tokens.
     */
    protected function compileCss(array $theme): string
    {
        $colors = $theme['colors'] ?? [];
        $primary = $colors['primary'] ?? '#2563EB';
        $secondary = $colors['secondary'] ?? '#7C3AED';
        $accent = $colors['accent'] ?? '#F59E0B';
        $background = $colors['background'] ?? '#FFFFFF';
        $surface = $colors['surface'] ?? '#F8FAFC';
        
        $textPrimary = is_array($colors['text'] ?? null) ? ($colors['text']['primary'] ?? '#0F172A') : ($colors['text'] ?? '#0F172A');
        $textSecondary = is_array($colors['text'] ?? null) ? ($colors['text']['secondary'] ?? '#475569') : '#475569';
        $textInverse = is_array($colors['text'] ?? null) ? ($colors['text']['inverse'] ?? '#FFFFFF') : '#FFFFFF';

        $headingFont = $theme['typography']['headingFamily'] ?? 'Inter, sans-serif';
        $bodyFont = $theme['typography']['bodyFamily'] ?? 'Inter, sans-serif';
        $maxWidth = $theme['spacing']['containerMaxWidth'] ?? '1200px';

        return <<<CSS
:root {
    --primary: {$primary};
    --secondary: {$secondary};
    --accent: {$accent};
    --bg: {$background};
    --surface: {$surface};
    --text-primary: {$textPrimary};
    --text-secondary: {$textSecondary};
    --text-inverse: {$textInverse};
    --font-heading: '{$headingFont}', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --font-body: '{$bodyFont}', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --container-max: {$maxWidth};
    --radius-sm: 0.375rem;
    --radius-md: 0.75rem;
    --radius-lg: 1rem;
    --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
    --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
    --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    background-color: var(--bg);
    color: var(--text-primary);
    font-family: var(--font-body);
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
}

h1, h2, h3, h4, h5, h6 {
    font-family: var(--font-heading);
    color: var(--text-primary);
    line-height: 1.2;
    font-weight: 700;
}

a { color: inherit; text-decoration: none; }
img { max-width: 100%; height: auto; display: block; }

.container {
    width: 100%;
    max-width: var(--container-max);
    margin-left: auto;
    margin-right: auto;
    padding-left: 1.5rem;
    padding-right: 1.5rem;
}

.section {
    padding-top: 5rem;
    padding-bottom: 5rem;
}

.section.surface { background-color: var(--surface); }
.section.default { background-color: var(--bg); }

/* Buttons */
.btn-primary {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background-color: var(--primary);
    color: var(--text-inverse);
    font-weight: 600;
    padding: 0.85rem 1.75rem;
    border-radius: var(--radius-md);
    transition: opacity 0.2s ease, transform 0.1s ease;
    border: none;
    cursor: pointer;
}
.btn-primary:hover { opacity: 0.92; transform: translateY(-1px); }

.btn-secondary {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background-color: transparent;
    color: var(--primary);
    border: 2px solid var(--primary);
    font-weight: 600;
    padding: 0.75rem 1.65rem;
    border-radius: var(--radius-md);
    transition: background-color 0.2s ease, color 0.2s ease;
    cursor: pointer;
}
.btn-secondary:hover { background-color: var(--primary); color: var(--text-inverse); }

/* Navigation */
.navbar {
    position: sticky;
    top: 0;
    z-index: 50;
    background-color: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(8px);
    border-bottom: 1px solid rgba(0, 0, 0, 0.05);
    padding: 1rem 0;
}
.nav-inner { display: flex; align-items: center; justify-content: space-between; }
.nav-logo { font-size: 1.35rem; font-weight: 700; color: var(--text-primary); }
.nav-links { display: flex; gap: 2rem; align-items: center; }
.nav-link { font-weight: 500; color: var(--text-secondary); transition: color 0.15s; }
.nav-link:hover { color: var(--primary); }

/* Hero */
.hero { text-align: center; padding: 6rem 0; }
.hero h1 { font-size: 3.5rem; margin-bottom: 1.5rem; letter-spacing: -0.02em; }
.hero p { font-size: 1.25rem; color: var(--text-secondary); max-width: 650px; margin: 0 auto 2.5rem; }
.hero-actions { display: flex; gap: 1rem; justify-content: center; }

/* Features */
.features-header { text-align: center; margin-bottom: 3.5rem; }
.features-header h2 { font-size: 2.25rem; margin-bottom: 1rem; }
.features-header p { color: var(--text-secondary); font-size: 1.15rem; }
.features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem; }
.feature-card {
    background: var(--surface);
    padding: 2.5rem;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0, 0, 0, 0.04);
}
.feature-card h3 { font-size: 1.35rem; margin-bottom: 0.75rem; }
.feature-card p { color: var(--text-secondary); font-size: 0.975rem; }

/* Call to Action */
.cta-box {
    background-color: var(--surface);
    border-radius: var(--radius-lg);
    padding: 4.5rem 2rem;
    text-align: center;
    border: 1px solid rgba(0, 0, 0, 0.05);
}
.cta-box h2 { font-size: 2.5rem; margin-bottom: 1rem; }
.cta-box p { color: var(--text-secondary); margin-bottom: 2rem; font-size: 1.15rem; }

/* Contact Form */
.contact-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; align-items: start; }
.contact-form { display: flex; flex-direction: column; gap: 1.25rem; }
.form-group { display: flex; flex-direction: column; gap: 0.5rem; }
.form-group label { font-size: 0.875rem; font-weight: 600; color: var(--text-primary); }
.form-input, .form-textarea {
    padding: 0.85rem 1rem;
    border: 1px solid rgba(0, 0, 0, 0.15);
    border-radius: var(--radius-md);
    font-family: inherit;
    font-size: 1rem;
    outline: none;
    transition: border-color 0.15s;
}
.form-input:focus, .form-textarea:focus { border-color: var(--primary); }
.form-status { padding: 1rem; border-radius: var(--radius-md); display: none; font-size: 0.95rem; }
.form-status.success { display: block; background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
.form-status.error { display: block; background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

/* Footer */
.footer { padding: 3rem 0; border-top: 1px solid rgba(0, 0, 0, 0.06); }
.footer-inner { display: flex; justify-content: space-between; align-items: center; }
.footer-copy { color: var(--text-secondary); font-size: 0.875rem; }
.footer-links { display: flex; gap: 1.5rem; }
.footer-links a { color: var(--text-secondary); font-size: 0.875rem; }
.footer-links a:hover { color: var(--primary); }

/* Responsive adjustments */
@media (max-width: 768px) {
    .hero h1 { font-size: 2.5rem; }
    .contact-grid { grid-template-columns: 1fr; gap: 2rem; }
    .footer-inner { flex-direction: column; gap: 1.5rem; text-align: center; }
}
CSS;
    }

    /**
     * Generate standalone client-side JavaScript.
     */
    protected function compileJs(?string $websiteId): string
    {
        $idParam = $websiteId ? json_encode($websiteId) : 'null';

        return <<<JS
(function() {
    'use strict';
    
    // Smooth scroll for internal links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const targetId = this.getAttribute('href');
            if (targetId.length > 1) {
                const target = document.querySelector(targetId);
                if (target) {
                    e.preventDefault();
                    target.scrollIntoView({ behavior: 'smooth' });
                }
            }
        });
    });

    // Contact Form AJAX Handler
    const forms = document.querySelectorAll('.contact-form');
    forms.forEach(form => {
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            const formId = form.dataset.formId;
            const statusBox = form.querySelector('.form-status');
            const submitBtn = form.querySelector('button[type="submit"]');

            if (!formId) return;

            const formData = new FormData(form);
            const payload = {};
            formData.forEach((value, key) => { payload[key] = value; });

            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.dataset.originalText = submitBtn.innerText;
                submitBtn.innerText = 'Sending...';
            }

            try {
                const res = await fetch('/api/v1/forms/' + encodeURIComponent(formId) + '/submit', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body: JSON.stringify(payload)
                });

                if (res.ok) {
                    form.reset();
                    if (statusBox) {
                        statusBox.className = 'form-status success';
                        statusBox.innerText = 'Thank you! Your message has been sent successfully.';
                    }
                } else {
                    const err = await res.json().catch(() => ({}));
                    if (statusBox) {
                        statusBox.className = 'form-status error';
                        statusBox.innerText = err.message || 'Failed to submit form. Please try again.';
                    }
                }
            } catch (err) {
                if (statusBox) {
                    statusBox.className = 'form-status error';
                    statusBox.innerText = 'Network error. Please try again.';
                }
            } finally {
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerText = submitBtn.dataset.originalText || 'Send Message';
                }
            }
        });
    });
})();
JS;
    }

    protected function renderNavigation(array $navigation, string $siteName): string
    {
        $logoText = htmlspecialchars($navigation['logo']['text'] ?? $siteName, ENT_QUOTES, 'UTF-8');
        $items = $navigation['items'] ?? [
            ['label' => 'Home', 'href' => '#', 'type' => 'link'],
            ['label' => 'Features', 'href' => '#features', 'type' => 'link'],
            ['label' => 'Contact', 'href' => '#contact', 'type' => 'button'],
        ];

        $linksHtml = '';
        foreach ($items as $item) {
            $label = htmlspecialchars($item['label'] ?? '', ENT_QUOTES, 'UTF-8');
            $href = htmlspecialchars($item['href'] ?? '#', ENT_QUOTES, 'UTF-8');
            $isBtn = ($item['type'] ?? '') === 'button';

            if ($isBtn) {
                $linksHtml .= "<a href=\"{$href}\" class=\"btn-primary\" style=\"padding: 0.5rem 1.25rem; font-size: 0.9rem;\">{$label}</a>";
            } else {
                $linksHtml .= "<a href=\"{$href}\" class=\"nav-link\">{$label}</a>";
            }
        }

        return <<<HTML
<header class="navbar">
    <div class="container nav-inner">
        <a href="/" class="nav-logo">{$logoText}</a>
        <nav class="nav-links">
            {$linksHtml}
        </nav>
    </div>
</header>
HTML;
    }

    protected function renderSection(array $section, string $siteName, ?string $websiteId): string
    {
        $id = htmlspecialchars($section['id'] ?? '', ENT_QUOTES, 'UTF-8');
        $component = $section['component'] ?? '';
        $props = $section['props'] ?? [];
        $bgStyle = $section['styles']['background'] ?? 'default';

        switch ($component) {
            case 'hero':
                $headline = htmlspecialchars($props['headline'] ?? "Welcome to {$siteName}", ENT_QUOTES, 'UTF-8');
                $subheadline = htmlspecialchars($props['subheadline'] ?? '', ENT_QUOTES, 'UTF-8');
                $ctaText = htmlspecialchars($props['ctaText'] ?? 'Get Started', ENT_QUOTES, 'UTF-8');
                $ctaLink = htmlspecialchars($props['ctaLink'] ?? '#contact', ENT_QUOTES, 'UTF-8');
                $secCtaText = !empty($props['secondaryCtaText']) ? htmlspecialchars($props['secondaryCtaText'], ENT_QUOTES, 'UTF-8') : null;
                $secCtaLink = !empty($props['secondaryCtaLink']) ? htmlspecialchars($props['secondaryCtaLink'], ENT_QUOTES, 'UTF-8') : null;

                $actions = "<a href=\"{$ctaLink}\" class=\"btn-primary\">{$ctaText}</a>";
                if ($secCtaText && $secCtaLink) {
                    $actions .= " <a href=\"{$secCtaLink}\" class=\"btn-secondary\">{$secCtaText}</a>";
                }

                return <<<HTML
<section id="hero" class="section hero {$bgStyle}">
    <div class="container">
        <h1>{$headline}</h1>
        <p>{$subheadline}</p>
        <div class="hero-actions">
            {$actions}
        </div>
    </div>
</section>
HTML;

            case 'features':
                $title = htmlspecialchars($props['title'] ?? 'Features', ENT_QUOTES, 'UTF-8');
                $subtitle = htmlspecialchars($props['subtitle'] ?? '', ENT_QUOTES, 'UTF-8');
                $items = $props['items'] ?? [];

                $cards = '';
                foreach ($items as $item) {
                    $iTitle = htmlspecialchars($item['title'] ?? '', ENT_QUOTES, 'UTF-8');
                    $iDesc = htmlspecialchars($item['description'] ?? '', ENT_QUOTES, 'UTF-8');
                    $cards .= <<<HTML
<div class="feature-card">
    <h3>{$iTitle}</h3>
    <p>{$iDesc}</p>
</div>
HTML;
                }

                return <<<HTML
<section id="features" class="section {$bgStyle}">
    <div class="container">
        <div class="features-header">
            <h2>{$title}</h2>
            <p>{$subtitle}</p>
        </div>
        <div class="features-grid">
            {$cards}
        </div>
    </div>
</section>
HTML;

            case 'cta':
                $headline = htmlspecialchars($props['headline'] ?? 'Ready to get started?', ENT_QUOTES, 'UTF-8');
                $desc = htmlspecialchars($props['description'] ?? '', ENT_QUOTES, 'UTF-8');
                $btnText = htmlspecialchars($props['buttonText'] ?? 'Get Started', ENT_QUOTES, 'UTF-8');
                $btnLink = htmlspecialchars($props['buttonLink'] ?? '#contact', ENT_QUOTES, 'UTF-8');

                return <<<HTML
<section class="section {$bgStyle}">
    <div class="container">
        <div class="cta-box">
            <h2>{$headline}</h2>
            <p>{$desc}</p>
            <a href="{$btnLink}" class="btn-primary">{$btnText}</a>
        </div>
    </div>
</section>
HTML;

            case 'contact':
                $title = htmlspecialchars($props['title'] ?? 'Contact Us', ENT_QUOTES, 'UTF-8');
                $desc = htmlspecialchars($props['description'] ?? 'Fill out the form below and we will get back to you shortly.', ENT_QUOTES, 'UTF-8');
                $formTarget = htmlspecialchars($websiteId ?? 'default', ENT_QUOTES, 'UTF-8');

                return <<<HTML
<section id="contact" class="section {$bgStyle}">
    <div class="container">
        <div class="contact-grid">
            <div>
                <h2>{$title}</h2>
                <p style="color: var(--text-secondary); margin-top: 1rem;">{$desc}</p>
            </div>
            <div>
                <form class="contact-form" data-form-id="{$formTarget}">
                    <div class="form-status"></div>
                    <div class="form-group">
                        <label for="name">Your Name</label>
                        <input type="text" id="name" name="name" class="form-input" required placeholder="Jane Doe">
                    </div>
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" class="form-input" required placeholder="jane@example.com">
                    </div>
                    <div class="form-group">
                        <label for="message">Message</label>
                        <textarea id="message" name="message" class="form-textarea" rows="4" required placeholder="How can we help?"></textarea>
                    </div>
                    <button type="submit" class="btn-primary">Send Message</button>
                </form>
            </div>
        </div>
    </div>
</section>
HTML;

            case 'footer':
                $copy = htmlspecialchars($props['copyright'] ?? "© " . date('Y') . " {$siteName}. All rights reserved.", ENT_QUOTES, 'UTF-8');
                $links = $props['links'] ?? [];

                $linksHtml = '';
                foreach ($links as $link) {
                    $lbl = htmlspecialchars($link['label'] ?? '', ENT_QUOTES, 'UTF-8');
                    $href = htmlspecialchars($link['href'] ?? '#', ENT_QUOTES, 'UTF-8');
                    $linksHtml .= "<a href=\"{$href}\">{$lbl}</a>";
                }

                return <<<HTML
<footer class="footer {$bgStyle}">
    <div class="container footer-inner">
        <div class="footer-copy">{$copy}</div>
        <div class="footer-links">{$linksHtml}</div>
    </div>
</footer>
HTML;

            default:
                return '';
        }
    }
}

