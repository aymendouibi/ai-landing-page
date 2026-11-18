import React from 'react';
import { ArrowRight } from 'lucide-react';
import { getSectionStyleProps, getHeadlineStyle } from '../styles/sectionStyles';

interface CtaProps {
  props: {
    headline: string;
    description?: string;
    buttonText: string;
    buttonLink?: string;
    headlineSize?: string;
  };
  styles?: Record<string, any>;
}

export const Cta: React.FC<CtaProps> = ({ props, styles = {} }) => {
  const { bgClass, textAlign: rawAlign } = getSectionStyleProps(styles, props);
  const textAlign = rawAlign !== 'inherit' ? rawAlign : 'center';
  const marginContainer =
    textAlign === 'center' ? '0 auto' : textAlign === 'right' ? '0 0 0 auto' : '0 auto 0 0';
  const justifyBtn =
    textAlign === 'center' ? 'center' : textAlign === 'right' ? 'flex-end' : 'flex-start';

  return (
    <div className={`section ${bgClass}`}>
      <div className="container" style={{ maxWidth: '800px', textAlign, margin: marginContainer }}>
        <h2
          className="text-h2"
          style={{ marginBottom: '1.25rem', ...getHeadlineStyle(props.headlineSize, 'h2') }}
        >
          {props.headline}
        </h2>
        {props.description && (
          <p className="text-lead" style={{ marginBottom: '2.5rem' }}>
            {props.description}
          </p>
        )}
        <div style={{ display: 'flex', justifyContent: justifyBtn }}>
          <a href={props.buttonLink || '#'} className="btn btn-primary" style={{ padding: '0.85rem 2.25rem' }}>
            {props.buttonText} <ArrowRight size={18} />
          </a>
        </div>
      </div>
    </div>
  );
};

