import React, { useEffect, useState, useRef } from 'react';
import { WebsiteDocument, BridgeMessage, SectionConfig } from '../types/schema';
import { generateCssVariables, generateGoogleFontsUrl } from './theme';
import { Navbar } from '../components/Navbar';
import { SectionWrapper } from '../components/SectionWrapper';
import { renderComponent } from '../components/ComponentRegistry';
import '../styles/base.css';

interface WebsiteRendererProps {
  initialDocument: WebsiteDocument;
  initialPageSlug?: string;
  isEditorMode?: boolean;
  onSectionSelect?: (sectionId: string) => void;
}

interface SelectedElementState {
  sectionId: string;
  component: string;
  elementKey: string;
  typeLabel: string;
  text: string;
  size: 'Small' | 'Medium' | 'Large';
  rect: { top: number; left: number; width: number; height: number };
}

// Extend window for Android JavaScript Interface bridge
declare global {
  interface Window {
    AndroidBridge?: {
      postMessage: (message: string) => void;
      onSectionSelected?: (sectionId: string) => void;
    };
    updateDocument?: (jsonString: string) => void;
    updateElementText?: (sectionId: string, elementKey: string, newText: string, size?: string) => void;
    addSection?: (sectionData: any) => void;
    deleteSection?: (sectionId: string) => void;
    reorderSections?: (sectionIds: string[]) => void;
    updateTheme?: (themeUpdates: any) => void;
    selectSection?: (sectionId: string) => void;
    setViewport?: (viewport: 'mobile' | 'tablet' | 'desktop') => void;
  }
}

