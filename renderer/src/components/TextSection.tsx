import React from 'react';
import { getSectionStyleProps, getHeadlineStyle } from '../styles/sectionStyles';

interface TextSectionProps {
  props: {
    headline?: string;
    subheadline?: string;
    content?: string;
    headlineSize?: string;
  };
  styles?: Record<string, any>;
}

export const TextSection: React.FC<TextSectionProps> = ({ props, styles = {} }) => {
  const { bgClass, textAlign: rawAlign } = getSectionStyleProps(styles, props);
  const textAlign = rawAlign !== 'inherit' ? rawAlign : 'left';
  const marginContainer =
    textAlign === 'center' ? '0 auto' : textAlign === 'right' ? '0 0 0 auto' : '0 auto 0 0';

  return (
    <div className={`section ${bgClass}`}>
      <div className="container" style={{ maxWidth: '780px', textAlign, margin: marginContainer }}>
        {props.headline && (
          <h2
            className="text-h2"
            style={{ marginBottom: '1.25rem', ...getHeadlineStyle(props.headlineSize, 'h2') }}
          >
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

