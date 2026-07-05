import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audio_player_service.dart';

class SleepTimerState {
  final Duration? remainingTime;
  final bool isEndOfTheSong;

  SleepTimerState({this.remainingTime, this.isEndOfTheSong = false});

  bool get isActive => remainingTime != null || isEndOfTheSong;

  SleepTimerState copyWith({
    Duration? remainingTime,
    bool? isEndOfTheSong,
    bool clearRemaining = false,
  }) {
    return SleepTimerState(
      remainingTime: clearRemaining ? null : (remainingTime ?? this.remainingTime),
      isEndOfTheSong: isEndOfTheSong ?? this.isEndOfTheSong,
    );
  }
}

class SleepTimerNotifier extends Notifier<SleepTimerState> {
  Timer? _timer;

  @override
  SleepTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return SleepTimerState();
  }

  void setTimer(Duration duration) {
    _timer?.cancel();
    state = SleepTimerState(remainingTime: duration);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentRemaining = state.remainingTime;
      if (currentRemaining == null || currentRemaining.inSeconds <= 1) {
        _triggerPause();
      } else {
        state = state.copyWith(remainingTime: currentRemaining - const Duration(seconds: 1));
      }
    });
  }

  void setEndOfTheSong(bool enabled) {
    _timer?.cancel();
    state = SleepTimerState(isEndOfTheSong: enabled);
  }

  void cancel() {
    _timer?.cancel();
    state = SleepTimerState();
  }

  void _triggerPause() {
    _timer?.cancel();
    state = SleepTimerState();
    ref.read(audioPlayerServiceProvider).pause();
  }

  void triggerEndOfTheSongPause() {
    _triggerPause();
  }
}

final sleepTimerProvider = NotifierProvider<SleepTimerNotifier, SleepTimerState>(() {
  return SleepTimerNotifier();
});
