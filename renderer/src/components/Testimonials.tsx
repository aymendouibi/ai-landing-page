import React from 'react';
import { Star } from 'lucide-react';

interface TestimonialItem {
  quote: string;
  author: string;
  role?: string;
  avatar?: string;
  rating?: number;
}

interface TestimonialsProps {
  props: {
    title?: string;
    items: TestimonialItem[];
  };
  styles?: Record<string, any>;
}

export const Testimonials: React.FC<TestimonialsProps> = ({ props, styles = {} }) => {
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';
  const items = props.items || [];

  return (
    <div className={`section ${bgClass}`}>
      <div className="container">
        {props.title && (
          <h2 className="text-h2" style={{ textAlign: 'center', marginBottom: '3.5rem' }}>
            {props.title}
          </h2>
        )}

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
            gap: '2rem',
          }}
        >
          {items.map((item, idx) => (
            <div key={idx} className="card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              <div>
                <div style={{ display: 'flex', gap: '0.25rem', marginBottom: '1rem', color: '#F59E0B' }}>
                  {Array.from({ length: item.rating || 5 }).map((_, i) => (
                    <Star key={i} size={18} fill="#F59E0B" />
                  ))}
                </div>
                <p className="text-body" style={{ fontStyle: 'italic', fontSize: '1.05rem', marginBottom: '1.5rem' }}>
                  "{item.quote}"
                </p>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                {item.avatar && (
                  <img
                    src={item.avatar}
                    alt={item.author}
                    style={{ width: '3rem', height: '3rem', borderRadius: '50%', objectFit: 'cover' }}
                  />
                )}
                <div>
                  <div style={{ fontWeight: 700, color: 'var(--color-text-primary)' }}>{item.author}</div>
                  {item.role && <div className="text-body" style={{ fontSize: '0.85rem' }}>{item.role}</div>}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

