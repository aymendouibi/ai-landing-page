import React from 'react';

interface AboutProps {
  variant?: string;
  props: {
    headline: string;
    description: string;
    highlights?: string[];
    image?: {
      src: string;
      alt?: string;
    };
  };
  styles?: Record<string, any>;
}

export const About: React.FC<AboutProps> = ({ props, styles = {} }) => {
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';

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
                src={props.image.src}
                alt={props.image.alt || props.headline}
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
          <div>
            <h2 className="text-h2" style={{ marginBottom: '1.5rem' }}>
              {props.headline}
            </h2>
            <p className="text-body" style={{ fontSize: '1.1rem', marginBottom: '2rem' }}>
              {props.description}
            </p>
            {props.highlights && props.highlights.length > 0 && (
              <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
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
