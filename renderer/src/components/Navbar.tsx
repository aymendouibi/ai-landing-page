import React, { useState } from 'react';
import { NavigationConfig } from '../types/schema';
import { Menu, X } from 'lucide-react';

interface NavbarProps {
  navigation?: NavigationConfig;
  siteName: string;
  siteUrl?: string;
  subdomain?: string;
  isEditorMode?: boolean;
  onSelect?: (id: string) => void;
  onBrandClick?: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({
  navigation,
  siteName,
  siteUrl,
  subdomain,
  isEditorMode = false,
  onSelect,
  onBrandClick,
}) => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  if (!navigation) return null;

  const items = navigation.items || [];
  const logo = navigation.logo?.text || siteName;
  const isTransparent = navigation.style === 'transparent';
  const brandHref =
    siteUrl ||
    (navigation.logo as any)?.href ||
    (subdomain
      ? `/sites/${subdomain}`
      : siteName
      ? `/sites/${encodeURIComponent(siteName.toLowerCase().replace(/[^a-z0-9]/g, ''))}`
      : '#');

  const handleHeaderClick = () => {
    if (isEditorMode && onSelect) {
      onSelect('sec_navigation');
    }
  };

  const handleBrandClick = (e: React.MouseEvent) => {
    if (isEditorMode) {
      e.preventDefault();
      e.stopPropagation();
      if (onBrandClick) {
        onBrandClick();
      } else if (onSelect) {
        onSelect('sec_navigation');
      }
    }
  };

  return (
    <header
      id="sec_navigation"
      data-section-id="sec_navigation"
      data-component="navigation"
      onClick={handleHeaderClick}
      style={{
        position: 'sticky',
        top: 0,
        zIndex: 100,
        backgroundColor: isTransparent ? 'rgba(255, 255, 255, 0.92)' : 'var(--color-bg)',
        backdropFilter: 'blur(8px)',
        borderBottom: '1px solid rgba(0, 0, 0, 0.06)',
        transition: 'background-color 0.2s ease',
        cursor: isEditorMode ? 'pointer' : 'default',
      }}
    >
      <div
        className="container"
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          height: '4.5rem',
        }}
      >
        {/* Brand / Logo */}
        <a
          href={brandHref}
          onClick={handleBrandClick}
          style={{
            fontSize: '1.25rem',
            fontWeight: 800,
            letterSpacing: '-0.02em',
            color: 'var(--color-primary)',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
            cursor: 'pointer',
          }}
          title={isEditorMode ? 'Edit website title & logo' : undefined}
        >
          {navigation.logo?.src ? (
            <img src={navigation.logo.src} alt={logo} style={{ height: '2rem' }} />
          ) : (
            <span>{logo}</span>
          )}
        </a>

        {/* Desktop Links */}
        <nav
          style={{
            display: 'none',
            alignItems: 'center',
            gap: '2rem',
          }}
          className="desktop-nav"
        >
          {items.map((item, idx) =>
            item.type === 'button' ? (
              <a key={idx} href={item.href} className="btn btn-primary">
                {item.label}
              </a>
            ) : (
              <a
                key={idx}
                href={item.href}
                style={{
                  fontSize: '0.95rem',
                  fontWeight: 500,
                  color: 'var(--color-text-secondary)',
                  transition: 'color 0.15s ease',
                }}
              >
                {item.label}
              </a>
            )
          )}
        </nav>

        {/* Mobile Hamburger Button */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          aria-label="Toggle navigation menu"
          style={{
            display: 'flex',
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            padding: '0.5rem',
            color: 'var(--color-text-primary)',
          }}
          className="mobile-toggle"
        >
          {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile Dropdown Menu */}
      {mobileMenuOpen && (
        <div
          style={{
            backgroundColor: 'var(--color-bg)',
            borderBottom: '1px solid rgba(0, 0, 0, 0.08)',
            padding: '1.5rem',
            display: 'flex',
            flexDirection: 'column',
            gap: '1rem',
          }}
        >
          {items.map((item, idx) =>
            item.type === 'button' ? (
              <a
                key={idx}
                href={item.href}
                className="btn btn-primary"
                onClick={() => setMobileMenuOpen(false)}
                style={{ width: '100%' }}
              >
                {item.label}
              </a>
            ) : (
              <a
                key={idx}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                style={{
                  padding: '0.5rem 0',
                  fontSize: '1rem',
                  fontWeight: 500,
                  color: 'var(--color-text-primary)',
                }}
              >
                {item.label}
              </a>
            )
          )}
        </div>
      )}

      <style>{`
        @media (min-width: 768px) {
          .desktop-nav { display: flex !important; }
          .mobile-toggle { display: none !important; }
        }
      `}</style>
    </header>
  );
};

