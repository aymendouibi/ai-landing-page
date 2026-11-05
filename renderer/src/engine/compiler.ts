import { WebsiteDocument } from '../types/schema';
import { generateCssVariables, generateGoogleFontsUrl } from './theme';

/**
 * Compile a WebsiteDocument into a standalone static HTML document for production CDN hosting.
 * Completely independent of the Laravel API at runtime!
 */
export function compileStaticHtml(doc: WebsiteDocument, pageSlug: string = '/'): string {
  const activePage = doc.pages.find(p => p.slug === pageSlug) || doc.pages[0];
  const pageTitle = activePage?.seo?.title || `${activePage?.title || 'Home'} - ${doc.site.name}`;
  const pageDesc = activePage?.seo?.description || activePage?.description || `Welcome to ${doc.site.name}`;
  const cssVars = generateCssVariables(doc.site.theme);
  const fontsUrl = generateGoogleFontsUrl(doc.site.settings?.googleFonts || []);

  const cssVarString = Object.entries(cssVars)
    .map(([k, v]) => `  ${k}: ${v};`)
    .join('\n');

  return `<!DOCTYPE html>
<html lang="${doc.site.settings?.language || 'en'}" dir="${doc.site.settings?.direction || 'ltr'}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(pageTitle)}</title>
  <meta name="description" content="${escapeHtml(pageDesc)}">
  ${fontsUrl ? `<link rel="stylesheet" href="${fontsUrl}">` : ''}
  <style>
:root {
${cssVarString}
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: var(--font-body); color: var(--color-text-primary); background-color: var(--color-bg); line-height: 1.6; }
h1, h2, h3 { font-family: var(--font-heading); color: var(--color-text-primary); font-weight: 700; line-height: 1.2; }
.container { width: 100%; max-width: var(--container-max-w); margin: 0 auto; padding: 0 var(--section-padding-x); }
.section { padding: var(--section-padding-y) 0; }
.bg-surface { background-color: var(--color-surface); }
.btn { display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem; padding: 0.75rem 1.75rem; font-weight: 600; border-radius: var(--radius-md); text-decoration: none; cursor: pointer; border: 1px solid transparent; }
.btn-primary { background-color: var(--color-primary); color: var(--color-text-inverse); }
.btn-secondary { background-color: transparent; color: var(--color-text-primary); border-color: var(--color-text-secondary); }
.card { background-color: var(--color-bg); border-radius: var(--radius-lg); padding: 2rem; border: 1px solid rgba(0,0,0,0.06); }
${doc.site.settings?.customCss || ''}
  </style>
</head>
<body>
  <div id="root">
    <!-- Static rendered content -->
    <header style="padding: 1.25rem 0; border-bottom: 1px solid rgba(0,0,0,0.06); background: var(--color-bg);">
      <div class="container" style="display: flex; justify-content: space-between; align-items: center;">
        <a href="/" style="font-size: 1.25rem; font-weight: 800; color: var(--color-primary); text-decoration: none;">
          ${escapeHtml(doc.site.name)}
        </a>
        <nav style="display: flex; gap: 1.5rem; align-items: center;">
          ${(doc.navigation?.items || []).map(item => `
            <a href="${item.href}" class="${item.type === 'button' ? 'btn btn-primary' : ''}" style="${item.type !== 'button' ? 'color: var(--color-text-secondary); text-decoration: none;' : ''}">
              ${escapeHtml(item.label)}
            </a>
          `).join('')}
        </nav>
      </div>
    </header>

    <main>
      ${(activePage?.sections || []).map(section => `
        <section id="${section.id}" class="section ${section.styles?.background === 'surface' ? 'bg-surface' : ''}">
          <div class="container">
            ${section.props?.headline ? `<h1 style="font-size: 2.75rem; margin-bottom: 1rem; text-align: center;">${escapeHtml(section.props.headline)}</h1>` : ''}
            ${section.props?.subheadline ? `<p style="font-size: 1.25rem; margin-bottom: 2rem; text-align: center; color: var(--color-text-secondary);">${escapeHtml(section.props.subheadline)}</p>` : ''}
            ${section.props?.title ? `<h2 style="font-size: 2rem; margin-bottom: 1rem; text-align: center;">${escapeHtml(section.props.title)}</h2>` : ''}
            ${section.props?.subtitle ? `<p style="font-size: 1.1rem; margin-bottom: 2rem; text-align: center; color: var(--color-text-secondary);">${escapeHtml(section.props.subtitle)}</p>` : ''}
          </div>
        </section>
      `).join('')}
    </main>

    <footer style="padding: 3rem 0; border-top: 1px solid rgba(0,0,0,0.06); text-align: center; color: var(--color-text-secondary);">
      <div class="container">
        <p>© ${new Date().getFullYear()} ${escapeHtml(doc.site.name)}. All rights reserved.</p>
      </div>
    </footer>
  </div>
</body>
</html>`;
}

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

