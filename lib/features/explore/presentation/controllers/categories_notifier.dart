import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../../player/domain/repositories/track_repository.dart';
import '../../../player/domain/entities/track.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(trackRepositoryProvider);
  return repository.getCategories();
});

final categoryTracksProvider = FutureProvider.family<List<Track>, String>((ref, categoryId) async {
  final repository = ref.read(trackRepositoryProvider);
  return repository.getTracksByCategory(categoryId);
});
