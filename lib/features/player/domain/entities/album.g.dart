// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Album _$AlbumFromJson(Map<String, dynamic> json) => _Album(
  id: json['id'] as String,
  title: json['title'] as String,
  coverUrl: json['coverUrl'] as String?,
  artistIds:
      (json['artistIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  releaseYear: (json['releaseYear'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AlbumToJson(_Album instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'coverUrl': instance.coverUrl,
  'artistIds': instance.artistIds,
  'releaseYear': instance.releaseYear,
};
