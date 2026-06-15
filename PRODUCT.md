# Product

## Register

product

## Users

macOS users (primarily Russian locale) who need a fast answer to «какой день недели у этого числа?» without opening Calendar.app or digging through Control Center widgets. They work with the menu bar visible and expect native, low-friction utilities (Raycast / Itsycal mental model).

## Product Purpose

**MacData Calendar** is a menu bar utility: a compact calendar icon opens a month grid popover. Users scan weekdays, navigate months, jump back to today, and see weekends and Russian public holidays at a glance. The system clock stays untouched; this is a separate affordance beside it.

Success looks like: open popover in one click, find the weekday for any date in under 3 seconds, stable UI with no layout jumps, trustworthy RU holiday highlighting.

## Brand Personality

Native, quiet, precise. **Compact · Trustworthy · Instant** — feels like part of macOS, not a web widget glued to the menu bar. No onboarding sermons, no fighting the OS.

## Anti-references

- Hiding or hijacking the system menu bar clock (impossible/unreliable on macOS 15+)
- Popover or window size that changes when navigating months
- Slow system tooltips; decorative UI that steals attention from the grid
- Full Calendar.app replacement (events, reminders, sync)
- «AI slop» web aesthetics in a native shell (gradients, glass cards, oversized radii)
- Nag banners about settings the user already dismissed

## Design Principles

1. **Earned familiarity** — standard macOS patterns (`MenuBarExtra`, system fonts, accent for «today»). Users should trust it like a built-in control.
2. **The grid is the product** — chrome stays minimal; month navigation and day semantics are the hero.
3. **Stable geometry** — fixed popover size; reserved space for controls that appear conditionally (e.g. «Сегодня»).
4. **Instant feedback** — hover tooltips and state changes without perceptible delay.
5. **Respect the platform** — system clock stays; MacData is the calendar, not the clock.

## Accessibility & Inclusion

- Target **WCAG 2.1 AA** where applicable (contrast on holiday/weekend reds against popover background; not color-only state — weight + fill + tooltip text).
- Full **keyboard** access to month navigation and day cells where SwiftUI allows.
- **`aria-label` / `accessibilityLabel`** on days with holiday names and «выходной» for weekends.
- **`prefers-reduced-motion`**: avoid decorative motion; popover appears without choreographed animation.
- Locale-aware: **Monday-first** week grid for `ru_*`; RU public holiday calendar with room to extend per year.
