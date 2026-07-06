import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/track.dart';

final offlineTrackServiceProvider = Provider<OfflineTrackService>((ref) {
  return OfflineTrackService();
});

class DownloadProgress {
  final double progress; // 0.0 to 1.0
  final bool isDone;
  final String? error;

  const DownloadProgress({
    required this.progress,
    this.isDone = false,
    this.error,
  });
}

class OfflineTrackService {
  static const String _manifestFile = 'offline_tracks.json';
  final Dio _dio = Dio();

  // In-memory download progress map
  final Map<String, ValueNotifier<DownloadProgress>> _progressMap = {};

  /// Returns directory used to store downloaded audio files.
  Future<Directory> get _offlineDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/offline_tracks');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns path to the manifest JSON file.
  Future<String> get _manifestPath async {
    final dir = await _offlineDir;
    return '${dir.path}/$_manifestFile';
  }

  /// Returns the file path for a downloaded track.
  Future<String> _trackFilePath(String trackId) async {
    final dir = await _offlineDir;
    return '${dir.path}/$trackId.mp3';
  }

  /// Read the manifest. Returns a Map of trackId -> Track JSON.
  Future<Map<String, dynamic>> _readManifest() async {
    final path = await _manifestPath;
    final file = File(path);
    if (!await file.exists()) return {};
    try {
      final content = await file.readAsString();
      return Map<String, dynamic>.from(jsonDecode(content) as Map);
    } catch (_) {
      return {};
    }
  }

  /// Write the manifest.
  Future<void> _writeManifest(Map<String, dynamic> manifest) async {
    final path = await _manifestPath;
    await File(path).writeAsString(jsonEncode(manifest));
  }

  /// Get a ValueNotifier for the download progress of a track.
  ValueNotifier<DownloadProgress> getProgressNotifier(String trackId) {
    return _progressMap.putIfAbsent(
      trackId,
      () => ValueNotifier(const DownloadProgress(progress: 0.0)),
    );
  }

  /// Returns true if a track is already downloaded locally.
  Future<bool> isTrackDownloaded(String trackId) async {
    // On non-mobile platforms, offline download is not supported
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return false;
    }
    final filePath = await _trackFilePath(trackId);
    return File(filePath).existsSync();
  }

  /// Download a track to local storage.
  Future<void> downloadTrack(Track track) async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return;
    }

    final notifier = getProgressNotifier(track.id);
    notifier.value = const DownloadProgress(progress: 0.0);

    try {
      final filePath = await _trackFilePath(track.id);

      await _dio.download(
        track.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            notifier.value = DownloadProgress(progress: received / total);
          }
        },
      );

      // Save metadata to manifest
      final manifest = await _readManifest();
      manifest[track.id] = {
        'id': track.id,
        'title': track.title,
        'artistIds': track.artistIds,
        'albumId': track.albumId,
        'coverUrl': track.coverUrl,
        'durationMs': track.durationMs,
        'isExplicit': track.isExplicit,
        'listeners': track.listeners,
        'lyrics': track.lyrics,
        'localPath': filePath,
      };
      await _writeManifest(manifest);

      notifier.value = const DownloadProgress(progress: 1.0, isDone: true);
    } catch (e) {
      notifier.value = DownloadProgress(
        progress: 0.0,
        isDone: true,
        error: e.toString(),
      );
    }
  }

  /// Delete a downloaded track.
  Future<void> deleteTrack(String trackId) async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return;
    }
    final filePath = await _trackFilePath(trackId);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    final manifest = await _readManifest();
    manifest.remove(trackId);
    await _writeManifest(manifest);

    _progressMap.remove(trackId);
  }

  /// Return the local file path if downloaded, otherwise null.
  Future<String?> getLocalFilePath(String trackId) async {
    if (!await isTrackDownloaded(trackId)) return null;
    return _trackFilePath(trackId);
  }

  /// Return all downloaded tracks from manifest.
  Future<List<Track>> getDownloadedTracks() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return [];
    }
    final manifest = await _readManifest();
    final tracks = <Track>[];
    for (final entry in manifest.entries) {
      final data = entry.value as Map<String, dynamic>;
      final localPath = data['localPath'] as String? ?? '';
      // Only include if file still exists
      if (localPath.isNotEmpty && File(localPath).existsSync()) {
        tracks.add(Track(
          id: data['id'] as String,
          title: data['title'] as String,
          url: localPath, // Use local path as URL
          artistIds: List<String>.from(data['artistIds'] as List? ?? []),
          albumId: data['albumId'] as String? ?? '',
          coverUrl: data['coverUrl'] as String?,
          durationMs: data['durationMs'] as int? ?? 0,
          isExplicit: data['isExplicit'] as bool? ?? false,
          listeners: data['listeners'] as int? ?? 0,
          lyrics: data['lyrics'] as String?,
        ));
      }
    }
    return tracks;
  }
}
