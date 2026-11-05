import React from 'react';
import { SectionConfig } from '../types/schema';

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

  const outlineStyle: React.CSSProperties = isEditorMode && isSelected
    ? {
        outline: '3px solid var(--color-primary)',
        outlineOffset: '-3px',
        position: 'relative',
        zIndex: 10,
      }
    : {};

  const editorIndicator = isEditorMode && isSelected && (
    <div
      style={{
        position: 'absolute',
        top: 0,
        left: '1rem',
        background: 'var(--color-primary)',
        color: '#ffffff',
        padding: '0.2rem 0.6rem',
        fontSize: '0.75rem',
        fontWeight: 600,
        borderRadius: '0 0 0.375rem 0.375rem',
        zIndex: 20,
        pointerEvents: 'none',
        textTransform: 'uppercase',
      }}
    >
      {section.component} ({section.variant})
    </div>
  );

  return (
    <section
      id={section.id}
      data-section-id={section.id}
      data-component={section.component}
      data-variant={section.variant}
      onClick={handleClick}
      style={{
        ...outlineStyle,
        position: 'relative',
        opacity: isHidden ? 0.4 : 1,
        transition: 'outline 0.15s ease',
      }}
    >
      {editorIndicator}
      {children}
    </section>
  );
};

