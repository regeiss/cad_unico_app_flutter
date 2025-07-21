class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isActive;
  final DateTime dateJoined;
  final List<String> roles;
  final List<String> permissions;
  
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isActive,
    required this.dateJoined,
    this.roles = const [],
    this.permissions = const [],
  });
  
  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isStaff: json['is_staff'] ?? false,
      isActive: json['is_active'] ?? true,
      dateJoined: DateTime.tryParse(json['date_joined'] ?? '') ?? DateTime.now(),
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
      permissions: json['permissions'] != null ? List<String>.from(json['permissions']) : [],
    );
  }
  
  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_active': isActive,
      'date_joined': dateJoined.toIso8601String(),
      'roles': roles,
      'permissions': permissions,
    };
  }
  
  // Check if user has specific role
  bool hasRole(String role) {
    return roles.contains(role);
  }
  
  // Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
  
  // Get full name
  String get fullName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return username;
    }
  }
  
  // Get display name (first name or username)
  String get displayName {
    return firstName.isNotEmpty ? firstName : username;
  }
  
  // Get initials
  String get initials {
    String result = '';
    
    if (firstName.isNotEmpty) {
      result += firstName[0].toUpperCase();
    }
    
    if (lastName.isNotEmpty) {
      result += lastName[0].toUpperCase();
    }
    
    if (result.isEmpty && username.isNotEmpty) {
      result = username[0].toUpperCase();
    }
    
    return result.isEmpty ? 'U' : result;
  }
  
  // Copy with method for updating user data
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isStaff,
    bool? isActive,
    DateTime? dateJoined,
    List<String>? roles,
    List<String>? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isStaff: isStaff ?? this.isStaff,
      isActive: isActive ?? this.isActive,
      dateJoined: dateJoined ?? this.dateJoined,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
    );
  }
  
  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, email: $email, fullName: $fullName}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ email.hashCode;
  }
}

// // ignore_for_file: type_annotate_public_apis

// import 'package:flutter/material.dart';

// class UserModel {
//   final int id;
//   final String username;
//   final String email;
//   final String firstName;
//   final String lastName;
//   final bool isStaff;
//   final bool isActive;
//   final DateTime? dateJoined;

//   UserModel({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     required this.isStaff,
//     required this.isActive,
//     this.dateJoined,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     final id = json['id'] ?? 0;
//     final username = json['username'] ?? '';
//     final email = json['email'] ?? '';
//     final firstName = json['first_name'] ?? '';
//     final lastName = json['last_name'] ?? '';
//     final isStaff = json['is_staff'] ?? false;
//     final isActive = json['is_active'] ?? true;

//     final dateJoinedString = json['date_joined'];
//     final dateJoined =
//         dateJoinedString != null ? DateTime.tryParse(dateJoinedString) : null;

//     debugPrint('Parsing UserModel:');
//     debugPrint('  id: $id');
//     debugPrint('  username: $username (type: ${username.runtimeType})');
//     debugPrint('  email: $email (type: ${email.runtimeType})');
//     debugPrint('  firstName: $firstName (type: ${firstName.runtimeType})');
//     debugPrint('  lastName: $lastName (type: ${lastName.runtimeType})');
//     debugPrint('  isStaff: $isStaff');
//     debugPrint('  isActive: $isActive');
//     debugPrint('  dateJoined: $dateJoined');
//     debugPrint(
//         '  Raw dateJoinedString: $dateJoinedString (type: ${dateJoinedString.runtimeType})'); // Crucial for date issue

//     return UserModel(
//       id: id,
//       username: username,
//       email: email,
//       firstName: firstName,
//       lastName: lastName,
//       isStaff: isStaff,
//       isActive: isActive,
//       dateJoined: dateJoined,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'username': username,
//         'email': email,
//         'first_name': firstName,
//         'last_name': lastName,
//         'is_staff': isStaff,
//         'is_active': isActive,
//         'date_joined': dateJoined?.toIso8601String(),
//       };

//   String get fullName {
//     if (firstName.isEmpty && lastName.isEmpty) {
//       return username;
//     }
//     return '$firstName $lastName'.trim();
//   }

//   String get initials {
//     if (firstName.isNotEmpty && lastName.isNotEmpty) {
//       return '${firstName[0]}${lastName[0]}'.toUpperCase();
//     } else if (firstName.isNotEmpty) {
//       return firstName.substring(0, 1).toUpperCase();
//     } else if (username.isNotEmpty) {
//       return username.substring(0, 1).toUpperCase();
//     }
//     return 'U';
//   }

//   UserModel copyWith({
//     int? id,
//     String? username,
//     String? email,
//     String? firstName,
//     String? lastName,
//     bool? isStaff,
//     bool? isActive,
//     DateTime? dateJoined,
//   }) =>
//       UserModel(
//         id: id ?? this.id,
//         username: username ?? this.username,
//         email: email ?? this.email,
//         firstName: firstName ?? this.firstName,
//         lastName: lastName ?? this.lastName,
//         isStaff: isStaff ?? this.isStaff,
//         isActive: isActive ?? this.isActive,
//         dateJoined: dateJoined ?? this.dateJoined,
//       );
// }
