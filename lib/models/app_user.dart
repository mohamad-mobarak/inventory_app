import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  // The user's id , same as the Firebase Auth uid
  final String id;
  // The user's display name
  final String name;
  // Constructor: every field must be given a value when creating a user
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });
  // Builds an AppUser from  a Firestore document
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
        id: id,
        name: data['name'] as String,
        email: data['email'] as String,
        role: data['role'] as String,
        isActive: data['isActive'] as bool,
        createdAt: (data['createdAt'] as Timestamp).toDate());
  }
}
