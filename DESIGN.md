---
name: MacData Calendar
description: Native macOS menu bar month calendar — compact icon, stable popover grid
colors:
  weekend-ink: "#D13838"
  holiday-fill: "#E6473D"
  holiday-fill-opacity: "0.18"
  today-ring: "{colors.accent}"
  accent: "systemAccentColor"
  surface: "systemBackground"
  ink-primary: "labelColor"
  ink-secondary: "secondaryLabelColor"
typography:
  menu-icon:
    fontFamily: "SF Pro, system-ui"
    fontSize: "15px"
    fontWeight: 400
  menu-day-badge:
    fontFamily: "SF Pro Rounded, system-ui"
    fontSize: "9px"
    fontWeight: 700
  month-title:
    fontFamily: "SF Pro, system-ui"
    fontSize: "headline"
    fontWeight: 600
  weekday-header:
    fontFamily: "SF Pro, system-ui"
    fontSize: "caption2"
    fontWeight: 600
  day-cell:
    fontFamily: "SF Pro, system-ui"
    fontSize: "13px"
    fontWeight: 400
  day-cell-emphasis:
    fontFamily: "SF Pro, system-ui"
    fontSize: "13px"
    fontWeight: 600
  today-link:
    fontFamily: "SF Pro, system-ui"
    fontSize: "caption"
    fontWeight: 400
  instant-tooltip:
    fontFamily: "SF Pro, system-ui"
    fontSize: "11px"
    fontWeight: 500
rounded:
  day-cell: "50%"
  tooltip: "5px"
spacing:
  popover-padding-x: "14px"
  popover-padding-top: "20px"
  popover-padding-bottom: "14px"
  header-block-height: "36px"
  grid-gap: "4px"
  section-gap: "12px"
components:
  popover-shell:
    width: "280px"
    height: "318px"
    padding: "{spacing.popover-padding-x}"
  day-cell-default:
    size: "28px"
    typography: "{typography.day-cell}"
    textColor: "{colors.ink-primary}"
  day-cell-weekend:
    size: "28px"
    typography: "{typography.day-cell-emphasis}"
    textColor: "{colors.weekend-ink}"
  day-cell-holiday:
    size: "28px"
    typography: "{typography.day-cell-emphasis}"
    textColor: "{colors.weekend-ink}"
    backgroundColor: "{colors.holiday-fill}"
  day-cell-today:
    size: "28px"
    backgroundColor: "{colors.accent}"
---

## Overview

Native **SwiftUI** menu bar app (`MenuBarExtra`, `.window` style). One surface: **menu bar label** (calendar SF Symbol + today's day number) and **month popover** (header with ‹ ›, optional «Сегодня», 7×6 day grid). Visual language follows **macOS system materials and accent**; custom color is reserved for **weekend/holiday semantics** (red family). Layout is **fixed 280×318pt** so month switches never resize the shell. Motion is minimal; hover tooltips are **custom instant overlays**, not delayed `.help()`.

## Colors

| Role | Value | Usage |
|------|-------|--------|
| Weekend ink | `#D13838` (RGB 0.82, 0.22, 0.22) | Sat/Sun day numbers, weekend column headers |
| Holiday fill | `#E6473D` @ 18% opacity | Circle behind public holiday days |
| Today | `Color.accentColor` @ 25% | Ring behind current date |
| Selection | `Color.accentColor` @ 12% | Tapped day highlight |
| Tooltip surface | `.thickMaterial` | Instant hover badge |

Workdays use `.primary`; headers use `.secondary` except weekend columns (weekend ink @ 85%).

**Day semantics** (not separate colors): `workday` / `weekend` / `holiday(title)` from `DayClassifier` + RU production calendar.

## Typography

- **System stack only** — SF Pro / SF Pro Rounded via SwiftUI `.system` and semantic styles (`.headline`, `.caption2`).
- **Menu bar**: 15pt icon + 9pt bold rounded day badge.
- **Grid**: 13pt day numbers; semibold for weekend/holiday.
- **Month title**: `.headline`, single line, `minimumScaleFactor(0.85)`.
- **«Сегодня»**: `.caption`, secondary — always occupies 36pt header block (hidden via opacity when on current month).

No fluid/clamp type; menu bar and popover are fixed-density product UI.

## Elevation

Flat popover on system background. Depth cues:
- **Today / holiday**: flat filled circles, no drop shadow on cells.
- **Instant tooltip**: `thickMaterial` + light shadow (`black @ 18%`, radius 3, y 1).
- No glassmorphism, no card stacks.

## Components

### MenuBarLabelView
- `calendar` hierarchical symbol + centered day-of-month digit.
- Accessibility: «Календарь».

### CalendarPopoverView
- Fixed frame **280×318**.
- Header row: chevron buttons (plain), centered title + «Сегодня» slot.

### MonthGridView
- 7-column `LazyVGrid`, 42 cells (6 weeks).
- Day cell 28×28; plain button style.
- `onHover` → instant tooltip above cell (`dayKind.tooltip`: «Выходной» or holiday name).
- States: default, weekend, holiday (+fill), today (+accent ring), selected (+accent wash).

### MonthNavigator
- ‹ › month; `goToToday()` when not on current month.

## Do's and Don'ts

**Do**
- Keep popover dimensions fixed when conditional UI toggles.
- Use system accent for «today» and selection.
- Show holiday names on hover immediately.
- Preserve Monday-first grid for Russian locale.
- Test long month names («Сентябрь») without layout reflow.

**Don't**
- Don't resize popover when «Сегодня» appears/disappears (use opacity + fixed header height).
- Don't use system `.help()` for time-sensitive hints (too slow).
- Don't add dock icon (`LSUIElement` stays true).
- Don't introduce web-style cards, gradients, or non-native controls in the popover.
- Don't rely on color alone — semibold weight + tooltip + holiday fill distinguish holidays from workdays.
