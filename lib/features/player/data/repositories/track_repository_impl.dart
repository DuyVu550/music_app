import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';

/// Repository kết nối với Branium API (thantrieu.com) và Gist URL
/// Fetch toàn bộ danh sách nhạc một lần và cache lại.
class TrackRepositoryImpl implements TrackRepository {
  final Dio _dio;
  List<Track>? _cachedTracks;

  TrackRepositoryImpl({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}));

  Future<void> _fetchAllTracksIfNeeded() async {
    if (_cachedTracks != null) return;

    List<Track> braniumTracks = [];
    List<Track> gistTracks = [];

    // Fetch Branium API
    try {
      final response = await _dio.get('https://thantrieu.com/resources/braniumapis/songs.json');
      final data = response.data;
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
      debugPrint('Error fetching tracks from Branium API: $e');
    }

    // Fetch Gist API
    try {
      final response = await _dio.get('https://gist.githubusercontent.com/jasonbaldridge/2668632/raw/e56320c485a33c339791a25cc107bf70e7f1d763/music.json');
      var gistData = response.data;
      if (gistData is String) {
        gistData = jsonDecode(gistData);
      }
      final List<dynamic> artistsJson = (gistData is List) ? gistData : [];

      final soundHelixUrls = [
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      ];

      int gistIndex = 0;
      final random = Random();

      for (final artist in artistsJson) {
        if (artist is! Map) continue;
        final artistName = artist['name']?.toString() ?? 'Unknown Artist';
        final List<dynamic> albums = artist['albums'] is List ? artist['albums'] : [];

        for (final album in albums) {
          if (album is! Map) continue;
          final albumTitle = album['title']?.toString() ?? 'Unknown Album';
          final List<dynamic> songs = album['songs'] is List ? album['songs'] : [];

          for (final song in songs) {
            if (song is! Map) continue;
            final songTitle = song['title']?.toString() ?? 'Unknown Song';
            final lengthStr = song['length']?.toString();

            int durationMs = 0;
            if (lengthStr != null && lengthStr.contains(':')) {
              final parts = lengthStr.split(':');
              if (parts.length == 2) {
                final minutes = int.tryParse(parts[0]) ?? 0;
                final seconds = int.tryParse(parts[1]) ?? 0;
                durationMs = (minutes * 60 + seconds) * 1000;
              }
            }

            final trackId = 'gist_${artistName.replaceAll(' ', '_')}_${albumTitle.replaceAll(' ', '_')}_${songTitle.replaceAll(' ', '_')}';

            gistTracks.add(Track(
              id: trackId,
              title: songTitle,
              url: soundHelixUrls[gistIndex % soundHelixUrls.length],
              albumId: albumTitle,
              artistIds: [artistName],
              durationMs: durationMs,
              coverUrl: 'https://picsum.photos/seed/${trackId.hashCode.abs()}/300/300',
              listeners: 5000 + random.nextInt(10000),
            ));
            gistIndex++;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching tracks from Gist: $e');
    }
    List<Track> firestoreTracks = [];
    try {
      final snapshot = await FirebaseFirestore.instance.collection('songs').get();
      firestoreTracks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Track(
          id: doc.id,
          title: data['title']?.toString() ?? 'Unknown',
          url: data['audioUrl']?.toString() ?? '',
          albumId: 'Admin Upload',
          artistIds: [data['artist']?.toString() ?? 'Unknown Artist'],
          durationMs: 0,
          coverUrl: (data['coverUrl']?.toString().isEmpty ?? true) ? null : data['coverUrl']?.toString(),
          listeners: 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching tracks from Firestore: $e');
    }

    _cachedTracks = [...firestoreTracks, ...braniumTracks, ...gistTracks];
  }

  @override
  Future<List<Track>> getAllTracks() async {
    await _fetchAllTracksIfNeeded();
    return _cachedTracks ?? [];
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
             (track.artistIds.isNotEmpty && track.artistIds.first.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
