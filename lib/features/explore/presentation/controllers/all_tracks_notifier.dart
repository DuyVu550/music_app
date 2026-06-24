import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/track.dart';
import 'featured_tracks_notifier.dart';

class AllTracksNotifier extends AsyncNotifier<List<Track>> {
  @override
  Future<List<Track>> build() async {
    final repo = ref.watch(featuredTrackRepositoryProvider);
    return repo.getAllTracks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(featuredTrackRepositoryProvider);
      return repo.getAllTracks();
    });
  }
}

final allTracksProvider = AsyncNotifierProvider<AllTracksNotifier, List<Track>>(() {
  return AllTracksNotifier();
});
