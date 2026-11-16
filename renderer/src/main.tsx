import React, { useState } from 'react';
import ReactDOM from 'react-dom/client';
import { WebsiteRenderer } from './engine/WebsiteRenderer';
import { WebsiteDocument } from './types/schema';
import { Smartphone, Tablet, Monitor } from 'lucide-react';

const sampleDocument: WebsiteDocument = {
  schema_version: 1,
  site: {
    name: 'Apex Studio',
    theme: {
      colors: {
        primary: '#4F46E5',
        secondary: '#06B6D4',
        accent: '#10B981',
        background: '#FFFFFF',
        surface: '#F8FAFC',
        text: {
          primary: '#0F172A',
          secondary: '#475569',
          inverse: '#FFFFFF',
        },
      },
      typography: {
        headingFamily: 'Inter',
        bodyFamily: 'Inter',
      },
    },
    settings: {
      language: 'en',
      googleFonts: ['Inter'],
    },
  },
  navigation: {
    logo: { text: 'Apex Studio' },
    items: [
      { label: 'Home', href: '/', type: 'link' },
      { label: 'Features', href: '#features', type: 'link' },
      { label: 'Testimonials', href: '#testimonials', type: 'link' },
      { label: 'FAQ', href: '#faq', type: 'link' },
      { label: 'Get Started', href: '#contact', type: 'button' },
    ],
  },
  pages: [
    {
      id: 'page_home',
      slug: '/',
      title: 'Home',
      sections: [
        {
          id: 'sec_hero_1',
          component: 'hero',
          variant: 'split_image',
          order: 0,
          props: {
            headline: 'Design, Build & Publish at the Speed of Thought',
            subheadline: 'The premier mobile-first website creation platform powered by curated templates and intelligent design recipes.',
            ctaText: 'Start Building Free',
            ctaLink: '#contact',
            secondaryCtaText: 'Explore Features',
            secondaryCtaLink: '#features',
            image: {
              src: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=800&q=80',
              alt: 'Apex Studio Platform Showcase',
            },
          },
          styles: { background: 'surface' },
        },
        {
          id: 'sec_feat_1',
          component: 'features',
          variant: 'grid_3col',
          order: 1,
          props: {
            title: 'Engineered for Digital Excellence',
            subtitle: 'Everything you need to craft high-conversion online experiences directly from your phone.',
            items: [
              {
                icon: 'zap',
                title: 'Instant Mobile Visual Editor',
                description: 'Direct interactive canvas with real-time responsive preview and zero lag.',
              },
              {
                icon: 'sparkles',
                title: 'AI Remix Intelligence',
                description: 'Personalize colors, copy, and layout without losing professional design identity.',
              },
              {
                icon: 'shield',
                title: 'Independent Static Hosting',
                description: 'Pre-compiled static delivery on Cloudflare edge CDN with custom domain support.',
              },
            ],
          },
        },
        {
          id: 'sec_test_1',
          component: 'testimonials',
          variant: 'cards',
          order: 2,
          props: {
            title: 'Trusted by over 10,000 creators worldwide',
            items: [
              {
                quote: 'I built and published my agency website from my phone in 20 minutes. The design quality is leagues above other mobile builders.',
                author: 'Sarah Jenkins',
                role: 'Founder, Lumina Creative',
                avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
                rating: 5,
              },
              {
                quote: 'The AI Remix feature saved us days of client back-and-forth. Clean code, fast loading, and rock solid stability.',
                author: 'David Vance',
                role: 'Digital Strategist',
                avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
                rating: 5,
              },
            ],
          },
          styles: { background: 'surface' },
        },
        {
          id: 'sec_faq_1',
          component: 'faq',
          variant: 'accordion',
          order: 3,
          props: {
            title: 'Frequently Asked Questions',
            items: [
              {
                question: 'Can I connect my own custom domain?',
                answer: 'Yes! Every website includes a free platform subdomain, and you can map your custom domain (with automatic free SSL) anytime.',
              },
              {
                question: 'Can I edit the website from desktop as well as phone?',
                answer: 'Yes. The website document is completely synchronized across the cloud and can be accessed anywhere.',
              },
            ],
          },
        },
        {
          id: 'sec_cta_1',
          component: 'cta',
          variant: 'centered',
          order: 4,
          props: {
            headline: 'Transform your web presence today',
            description: 'Join thousands of businesses crafting stunning websites in minutes.',
            buttonText: 'Get Started Now',
            buttonLink: '#contact',
          },
        },
        {
          id: 'sec_contact_1',
          component: 'contact',
          variant: 'form_split',
          order: 5,
          props: {
            title: 'Contact Our Team',
            description: 'Have questions or want custom enterprise solutions? Reach out today.',
            email: 'hello@apexstudio.local',
            phone: '+1 (555) 234-5678',
            address: '742 Evergreen Terrace, San Francisco, CA',
          },
          styles: { background: 'surface' },
        },
        {
          id: 'sec_foot_1',
          component: 'footer',
          variant: 'simple',
          order: 6,
          props: {
            copyright: '© 2026 Apex Studio. All rights reserved.',
            links: [
              { label: 'Privacy', href: '#' },
              { label: 'Terms', href: '#' },
              { label: 'Status', href: '#' },
            ],
          },
        },
      ],
    },
  ],
};

