// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Playlist _$PlaylistFromJson(Map<String, dynamic> json) => _Playlist(
  id: json['id'] as String,
  name: json['name'] as String,
  userId: json['userId'] as String,
  trackIds:
      (json['trackIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  description: json['description'] as String?,
  coverUrl: json['coverUrl'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$PlaylistToJson(_Playlist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'userId': instance.userId,
  'trackIds': instance.trackIds,
  'description': instance.description,
  'coverUrl': instance.coverUrl,
  'createdAt': instance.createdAt,
};
