# Menu Bar Calendar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a macOS menu bar app that shows date/time, opens a month calendar popover on click, and offers one-click system clock hiding with fallback.

**Architecture:** Swift Package executable with SwiftUI `MenuBarExtra`; pure `CalendarMonthModel` for grid math; `MonthNavigator` for UI state; `SystemClockHider` shells out to `defaults` + `killall ControlCenter` on user action only.

**Tech Stack:** Swift 6, SwiftUI, macOS 13+, SwiftPM, XCTest

---

## File map

| File | Responsibility |
|------|----------------|
| `Package.swift` | SPM manifest, macOS 13 platform |
| `Sources/MacDataCalendar/MacDataCalendarApp.swift` | `@main`, scenes, onboarding gate |
| `Sources/MacDataCalendar/CalendarMonthModel.swift` | Day cells, grid generation |
| `Sources/MacDataCalendar/MonthNavigator.swift` | Month navigation state |
| `Sources/MacDataCalendar/MenuBarLabelView.swift` | Status bar date/time label |
| `Sources/MacDataCalendar/CalendarPopoverView.swift` | Popover layout |
| `Sources/MacDataCalendar/MonthGridView.swift` | Weekday headers + grid |
| `Sources/MacDataCalendar/SystemClockHider.swift` | Hide system clock helper |
| `Sources/MacDataCalendar/OnboardingView.swift` | First-run sheet |
| `Sources/MacDataCalendar/SettingsView.swift` | Preferences window |
| `Sources/MacDataCalendar/AppSettings.swift` | UserDefaults wrapper |
| `Sources/MacDataCalendar/Info.plist` | `LSUIElement`, bundle ID |
| `Scripts/build-app.sh` | `swift build` + `.app` bundle |
| `Tests/MacDataCalendarTests/CalendarMonthModelTests.swift` | Grid unit tests |

---

### Task 1: Swift package scaffold

**Files:**
- Create: `Package.swift`, `Scripts/build-app.sh`, `Sources/MacDataCalendar/Info.plist`

- [ ] **Step 1:** Create `Package.swift` with executable + test targets, `platforms: [.macOS(.v13)]`
- [ ] **Step 2:** Create `Info.plist` with `LSUIElement=true`, `CFBundleIdentifier=com.macdata.calendar`
- [ ] **Step 3:** Create `Scripts/build-app.sh` — release build, copy binary + plist into `build/MacDataCalendar.app`
- [ ] **Step 4:** Run `swift package resolve` — expect success

---

### Task 2: CalendarMonthModel (TDD)

**Files:**
- Create: `Sources/MacDataCalendar/CalendarMonthModel.swift`
- Test: `Tests/MacDataCalendarTests/CalendarMonthModelTests.swift`

- [ ] **Step 1:** Write failing tests for June 2026 grid, Monday-first locale, leap Feb 2024, empty leading cells
- [ ] **Step 2:** Run `swift test` — FAIL
- [ ] **Step 3:** Implement `DayCell`, `makeMonthGrid(year:month:calendar:now:)` 
- [ ] **Step 4:** Run `swift test` — PASS

---

### Task 3: MonthNavigator

**Files:**
- Create: `Sources/MacDataCalendar/MonthNavigator.swift`

- [ ] **Step 1:** `ObservableObject` with `displayedMonth`, `goToPreviousMonth()`, `goToNextMonth()`, `monthTitle`
- [ ] **Step 2:** Unit test Dec 2026 → Jan 2027 navigation in test file
- [ ] **Step 3:** `swift test` — PASS

---

### Task 4: Menu bar + popover UI

**Files:**
- Create: `MacDataCalendarApp.swift`, `MenuBarLabelView.swift`, `CalendarPopoverView.swift`, `MonthGridView.swift`

- [ ] **Step 1:** `MenuBarExtra` with label + popover content
- [ ] **Step 2:** `MenuBarLabelView` — `TimelineView(.periodic from:by:)` every 60s, medium date + short time
- [ ] **Step 3:** `MonthGridView` — 7 columns, today ring, optional selected day
- [ ] **Step 4:** `CalendarPopoverView` — ‹ › buttons wired to navigator

---

### Task 5: SystemClockHider + onboarding

**Files:**
- Create: `SystemClockHider.swift`, `OnboardingView.swift`, `AppSettings.swift`, `SettingsView.swift`

- [ ] **Step 1:** `SystemClockHider.hide()` runs Process for defaults + killall, returns `Result`
- [ ] **Step 2:** `OnboardingView` — explain, hide button, skip, error text
- [ ] **Step 3:** Show onboarding sheet when `!AppSettings.hasSeenOnboarding`
- [ ] **Step 4:** `Settings` scene with repeat hide-clock button

---

### Task 6: Build and verify

- [ ] **Step 1:** `swift test` — all green
- [ ] **Step 2:** `Scripts/build-app.sh` — produces `build/MacDataCalendar.app`
- [ ] **Step 3:** Manual: open app, popover, month nav, onboarding skip

---

## Spec coverage

| Spec requirement | Task |
|------------------|------|
| Menu bar date/time | 4 |
| Month popover + ‹ › | 2, 3, 4 |
| Today highlight | 2, 4 |
| Hide system clock button | 5 |
| Onboarding skip | 5 |
| Unit tests for grid | 2 |
| macOS 13+ MenuBarExtra | 1, 4 |
