import { ThemeConfig } from '../types/schema';

export function generateCssVariables(theme?: ThemeConfig): Record<string, string> {
  const t = theme || ({} as any);
  const colors = t.colors || {};
  const text = colors.text || {};

  const vars: Record<string, string> = {
    '--color-primary': colors.primary || '#0C0C14',
    '--color-secondary': colors.secondary || '#64748B',
    '--color-accent': colors.accent || '#7C5CFF',
    '--color-bg': colors.background || '#FFFFFF',
    '--color-surface': colors.surface || '#FFFFFF',
    '--color-text-primary': text.primary || '#0F172A',
    '--color-text-secondary': text.secondary || '#475569',
    '--color-text-inverse': text.inverse || '#FFFFFF',

    '--font-heading': `"${t.typography?.headingFamily || 'Inter'}", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`,
    '--font-body': `"${t.typography?.bodyFamily || 'Inter'}", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`,

    '--container-max-w': t.spacing?.containerMaxWidth || '1200px',
    '--section-padding-x': t.spacing?.sectionPadding?.x || '1.5rem',
    '--section-padding-y': t.spacing?.sectionPadding?.y || '5rem',

    '--radius-sm': t.spacing?.borderRadius?.small || '0.375rem',
    '--radius-md': t.spacing?.borderRadius?.medium || '0.75rem',
    '--radius-lg': t.spacing?.borderRadius?.large || '1rem',
    '--radius-full': t.spacing?.borderRadius?.full || '9999px',
  };

  return vars;
}

export function getGoogleFontsForDocument(doc: { site?: { theme?: ThemeConfig; settings?: { googleFonts?: string[] } } }): string[] {
  const fonts = new Set<string>();

  // Settings fonts
  if (doc?.site?.settings?.googleFonts && Array.isArray(doc.site.settings.googleFonts)) {
    doc.site.settings.googleFonts.forEach(f => {
      if (f && typeof f === 'string' && f.trim()) fonts.add(f.trim());
    });
  }

  // Theme typography fonts
  const headingFamily = doc?.site?.theme?.typography?.headingFamily;
  if (headingFamily && typeof headingFamily === 'string' && headingFamily.trim()) {
    fonts.add(headingFamily.trim());
  }

  const bodyFamily = doc?.site?.theme?.typography?.bodyFamily;
  if (bodyFamily && typeof bodyFamily === 'string' && bodyFamily.trim()) {
    fonts.add(bodyFamily.trim());
  }

  // Fallback default
  if (fonts.size === 0) {
    fonts.add('Inter');
  }

  return Array.from(fonts);
}

export function generateGoogleFontsUrl(fonts: string[]): string {
  if (!fonts || fonts.length === 0) return '';
  // Filter out system fallbacks if any passed
  const systemFonts = ['sans-serif', 'serif', 'monospace', 'system-ui', '-apple-system', 'inherit'];
  const validFamilies = fonts.filter(f => !systemFonts.includes(f.toLowerCase()));
  if (validFamilies.length === 0) return '';
  const families = validFamilies.map(f => `family=${encodeURIComponent(f)}:wght@400;500;600;700`).join('&');
  return `https://fonts.googleapis.com/css2?${families}&display=swap`;
}

