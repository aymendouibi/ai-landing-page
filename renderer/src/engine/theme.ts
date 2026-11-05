import { ThemeConfig } from '../types/schema';

export function generateCssVariables(theme: ThemeConfig): Record<string, string> {
  const vars: Record<string, string> = {
    '--color-primary': theme.colors.primary,
    '--color-secondary': theme.colors.secondary,
    '--color-accent': theme.colors.accent,
    '--color-bg': theme.colors.background,
    '--color-surface': theme.colors.surface,
    '--color-text-primary': theme.colors.text.primary,
    '--color-text-secondary': theme.colors.text.secondary,
    '--color-text-inverse': theme.colors.text.inverse,

    '--font-heading': `"${theme.typography.headingFamily}", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`,
    '--font-body': `"${theme.typography.bodyFamily}", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`,

    '--container-max-w': theme.spacing?.containerMaxWidth || '1200px',
    '--section-padding-x': theme.spacing?.sectionPadding?.x || '1.5rem',
    '--section-padding-y': theme.spacing?.sectionPadding?.y || '5rem',

    '--radius-sm': theme.spacing?.borderRadius?.small || '0.375rem',
    '--radius-md': theme.spacing?.borderRadius?.medium || '0.75rem',
    '--radius-lg': theme.spacing?.borderRadius?.large || '1rem',
    '--radius-full': theme.spacing?.borderRadius?.full || '9999px',
  };

  return vars;
}

export function generateGoogleFontsUrl(fonts: string[]): string {
  if (!fonts || fonts.length === 0) return '';
  const families = fonts.map(f => `family=${encodeURIComponent(f)}:wght@400;500;600;700`).join('&');
  return `https://fonts.googleapis.com/css2?${families}&display=swap`;
}
