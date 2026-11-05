import React from 'react';
import * as LucideIcons from 'lucide-react';

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
    items?: FeatureItem[];
  };
  styles?: Record<string, any>;
}

export const Features: React.FC<FeaturesProps> = ({ variant = 'grid_3col', props, styles = {} }) => {
  const items = props.items || [];
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';
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

  return (
    <div className={`section ${bgClass}`}>
      <div className="container">
        {(props.title || props.subtitle) && (
          <div style={{ textAlign: 'center', maxWidth: '720px', margin: '0 auto 4rem auto' }}>
            {props.title && <h2 className="text-h2" style={{ marginBottom: '1rem' }}>{props.title}</h2>}
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
            <div key={idx} className="card" style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div
                style={{
                  width: '3.5rem',
                  height: '3.5rem',
                  borderRadius: 'var(--radius-md)',
                  backgroundColor: 'rgba(37, 99, 235, 0.08)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
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

