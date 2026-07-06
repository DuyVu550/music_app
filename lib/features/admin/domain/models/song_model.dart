import 'package:cloud_firestore/cloud_firestore.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String coverUrl;
  final DateTime createdAt;
  final String? lyrics;
  final String? albumId;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.coverUrl,
    required this.createdAt,
    this.lyrics,
    this.albumId,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      lyrics: json['lyrics'] as String?,
      albumId: json['albumId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'coverUrl': coverUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lyrics': lyrics,
      'albumId': albumId,
    };
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioUrl,
    String? coverUrl,
    DateTime? createdAt,
    String? lyrics,
    String? albumId,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      lyrics: lyrics ?? this.lyrics,
      albumId: albumId ?? this.albumId,
    );
  }
}
