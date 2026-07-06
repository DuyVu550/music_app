import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/presentation/widgets/equalizer_sheet.dart';
import 'package:music_app/features/player/data/datasources/audio_player_service.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/player/domain/entities/player_state.dart';

class FakeAudioPlayerService implements AudioPlayerService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePlayerNotifier extends PlayerNotifier {
  @override
  Future<PlayerState> build() async {
    return const PlayerState(playlist: [], isPlaying: false);
  }
}

void main() {
  testWidgets('EqualizerSheet shows "Khác..." chip and opens input dialog', (WidgetTester tester) async {
    // Set physical screen size to be wider so that all horizontal chips are built and visible
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPlayerServiceProvider.overrideWithValue(FakeAudioPlayerService()),
          playerNotifierProvider.overrideWith(() => FakePlayerNotifier()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: EqualizerSheet(),
          ),
        ),
      ),
    );

    // Let it render
    await tester.pumpAndSettle();

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
