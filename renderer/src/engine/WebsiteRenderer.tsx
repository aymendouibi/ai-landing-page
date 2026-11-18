import React, { useEffect, useState, useRef } from 'react';
import { Pencil, ChevronUp, ChevronDown, Copy, Trash2, CornerUpLeft } from 'lucide-react';
import { WebsiteDocument, BridgeMessage, SectionConfig } from '../types/schema';
import { generateCssVariables, generateGoogleFontsUrl, getGoogleFontsForDocument } from './theme';
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

  // Synchronize document title and custom favicon to the browser tab
  useEffect(() => {
    const siteName = doc?.site?.name;
    const pageTitle = doc?.pages?.[0]?.seo?.title || siteName;
    if (pageTitle && typeof document !== 'undefined') {
      document.title = pageTitle;
    }

    const faviconUrl = doc?.site?.favicon;
    if (faviconUrl && typeof document !== 'undefined') {
      let link: HTMLLinkElement | null = document.querySelector("link[rel~='icon']");
      if (!link) {
        link = document.createElement('link');
        link.rel = 'icon';
        document.head.appendChild(link);
      }
      link.href = faviconUrl;
    }
  }, [doc?.site?.name, doc?.site?.favicon, doc?.pages]);

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
            if (elementKey === 'headline' || elementKey === 'title') {
              updatedProps.headline = newText;
              updatedProps.title = newText;
              if (size) updatedProps.headlineSize = size;
            } else if (elementKey === 'subheadline' || elementKey === 'subtitle' || elementKey === 'description' || elementKey === 'body') {
              updatedProps.subheadline = newText;
              updatedProps.subtitle = newText;
              updatedProps.description = newText;
              updatedProps.body = newText;
            } else if (elementKey === 'ctaText' || elementKey === 'buttonText') {
              updatedProps.ctaText = newText;
              updatedProps.buttonText = newText;
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

    (window as any).updateSectionStyles = (sectionId: string, stylesData: any) => {
      try {
        const styles = typeof stylesData === 'string' ? JSON.parse(stylesData) : stylesData;
        setDoc(prev => {
          const newPages = prev.pages.map(page => ({
            ...page,
            sections: page.sections.map(sec => {
              if (sec.id !== sectionId) return sec;
              return { ...sec, styles: { ...sec.styles, ...styles } };
            }),
          }));
          return { ...prev, pages: newPages };
        });
      } catch (e) {
        console.error('Failed to update section styles', e);
      }
    };

    (window as any).updateWebsiteTitle = (newTitle: string) => {
      setDoc(prev => ({
        ...prev,
        site: { ...prev.site, name: newTitle },
        navigation: prev.navigation
          ? {
              ...prev.navigation,
              logo: { ...prev.navigation.logo, text: newTitle },
            }
          : prev.navigation,
      }));
    };

    window.selectSection = (sectionId: string) => {
      setSelectedSectionId(sectionId);
      setSelectedElement(null);

      if (sectionId === 'sec_navigation' || sectionId === 'navigation') {
        window.scrollTo({ top: 0, behavior: 'smooth' });
        return;
      }
      if (sectionId === 'sec_footer' || sectionId === 'footer') {
        window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
        return;
      }

      let el = document.getElementById(sectionId);
      if (!el) {
        el = document.querySelector(`[data-section-id="${sectionId}"]`) as HTMLElement;
      }
      if (!el) {
        const cleanName = sectionId.replace(/^sec_/, '');
        el = document.querySelector(`[data-component="${cleanName}"]`) as HTMLElement;
      }
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

  // Synchronize CSS variables and body background to document root
  useEffect(() => {
    const vars = generateCssVariables(doc.site.theme);
    Object.entries(vars).forEach(([k, v]) => {
      document.documentElement.style.setProperty(k, v);
    });
    if (vars['--color-bg']) {
      document.body.style.backgroundColor = vars['--color-bg'];
    }
  }, [doc.site.theme]);

  // Section level selection
  const handleSectionSelect = (sectionId: string) => {
    setSelectedSectionId(sectionId);
    setSelectedElement(null);

    const activePage = doc.pages.find(p => p.slug === currentSlug) || doc.pages[0];
    const sec = activePage?.sections.find(s => s.id === sectionId);
    const isNav = sectionId === 'sec_navigation' || sectionId === 'navigation';
    const isFooter = sectionId === 'sec_footer' || sectionId === 'footer';
    const comp = isNav ? 'navigation' : isFooter ? 'footer' : (sec?.component || 'section');
    const compName = isNav
      ? 'Navigation Bar'
      : isFooter
      ? 'Footer'
      : comp.charAt(0).toUpperCase() + comp.slice(1);

    if (onSectionSelect) {
      onSectionSelect(sectionId);
    }

    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(
        JSON.stringify({
          action: 'SELECT_SECTION',
          payload: { sectionId, component: comp, componentName: compName },
        })
      );
    } else if (window.AndroidBridge?.onSectionSelected) {
      window.AndroidBridge.onSectionSelected(sectionId);
    }
  };

  // Element-level click handler for granular inline editing
  const handleElementClick = (e: React.MouseEvent) => {
    if (!isEditorMode) return;

    const target = e.target as HTMLElement;
    // Don't trigger if clicking inside a floating toolbar
    if (target.closest('.floating-editor-toolbar')) return;

    const sectionEl = target.closest('[data-section-id]') as HTMLElement | null;
    if (!sectionEl) return;

    const sectionId = sectionEl.getAttribute('data-section-id') || '';
    const component = sectionEl.getAttribute('data-component') || 'section';
    const componentName = component.charAt(0).toUpperCase() + component.slice(1);

    // If clicked on navigation, select navigation layer
    if (sectionId === 'sec_navigation' || component === 'navigation') {
      handleSectionSelect('sec_navigation');
      return;
    }

    const isHeading = ['H1', 'H2', 'H3', 'H4'].includes(target.tagName);
    const isParagraph = target.tagName === 'P';
    const isButton = target.tagName === 'A' || target.tagName === 'BUTTON' || target.classList.contains('btn');
    const isImage = component === 'image' || target.tagName === 'IMG' || target.tagName === 'FIGURE';

    // If clicked on section container itself, an image, or non-text element, select section
    if (isImage || target === sectionEl || (!isHeading && !isParagraph && !isButton && target.children.length > 2)) {
      handleSectionSelect(sectionId);
      return;
    }

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

    const activePage = doc.pages.find(p => p.slug === currentSlug) || doc.pages[0];
    const currentSec = activePage?.sections?.find(s => s.id === sectionId);
    const rawHeadlineSize = (currentSec?.props?.headlineSize || 'Large') as string;
    const elementSize = (rawHeadlineSize.charAt(0).toUpperCase() + rawHeadlineSize.slice(1).toLowerCase()) as
      | 'Small'
      | 'Medium'
      | 'Large';

    const text = target.innerText.trim();
    const rect = target.getBoundingClientRect();
    const rootRect = rootRef.current?.getBoundingClientRect() || { top: 0, left: 0 };

    setSelectedElement({
      sectionId,
      component,
      elementKey,
      typeLabel,
      text,
      size: ['Small', 'Medium', 'Large'].includes(elementSize) ? elementSize : 'Large',
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
      size: ['Small', 'Medium', 'Large'].includes(elementSize) ? elementSize : 'Large',
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

  const handleOpenEdit = () => {
    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(JSON.stringify({ action: 'OPEN_EDIT_TAB' }));
    }
  };

  const handleFocusAi = (contextName: string) => {
    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(
        JSON.stringify({
          action: 'FOCUS_AI_PROMPT',
          payload: { context: contextName, sectionId: selectedSectionId },
        })
      );
    }
  };

  const handleMoveSection = (direction: 'up' | 'down') => {
    if (!selectedSectionId) return;
    const activePage = doc.pages.find(p => p.slug === currentSlug) || doc.pages[0];
    const sections = [...activePage.sections];
    const idx = sections.findIndex(s => s.id === selectedSectionId);
    if (idx === -1) return;

    if (direction === 'up' && idx > 0) {
      const temp = sections[idx];
      sections[idx] = sections[idx - 1];
      sections[idx - 1] = temp;
    } else if (direction === 'down' && idx < sections.length - 1) {
      const temp = sections[idx];
      sections[idx] = sections[idx + 1];
      sections[idx + 1] = temp;
    }

    const reorderedIds = sections.map(s => s.id);
    window.reorderSections?.(reorderedIds);
    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(JSON.stringify({ action: 'REORDER_SECTIONS', payload: { sectionIds: reorderedIds } }));
    }
  };

  const handleDuplicateSection = () => {
    if (!selectedSectionId) return;
    const activePage = doc.pages.find(p => p.slug === currentSlug) || doc.pages[0];
    const sec = activePage.sections.find(s => s.id === selectedSectionId);
    if (!sec) return;

    const newId = `sec_${sec.component}_${Date.now()}`;
    const clone: SectionConfig = {
      ...JSON.parse(JSON.stringify(sec)),
      id: newId,
      order: sec.order + 1,
    };
    window.addSection?.(clone);
  };

  const handleDeleteSection = () => {
    if (!selectedSectionId) return;
    window.deleteSection?.(selectedSectionId);
    if (window.AndroidBridge?.postMessage) {
      window.AndroidBridge.postMessage(JSON.stringify({ action: 'DELETE_SECTION', payload: { sectionId: selectedSectionId } }));
    }
  };

  const activePage = doc.pages.find(p => p.slug === currentSlug) || doc.pages[0];
  const sortedSections = [...(activePage?.sections || [])].sort((a, b) => a.order - b.order);
  const selectedSecConfig = sortedSections.find(s => s.id === selectedSectionId);
  const selectedSecComponent = selectedSecConfig?.component || 'Section';
  const selectedSecTitle = selectedSecComponent.charAt(0).toUpperCase() + selectedSecComponent.slice(1);

  // Dynamic CSS variables from theme
  const cssVariables = generateCssVariables(doc.site.theme) as React.CSSProperties;
  const fontsUrl = generateGoogleFontsUrl(getGoogleFontsForDocument(doc));

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
        backgroundColor: 'var(--color-bg, #FFFFFF)',
        paddingBottom: isEditorMode ? '140px' : '0px',
      }}
    >
      {/* Dynamic Google Fonts Link */}
      {fontsUrl && <link rel="stylesheet" href={fontsUrl} />}

      {/* Navigation */}
      <Navbar
        navigation={doc.navigation}
        siteName={doc.site?.name || ''}
        siteUrl={doc.site?.url}
        subdomain={doc.site?.subdomain}
        isEditorMode={isEditorMode}
        onSelect={handleSectionSelect}
        onBrandClick={() => handleSectionSelect('sec_navigation')}
      />

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
                backgroundColor: 'var(--color-bg, #FFFFFF)',
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
          sortedSections.map(section => {
            const isSecSelected = selectedSectionId === section.id;
            return (
              <div key={section.id} style={{ position: 'relative' }}>
                <SectionWrapper
                  section={section}
                  isSelected={isSecSelected && !selectedElement}
                  isEditorMode={isEditorMode}
                  onSelect={handleSectionSelect}
                >
                  {renderComponent(section)}
                </SectionWrapper>

                {/* Section Level Floating Toolbar (Screenshot 4 & 5) */}
                {isEditorMode && isSecSelected && !selectedElement && (
                  <div
                    className="floating-editor-toolbar"
                    style={{
                      position: 'absolute',
                      bottom: '-22px',
                      left: '20px',
                      backgroundColor: '#0F172A',
                      color: '#FFFFFF',
                      borderRadius: '999px',
                      padding: '6px 14px',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      boxShadow: '0 8px 20px rgba(0, 0, 0, 0.35)',
                      zIndex: 1000,
                      pointerEvents: 'auto',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    <span style={{ fontWeight: 700, fontSize: '13px' }}>{selectedSecTitle}</span>
                    <span style={{ color: '#475569', fontSize: '12px' }}>|</span>

                    {/* Edit Pencil */}
                    <button
                      onClick={handleOpenEdit}
                      title="Edit Section"
                      style={{ background: 'none', border: 'none', color: '#FFFFFF', cursor: 'pointer', display: 'flex', alignItems: 'center', padding: 0 }}
                    >
                      <Pencil size={14} strokeWidth={2.5} />
                    </button>

                    {/* AI Orb */}
                    <div
                      onClick={() => handleFocusAi(selectedSecComponent)}
                      title="Ask AI about this section"
                      style={{
                        width: '16px',
                        height: '16px',
                        borderRadius: '50%',
                        background: 'radial-gradient(circle at 35% 35%, #38BDF8, #818CF8 50%, #C084FC)',
                        boxShadow: '0 0 8px rgba(129, 140, 248, 0.8)',
                        cursor: 'pointer',
                      }}
                    />

                    {/* Move Up */}
                    <button
                      onClick={() => handleMoveSection('up')}
                      title="Move Up"
                      style={{ background: 'none', border: 'none', color: '#FFFFFF', cursor: 'pointer', display: 'flex', alignItems: 'center', padding: 0 }}
                    >
                      <ChevronUp size={15} strokeWidth={2.5} />
                    </button>

                    {/* Move Down */}
                    <button
                      onClick={() => handleMoveSection('down')}
                      title="Move Down"
                      style={{ background: 'none', border: 'none', color: '#FFFFFF', cursor: 'pointer', display: 'flex', alignItems: 'center', padding: 0 }}
                    >
                      <ChevronDown size={15} strokeWidth={2.5} />
                    </button>

                    {/* Duplicate */}
                    <button
                      onClick={handleDuplicateSection}
                      title="Duplicate Section"
                      style={{ background: 'none', border: 'none', color: '#FFFFFF', cursor: 'pointer', display: 'flex', alignItems: 'center', padding: 0 }}
                    >
                      <Copy size={14} strokeWidth={2.2} />
                    </button>

                    {/* Delete (coral red) */}
                    <button
                      onClick={handleDeleteSection}
                      title="Delete Section"
                      style={{ background: 'none', border: 'none', color: '#F87171', cursor: 'pointer', display: 'flex', alignItems: 'center', padding: 0 }}
                    >
                      <Trash2 size={14} strokeWidth={2.2} />
                    </button>
                  </div>
                )}
              </div>
            );
          })
        )}

        {/* Element Level Floating Box & Toolbar (Screenshot 2) */}
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
            {/* Top-left dark pill toolbar (Screenshot 2) */}
            <div
              className="floating-editor-toolbar"
              style={{
                position: 'absolute',
                top: selectedElement.rect.top < 45 ? `${selectedElement.rect.height + 8}px` : '-38px',
                left: '-2px',
                backgroundColor: '#0F172A',
                color: '#FFFFFF',
                borderRadius: '999px',
                padding: '5px 12px',
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
                boxShadow: '0 4px 14px rgba(0, 0, 0, 0.3)',
                whiteSpace: 'nowrap',
                pointerEvents: 'auto',
              }}
            >
              <span style={{ fontWeight: 700, fontSize: '12px' }}>{selectedElement.typeLabel}</span>
              <span style={{ color: '#475569', fontSize: '11px' }}>|</span>

              {/* Edit Pencil */}
              <button
                onClick={handleOpenEdit}
                title="Edit Text"
                style={{ background: 'none', border: 'none', color: '#FFFFFF', cursor: 'pointer', display: 'flex', alignItems: 'center', padding: 0 }}
              >
                <Pencil size={13} strokeWidth={2.5} />
              </button>

              {/* AI Orb */}
              <div
                onClick={() => handleFocusAi(selectedElement.typeLabel)}
                title="Ask AI about this heading"
                style={{
                  width: '15px',
                  height: '15px',
                  borderRadius: '50%',
                  background: 'radial-gradient(circle at 35% 35%, #38BDF8, #818CF8 50%, #C084FC)',
                  boxShadow: '0 0 6px rgba(129, 140, 248, 0.8)',
                  cursor: 'pointer',
                }}
              />

              {/* Reorder / turn arrow */}
              <CornerUpLeft size={13} strokeWidth={2.2} color="#94A3B8" />
            </div>

            {/* 4 Circular Corner Handles (Screenshot 2) */}
            <div style={{ position: 'absolute', top: '-5px', left: '-5px', width: '9px', height: '9px', backgroundColor: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%' }} />
            <div style={{ position: 'absolute', top: '-5px', right: '-5px', width: '9px', height: '9px', backgroundColor: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%' }} />
            <div style={{ position: 'absolute', bottom: '-5px', left: '-5px', width: '9px', height: '9px', backgroundColor: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%' }} />
            <div style={{ position: 'absolute', bottom: '-5px', right: '-5px', width: '9px', height: '9px', backgroundColor: '#FFFFFF', border: '2px solid #2563EB', borderRadius: '50%' }} />
          </div>
        )}
      </main>
    </div>
  );
};
