import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';

class PopularTracksNotifier extends AsyncNotifier<List<Track>> {
  StreamSubscription? _subscription;

  @override
  Future<List<Track>> build() async {
    final repo = ref.watch(trackRepositoryProvider);

    final completer = Completer<List<Track>>();
    _subscription?.cancel();
    _subscription = repo.getPopularTracksStream().listen(
      (tracks) {
        if (!completer.isCompleted) {
          completer.complete(tracks);
        } else {
          state = AsyncData(tracks);
        }
      },
      onError: (err, stack) {
        if (!completer.isCompleted) {
          completer.completeError(err, stack);
        } else {
          state = AsyncError(err, stack);
        }
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return completer.future;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final popularTracksProvider = AsyncNotifierProvider<PopularTracksNotifier, List<Track>>(() {
  return PopularTracksNotifier();
});
