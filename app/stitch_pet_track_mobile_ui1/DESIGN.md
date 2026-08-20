---
name: Kindred Finder
colors:
  surface: '#f8f9ff'
  surface-dim: '#ccdbf4'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dde9ff'
  surface-container-highest: '#d5e3fd'
  on-surface: '#0d1c2f'
  on-surface-variant: '#3f4a3c'
  inverse-surface: '#233144'
  inverse-on-surface: '#ebf1ff'
  outline: '#6f7a6b'
  outline-variant: '#becab9'
  surface-tint: '#006e1c'
  primary: '#006e1c'
  on-primary: '#ffffff'
  primary-container: '#4caf50'
  on-primary-container: '#003c0b'
  inverse-primary: '#78dc77'
  secondary: '#8b5000'
  on-secondary: '#ffffff'
  secondary-container: '#ff9800'
  on-secondary-container: '#653900'
  tertiary: '#0061a4'
  on-tertiary: '#ffffff'
  tertiary-container: '#33a0fe'
  on-tertiary-container: '#00355d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#94f990'
  primary-fixed-dim: '#78dc77'
  on-primary-fixed: '#002204'
  on-primary-fixed-variant: '#005313'
  secondary-fixed: '#ffdcbe'
  secondary-fixed-dim: '#ffb870'
  on-secondary-fixed: '#2c1600'
  on-secondary-fixed-variant: '#693c00'
  tertiary-fixed: '#d1e4ff'
  tertiary-fixed-dim: '#9ecaff'
  on-tertiary-fixed: '#001d36'
  on-tertiary-fixed-variant: '#00497d'
  background: '#f8f9ff'
  on-background: '#0d1c2f'
  surface-variant: '#d5e3fd'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style

The design system is centered on empathy, urgency, and reliability. As a platform for lost pets, the UI must balance a sense of calm reassurance with the functional clarity required during high-stress situations.

The aesthetic follows a **Modern Corporate** style with **Soft Tactile** influences. It prioritizes high legibility and a friendly, approachable atmosphere to reduce user anxiety. Key characteristics include:
- **Optimistic Utility:** A clean, organized interface that feels professional yet warm.
- **Softness:** Extensive use of rounded corners and gentle shadows to evoke a sense of safety and care.
- **Clarity:** Heavy emphasis on whitespace and clear visual hierarchies to ensure users can navigate the app quickly under pressure.

## Colors

The color palette is designed to be both functional and emotionally resonant:

- **Primary (Hope Green):** Used for primary actions, success states, and the core brand identity. It represents the positive outcome of finding a pet.
- **Secondary (Alert Orange):** Reserved for high-visibility alerts, "Lost" status badges, and urgent notifications. Its warmth prevents it from feeling purely clinical or alarming.
- **Neutral (Deep Slate):** Used for typography and iconography to ensure maximum contrast and sophisticated readability.
- **Background (Soft Mist):** An off-white, slightly cool background that reduces screen glare and makes content cards pop.
- **Surface:** Pure white (#FFFFFF) is used for cards and interactive containers to create clear separation from the background.

## Typography

This design system utilizes **Inter** for its exceptional legibility on mobile screens and its neutral, modern character.

- **Headlines:** Use Bold (700) or SemiBold (600) weights with slight negative letter-spacing to create a strong, grounded hierarchy.
- **Body Text:** Use Regular (400) weight for all long-form content to ensure a comfortable reading experience.
- **Labels:** Use SemiBold (600) for buttons and navigation items to distinguish interactive elements from static text.
- **Scale:** On mobile devices, headlines scale down slightly to ensure text doesn't wrap awkwardly while maintaining a clear visual "punch."

## Layout & Spacing

The design system employs a **fluid layout model** optimized for mobile-first interaction. 

- **Grid:** A standard 4-column grid for mobile with 20px outside margins and 16px gutters.
- **Rhythm:** All spacing must be a multiple of 8px (the `base` unit). 
- **Touch Targets:** All interactive elements (buttons, links, inputs) must maintain a minimum touch target size of 48x48px to accommodate users in stressful or outdoor environments.
- **Padding:** Use generous internal padding (`lg` or 24px) within cards to create a sense of breathability and focus.

## Elevation & Depth

Visual hierarchy is achieved through a combination of **Tonal Layers** and **Ambient Shadows**:

- **Level 0 (Background):** The base `#F8FAFC` surface.
- **Level 1 (Cards):** White surfaces with a subtle, highly diffused shadow (Box Shadow: `0px 4px 12px rgba(51, 65, 85, 0.05)`). This represents standard content.
- **Level 2 (Interactive/Floating):** Elements like "Report Lost Pet" buttons use a more pronounced shadow to indicate they sit above the content (Box Shadow: `0px 8px 20px rgba(51, 65, 85, 0.12)`).
- **Overlays:** Use a 40% opacity Slate (#334155) backdrop for modals to maintain focus while keeping the underlying context visible.

## Shapes

The shape language is consistently **Rounded** to convey friendliness and safety.

- **Standard Components:** Buttons, input fields, and small chips use `rounded` (0.5rem / 8px).
- **Containers:** Large content cards and modals use `rounded-xl` (1.5rem / 24px) to create a distinct, soft frame for pet photos.
- **Avatars:** Pet photos and user profiles should use `rounded-lg` (1rem / 16px) or full circles for a "friendly" portrait feel.

## Components

### Buttons
- **Primary:** Solid Hope Green with white text. Rounded corners (8px). Subtle 5% dark gradient from top to bottom.
- **Secondary/Alert:** Solid Alert Orange for the "Report Lost" action.
- **Ghost:** Transparent background with Slate text for low-priority actions.

### Cards
- **Pet Profile Card:** White background, 24px corner radius. Features a large, high-resolution image at the top with a "status chip" (Lost/Found) overlaid in the top-right corner.

### Chips & Badges
- **Status Chips:** Use high-contrast backgrounds (Green for "Found", Orange for "Lost") with SemiBold uppercase text for instant recognition at a glance.

### Input Fields
- **Search & Forms:** Large 56px height for mobile ease. Light gray border (#E2E8F0) that turns Primary Green on focus. Includes 16px horizontal padding.

### Lists
- **Activity Feed:** Clean list items separated by 1px light gray borders. Each item features a 48px rounded thumbnail and a 2-line text summary.

### Progress Indicators
- **Step Trackers:** Used for the "Report a Pet" flow. Uses a thick 4px Hope Green bar to show completion, providing a sense of momentum to the user.