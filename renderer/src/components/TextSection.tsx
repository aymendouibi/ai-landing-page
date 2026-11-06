import React from 'react';

interface TextSectionProps {
  props: {
    headline?: string;
    subheadline?: string;
    content?: string;
  };
  styles?: Record<string, any>;
}

export const TextSection: React.FC<TextSectionProps> = ({ props, styles = {} }) => {
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';

  return (
    <div className={`section ${bgClass}`}>
      <div className="container" style={{ maxWidth: '780px' }}>
        {props.headline && (
          <h2 className="text-h2" style={{ marginBottom: '1.25rem' }}>
            {props.headline}
          </h2>
        )}
        {props.subheadline && (
          <p className="text-lead" style={{ marginBottom: '1.75rem', color: '#475569' }}>
            {props.subheadline}
          </p>
        )}
        {props.content && (
          <div
            className="text-body"
            style={{
              fontSize: '1.05rem',
              lineHeight: 1.8,
              color: '#334155',
              whiteSpace: 'pre-line',
            }}
          >
            {props.content}
          </div>
        )}
      </div>
    </div>
  );
};

