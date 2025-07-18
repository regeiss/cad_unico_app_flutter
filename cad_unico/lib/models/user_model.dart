// ignore_for_file: type_annotate_public_apis

import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isActive;
  final DateTime? dateJoined;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isActive,
    this.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? 0;
    final username = json['username'] ?? '';
    final email = json['email'] ?? '';
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final isStaff = json['is_staff'] ?? false;
    final isActive = json['is_active'] ?? true;

    final dateJoinedString = json['date_joined'];
    final dateJoined =
        dateJoinedString != null ? DateTime.tryParse(dateJoinedString) : null;

    debugPrint('Parsing UserModel:');
    debugPrint('  id: $id');
    debugPrint('  username: $username (type: ${username.runtimeType})');
    debugPrint('  email: $email (type: ${email.runtimeType})');
    debugPrint('  firstName: $firstName (type: ${firstName.runtimeType})');
    debugPrint('  lastName: $lastName (type: ${lastName.runtimeType})');
    debugPrint('  isStaff: $isStaff');
    debugPrint('  isActive: $isActive');
    debugPrint('  dateJoined: $dateJoined');
    debugPrint(
        '  Raw dateJoinedString: $dateJoinedString (type: ${dateJoinedString.runtimeType})'); // Crucial for date issue

    return UserModel(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      isStaff: isStaff,
      isActive: isActive,
      dateJoined: dateJoined,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'is_staff': isStaff,
        'is_active': isActive,
        'date_joined': dateJoined?.toIso8601String(),
      };

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) {
      return username;
    }
    return '$firstName $lastName'.trim();
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName.substring(0, 1).toUpperCase();
    } else if (username.isNotEmpty) {
      return username.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isStaff,
    bool? isActive,
    DateTime? dateJoined,
  }) =>
      UserModel(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isStaff: isStaff ?? this.isStaff,
        isActive: isActive ?? this.isActive,
        dateJoined: dateJoined ?? this.dateJoined,
      );
}
