import React, { useEffect, useState } from 'react';
import { WebsiteDocument, BridgeMessage } from '../types/schema';
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

// Extend window for Android JavaScript Interface bridge
declare global {
  interface Window {
    AndroidBridge?: {
      postMessage: (message: string) => void;
      onSectionSelected?: (sectionId: string) => void;
    };
    updateDocument?: (jsonString: string) => void;
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

  useEffect(() => {
    if (initialDocument) {
      setDoc(initialDocument);
    }
  }, [initialDocument]);

  // Setup communication bridge with Android WebView and Parent Window
  useEffect(() => {
    // 1. Listen for window messages (Web iframe or WebView postMessage)
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
        // Ignore unparseable messages
      }
    };

    window.addEventListener('message', handleMessage);

    // 2. Expose global functions callable directly by Android WebView: webView.evaluateJavascript("...")
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
  }, []);

  // Handle section click in editor mode
  const handleSectionSelect = (sectionId: string) => {
    setSelectedSectionId(sectionId);

    if (onSectionSelect) {
      onSectionSelect(sectionId);
    }

    // Inform Android native container via JavaScript Bridge
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

    // Inform parent frame if inside iframe
    if (window.parent && window.parent !== window) {
      window.parent.postMessage({ action: 'SELECT_SECTION', payload: { sectionId } }, '*');
    }
  };

  const activePage = doc.pages.find(p => p.slug === currentSlug) || doc.pages[0];
  const sortedSections = [...(activePage?.sections || [])].sort((a, b) => a.order - b.order);

  // Dynamic CSS variables from theme
  const cssVariables = generateCssVariables(doc.site.theme) as React.CSSProperties;
  const fontsUrl = generateGoogleFontsUrl(doc.site.settings?.googleFonts || []);

  return (
    <div
      className="website-root"
      style={{
        ...cssVariables,
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {/* Dynamic Google Fonts Link */}
      {fontsUrl && <link rel="stylesheet" href={fontsUrl} />}

      {/* Navigation */}
      <Navbar navigation={doc.navigation} siteName={doc.site.name} />

      {/* Sections */}
      <main style={{ flex: 1 }}>
        {sortedSections.map(section => (
          <SectionWrapper
            key={section.id}
            section={section}
            isSelected={selectedSectionId === section.id}
            isEditorMode={isEditorMode}
            onSelect={handleSectionSelect}
          >
            {renderComponent(section)}
          </SectionWrapper>
        ))}
      </main>
    </div>
  );
};

