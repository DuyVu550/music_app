import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';
import '../../../explore/domain/entities/category.dart';
import '../../../explore/domain/entities/artist.dart';

/// Repository kết nối với Branium API (thantrieu.com) và Gist URL
/// Fetch toàn bộ danh sách nhạc một lần và cache lại.
class TrackRepositoryImpl implements TrackRepository {
  final Dio _dio;
  List<Track>? _cachedTracks;
  List<Artist>? _cachedArtists;
  final Map<String, List<Track>> _categoryTracksCache = {};
  final Map<String, List<Track>> _artistTracksCache = {};

  TrackRepositoryImpl({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
              },
            ),
          );

  Future<void> _fetchAllTracksIfNeeded() async {
    if (_cachedTracks != null) return;

    List<Track> braniumTracks = [];

    // Fetch Branium API
    try {
      final response = await _dio
          .get('https://thantrieu.com/resources/braniumapis/songs.json')
          .timeout(const Duration(seconds: 5));
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      final List<dynamic> songsJson = (data is Map) ? data['songs'] : [];
      braniumTracks = songsJson.map((json) {
        return Track(
          id: json['id']?.toString() ?? '',
          title: json['title']?.toString() ?? 'Unknown',
          url: json['source']?.toString() ?? '',
          albumId: json['album']?.toString() ?? '',
          artistIds: [json['artist']?.toString() ?? 'Unknown Artist'],
          // Convert seconds to milliseconds
          durationMs: (json['duration'] is int)
              ? (json['duration'] as int) * 1000
              : int.tryParse(json['duration'].toString()) != null
              ? int.parse(json['duration'].toString()) * 1000
              : 0,
          coverUrl: json['image']?.toString(),
          listeners: json['counter'] is int
              ? json['counter'] as int
              : int.tryParse(json['counter'].toString()) ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching tracks from Branium API, trying local assets fallback: $e');
      try {
        final jsonStr = await rootBundle.loadString('assets/songs.json');
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final List<dynamic> songsJson = data['songs'] is List ? data['songs'] : [];
        braniumTracks = songsJson.map((json) {
          return Track(
            id: json['id']?.toString() ?? '',
            title: json['title']?.toString() ?? 'Unknown',
            url: json['source']?.toString() ?? '',
            albumId: json['album']?.toString() ?? '',
            artistIds: [json['artist']?.toString() ?? 'Unknown Artist'],
            durationMs: (json['duration'] is int)
                ? (json['duration'] as int) * 1000
                : int.tryParse(json['duration'].toString()) != null
                ? int.parse(json['duration'].toString()) * 1000
                : 0,
            coverUrl: json['image']?.toString(),
            listeners: json['counter'] is int
                ? json['counter'] as int
                : int.tryParse(json['counter'].toString()) ?? 0,
          );
        }).toList();
        debugPrint('Successfully loaded thantrieu songs from local assets fallback!');
      } catch (assetErr) {
        debugPrint('Error loading thantrieu songs from assets fallback: $assetErr');
      }
    }

    List<Track> firestoreTracks = [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('songs')
          .get()
          .timeout(const Duration(seconds: 3));
      firestoreTracks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Track(
          id: doc.id,
          title: data['title']?.toString() ?? 'Unknown',
          url: data['audioUrl']?.toString() ?? '',
          albumId: 'Admin Upload',
          artistIds: [data['artist']?.toString() ?? 'Unknown Artist'],
          durationMs: 0,
          coverUrl: (data['coverUrl']?.toString().isEmpty ?? true)
              ? null
              : data['coverUrl']?.toString(),
          listeners: 0,
          lyrics: data['lyrics']?.toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching tracks from Firestore: $e');
    }

    _cachedTracks = [...firestoreTracks, ...braniumTracks];
  }

  @override
  Future<List<Track>> getAllTracks() async {
    await _fetchAllTracksIfNeeded();
    return _cachedTracks ?? [];
  }

  @override
  Stream<List<Track>> getAllTracksStream() {
    if (Firebase.apps.isEmpty) {
      return Stream.fromFuture(getAllTracks());
    }

    return FirebaseFirestore.instance.collection('songs').snapshots().asyncMap((
      snapshot,
    ) async {
      await _fetchAllTracksIfNeeded();

      final firestoreTracks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Track(
          id: doc.id,
          title: data['title']?.toString() ?? 'Unknown',
          url: data['audioUrl']?.toString() ?? '',
          albumId: 'Admin Upload',
          artistIds: [data['artist']?.toString() ?? 'Unknown Artist'],
          durationMs: 0,
          coverUrl: (data['coverUrl']?.toString().isEmpty ?? true)
              ? null
              : data['coverUrl']?.toString(),
          listeners: 0,
          lyrics: data['lyrics']?.toString(),
        );
      }).toList();

      final staticTracks = (_cachedTracks ?? [])
          .where((t) => t.albumId != 'Admin Upload')
          .toList();
      final combined = [...firestoreTracks, ...staticTracks];
      return combined;
    });
  }

  @override
  Future<List<Track>> getFeaturedTracks() async {
    await _fetchAllTracksIfNeeded();
    final list = List<Track>.from(_cachedTracks ?? []);
    list.shuffle(Random());
    return list.take(10).toList();
  }

  @override
  Future<List<Track>> getPopularTracks() async {
    await _fetchAllTracksIfNeeded();
    final list = List<Track>.from(_cachedTracks ?? []);
    // Sort by listeners (counter) descending
    list.sort((a, b) => b.listeners.compareTo(a.listeners));
    return list.take(20).toList();
  }

  @override
  Stream<List<Track>> getPopularTracksStream() {
    if (Firebase.apps.isEmpty) {
      return Stream.fromFuture(getPopularTracks());
    }

    return FirebaseFirestore.instance.collection('songs').snapshots().asyncMap((
      snapshot,
    ) async {
      await _fetchAllTracksIfNeeded();

      final firestoreTracks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Track(
          id: doc.id,
          title: data['title']?.toString() ?? 'Unknown',
          url: data['audioUrl']?.toString() ?? '',
          albumId: 'Admin Upload',
          artistIds: [data['artist']?.toString() ?? 'Unknown Artist'],
          durationMs: 0,
          coverUrl: (data['coverUrl']?.toString().isEmpty ?? true)
              ? null
              : data['coverUrl']?.toString(),
          listeners: 0,
          lyrics: data['lyrics']?.toString(),
        );
      }).toList();

      final staticTracks = (_cachedTracks ?? [])
          .where((t) => t.albumId != 'Admin Upload')
          .toList();
      final combined = [...firestoreTracks, ...staticTracks];
      combined.sort((a, b) => b.listeners.compareTo(a.listeners));
      return combined.take(20).toList();
    });
  }

  @override
  Future<List<Track>> getNewTracks() async {
    await _fetchAllTracksIfNeeded();
    final list = List<Track>.from(_cachedTracks ?? []);
    // Sort by ID descending as a fake "New" sorting
    list.sort((a, b) => b.id.compareTo(a.id));
    return list.take(10).toList();
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    await _fetchAllTracksIfNeeded();
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return (_cachedTracks ?? []).where((track) {
      return track.title.toLowerCase().contains(lowerQuery) ||
          (track.artistIds.isNotEmpty &&
              track.artistIds.first.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    const defaults = [
      Category(
        id: 'c1',
        name: 'Pop',
        imageUrl: 'https://picsum.photos/seed/pop/300/300',
      ),
      Category(
        id: 'c2',
        name: 'Rock',
        imageUrl: 'https://picsum.photos/seed/rock/300/300',
      ),
      Category(
        id: 'c3',
        name: 'Hip Hop',
        imageUrl: 'https://picsum.photos/seed/hiphop/300/300',
      ),
      Category(
        id: 'c4',
        name: 'Electronic',
        imageUrl: 'https://picsum.photos/seed/electronic/300/300',
      ),
      Category(
        id: 'c5',
        name: 'Jazz',
        imageUrl: 'https://picsum.photos/seed/jazz/300/300',
      ),
      Category(
        id: 'c6',
        name: 'Classical',
        imageUrl: 'https://picsum.photos/seed/classical/300/300',
      ),
    ];

    if (Firebase.apps.isEmpty) {
      return defaults;
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get()
          .timeout(const Duration(seconds: 3));
      if (snapshot.docs.isEmpty) {
        return defaults;
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Category.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return defaults;
    }
  }

  @override
  Future<List<Artist>> getArtists() async {
    List<Artist> firestoreArtists = [];
    try {
      if (Firebase.apps.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('artists')
            .get()
            .timeout(const Duration(seconds: 3));
        firestoreArtists = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Artist.fromJson(data);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error getting artists from Firestore: $e');
    }

    final staticArtists = await getArtistsStatic();
    final Map<String, Artist> merged = {};

    // Static/extracted artists first
    for (final artist in staticArtists) {
      merged[artist.name.toLowerCase().trim()] = artist;
    }

    // Firestore artists overwrite or add to the list
    for (final artist in firestoreArtists) {
      merged[artist.name.toLowerCase().trim()] = artist;
    }

    return merged.values.toList();
  }

  Future<List<Artist>> getArtistsStatic() async {
    await _fetchAllTracksIfNeeded();
    if (_cachedArtists == null) {
      final artistNames = <String>{};
      for (final track in _cachedTracks ?? <Track>[]) {
        artistNames.addAll(track.artistIds);
      }
      _cachedArtists = artistNames.map((name) {
        return Artist(
          id: 'artist_${name.replaceAll(' ', '_')}',
          name: name,
          imageUrl: 'https://picsum.photos/seed/${name.hashCode.abs()}/300/300',
        );
      }).toList();
    }
    return _cachedArtists!;
  }

  @override
  Future<List<Track>> getTracksByCategory(String categoryId) async {
    if (_categoryTracksCache.containsKey(categoryId)) {
      return _categoryTracksCache[categoryId]!;
    }
    await _fetchAllTracksIfNeeded();
    // Simulate filtering by category (we randomly assign categories to mock data if it doesn't have it)
    final list = List<Track>.from(_cachedTracks ?? []);
    list.shuffle(Random(categoryId.hashCode));
    final result = list.take(15).toList();
    _categoryTracksCache[categoryId] = result;
    return result;
  }

  @override
  Future<List<Track>> getTracksByArtist(String artistId) async {
    if (_artistTracksCache.containsKey(artistId)) {
      return _artistTracksCache[artistId]!;
    }
    await _fetchAllTracksIfNeeded();

    // Find the artist by id to get their name
    final artists = await getArtists();
    final artist = artists.firstWhere(
      (a) => a.id == artistId,
      orElse: () => Artist(
        id: artistId,
        name: artistId.replaceAll('artist_', '').replaceAll('_', ' '),
        imageUrl: '',
      ),
    );
    final targetName = artist.name.toLowerCase().trim();

    final result = (_cachedTracks ?? []).where((track) {
      return track.artistIds.any(
        (name) => name.toLowerCase().trim() == targetName,
      );
    }).toList();

    _artistTracksCache[artistId] = result;
    return result;
  }
}
