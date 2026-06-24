// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;

  Future<void> setPlaylist(List<Track> tracks, {int initialIndex = 0}) async {
    try {
      final audioSources = tracks.map((track) {
        return AudioSource.uri(
          Uri.parse(track.url),
          tag: MediaItem(
            id: track.id,
            album: track.albumId,
            title: track.title,
            artist: track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
            artUri: track.coverUrl != null && track.coverUrl!.startsWith('http') 
                ? Uri.parse(track.coverUrl!) 
                : null,
          ),
        );
      }).toList();
      
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: initialIndex,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing audio playlist: $e");
    }
  }

  void resume() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position, {int? index}) {
    _audioPlayer.seek(position, index: index);
  }

  void seekToNext() {
    _audioPlayer.seekToNext();
  }

  void seekToPrevious() {
    _audioPlayer.seekToPrevious();
  }

  void stop() {
    _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
