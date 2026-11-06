import React from 'react';

interface FooterProps {
  props: {
    copyright?: string;
    links?: Array<{ label: string; href: string }>;
    columns?: Array<{
      title: string;
      links: Array<{ label: string; href: string }>;
    }>;
  };
  styles?: Record<string, any>;
}

export const Footer: React.FC<FooterProps> = ({ props, styles = {} }) => {
  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';
  const columns = props.columns;

  return (
    <footer
      id="sec_footer"
      className={`section ${bgClass}`}
      style={{
        paddingTop: '4rem',
        paddingBottom: '3rem',
        borderTop: '1px solid rgba(0, 0, 0, 0.06)',
      }}
    >
      <div className="container">
        {columns && columns.length > 0 ? (
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: `repeat(auto-fit, minmax(180px, 1fr))`,
              gap: '2.5rem',
              marginBottom: '3rem',
            }}
          >
            {columns.map((col, idx) => (
              <div key={idx}>
                <h4 style={{ fontSize: '0.95rem', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: '1.25rem' }}>
                  {col.title}
                </h4>
                <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                  {col.links.map((link, lIdx) => (
                    <li key={lIdx}>
                      <a href={link.href} className="text-body" style={{ fontSize: '0.9rem' }}>
                        {link.label}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        ) : null}

        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: '1rem',
            borderTop: columns ? '1px solid rgba(0,0,0,0.06)' : 'none',
            paddingTop: columns ? '2rem' : 0,
          }}
        >
          <div className="text-body" style={{ fontSize: '0.875rem' }}>
            {props.copyright || `© ${new Date().getFullYear()} All rights reserved.`}
          </div>

          {props.links && (
            <div style={{ display: 'flex', gap: '1.5rem' }}>
              {props.links.map((link, idx) => (
                <a key={idx} href={link.href} className="text-body" style={{ fontSize: '0.875rem' }}>
                  {link.label}
                </a>
              ))}
            </div>
          )}
        </div>
      </div>
    </footer>
  );
};

