import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/artist.dart';
import '../../../player/domain/repositories/track_repository.dart';
import '../../../player/domain/entities/track.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';

final artistsProvider = FutureProvider<List<Artist>>((ref) async {
  ref.watch(authNotifierProvider);
  final repository = ref.read(trackRepositoryProvider);
  return repository.getArtists();
});

final artistTracksProvider = FutureProvider.family<List<Track>, String>((ref, artistId) async {
  final repository = ref.read(trackRepositoryProvider);
  return repository.getTracksByArtist(artistId);
});
