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
      onClick={handleClick}
      style={{
        ...outlineStyle,
        position: 'relative',
        opacity: isHidden ? 0.4 : 1,
        transition: 'outline 0.15s ease',
      }}
    >
      {children}
    </section>
  );
};