export const WebsiteRenderer: React.FC<WebsiteRendererProps> = ({
  initialDocument,
  initialPageSlug = '/',
  isEditorMode = false,
  onSectionSelect,
}) => {
  const [doc, setDoc] = useState<WebsiteDocument>(initialDocument);
  const [currentSlug] = useState<string>(initialPageSlug);
  const [selectedSectionId, setSelectedSectionId] = useState<string | null>(null);
  const [selectedElement, setSelectedElement] = useState<SelectedElementState | null>(null);
  const rootRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (initialDocument) {
      setDoc(initialDocument);
    }
  }, [initialDocument]);

  // Setup communication bridge with Android WebView and Parent Window
  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      try {
        const data: BridgeMessage = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
        if (!data || !data.action) return;

        switch (data.action) {
          case 'UPDATE_SECTION_PROPS': {
            const { sectionId, props } = data.payload;
            setDoc(prev => {
              const newPages = prev.pages.map(page => ({
                ...page,
                sections: page.sections.map(sec =>
                  sec.id === sectionId ? { ...sec, props: { ...sec.props, ...props } } : sec
                ),
              }));
              return { ...prev, pages: newPages };
            });
            break;
          }
          case 'SELECT_SECTION': {
            setSelectedSectionId(data.payload.sectionId);
            break;
          }
        }
      } catch {
        // Ignore unparseable
      }
    };

    window.addEventListener('message', handleMessage);

    // Expose functions for Android WebView JavaScript injection
    window.updateDocument = (data: any) => {
      try {
        const updated = typeof data === 'string' ? JSON.parse(data) : data;
        if (updated && typeof updated === 'object') {
          setDoc(updated);
        }
      } catch (err) {
        console.error('Failed to parse updated document', err);
      }
    };

    window.updateElementText = (sectionId: string, elementKey: string, newText: string, size?: string) => {
      setDoc(prev => {
        const newPages = prev.pages.map(page => ({
          ...page,
          sections: page.sections.map(sec => {
            if (sec.id !== sectionId) return sec;
            const updatedProps = { ...sec.props };
            if (elementKey === 'headline') {
              updatedProps.headline = newText;
              if (size) updatedProps.headlineSize = size;
            } else if (elementKey === 'subheadline') {
              updatedProps.subheadline = newText;
            } else if (elementKey === 'ctaText') {
              updatedProps.ctaText = newText;
            } else {
              updatedProps[elementKey] = newText;
            }
            return { ...sec, props: updatedProps };
          }),
        }));
        return { ...prev, pages: newPages };
      });
      if (selectedElement && selectedElement.sectionId === sectionId) {
        setSelectedElement(prev => prev ? { ...prev, text: newText, size: (size as any) || prev.size } : null);
      }
    };

    window.addSection = (sectionData: any) => {
      try {
        const newSec: SectionConfig = typeof sectionData === 'string' ? JSON.parse(sectionData) : sectionData;
        setDoc(prev => {
          const newPages = prev.pages.map((page, idx) => {
            if (idx === 0 || page.slug === currentSlug) {
              const currentSections = page.sections || [];
              return {
                ...page,
                sections: [...currentSections, { ...newSec, order: currentSections.length }],
              };
            }
            return page;
          });
          return { ...prev, pages: newPages };
        });
        setSelectedSectionId(newSec.id);
      } catch (e) {
        console.error('Failed to add section', e);
      }
    };

    window.deleteSection = (sectionId: string) => {
      setDoc(prev => {
        const newPages = prev.pages.map(page => ({
          ...page,
          sections: page.sections.filter(s => s.id !== sectionId),
        }));
        return { ...prev, pages: newPages };
      });
      if (selectedSectionId === sectionId) setSelectedSectionId(null);
      if (selectedElement?.sectionId === sectionId) setSelectedElement(null);
    };

    window.reorderSections = (sectionIds: string[]) => {
      setDoc(prev => {
        const newPages = prev.pages.map(page => {
          const secMap = new Map(page.sections.map(s => [s.id, s]));
          const reordered = sectionIds.map((id, index) => {
            const sec = secMap.get(id);
            return sec ? { ...sec, order: index } : null;
          }).filter(Boolean) as SectionConfig[];
          return { ...page, sections: reordered };
        });
        return { ...prev, pages: newPages };
      });
    };

    window.updateTheme = (themeUpdates: any) => {
      try {
        const updates = typeof themeUpdates === 'string' ? JSON.parse(themeUpdates) : themeUpdates;
        setDoc(prev => ({
          ...prev,
          site: {
            ...prev.site,
            theme: {
              ...prev.site.theme,
              ...updates,
              colors: { ...prev.site.theme?.colors, ...updates.colors },
              typography: { ...prev.site.theme?.typography, ...updates.typography },
            },
          },
        }));
      } catch (e) {
        console.error('Failed to update theme', e);
      }
    };

    window.selectSection = (sectionId: string) => {
      setSelectedSectionId(sectionId);
      const el = document.getElementById(sectionId);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    };

    // Notify Android container that the editor is mounted and ready
    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(JSON.stringify({ action: 'EDITOR_READY', payload: {} }));
    }

    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, [currentSlug, selectedElement, selectedSectionId]);

  // Handle section click in editor mode
  const handleSectionSelect = (sectionId: string) => {
    setSelectedSectionId(sectionId);

    if (onSectionSelect) {
      onSectionSelect(sectionId);
    }

    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(
        JSON.stringify({
          action: 'SELECT_SECTION',
          payload: { sectionId },
        })
      );
    } else if (window.AndroidBridge?.onSectionSelected) {
      window.AndroidBridge.onSectionSelected(sectionId);
    }

    if (window.parent && window.parent !== window) {
      window.parent.postMessage({ action: 'SELECT_SECTION', payload: { sectionId } }, '*');
    }
  };

  // Element-level click handler for granular inline editing
  const handleElementClick = (e: React.MouseEvent) => {
    if (!isEditorMode) return;

    const target = e.target as HTMLElement;
    const sectionEl = target.closest('[data-section-id]') as HTMLElement | null;
    if (!sectionEl) return;

    const sectionId = sectionEl.getAttribute('data-section-id') || '';
    const component = sectionEl.getAttribute('data-component') || 'section';
    const componentName = component.charAt(0).toUpperCase() + component.slice(1);

    const isHeading = ['H1', 'H2', 'H3', 'H4'].includes(target.tagName);
    const isParagraph = target.tagName === 'P';
    const isButton = target.tagName === 'A' || target.tagName === 'BUTTON' || target.classList.contains('btn');

    let elementKey = 'headline';
    let typeLabel = 'Heading';

    if (isHeading) {
      elementKey = 'headline';
      typeLabel = 'Heading';
    } else if (isParagraph) {
      elementKey = 'subheadline';
      typeLabel = 'Text';
    } else if (isButton) {
      elementKey = 'ctaText';
      typeLabel = 'Button';
    } else {
      elementKey = 'headline';
      typeLabel = 'Element';
    }

    const text = target.innerText.trim();
    const rect = target.getBoundingClientRect();
    const rootRect = rootRef.current?.getBoundingClientRect() || { top: 0, left: 0 };

    setSelectedElement({
      sectionId,
      component,
      elementKey,
      typeLabel,
      text,
      size: 'Large',
      rect: {
        top: rect.top - rootRect.top + (rootRef.current?.scrollTop || 0),
        left: rect.left - rootRect.left,
        width: rect.width,
        height: rect.height,
      },
    });

    setSelectedSectionId(sectionId);

    // Send SELECT_ELEMENT event to Android bridge
    const payload = {
      sectionId,
      component,
      elementKey,
      elementName: `${typeLabel} in ${componentName}`,
      text,
      size: 'Large',
    };

    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(
        JSON.stringify({
          action: 'SELECT_ELEMENT',
          payload,
        })
      );
    }
  };

  const activePage = doc.pages.find(p => p.slug === currentSlug) || doc.pages[0];
  const sortedSections = [...(activePage?.sections || [])].sort((a, b) => a.order - b.order);

  // Dynamic CSS variables from theme
  const cssVariables = generateCssVariables(doc.site.theme) as React.CSSProperties;
  const fontsUrl = generateGoogleFontsUrl(doc.site.settings?.googleFonts || []);

  return (
    <div
      ref={rootRef}
      className="website-root"
      onClick={handleElementClick}
      style={{
        ...cssVariables,
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        position: 'relative',
        backgroundColor: '#FFFFFF',
      }}
    >
      {/* Dynamic Google Fonts Link */}
      {fontsUrl && <link rel="stylesheet" href={fontsUrl} />}

      {/* Navigation */}
      <Navbar navigation={doc.navigation} siteName={doc.site.name} />

      {/* Sections or Empty Page State */}
      <main style={{ flex: 1, position: 'relative' }}>
        {sortedSections.length === 0 ? (
          <div
            style={{
              minHeight: '65vh',
              padding: '2rem 1.25rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <div
              style={{
                width: '100%',
                minHeight: '380px',
                border: '2px dashed #CBD5E1',
                borderRadius: '16px',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                textAlign: 'center',
                padding: '2.5rem 1.5rem',
                backgroundColor: '#FFFFFF',
              }}
            >
              <h3
                style={{
                  fontSize: '1.25rem',
                  fontWeight: 700,
                  color: '#0F172A',
                  marginBottom: '0.5rem',
                  letterSpacing: '-0.01em',
                }}
              >
                Empty page
              </h3>
              <p
                style={{
                  fontSize: '0.925rem',
                  color: '#64748B',
                  maxWidth: '260px',
                  lineHeight: 1.5,
                  margin: 0,
                }}
              >
                Drag a section here, or ask AI for a first draft
              </p>
            </div>
          </div>
        ) : (
          sortedSections.map(section => (
            <SectionWrapper
              key={section.id}
              section={section}
              isSelected={selectedSectionId === section.id && !selectedElement}
              isEditorMode={isEditorMode}
              onSelect={handleSectionSelect}
            >
              {renderComponent(section)}
            </SectionWrapper>
          ))
        )}

        {/* Floating Selection Box & Pill for selected element */}
        {isEditorMode && selectedElement && (
          <div
            style={{
              position: 'absolute',
              top: `${selectedElement.rect.top}px`,
              left: `${selectedElement.rect.left}px`,
              width: `${selectedElement.rect.width}px`,
              height: `${selectedElement.rect.height}px`,
              border: '2px solid #2563EB',
              borderRadius: '4px',
              pointerEvents: 'none',
              zIndex: 999,
              boxShadow: '0 0 0 1px rgba(255, 255, 255, 0.8)',
            }}
          >
            {/* Top-left pill label: Heading */}
            <div
              style={{
                position: 'absolute',
                top: '-28px',
                left: '-2px',
                backgroundColor: '#2563EB',
                color: '#FFFFFF',
                fontSize: '11px',
                fontWeight: 700,
                padding: '3px 8px',
                borderRadius: '6px',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                boxShadow: '0 2px 4px rgba(0,0,0,0.15)',
                whiteSpace: 'nowrap',
              }}
            >
              <span style={{ fontSize: '10px' }}>✎</span> {selectedElement.typeLabel}
            </div>

            {/* Corner Resize Handles */}
            <div style={{ position: 'absolute', top: '-4px', left: '-4px', width: '8px', height: '8px', backgroundColor: '#FFFFFF', border: '1.5px solid #2563EB', borderRadius: '1px' }} />
            <div style={{ position: 'absolute', top: '-4px', right: '-4px', width: '8px', height: '8px', backgroundColor: '#FFFFFF', border: '1.5px solid #2563EB', borderRadius: '1px' }} />
            <div style={{ position: 'absolute', bottom: '-4px', left: '-4px', width: '8px', height: '8px', backgroundColor: '#FFFFFF', border: '1.5px solid #2563EB', borderRadius: '1px' }} />
            <div style={{ position: 'absolute', bottom: '-4px', right: '-4px', width: '8px', height: '8px', backgroundColor: '#FFFFFF', border: '1.5px solid #2563EB', borderRadius: '1px' }} />
          </div>
        )}
      </main>
    </div>
  );
};
