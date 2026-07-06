# Custom Sleep Timer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable users to set a custom duration for the sleep timer (in minutes) via an input dialog triggered by a "Khác" ChoiceChip, and dynamically update the chip's label to show the remaining time.

**Architecture:** Extend the existing horizontal list of preset timer options in `equalizer_sheet.dart`. Detect if the active sleep timer has a custom duration (not matching any preset) and highlight the "Khác" chip with dynamic countdown labels. Show an input dialog when the "Khác" chip is tapped.

**Tech Stack:** Flutter, Riverpod, Dart

## Global Constraints
- Target platform: iOS, Android, Web
- Ensure clean code and no unnecessary dependencies.
- Follow TDD practices (write test first, run to fail, write minimal implementation, verify pass, commit).

---

### Task 1: Update UI and ChoiceChip Selection in Equalizer Bottom Sheet

**Files:**
- Modify: `lib/features/player/presentation/widgets/equalizer_sheet.dart`
- Test: `test/widget_test.dart` (or create a dedicated widget test)

**Interfaces:**
- Consumes: `sleepTimerProvider` (SleepTimerState)
- Produces: Dynamic chip label and input dialog triggers for custom duration sleep timer.

- [ ] **Step 1: Write a failing widget test to verify the custom sleep timer option is present and triggers a dialog**

Write the following test in `test/widget_test.dart` or a new test file:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/presentation/widgets/equalizer_sheet.dart';

void main() {
  testWidgets('EqualizerSheet shows "Khác..." chip and opens input dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: EqualizerSheet(),
          ),
        ),
      ),
    );

    // Verify "Khác..." chip exists
    final khacChip = find.text('Khác...');
    expect(khacChip, findsOneWidget);

    // Tap the chip
    await tester.tap(khacChip);
    await tester.pumpAndSettle();

    // Verify the dialog appears
    expect(find.text('Hẹn giờ tùy chỉnh'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `flutter test test/widget_test.dart` (or the specific file)
Expected: Failure with "Khác..." text not found.

- [ ] **Step 3: Modify `equalizer_sheet.dart` to add the custom chip and show the dialog**

Modify the file `lib/features/player/presentation/widgets/equalizer_sheet.dart`:
```dart
// Modify _timerOptions (around line 16):
final List<String> _timerOptions = ['Tắt', '5 phút', '15 phút', '30 phút', '45 phút', '60 phút', 'Hết bài', 'Khác'];

// Update _onTimerOptionSelected (around line 18):
void _onTimerOptionSelected(String option) {
  final sleepTimerNotifier = ref.read(sleepTimerProvider.notifier);
  if (option == 'Tắt') {
    sleepTimerNotifier.cancel();
  } else if (option == 'Hết bài') {
    sleepTimerNotifier.setEndOfTheSong(true);
  } else if (option == 'Khác') {
    _showCustomTimerDialog();
  } else {
    final minutes = int.parse(option.split(' ')[0]);
    sleepTimerNotifier.setTimer(Duration(minutes: minutes));
  }
}

// Add _showCustomTimerDialog to _EqualizerSheetState class:
void _showCustomTimerDialog() {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.2)),
        ),
        title: const Text(
          'Hẹn giờ tùy chỉnh',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập số phút hẹn giờ tắt nhạc:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ví dụ: 90',
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text.trim());
              if (minutes != null && minutes > 0) {
                ref.read(sleepTimerProvider.notifier).setTimer(Duration(minutes: minutes));
              }
              Navigator.pop(context);
            },
            child: const Text('Bật', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      );
    },
  );
}

// Update ListView.builder item build logic (around line 133):
final option = _timerOptions[index];
final bool isSelected;
if (option == 'Tắt') {
  isSelected = !sleepTimer.isActive;
} else if (option == 'Hết bài') {
  isSelected = sleepTimer.isEndOfTheSong;
} else if (option == 'Khác') {
  final presets = [5, 15, 30, 45, 60];
  isSelected = sleepTimer.isActive &&
      !sleepTimer.isEndOfTheSong &&
      (sleepTimer.remainingTime != null &&
          !presets.contains(sleepTimer.remainingTime!.inMinutes) &&
          !presets.contains(sleepTimer.remainingTime!.inMinutes + 1));
} else {
  final minutes = int.parse(option.split(' ')[0]);
  isSelected = sleepTimer.remainingTime != null &&
      !sleepTimer.isEndOfTheSong &&
      (sleepTimer.remainingTime!.inMinutes == minutes ||
          (sleepTimer.remainingTime!.inMinutes + 1 == minutes &&
              sleepTimer.remainingTime!.inSeconds % 60 > 30));
}

// Compute chip label dynamically:
String chipLabel = option;
if (option == 'Khác') {
  final presets = [5, 15, 30, 45, 60];
  final isCustomActive = sleepTimer.isActive &&
      !sleepTimer.isEndOfTheSong &&
      (sleepTimer.remainingTime != null &&
          !presets.contains(sleepTimer.remainingTime!.inMinutes) &&
          !presets.contains(sleepTimer.remainingTime!.inMinutes + 1));
  if (isCustomActive) {
    final mins = sleepTimer.remainingTime!.inMinutes +
        (sleepTimer.remainingTime!.inSeconds % 60 > 0 ? 1 : 0);
    chipLabel = 'Khác (${mins}p)';
  } else {
    chipLabel = 'Khác...';
  }
}

// In the ChoiceChip widget, change:
label: Text(chipLabel),
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/widget_test.dart` (or the specific file)
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add lib/features/player/presentation/widgets/equalizer_sheet.dart
git commit -m "feat: support custom sleep timer with dialog input"
```
