import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/favorite_notifier.dart';

class FavoriteButton extends ConsumerWidget {
  final String trackId;
  final double size;
  
  const FavoriteButton({super.key, required this.trackId, this.size = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteNotifierProvider.notifier).isFavorite(trackId);
    
    // We also need to watch the state to trigger rebuilds when state changes
    ref.watch(favoriteNotifierProvider);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.redAccent : Colors.white70,
        size: size,
      ),
      onPressed: () {
        ref.read(favoriteNotifierProvider.notifier).toggleFavorite(trackId);
      },
    );
  }
}