declare global {
  interface Window {
    AndroidBridge?: {
      postMessage: (message: string) => void;
      onSectionSelected?: (sectionId: string) => void;
    };
    updateDocument?: (jsonString: string) => void;
  }
}

function App() {
  const [viewport, setViewport] = useState<'mobile' | 'tablet' | 'desktop'>('desktop');
  const [currentDoc] = useState<WebsiteDocument>(sampleDocument);
  const isMobileEditor =
    window.location.search.includes('editor=true') ||
    typeof (window as any).AndroidBridge !== 'undefined' ||
    typeof (window as any).webkit?.messageHandlers?.AndroidBridge !== 'undefined' ||
    window.innerWidth < 640;

  React.useEffect(() => {
    // Notify mobile container that webview renderer is ready
    const bridge = (window as any).AndroidBridge || (window as any).webkit?.messageHandlers?.AndroidBridge;
    if (bridge?.postMessage) {
      bridge.postMessage(JSON.stringify({ type: 'RENDERER_READY' }));
    }
  }, []);

  const handleSectionSelect = (sectionId: string) => {
    const bridge = (window as any).AndroidBridge || (window as any).webkit?.messageHandlers?.AndroidBridge;
    if (bridge?.postMessage) {
      bridge.postMessage(
        JSON.stringify({
          type: 'SECTION_SELECTED',
          sectionId,
        })
      );
    }
  };

  const viewportWidths = {
    mobile: '375px',
    tablet: '768px',
    desktop: '100%',
  };

  // In mobile WebView / editor mode, render full width directly without preview frame
  if (isMobileEditor) {
    return (
      <WebsiteRenderer
        initialDocument={currentDoc}
        isEditorMode={true}
        onSectionSelect={handleSectionSelect}
      />
    );
  }

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#0F172A', display: 'flex', flexDirection: 'column' }}>
      {/* Device Toolbar */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          padding: '0.75rem 1.5rem',
          backgroundColor: '#1E293B',
          borderBottom: '1px solid #334155',
          color: '#F8FAFC',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <span style={{ fontWeight: 700, fontSize: '0.95rem' }}>AI Landing Page Canvas</span>
          <span style={{ fontSize: '0.75rem', background: '#334155', padding: '0.2rem 0.5rem', borderRadius: '4px' }}>
            Renderer Preview
          </span>
        </div>

        {/* Viewport Toggles */}
        <div style={{ display: 'flex', gap: '0.5rem', background: '#0F172A', padding: '0.25rem', borderRadius: '8px' }}>
          <button
            onClick={() => setViewport('mobile')}
            style={{
              background: viewport === 'mobile' ? '#4F46E5' : 'transparent',
              color: '#FFFFFF',
              border: 'none',
              padding: '0.4rem 0.8rem',
              borderRadius: '6px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.4rem',
              fontSize: '0.85rem',
            }}
          >
            <Smartphone size={16} /> Mobile
          </button>
          <button
            onClick={() => setViewport('tablet')}
            style={{
              background: viewport === 'tablet' ? '#4F46E5' : 'transparent',
              color: '#FFFFFF',
              border: 'none',
              padding: '0.4rem 0.8rem',
              borderRadius: '6px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.4rem',
              fontSize: '0.85rem',
            }}
          >
            <Tablet size={16} /> Tablet
          </button>
          <button
            onClick={() => setViewport('desktop')}
            style={{
              background: viewport === 'desktop' ? '#4F46E5' : 'transparent',
              color: '#FFFFFF',
              border: 'none',
              padding: '0.4rem 0.8rem',
              borderRadius: '6px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.4rem',
              fontSize: '0.85rem',
            }}
          >
            <Monitor size={16} /> Desktop
          </button>
        </div>
      </div>

      {/* Canvas Viewport Frame */}
      <div style={{ flex: 1, overflow: 'auto', display: 'flex', justifyContent: 'center', padding: viewport === 'desktop' ? 0 : '2rem' }}>
        <div
          style={{
            width: viewportWidths[viewport],
            backgroundColor: '#FFFFFF',
            boxShadow: viewport === 'desktop' ? 'none' : '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
            borderRadius: viewport === 'desktop' ? 0 : '12px',
            overflow: 'hidden',
            transition: 'width 0.25s ease',
          }}
        >
          <WebsiteRenderer
            initialDocument={sampleDocument}
            isEditorMode={true}
            onSectionSelect={secId => console.log('Selected section:', secId)}
          />
        </div>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

