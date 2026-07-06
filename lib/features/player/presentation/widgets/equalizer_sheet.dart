import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sleep_timer_notifier.dart';
import '../controllers/equalizer_notifier.dart';
import '../controllers/player_notifier.dart';

class EqualizerSheet extends ConsumerStatefulWidget {
  const EqualizerSheet({super.key});

  @override
  ConsumerState<EqualizerSheet> createState() => _EqualizerSheetState();
}

class _EqualizerSheetState extends ConsumerState<EqualizerSheet> {
  final List<String> _timerOptions = ['Tắt', '5 phút', '15 phút', '30 phút', '45 phút', '60 phút', 'Hết bài', 'Khác'];

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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final sleepTimer = ref.watch(sleepTimerProvider);
    final equalizer = ref.watch(equalizerProvider);
    final playerStateAsync = ref.watch(playerNotifierProvider);
    final isPlaying = playerStateAsync.value?.isPlaying ?? false;

    // Frequencies for the 5-bands
    final frequencies = ['60Hz', '230Hz', '910Hz', '4kHz', '14kHz'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF16162A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Equalizer & Hẹn Giờ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (sleepTimer.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_rounded, color: Colors.cyanAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            sleepTimer.isEndOfTheSong
                                ? 'Sau hết bài'
                                : _formatDuration(sleepTimer.remainingTime ?? Duration.zero),
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION 1: SLEEP TIMER
              const Text(
                'HẸN GIỜ TẮT NHẠC',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _timerOptions.length,
                  itemBuilder: (context, index) {
                    final option = _timerOptions[index];
                    final bool isSelected;
                    String chipLabel = option;

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
                      if (isSelected) {
                        final mins = sleepTimer.remainingTime!.inMinutes +
                            (sleepTimer.remainingTime!.inSeconds % 60 > 0 ? 1 : 0);
                        chipLabel = 'Khác (${mins}p)';
                      } else {
                        chipLabel = 'Khác...';
                      }
                    } else {
                      final minutes = int.parse(option.split(' ')[0]);
                      isSelected = sleepTimer.remainingTime != null &&
                          !sleepTimer.isEndOfTheSong &&
                          (sleepTimer.remainingTime!.inMinutes == minutes ||
                              (sleepTimer.remainingTime!.inMinutes + 1 == minutes &&
                                  sleepTimer.remainingTime!.inSeconds % 60 > 30));
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(chipLabel),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) _onTimerOptionSelected(option);
                        },
                        selectedColor: Colors.cyanAccent,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // SECTION 2: EQUALIZER
              const Text(
                'BỘ CÂN BẰNG ÂM THANH (PRESETS)',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              // Preset chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EqualizerNotifier.presets.keys.map((name) {
                  final isSelected = equalizer.presetName == name;
                  return ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        ref.read(equalizerProvider.notifier).setPreset(name);
                      }
                    },
                    selectedColor: Colors.cyanAccent,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Frequency Sliders
              Container(
                height: 180,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    final value = equalizer.bandValues[index];
                    return Column(
                      children: [
                        // dB value text
                        Text(
                          '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontFamily: 'monospace'),
                        ),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                activeTrackColor: Colors.cyanAccent,
                                inactiveTrackColor: Colors.white12,
                                thumbColor: Colors.cyanAccent,
                                overlayColor: Colors.cyanAccent.withValues(alpha: 0.1),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: value,
                                min: -10.0,
                                max: 10.0,
                                onChanged: (val) {
                                  ref.read(equalizerProvider.notifier).updateBandValue(index, val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Frequency label
                        Text(
                          frequencies[index],
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Visualizer simulation at the bottom
              Center(
                child: Text(
                  equalizer.presetName == 'Custom'
                      ? 'Chế độ Equalizer Tự chỉnh'
                      : 'Đang áp dụng bộ lọc ${equalizer.presetName}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: AudioVisualizer(isPlaying: isPlaying),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;

  const AudioVisualizer({super.key, required this.isPlaying});

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heights = List.generate(24, (index) => 4.0);
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        if (widget.isPlaying) {
          setState(() {
            for (int i = 0; i < _heights.length; i++) {
              // Create dynamic wave height
              _heights[i] = 4.0 + _random.nextDouble() * 36.0;
            }
          });
        }
      });

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        setState(() {
          for (int i = 0; i < _heights.length; i++) {
            _heights[i] = 4.0;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_heights.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 3.5,
          height: _heights[index],
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            gradient: const LinearGradient(
              colors: [Colors.purpleAccent, Colors.cyanAccent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        );
      }),
    );
  }
}
