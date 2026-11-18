import React from 'react';
import { getSectionStyleProps, getHeadlineStyle } from '../styles/sectionStyles';

interface GalleryItem {
  src: string;
  alt?: string;
  caption?: string;
}

interface GalleryProps {
  props: {
    title?: string;
    subtitle?: string;
    headlineSize?: string;
    items?: GalleryItem[];
  };
  styles?: Record<string, any>;
}

export const Gallery: React.FC<GalleryProps> = ({ props, styles = {} }) => {
  const { bgClass, textAlign: rawAlign } = getSectionStyleProps(styles, props);
  const textAlign = rawAlign !== 'inherit' ? rawAlign : 'center';
  const headerMargin =
    textAlign === 'left'
      ? '0 auto 2rem 0'
      : textAlign === 'right'
      ? '0 0 2rem auto'
      : '0 auto 2rem auto';
  const defaultItems: GalleryItem[] = [
    {
      src: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=600&q=80',
      alt: 'Artisan Pour Over Coffee',
      caption: 'Single Origin Pour Over',
    },
    {
      src: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=600&q=80',
      alt: 'Coffee Roasting Process',
      caption: 'Small Batch Roasting',
    },
    {
      src: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=600&q=80',
      alt: 'Freshly Baked Pastries',
      caption: 'Morning Pairings',
    },
  ];

  const items = props.items && props.items.length > 0 ? props.items : defaultItems;

  return (
    <div className={`section ${bgClass}`}>
      <div className="container">
        {(props.title || props.subtitle) && (
          <div style={{ textAlign, marginBottom: '2rem', margin: headerMargin }}>
            {props.title && (
              <h2
                className="text-h2"
                style={{ marginBottom: '0.5rem', ...getHeadlineStyle(props.headlineSize, 'h2') }}
              >
                {props.title}
              </h2>
            )}
            {props.subtitle && <p className="text-lead">{props.subtitle}</p>}
          </div>
        )}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))',
            gap: '1.25rem',
          }}
        >
          {items.map((img, idx) => (
            <div
              key={idx}
              style={{
                position: 'relative',
                borderRadius: 'var(--radius-lg, 16px)',
                overflow: 'hidden',
                aspectRatio: '4 / 3',
                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.08)',
              }}
            >
              <img
                src={img.src}
                alt={img.alt || 'Gallery photo'}
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              />
              {img.caption && (
                <div
                  style={{
                    position: 'absolute',
                    bottom: 0,
                    left: 0,
                    right: 0,
                    padding: '0.75rem 1rem',
                    background: 'linear-gradient(transparent, rgba(15, 23, 42, 0.75))',
                    color: '#FFFFFF',
                    fontSize: '0.85rem',
                    fontWeight: 500,
                  }}
                >
                  {img.caption}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

