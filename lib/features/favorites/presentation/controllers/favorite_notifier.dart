import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../domain/models/favorite_model.dart';

final favoriteNotifierProvider = AsyncNotifierProvider<FavoriteNotifier, List<FavoriteModel>>(() {
  return FavoriteNotifier();
});

class FavoriteNotifier extends AsyncNotifier<List<FavoriteModel>> {
  StreamSubscription? _subscription;
  String? _userId;

  @override
  Future<List<FavoriteModel>> build() async {
    final authState = ref.watch(authNotifierProvider);
    _userId = authState.value?.id;

    if (_userId == null) {
      return [];
    }

    final repository = ref.watch(favoriteRepositoryProvider);

    // Setup listener
    final completer = Completer<List<FavoriteModel>>();
    
    _subscription?.cancel();
    _subscription = repository.getFavoritesStream(_userId!).listen(
      (favorites) {
        if (!completer.isCompleted) {
          completer.complete(favorites);
        } else {
          state = AsyncData(favorites);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        } else {
          state = AsyncError(error, StackTrace.current);
        }
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return completer.future;
  }

  bool isFavorite(String trackId) {
    final favorites = state.value;
    if (favorites == null) return false;
    return favorites.any((fav) => fav.trackId == trackId);
  }

  Future<void> toggleFavorite(String trackId) async {
    if (_userId == null) return;
    
    final currentFavorites = state.value ?? [];
    final isFav = isFavorite(trackId);
    
    // Optimistic UI update
    if (isFav) {
      state = AsyncData(currentFavorites.where((f) => f.trackId != trackId).toList());
    } else {
      state = AsyncData([
        FavoriteModel(id: 'temp', userId: _userId!, trackId: trackId, createdAt: DateTime.now()),
        ...currentFavorites
      ]);
    }

    try {
      final repository = ref.read(favoriteRepositoryProvider);
      await repository.toggleFavorite(_userId!, trackId, !isFav);
    } catch (e) {
      // Revert if error
      state = AsyncData(currentFavorites);
    }
  }
}
