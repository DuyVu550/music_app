import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/track.dart';
import 'featured_tracks_notifier.dart';

class PopularTracksNotifier extends AsyncNotifier<List<Track>> {
  @override
  Future<List<Track>> build() async {
    final repo = ref.watch(featuredTrackRepositoryProvider);
    return repo.getPopularTracks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(featuredTrackRepositoryProvider);
      return repo.getPopularTracks();
    });
  }
}

final popularTracksProvider = AsyncNotifierProvider<PopularTracksNotifier, List<Track>>(() {
  return PopularTracksNotifier();
});
