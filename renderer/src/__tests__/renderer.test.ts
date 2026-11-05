import { describe, it, expect } from 'vitest';
import { generateCssVariables, generateGoogleFontsUrl } from '../engine/theme';
import { compileStaticHtml } from '../engine/compiler';
import { COMPONENT_MAP } from '../components/ComponentRegistry';
import { WebsiteDocument } from '../types/schema';

describe('Website Renderer Engine', () => {
  const mockDoc: WebsiteDocument = {
    schema_version: 1,
    site: {
      name: 'Test Venture',
      theme: {
        colors: {
          primary: '#1D4ED8',
          secondary: '#7C3AED',
          accent: '#10B981',
          background: '#FFFFFF',
          surface: '#F1F5F9',
          text: {
            primary: '#0F172A',
            secondary: '#64748B',
            inverse: '#FFFFFF',
          },
        },
        typography: {
          headingFamily: 'Plus Jakarta Sans',
          bodyFamily: 'Inter',
        },
        spacing: {
          containerMaxWidth: '1280px',
        },
      },
    },
    pages: [
      {
        id: 'p_home',
        slug: '/',
        title: 'Home Page',
        sections: [
          {
            id: 'sec_1',
            component: 'hero',
            variant: 'centered',
            order: 0,
            props: { headline: 'Test Headline' },
          },
        ],
      },
    ],
  };

  it('generates accurate CSS variables from theme tokens', () => {
    const vars = generateCssVariables(mockDoc.site.theme);
    expect(vars['--color-primary']).toBe('#1D4ED8');
    expect(vars['--color-bg']).toBe('#FFFFFF');
    expect(vars['--container-max-w']).toBe('1280px');
    expect(vars['--font-heading']).toContain('Plus Jakarta Sans');
  });

  it('generates valid Google Fonts URL', () => {
    const url = generateGoogleFontsUrl(['Inter', 'Plus Jakarta Sans']);
    expect(url).toContain('https://fonts.googleapis.com/css2?');
    expect(url).toContain('family=Inter');
    expect(url).toContain('family=Plus%20Jakarta%20Sans');
  });

  it('compiles standalone production-ready static HTML', () => {
    const html = compileStaticHtml(mockDoc);
    expect(html).toContain('<!DOCTYPE html>');
    expect(html).toContain('Test Venture');
    expect(html).toContain('Test Headline');
    expect(html).toContain('--color-primary: #1D4ED8;');
  });

  it('has component mappings for all core categories', () => {
    const expected = ['hero', 'features', 'about', 'statistics', 'testimonials', 'faq', 'cta', 'contact', 'footer'];
    for (const cat of expected) {
      expect(COMPONENT_MAP[cat]).toBeDefined();
    }
  });
});
