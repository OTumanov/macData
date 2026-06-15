# MacData Calendar — Tier A Utility Pack

**Date:** 2026-06-15  
**Status:** Approved — implemented  
**Depends on:** MVP (`2026-06-15-menubar-calendar-design.md`), PRODUCT.md  
**Scope:** Quit, Launch at login, weekday tooltips, copy date on click

## Problem

MVP delivers the month grid and RU holidays, but the app still behaves like a demo: no obvious way to quit (LSUIElement, no Dock), no persistence across reboots, tooltips only on holidays/weekends, and no way to reuse a date after lookup.

## Goal

Four small features that make MacData a daily menu bar utility without expanding scope into Calendar.app replacement.

**Success criteria:**

1. User can quit the app in ≤2 actions without Activity Monitor.
2. User can enable «Запускать при входе» once and forget.
3. Hovering any day shows full weekday + date in Russian (≤50 ms perceived delay).
4. Single click on a day copies a useful date string; user gets brief confirmation.

**Non-goals (this pack):**

- Week numbers, year navigation, Calendar.app deep links
- Settings window / format picker
- EventKit, reminders, sync
- App Store sandboxing or notarization

---

## Feature 1: Quit

### UX

- **Primary:** footer link «Выйти» inside the popover (always visible).
- **Secondary:** right-click (control-click) on menu bar icon → context menu with «Выйти».
- Action: `NSApplication.shared.terminate(nil)`.

### UI

Footer row below the grid, separated by a 1 px `Divider()`:

```
─────────────────────────
☐ Запускать при входе     Выйти
```

«Выйти» — plain text button, trailing, secondary color; no destructive red (product register: quiet utility).

### Accessibility

- `accessibilityLabel`: «Выйти из MacData Calendar»
- Keyboard: not required for MVP of this feature (footer is mouse-first).

---

## Feature 2: Launch at login

### UX

- Toggle «Запускать при входе» in popover footer (leading).
- Persists via `@AppStorage("launchAtLogin")`.
- On toggle ON: register login item; OFF: unregister.
- If registration fails (permissions, SMAppService error): revert toggle, show inline caption under toggle: «Не удалось добавить в автозапуск» (one line, no modal).

### Implementation

- Wrapper `LaunchAtLoginService` using `ServiceManagement.SMAppService.mainApp` (macOS 13+; project minimum is 14).
- On app launch: sync toggle UI with `SMAppService.mainApp.status` (`.enabled` / `.notRegistered`) so UI reflects reality if user changed Login Items in System Settings.
- Ad-hoc signed `.app` copied to `/Applications` — SMAppService works for user-local login items without App Store entitlements.

### Error handling

| Case | Behavior |
|------|----------|
| Register succeeds | Toggle stays ON |
| Register fails | Toggle reverts OFF, inline error text |
| App moved/deleted after register | Next launch: status `.notFound` → toggle OFF, clear error |
| User disables in System Settings | Next open popover: sync shows OFF |

---

## Feature 3: Weekday tooltip on every day

### UX

- On hover, every day cell (not only holidays) shows instant tooltip.
- Format: **`EEEE, d MMMM`** localized (e.g. `воскресенье, 15 июня`).
- Holiday/weekend: append existing semantic line — e.g. `воскресенье, 15 июня · Выходной` or `пятница, 12 июня · День России`.
- Same overlay mechanism as today (`onHover`, no `.help()`).
- Tooltip placement rules unchanged (top rows → below cell).

### Implementation

- `DayTooltipFormatter` — static `DateFormatter`, locale `Locale.current`, template `EEEE, d MMMM`.
- `DayKind.tooltipSuffix` — optional second part after ` · `.
- One formatter instance (no per-cell allocation).

---

## Feature 4: Copy date on click

### UX

- Single click on a day copies to pasteboard.
- **Default format:** `d MMMM yyyy, EEEE` → `15 июня 2026, воскресенье` (readable for RU users).
- Brief feedback: 800 ms caption overlay centered in popover bottom area: «Скопировано» (replaces nothing permanently; fades via opacity).
- Popover stays open (user may copy several dates).
- Empty/padding cells: no action.

### Implementation

- `NSPasteboard.general.clearContents()` + `setString(_:forType: .string)`.
- `@State private var copyConfirmationVisible` in `CalendarPopoverView` or `MonthGridView` with `Task.sleep` auto-hide.
- `accessibilityHint` on day cells: «Нажмите, чтобы скопировать дату».

### Future hook (not built now)

- `@AppStorage("copyFormat")` — deferred; single format keeps scope minimal.

---

## Layout changes

### Popover geometry

Current: 280 × 292. Footer adds ~36 pt (divider + toggle row + padding).

**New fixed size:** 280 × **328** (stable geometry principle — reserve footer always, no resize on copy toast).

Copy toast floats over footer area with opacity animation; does not change window height.

### Files (planned)

| File | Role |
|------|------|
| `PopoverFooterView.swift` | Toggle + Quit + copy toast host |
| `LaunchAtLoginService.swift` | SMAppService wrapper + status sync |
| `DayTooltipFormatter.swift` | Tooltip + clipboard formatters |
| `MonthGridView.swift` | Hover text for all days; click → copy callback |
| `CalendarPopoverView.swift` | Wire footer, pass copy handler |
| `MenuBarLabelView.swift` | `.contextMenu { Quit }` |
| `CalendarTheme.swift` | `popoverHeight = 328`, footer constants |

---

## Architecture

```
MenuBarExtra
├── MenuBarLabelView (+ contextMenu Quit)
└── CalendarPopoverView
    ├── Header (month nav)
    ├── MonthGridView
    │   ├── onHover → DayTooltipFormatter.fullLine(date, dayKind)
    │   └── onTap   → callback → NSPasteboard + toast
    └── PopoverFooterView
        ├── Toggle → LaunchAtLoginService
        └── Quit button
```

Boundaries:

- **LaunchAtLoginService** — only SMAppService; no SwiftUI.
- **DayTooltipFormatter** — pure formatting; no UI.
- **PopoverFooterView** — footer chrome only.

---

## Testing

| Test | Type | What |
|------|------|------|
| `DayTooltipFormatterTests` | Unit | RU locale line for known date; holiday suffix |
| `ClipboardDateFormatterTests` | Unit | Copy string for known date |
| `LaunchAtLoginServiceTests` | Unit (mock) | Optional — thin wrapper; manual QA acceptable |
| Manual | QA | Quit both paths; toggle login item; hover all cell types; copy + toast |

Unit tests use same `ru_RU` calendar setup as existing `CalendarMonthModelTests`.

---

## Accessibility & PRODUCT alignment

- WCAG: tooltip text supplements color (weekend red + words).
- Reduced motion: copy toast uses opacity only, no slide.
- Anti-references honored: no events, no clock hijack, no popover resize on month change.
- Keyboard shortcuts (←/→/T) unchanged.

---

## Implementation order

1. `DayTooltipFormatter` + weekday tooltips (visible win, no new UI chrome)
2. Copy on click + toast
3. `PopoverFooterView` with Quit
4. Context menu on menu bar label
5. `LaunchAtLoginService` + toggle (test last — environment-dependent)

Estimated effort: **~4–6 hours** total.

---

## Open decisions (resolved in this spec)

| Question | Decision |
|----------|----------|
| Copy format | `15 июня 2026, воскресенье` |
| Quit placement | Footer + context menu |
| Login item API | `SMAppService.mainApp` |
| Popover height | 328 pt fixed |
