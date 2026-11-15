import React from 'react';
import { ArrowRight } from 'lucide-react';

interface HeroProps {
  variant?: string;
  props: {
    headline: string;
    subheadline?: string;
    ctaText?: string;
    ctaLink?: string;
    secondaryCtaText?: string;
    secondaryCtaLink?: string;
    image?: {
      src: string;
      alt?: string;
    };
  };
  styles?: Record<string, any>;
}

export const Hero: React.FC<HeroProps> = ({ variant = 'centered', props, styles = {} }) => {
  const isSplit = variant === 'split_image';
  const isMinimal = variant === 'minimal';
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';

  if (isSplit) {
    return (
      <div className={`section ${bgClass}`} style={{ overflow: 'hidden' }}>
        <div className="container">
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
              gap: '3.5rem',
              alignItems: 'center',
            }}
          >
            <div>
              <h1 className="text-h1" style={{ marginBottom: '1.5rem' }}>
                {props.headline}
              </h1>
              {props.subheadline && (
                <p className="text-lead" style={{ marginBottom: '2.5rem' }}>
                  {props.subheadline}
                </p>
              )}
              <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                {props.ctaText && (
                  <a href={props.ctaLink || '#'} className="btn btn-primary">
                    {props.ctaText} <ArrowRight size={18} />
                  </a>
                )}
                {props.secondaryCtaText && (
                  <a href={props.secondaryCtaLink || '#'} className="btn btn-secondary">
                    {props.secondaryCtaText}
                  </a>
                )}
              </div>
            </div>

            <div>
              <img
                src={props.image?.src || 'https://images.unsplash.com/photo-1551434678-e076c223a692?auto=format&fit=crop&w=800&q=80'}
                alt={props.image?.alt || props.headline}
                style={{
                  width: '100%',
                  borderRadius: 'var(--radius-lg)',
                  boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
                  objectFit: 'cover',
                  maxHeight: '480px',
                }}
              />
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Centered or Minimal Variant
  return (
    <div className={`section ${bgClass}`}>
      <div className="container" style={{ textAlign: 'center', maxWidth: isMinimal ? '760px' : '880px' }}>
        <h1 className="text-h1" style={{ marginBottom: '1.5rem' }}>
          {props.headline}
        </h1>
        {props.subheadline && (
          <p className="text-lead" style={{ marginBottom: '2.5rem', marginLeft: 'auto', marginRight: 'auto' }}>
            {props.subheadline}
          </p>
        )}
        {(props.ctaText || props.secondaryCtaText) && (
          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' }}>
            {props.ctaText && (
              <a href={props.ctaLink || '#'} className="btn btn-primary">
                {props.ctaText} <ArrowRight size={18} />
              </a>
            )}
            {props.secondaryCtaText && (
              <a href={props.secondaryCtaLink || '#'} className="btn btn-secondary">
                {props.secondaryCtaText}
              </a>
            )}
          </div>
        )}
        {props.image && (
          <div style={{ marginTop: '2.5rem' }}>
            <img
              src={typeof props.image === 'string' ? props.image : (props.image.src || (props.image as any).url || 'https://images.unsplash.com/photo-1551434678-e076c223a692?auto=format&fit=crop&w=800&q=80')}
              alt={typeof props.image === 'string' ? props.headline : (props.image.alt || props.headline)}
              key={typeof props.image === 'string' ? props.image : (props.image.src || (props.image as any).url)}
              style={{
                width: '100%',
                maxHeight: '440px',
                objectFit: 'cover',
                borderRadius: 'var(--radius-lg)',
                boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
                display: 'block',
                margin: '0 auto',
              }}
            />
          </div>
        )}
      </div>
    </div>
  );
};

