import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('user')
  user,
}

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
    @Default(UserRole.user) UserRole role,
  }) = _User;
}
