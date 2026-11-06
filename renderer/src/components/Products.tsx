import React from 'react';

interface ProductItem {
  name: string;
  price?: string;
  description?: string;
  image?: string;
}

interface ProductsProps {
  variant?: string;
  props: {
    title?: string;
    subtitle?: string;
    items?: ProductItem[];
  };
  styles?: Record<string, any>;
}

export const Products: React.FC<ProductsProps> = ({ props, styles = {} }) => {
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';
  const defaultItems: ProductItem[] = [
    {
      name: 'Ethiopia Yirgacheffe',
      price: '$18.00',
      description: 'Floral jasmine, bergamot, and sweet peach notes with crisp acidity.',
      image: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=400&q=80',
    },
    {
      name: 'Colombia Huila Reserve',
      price: '$17.50',
      description: 'Milk chocolate, caramel, and bright red apple with a silky finish.',
      image: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
    },
    {
      name: 'Guatemala Antigua',
      price: '$19.00',
      description: 'Rich dark cocoa, toasted hazelnut, and sweet brown sugar aroma.',
      image: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=400&q=80',
    },
  ];

  const items = props.items && props.items.length > 0 ? props.items : defaultItems;

  return (
    <div className={`section ${bgClass}`}>
      <div className="container">
        {(props.title || props.subtitle) && (
          <div style={{ textAlign: 'center', marginBottom: '2.5rem' }}>
            {props.title && <h2 className="text-h2" style={{ marginBottom: '0.75rem' }}>{props.title}</h2>}
            {props.subtitle && <p className="text-lead" style={{ maxWidth: '600px', margin: '0 auto' }}>{props.subtitle}</p>}
          </div>
        )}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
            gap: '1.5rem',
          }}
        >
          {items.map((item, idx) => (
            <div
              key={idx}
              style={{
                background: '#FFFFFF',
                borderRadius: 'var(--radius-lg, 16px)',
                overflow: 'hidden',
                border: '1px solid #E2E8F0',
                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)',
                display: 'flex',
                flexDirection: 'column',
              }}
            >
              {item.image && (
                <div style={{ height: '180px', overflow: 'hidden' }}>
                  <img
                    src={item.image}
                    alt={item.name}
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  />
                </div>
              )}
              <div style={{ padding: '1.25rem', display: 'flex', flexDirection: 'column', flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '0.5rem' }}>
                  <h3 style={{ fontSize: '1.1rem', fontWeight: 600, color: '#0F172A' }}>{item.name}</h3>
                  {item.price && <span style={{ fontWeight: 700, color: 'var(--color-primary, #B85028)' }}>{item.price}</span>}
                </div>
                {item.description && (
                  <p style={{ fontSize: '0.9rem', color: '#64748B', lineHeight: 1.5, flex: 1, marginBottom: '1rem' }}>
                    {item.description}
                  </p>
                )}
                <button
                  type="button"
                  style={{
                    padding: '0.5rem 1rem',
                    borderRadius: '8px',
                    border: '1px solid #CBD5E1',
                    background: '#F8FAFC',
                    color: '#0F172A',
                    fontWeight: 600,
                    fontSize: '0.85rem',
                    cursor: 'pointer',
                  }}
                >
                  View Details
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
