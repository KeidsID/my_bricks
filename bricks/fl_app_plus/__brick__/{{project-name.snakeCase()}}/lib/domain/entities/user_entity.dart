import "package:freezed_annotation/freezed_annotation.dart";

part "user_entity.freezed.dart";

@freezed
sealed class User with _$User {
  const factory User({required String id, required String username}) = _User;
}
