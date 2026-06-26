import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../../player/domain/repositories/track_repository.dart';
import '../../../player/domain/entities/track.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  ref.watch(authNotifierProvider);
  final repository = ref.read(trackRepositoryProvider);
  return repository.getCategories();
});

final categoryTracksProvider = FutureProvider.family<List<Track>, String>((ref, categoryId) async {
  final repository = ref.read(trackRepositoryProvider);
  return repository.getTracksByCategory(categoryId);
});
