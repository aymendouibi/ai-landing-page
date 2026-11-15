import React from 'react';

interface ImageSectionProps {
  props: {
    url?: string;
    src?: string;
    imageUrl?: string;
    image?: string;
    alt?: string;
    caption?: string;
    fit?: 'crop' | 'fit' | 'cover' | 'contain';
    aspectRatio?: string;
  };
  styles?: Record<string, any>;
}

export const ImageSection: React.FC<ImageSectionProps> = ({ props }) => {
  const imgSrc =
    props.url ||
    props.src ||
    props.imageUrl ||
    props.image ||
    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=80';

  const isFit = props.fit === 'fit' || props.fit === 'contain';
  const objectFit = isFit ? 'contain' : 'cover';
  const aspectRatio = props.aspectRatio || (isFit ? 'auto' : '16/10');

  return (
    <div style={{ padding: '1.25rem 1rem', width: '100%', boxSizing: 'border-box' }}>
      <div
        style={{
          width: '100%',
          maxWidth: '100%',
          margin: '0 auto',
          borderRadius: '16px',
          overflow: 'hidden',
          backgroundColor: isFit ? '#F8FAFC' : 'transparent',
          boxShadow: '0 4px 16px rgba(0, 0, 0, 0.06)',
        }}
      >
        <img
          src={imgSrc}
          alt={props.alt || 'Website visual'}
          key={imgSrc}
          style={{
            width: '100%',
            height: isFit ? 'auto' : '100%',
            maxHeight: isFit ? '420px' : '340px',
            aspectRatio: aspectRatio,
            objectFit: objectFit,
            display: 'block',
          }}
          loading="lazy"
        />
      </div>
      {props.caption && (
        <p
          style={{
            marginTop: '0.5rem',
            textAlign: 'center',
            fontSize: '0.85rem',
            color: '#64748B',
          }}
        >
          {props.caption}
        </p>
      )}
    </div>
  );
};

