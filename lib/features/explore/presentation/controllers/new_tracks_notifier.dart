import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';

class NewTracksNotifier extends AsyncNotifier<List<Track>> {
  @override
  Future<List<Track>> build() async {
    final repo = ref.watch(trackRepositoryProvider);
    return repo.getNewTracks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(trackRepositoryProvider);
      return repo.getNewTracks();
    });
  }
}

final newTracksProvider = AsyncNotifierProvider<NewTracksNotifier, List<Track>>(() {
  return NewTracksNotifier();
});
