import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/data/repositories/track_repository_impl.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';

/// Provider riêng biệt cho danh sách bài hát nổi bật (Featured Tracks).
/// Sử dụng AsyncNotifier để quản lý trạng thái bất đồng bộ khi gọi API.
class FeaturedTracksNotifier extends AsyncNotifier<List<Track>> {
  @override
  Future<List<Track>> build() async {
    final repo = ref.watch(featuredTrackRepositoryProvider);
    return repo.getFeaturedTracks();
  }

  /// Làm mới danh sách bài hát nổi bật (pull-to-refresh hoặc realtime reload).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(featuredTrackRepositoryProvider);
      return repo.getFeaturedTracks();
    });
  }
}

/// Provider cho TrackRepository dùng trong featured tracks.
final featuredTrackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepositoryImpl();
});

/// Provider chính cho danh sách featured tracks.
final featuredTracksProvider =
    AsyncNotifierProvider<FeaturedTracksNotifier, List<Track>>(() {
  return FeaturedTracksNotifier();
});
