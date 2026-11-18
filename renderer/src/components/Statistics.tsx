import React from 'react';
import { getSectionStyleProps } from '../styles/sectionStyles';

interface StatItem {
  value: string;
  label: string;
}

interface StatisticsProps {
  props: {
    items: StatItem[];
  };
  styles?: Record<string, any>;
}

export const Statistics: React.FC<StatisticsProps> = ({ props, styles = {} }) => {
  const { bgClass, textAlign: rawAlign, paddingY } = getSectionStyleProps(styles, props);
  const textAlign = rawAlign !== 'inherit' ? rawAlign : 'center';
  const items = props.items || [];

  return (
    <div className={`section ${bgClass}`} style={{ padding: `${paddingY} 0` }}>
      <div className="container">
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: `repeat(auto-fit, minmax(200px, 1fr))`,
            gap: '2rem',
            textAlign,
          }}
        >
          {items.map((stat, idx) => (
            <div key={idx}>
              <div
                style={{
                  fontSize: '3rem',
                  fontWeight: 800,
                  color: 'var(--color-primary)',
                  letterSpacing: '-0.03em',
                  lineHeight: 1.1,
                  marginBottom: '0.5rem',
                }}
              >
                {stat.value}
              </div>
              <div className="text-body" style={{ fontWeight: 600, fontSize: '1rem' }}>
                {stat.label}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

