import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audio_player_service.dart';

class EqualizerState {
  final String presetName;
  final List<double> bandValues; // 5 bands in dB: 60Hz, 230Hz, 910Hz, 4kHz, 14kHz

  EqualizerState({
    required this.presetName,
    required this.bandValues,
  });

  EqualizerState copyWith({
    String? presetName,
    List<double>? bandValues,
  }) {
    return EqualizerState(
      presetName: presetName ?? this.presetName,
      bandValues: bandValues ?? this.bandValues,
    );
  }
}

class EqualizerNotifier extends Notifier<EqualizerState> {
  static const Map<String, List<double>> presets = {
    'Flat': [0.0, 0.0, 0.0, 0.0, 0.0],
    'Pop': [1.5, 3.0, 0.0, -1.0, 1.0],
    'Rock': [4.0, 2.5, -2.0, 2.0, 4.0],
    'Jazz': [3.0, 1.5, 1.0, 2.0, -1.0],
    'Classical': [3.5, 2.0, 0.0, 2.5, 3.5],
    'Bass Booster': [6.0, 3.5, 0.0, 0.0, 0.0],
  };

  @override
  EqualizerState build() {
    return EqualizerState(
      presetName: 'Flat',
      bandValues: List.from(presets['Flat']!),
    );
  }

  void setPreset(String name) {
    if (presets.containsKey(name)) {
      final bands = List<double>.from(presets[name]!);
      state = EqualizerState(presetName: name, bandValues: bands);
      _applyToAudio(bands);
    }
  }

  void updateBandValue(int index, double value) {
    if (index >= 0 && index < state.bandValues.length) {
      final newValues = List<double>.from(state.bandValues);
      newValues[index] = value;
      state = EqualizerState(presetName: 'Custom', bandValues: newValues);
      _applyToAudio(newValues);
    }
  }

  void _applyToAudio(List<double> bands) {
    ref.read(audioPlayerServiceProvider).applyEqualizerBands(bands);
  }
}

final equalizerProvider = NotifierProvider<EqualizerNotifier, EqualizerState>(() {
  return EqualizerNotifier();
});
