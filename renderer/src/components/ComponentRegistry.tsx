import React from 'react';
import { SectionConfig } from '../types/schema';
import { Hero } from './Hero';
import { Features } from './Features';
import { About } from './About';
import { Statistics } from './Statistics';
import { Testimonials } from './Testimonials';
import { Faq } from './Faq';
import { Cta } from './Cta';
import { Contact } from './Contact';
import { Footer } from './Footer';

export const COMPONENT_MAP: Record<string, React.FC<any>> = {
  hero: Hero,
  features: Features,
  benefits: Features, // Reuses features renderer with variant mapping
  about: About,
  statistics: Statistics,
  testimonials: Testimonials,
  reviews: Testimonials,
  faq: Faq,
  cta: Cta,
  contact: Contact,
  forms: Contact,
  footer: Footer,
};

export const renderComponent = (section: SectionConfig): React.ReactNode => {
  const Component = COMPONENT_MAP[section.component];

  if (!Component) {
    return (
      <div style={{ padding: '3rem 1.5rem', textAlign: 'center', background: '#FEF2F2', color: '#991B1B' }}>
        <strong>Unknown component:</strong> {section.component} ({section.variant})
      </div>
    );
  }

  return (
    <Component
      variant={section.variant}
      props={section.props}
      styles={section.styles || {}}
    />
  );
};
