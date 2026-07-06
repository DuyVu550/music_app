# Design Spec - Custom Sleep Timer

**Date:** 2026-07-06  
**Status:** Approved  
**Author:** Antigravity  

---

## 1. Goal Description
The current music application has a pre-defined set of sleep timer options: Off, 5 mins, 15 mins, 30 mins, 45 mins, 60 mins, and End of Song. Users cannot specify a custom duration (e.g., 90 minutes). 
This design introduces a "Custom" option to let users enter any positive integer representing the sleep timer duration in minutes. The bottom sheet UI will dynamically display the remaining custom time directly on the "Custom" chip when active.

---

## 2. Proposed Changes

### Presentation Layer

#### [MODIFY] [equalizer_sheet.dart](file:///d:/music_app/lib/features/player/presentation/widgets/equalizer_sheet.dart)
- Append `'Khác'` to the list of `_timerOptions` array.
- In `ChoiceChip` list builder, if the option is `'Khác'`:
  - Determine if it is selected by checking if `sleepTimer.isActive && !sleepTimer.isEndOfTheSong && !presets.contains(remainingTimeInMinutes)`.
  - Display the label dynamically: `'Khác'` if not active, or `'Khác (${remainingTime}p)'` if active.
  - Implement a dialog to prompt the user to input custom minutes when tapped.
  - On submit, call `sleepTimerProvider.notifier.setTimer(...)` with the custom minutes converted to a `Duration`.

---

## 3. Verification Plan

### Automated Tests
- Run `flutter test` to ensure existing player and equalizer tests continue to pass.

### Manual Verification
- Open the Equalizer & Sleep Timer bottom sheet.
- Tap on the "Khác" chip. An input dialog should prompt for the number of minutes.
- Input `90` and tap "Bật".
- The "Khác" chip should become selected and display "Khác (90p)".
- The timer badge in the sheet header should show "90:00" and tick down.
