import React from 'react';
import { getSectionStyleProps, getHeadlineStyle } from '../styles/sectionStyles';

interface AboutProps {
  variant?: string;
  props: {
    headline: string;
    description: string;
    headlineSize?: string;
    highlights?: string[];
    image?: {
      src: string;
      alt?: string;
    };
  };
  styles?: Record<string, any>;
}

export const About: React.FC<AboutProps> = ({ props, styles = {} }) => {
  const { bgClass, textAlign: rawAlign } = getSectionStyleProps(styles, props);
  const textAlign = rawAlign !== 'inherit' ? rawAlign : 'left';

  return (
    <div className={`section ${bgClass}`}>
      <div className="container">
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
            gap: '3.5rem',
            alignItems: 'center',
          }}
        >
          {props.image && (
            <div>
              <img
                src={typeof props.image === 'string' ? props.image : (props.image.src || (props.image as any).url || '')}
                alt={typeof props.image === 'string' ? props.headline : (props.image.alt || props.headline)}
                key={typeof props.image === 'string' ? props.image : (props.image.src || (props.image as any).url)}
                style={{
                  width: '100%',
                  borderRadius: 'var(--radius-lg)',
                  boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.08)',
                  objectFit: 'cover',
                  maxHeight: '450px',
                }}
              />
            </div>
          )}
          <div style={{ textAlign }}>
            <h2
              className="text-h2"
              style={{ marginBottom: '1.5rem', ...getHeadlineStyle(props.headlineSize, 'h2') }}
            >
              {props.headline}
            </h2>
            <p className="text-body" style={{ fontSize: '1.1rem', marginBottom: '2rem' }}>
              {props.description}
            </p>
            {props.highlights && props.highlights.length > 0 && (
              <ul
                style={{
                  listStyle: 'none',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '0.75rem',
                  alignItems: textAlign === 'center' ? 'center' : textAlign === 'right' ? 'flex-end' : 'flex-start',
                }}
              >
                {props.highlights.map((h, i) => (
                  <li key={i} style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', fontWeight: 500 }}>
                    <span style={{ color: 'var(--color-primary)', fontSize: '1.25rem' }}>✓</span>
                    <span>{h}</span>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

