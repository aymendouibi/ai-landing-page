import React from 'react';
import { ArrowRight } from 'lucide-react';

interface CtaProps {
  props: {
    headline: string;
    description?: string;
    buttonText: string;
    buttonLink?: string;
  };
  styles?: Record<string, any>;
}

export const Cta: React.FC<CtaProps> = ({ props, styles = {} }) => {
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';

  return (
    <div className={`section ${bgClass}`}>
      <div className="container" style={{ maxWidth: '800px', textAlign: 'center' }}>
        <h2 className="text-h2" style={{ marginBottom: '1.25rem' }}>
          {props.headline}
        </h2>
        {props.description && (
          <p className="text-lead" style={{ marginBottom: '2.5rem' }}>
            {props.description}
          </p>
        )}
        <a href={props.buttonLink || '#'} className="btn btn-primary" style={{ padding: '0.85rem 2.25rem' }}>
          {props.buttonText} <ArrowRight size={18} />
        </a>
      </div>
    </div>
  );
};

