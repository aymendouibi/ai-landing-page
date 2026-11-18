import React from 'react';
import * as LucideIcons from 'lucide-react';
import { getSectionStyleProps, getHeadlineStyle } from '../styles/sectionStyles';

interface FeatureItem {
  icon?: string;
  title: string;
  description: string;
}

interface FeaturesProps {
  variant?: string;
  props: {
    title?: string;
    subtitle?: string;
    headlineSize?: string;
    items?: FeatureItem[];
  };
  styles?: Record<string, any>;
}

export const Features: React.FC<FeaturesProps> = ({ variant = 'grid_3col', props, styles = {} }) => {
  const items = props.items || [];
  const { bgClass, textAlign: rawAlign } = getSectionStyleProps(styles, props);
  const textAlign = rawAlign !== 'inherit' ? rawAlign : 'center';
  const headerMargin =
    textAlign === 'left'
      ? '0 auto 4rem 0'
      : textAlign === 'right'
      ? '0 0 4rem auto'
      : '0 auto 4rem auto';
  const columns = variant === 'two_column' ? 'repeat(auto-fit, minmax(320px, 1fr))' : 'repeat(auto-fit, minmax(280px, 1fr))';

  const renderIcon = (iconName?: string) => {
    if (!iconName) return <LucideIcons.Sparkles size={24} color="var(--color-primary)" />;
    // Normalize name e.g. zap -> Zap, check-circle -> CheckCircle
    const pascalName = iconName
      .split('-')
      .map(part => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
      .join('');
    const IconComponent = (LucideIcons as any)[pascalName] || LucideIcons.Sparkles;
    return <IconComponent size={24} color="var(--color-primary)" />;
  };

  const cardAlign = textAlign === 'right' ? 'flex-end' : textAlign === 'center' ? 'center' : 'flex-start';

  return (
    <div className={`section ${bgClass}`}>
      <div className="container">
        {(props.title || props.subtitle) && (
          <div style={{ textAlign, maxWidth: '720px', margin: headerMargin }}>
            {props.title && (
              <h2
                className="text-h2"
                style={{ marginBottom: '1rem', ...getHeadlineStyle(props.headlineSize, 'h2') }}
              >
                {props.title}
              </h2>
            )}
            {props.subtitle && <p className="text-body" style={{ fontSize: '1.125rem' }}>{props.subtitle}</p>}
          </div>
        )}

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: columns,
            gap: '2rem',
          }}
        >
          {items.map((item, idx) => (
            <div
              key={idx}
              className="card"
              style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '1rem',
                textAlign: textAlign !== 'center' ? textAlign : undefined,
                alignItems: textAlign === 'center' ? 'center' : textAlign === 'right' ? 'flex-end' : 'flex-start',
              }}
            >
              <div
                style={{
                  width: '3.5rem',
                  height: '3.5rem',
                  borderRadius: 'var(--radius-md)',
                  backgroundColor: 'rgba(37, 99, 235, 0.08)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  alignSelf: cardAlign,
                }}
              >
                {renderIcon(item.icon)}
              </div>
              <h3 className="text-h3" style={{ fontSize: '1.25rem' }}>
                {item.title}
              </h3>
              <p className="text-body">{item.description}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

