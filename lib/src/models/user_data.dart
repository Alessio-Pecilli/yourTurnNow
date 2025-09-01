import 'package:flutter/foundation.dart';

@immutable
class UserData {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const UserData({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  UserData copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}