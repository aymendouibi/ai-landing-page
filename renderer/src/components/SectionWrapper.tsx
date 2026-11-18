import React from 'react';
import { SectionConfig } from '../types/schema';
import { getSectionStyleProps } from '../styles/sectionStyles';

interface SectionWrapperProps {
  section: SectionConfig;
  isSelected?: boolean;
  isEditorMode?: boolean;
  onSelect?: (id: string) => void;
  children: React.ReactNode;
}

export const SectionWrapper: React.FC<SectionWrapperProps> = ({
  section,
  isSelected = false,
  isEditorMode = false,
  onSelect,
  children,
}) => {
  const handleClick = (e: React.MouseEvent) => {
    if (isEditorMode && onSelect) {
      e.stopPropagation();
      onSelect(section.id);
    }
  };

  const isHidden = section.visible === false;
  if (isHidden && !isEditorMode) {
    return null;
  }

  const { bgClass, textAlign, paddingY, headlineSize } = getSectionStyleProps(
    section.styles,
    section.props
  );

  const outlineStyle: React.CSSProperties = isEditorMode && isSelected
    ? {
        outline: '2px solid #2563EB',
        outlineOffset: '-2px',
        position: 'relative',
        zIndex: 10,
      }
    : {};

  return (
    <section
      id={section.id}
      data-section-id={section.id}
      data-component={section.component}
      data-variant={section.variant}
      data-headline-size={headlineSize}
      onClick={handleClick}
      className={`section-wrapper ${bgClass}`}
      style={{
        ...outlineStyle,
        position: 'relative',
        opacity: isHidden ? 0.4 : 1,
        transition: 'outline 0.15s ease',
        ['--section-padding-y' as any]: paddingY,
        ['--section-text-align' as any]: textAlign,
        textAlign: textAlign !== 'inherit' ? textAlign : undefined,
      }}
    >
      {isEditorMode && isSelected && (
        <>
          {/* 8 Drag / Selection Handles */}
          <span style={{ position: 'absolute', top: -4, left: -4, width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />
          <span style={{ position: 'absolute', top: -4, left: '50%', transform: 'translateX(-50%)', width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />
          <span style={{ position: 'absolute', top: -4, right: -4, width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />
          <span style={{ position: 'absolute', top: '50%', left: -4, transform: 'translateY(-50%)', width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />
          <span style={{ position: 'absolute', top: '50%', right: -4, transform: 'translateY(-50%)', width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />
          <span style={{ position: 'absolute', bottom: -4, left: -4, width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />
          <span style={{ position: 'absolute', bottom: -4, left: '50%', transform: 'translateX(-50%)', width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />
          <span style={{ position: 'absolute', bottom: -4, right: -4, width: 8, height: 8, background: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%', zIndex: 12, pointerEvents: 'none' }} />

          {/* Floating Context Pill: Image | ✏️ | ✨ | ↑ */}
          <div
            style={{
              position: 'absolute',
              top: -42,
              right: 16,
              background: '#0F172A',
              color: '#FFFFFF',
              borderRadius: 24,
              padding: '6px 14px',
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              fontSize: 13,
              fontWeight: 600,
              boxShadow: '0 6px 16px rgba(0,0,0,0.25)',
              zIndex: 30,
              userSelect: 'none',
            }}
          >
            <span>{section.component.charAt(0).toUpperCase() + section.component.slice(1)}</span>
            <span style={{ opacity: 0.25, fontWeight: 300 }}>|</span>
            {/* Pencil (Edit) */}
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" style={{ cursor: 'pointer' }}><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/><path d="m15 5 4 4"/></svg>
            {/* Sparkles (AI) */}
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#C084FC" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ cursor: 'pointer' }}><path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3Z"/></svg>
            {/* Arrow Up (Move) */}
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" style={{ cursor: 'pointer' }}><path d="m5 12 7-7 7 7"/><path d="M12 19V5"/></svg>
          </div>
        </>
      )}
      {children}
    </section>
  );
};

