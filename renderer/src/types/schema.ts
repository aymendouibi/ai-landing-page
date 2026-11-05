export type ComponentType =
  | 'navigation'
  | 'hero'
  | 'features'
  | 'benefits'
  | 'products'
  | 'galleries'
  | 'video'
  | 'about'
  | 'statistics'
  | 'testimonials'
  | 'reviews'
  | 'pricing'
  | 'comparison'
  | 'team'
  | 'faq'
  | 'contact'
  | 'forms'
  | 'newsletter'
  | 'cta'
  | 'footer';

export interface ColorPalette {
  primary: string;
  secondary: string;
  accent: string;
  background: string;
  surface: string;
  text: {
    primary: string;
    secondary: string;
    inverse: string;
  };
}

export interface TypographyScale {
  size: string;
  weight: number;
  lineHeight: number;
}

export interface TypographyConfig {
  headingFamily: string;
  bodyFamily: string;
  scale?: {
    h1?: TypographyScale;
    h2?: TypographyScale;
    h3?: TypographyScale;
    body?: TypographyScale;
    small?: TypographyScale;
  };
}

export interface SpacingConfig {
  sectionPadding?: { x: string; y: string };
  containerMaxWidth?: string;
  borderRadius?: {
    small?: string;
    medium?: string;
    large?: string;
    full?: string;
  };
}

export interface ButtonStyle {
  bg: string;
  text: string;
  border?: string;
  radius?: string;
  padding?: string;
}

export interface ThemeConfig {
  colors: ColorPalette;
  typography: TypographyConfig;
  spacing?: SpacingConfig;
  buttons?: {
    primary?: ButtonStyle;
    secondary?: ButtonStyle;
  };
}

export interface SiteSettings {
  language?: string;
  direction?: 'ltr' | 'rtl';
  googleFonts?: string[];
  customCss?: string | null;
}

export interface SiteConfig {
  name: string;
  favicon?: string | null;
  theme: ThemeConfig;
  settings?: SiteSettings;
}

export interface SeoConfig {
  title?: string;
  description?: string;
  ogImage?: string | null;
  noIndex?: boolean;
}

export interface SectionStyles {
  background?: string;
  textAlign?: 'left' | 'center' | 'right';
  paddingY?: string;
  [key: string]: unknown;
}

export interface SectionConfig {
  id: string;
  component: ComponentType;
  variant: string;
  order: number;
  visible?: boolean;
  props: Record<string, any>;
  styles?: SectionStyles;
  responsive?: {
    mobile?: {
      styles?: SectionStyles;
      props?: Record<string, any>;
    };
    tablet?: {
      styles?: SectionStyles;
      props?: Record<string, any>;
    };
  };
}

export interface PageConfig {
  id: string;
  slug: string;
  title: string;
  description?: string;
  seo?: SeoConfig;
  sections: SectionConfig[];
}

export interface NavItem {
  label: string;
  href: string;
  type?: 'link' | 'button';
}

export interface NavigationConfig {
  logo?: {
    text?: string;
    src?: string;
    alt?: string;
  };
  items: NavItem[];
  style?: 'transparent' | 'solid' | 'minimal';
}

export interface WebsiteDocument {
  schema_version: number;
  site: SiteConfig;
  pages: PageConfig[];
  navigation?: NavigationConfig;
}

// Editor Bridge Types for Android WebView communication
export type BridgeAction =
  | 'SELECT_SECTION'
  | 'UPDATE_SECTION_PROPS'
  | 'REORDER_SECTIONS'
  | 'DELETE_SECTION'
  | 'ADD_SECTION'
  | 'CHANGE_VIEWPORT'
  | 'EDITOR_READY';

export interface BridgeMessage<T = any> {
  action: BridgeAction;
  payload: T;
}

