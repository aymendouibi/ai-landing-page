import React from 'react';

export interface SectionStyleResult {
  bg: string;
  bgClass: string;
  textAlign: 'left' | 'center' | 'right' | 'inherit';
  paddingY: string;
  headlineSize: 'Small' | 'Medium' | 'Large';
}

export function getSectionStyleProps(
  styles: Record<string, any> = {},
  props: Record<string, any> = {}
): SectionStyleResult {
  const bg = styles.background || 'default';
  const bgClass =
    bg === 'dark'
      ? 'bg-dark'
      : bg === 'brand'
      ? 'bg-brand'
      : bg === 'surface'
      ? 'bg-surface'
      : 'bg-default';

  const textAlign = (styles.textAlign || 'inherit') as 'left' | 'center' | 'right' | 'inherit';

  const pad = styles.padding;
  const paddingY = pad === 'compact' ? '2.25rem' : pad === 'spacious' ? '8rem' : '4.5rem';

  const rawSize = props.headlineSize || 'Large';
  const headlineSize = (rawSize.charAt(0).toUpperCase() + rawSize.slice(1).toLowerCase()) as
    | 'Small'
    | 'Medium'
    | 'Large';

  return {
    bg,
    bgClass,
    textAlign,
    paddingY,
    headlineSize: ['Small', 'Medium', 'Large'].includes(headlineSize) ? headlineSize : 'Large',
  };
}

export function getHeadlineStyle(headlineSize?: string, tag: 'h1' | 'h2' = 'h2'): React.CSSProperties {
  const size = (headlineSize || 'Large').toLowerCase();
  if (tag === 'h1') {
    if (size === 'small' || size === 'compact') return { fontSize: 'clamp(1.6rem, 3.5vw, 2.35rem)' };
    if (size === 'medium' || size === 'normal') return { fontSize: 'clamp(2.1rem, 4.3vw, 3.1rem)' };
    return { fontSize: 'clamp(2.5rem, 5.5vw, 4rem)' };
  } else {
    if (size === 'small' || size === 'compact') return { fontSize: 'clamp(1.25rem, 2.5vw, 1.65rem)' };
    if (size === 'medium' || size === 'normal') return { fontSize: 'clamp(1.55rem, 3.2vw, 2.15rem)' };
    return { fontSize: 'clamp(1.85rem, 3.8vw, 2.75rem)' };
  }
}
