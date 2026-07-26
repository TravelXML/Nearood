---
name: Kindred Spirits
colors:
  surface: '#fcf8ff'
  surface-dim: '#dad6ff'
  surface-bright: '#fcf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f2ff'
  surface-container: '#efebff'
  surface-container-high: '#e9e5ff'
  surface-container-highest: '#e3dfff'
  on-surface: '#181445'
  on-surface-variant: '#464554'
  inverse-surface: '#2d2a5b'
  inverse-on-surface: '#f3eeff'
  outline: '#777586'
  outline-variant: '#c7c4d7'
  surface-tint: '#5148d7'
  primary: '#2a14b4'
  on-primary: '#ffffff'
  primary-container: '#4338ca'
  on-primary-container: '#c1beff'
  inverse-primary: '#c3c0ff'
  secondary: '#9d4300'
  on-secondary: '#ffffff'
  secondary-container: '#fd761a'
  on-secondary-container: '#5c2400'
  tertiary: '#692400'
  on-tertiary: '#ffffff'
  tertiary-container: '#8f3400'
  on-tertiary-container: '#ffb393'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e3dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#100069'
  on-primary-fixed-variant: '#372abf'
  secondary-fixed: '#ffdbca'
  secondary-fixed-dim: '#ffb690'
  on-secondary-fixed: '#341100'
  on-secondary-fixed-variant: '#783200'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb597'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#fcf8ff'
  on-background: '#181445'
  surface-variant: '#e3dfff'
typography:
  display-lg:
    fontFamily: Comfortaa
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Comfortaa
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Comfortaa
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Comfortaa
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: 0em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: 0em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
  container-max: 1280px
---

## Brand & Style
The brand personality is rooted in warmth, safety, and human connection. It seeks to evoke an emotional response of belonging and trust, positioning itself as a premium "digital third place." 

The design style is a blend of **Soft Minimalism** and **Tactile Modernism**. It prioritizes heavy whitespace and a restricted color palette to ensure clarity, but softens the digital edges with organic shapes and gentle depth. The interface avoids the coldness of corporate SaaS by utilizing approachable typography and "squishy" interactive states that feel responsive and inviting to the touch. It is a design system built for community-focused platforms where safety and quality of interaction are paramount.

## Colors
The palette is anchored by a deep, authoritative **Deep Violet (#4338ca)**, providing a sense of stability and premium quality. This is balanced by a vibrant **Warm Orange (#f97316)** used sparingly for calls to action and moments of delight, injecting energy into the community experience. 

The neutral palette leans into stone and cream tones rather than pure grays to maintain a "warm" atmosphere. Surfaces should use a soft off-white (#fafaf9) to reduce eye strain and enhance the artistic feel of the typography. Secondary actions and borders should utilize low-opacity tints of the primary violet to ensure tonal harmony.

## Typography
This design system uses **Comfortaa** for headings to provide a distinctive, artistic, and friendly character. Its rounded terminals suggest an approachable nature without sacrificing the premium "boutique" feel. 

For high legibility in dense information areas, **Plus Jakarta Sans** is used for body copy and UI labels. This font offers a clean, modern geometric structure that complements the roundness of the display face while maintaining professional clarity. 

- **Hierarchy:** Use large, bold display sizes for page titles to establish the brand voice.
- **Rhythm:** Maintain generous line heights (1.5x for body) to ensure a relaxed reading pace.
- **Micro-copy:** Small labels should use increased letter spacing and semi-bold weights to remain legible against soft backgrounds.

## Layout & Spacing
The layout follows a **Fluid Grid** model with a soft 4px base unit. This ensures a consistent vertical rhythm and spatial balance. 

- **Desktop:** 12-column grid with 24px gutters. Content is centered within a 1280px max-width container to maintain focus.
- **Mobile:** Single column with 16px side margins.
- **Spacing Philosophy:** Use "generous breathing room." Components should be spaced further apart than in traditional utility-first designs to emphasize the calm, premium aesthetic. For example, use 48px or 64px of vertical padding between major page sections.

## Elevation & Depth
Depth is achieved through **Tonal Layers** and **Ambient Shadows**. Instead of harsh dropshadows, this system uses "glow" shadows—diffused, low-opacity blurs that take on a slight tint of the primary color.

- **Level 0 (Base):** Off-white background (#fafaf9).
- **Level 1 (Cards):** White surface with a 1px border (#e2e8f0) or an extremely soft shadow (Y: 4, B: 20, Opacity: 4% Primary Color).
- **Level 2 (Interactive):** Floating elements use a more pronounced shadow (Y: 8, B: 30, Opacity: 8% Primary Color) to indicate hover states or modals.
- **Glassmorphism:** Use sparingly for navigation bars or overlays. A 12px backdrop blur with a 70% white fill creates a sophisticated sense of place.

## Shapes
The shape language is consistently **Rounded**, echoing the geometry of the Comfortaa typeface. 

- **Standard Elements:** Buttons, inputs, and small cards use a 0.5rem (8px) radius.
- **Large Containers:** Content blocks and feature cards use a 1rem (16px) radius.
- **Icons:** Use rounded icon sets (e.g., Lucide Rounded) to match the soft visual language. Avoid sharp corners or jagged edges in any custom illustrative elements.

## Components
- **Buttons:** Primary buttons use the Deep Violet background with white text and a subtle hover lift. Secondary buttons use a transparent background with a violet border. All buttons should have a minimum height of 48px to feel "squishy" and accessible.
- **Input Fields:** Use a light stone background (#f1f5f9) with a 2px bottom border that animates into a full violet outline on focus.
- **Cards:** Cards should be borderless but defined by the Level 1 Ambient Shadow. They should include 24px of internal padding to ensure content doesn't feel cramped.
- **Chips/Badges:** Use the Warm Orange at low opacity (10%) with 100% opacity text for status indicators or categories, ensuring they stand out without overwhelming the primary violet.
- **Lists:** List items should be separated by whitespace rather than lines where possible, using a subtle background hover state to indicate interactivity.
- **Feedback Elements:** Checkboxes and radios should be slightly oversized (20px) with fully rounded corners to feel friendly and tactile.