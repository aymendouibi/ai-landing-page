import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { getSectionStyleProps, getHeadlineStyle } from '../styles/sectionStyles';

interface FaqItem {
  question: string;
  answer: string;
}

interface FaqProps {
  props: {
    title?: string;
    subtitle?: string;
    headlineSize?: string;
    items: FaqItem[];
  };
  styles?: Record<string, any>;
}

export const Faq: React.FC<FaqProps> = ({ props, styles = {} }) => {
  const [openIndex, setOpenIndex] = useState<number | null>(0);
  const items = props.items || [];
  const { bgClass, textAlign: rawAlign } = getSectionStyleProps(styles, props);
  const textAlign = rawAlign !== 'inherit' ? rawAlign : 'center';
  const headerMargin =
    textAlign === 'left'
      ? '0 auto 3.5rem 0'
      : textAlign === 'right'
      ? '0 0 3.5rem auto'
      : '0 auto 3.5rem auto';

  const toggle = (idx: number) => {
    setOpenIndex(openIndex === idx ? null : idx);
  };

  return (
    <div className={`section ${bgClass}`}>
      <div className="container" style={{ maxWidth: '800px' }}>
        {(props.title || props.subtitle) && (
          <div style={{ textAlign, marginBottom: '3.5rem', margin: headerMargin }}>
            {props.title && (
              <h2
                className="text-h2"
                style={{ marginBottom: '1rem', ...getHeadlineStyle(props.headlineSize, 'h2') }}
              >
                {props.title}
              </h2>
            )}
            {props.subtitle && <p className="text-body">{props.subtitle}</p>}
          </div>
        )}

        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {items.map((item, idx) => {
            const isOpen = openIndex === idx;
            return (
              <div
                key={idx}
                style={{
                  border: '1px solid rgba(0, 0, 0, 0.08)',
                  borderRadius: 'var(--radius-md)',
                  backgroundColor: 'var(--color-bg)',
                  overflow: 'hidden',
                }}
              >
                <button
                  onClick={() => toggle(idx)}
                  style={{
                    width: '100%',
                    padding: '1.25rem 1.5rem',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    background: 'none',
                    border: 'none',
                    textAlign: 'left',
                    cursor: 'pointer',
                    fontSize: '1.1rem',
                    fontWeight: 600,
                    color: 'var(--color-text-primary)',
                  }}
                >
                  <span>{item.question}</span>
                  {isOpen ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                </button>
                {isOpen && (
                  <div style={{ padding: '0 1.5rem 1.5rem 1.5rem', textAlign: 'left' }}>
                    <p className="text-body">{item.answer}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

