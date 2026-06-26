import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';

/// Provider riêng biệt cho danh sách bài hát nổi bật (Featured Tracks).
/// Sử dụng AsyncNotifier để quản lý trạng thái bất đồng bộ khi gọi API.
class FeaturedTracksNotifier extends AsyncNotifier<List<Track>> {
  @override
  Future<List<Track>> build() async {
    ref.watch(authNotifierProvider);
    final repo = ref.watch(trackRepositoryProvider);
    return repo.getFeaturedTracks();
  }

  /// Làm mới danh sách bài hát nổi bật (pull-to-refresh hoặc realtime reload).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(trackRepositoryProvider);
      return repo.getFeaturedTracks();
    });
  }
}


/// Provider chính cho danh sách featured tracks.
final featuredTracksProvider =
    AsyncNotifierProvider<FeaturedTracksNotifier, List<Track>>(() {
  return FeaturedTracksNotifier();
});
