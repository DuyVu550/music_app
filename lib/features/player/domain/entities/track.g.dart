// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Track _$TrackFromJson(Map<String, dynamic> json) => _Track(
  id: json['id'] as String,
  title: json['title'] as String,
  url: json['url'] as String,
  albumId: json['albumId'] as String,
  artistIds: (json['artistIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
  isExplicit: json['isExplicit'] as bool? ?? false,
  coverUrl: json['coverUrl'] as String?,
  listeners: (json['listeners'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TrackToJson(_Track instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'url': instance.url,
  'albumId': instance.albumId,
  'artistIds': instance.artistIds,
  'durationMs': instance.durationMs,
  'isExplicit': instance.isExplicit,
  'coverUrl': instance.coverUrl,
  'listeners': instance.listeners,
};
