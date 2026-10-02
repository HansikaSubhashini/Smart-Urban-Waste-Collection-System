import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

/// Handles user authentication using Firestore (no Firebase Auth).
/// Passwords are hashed with SHA-256 before storage.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  UserModel? _currentUser;

  /// Currently logged-in user (null if not logged in)
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register a new admin account
  Future<UserModel> registerAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    // Check if email is already registered
    final existing = await _db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }

    final docRef = _db.collection('users').doc();
    final user = UserModel(
      uid: docRef.id,
      name: name.trim(),
      email: email.toLowerCase().trim(),
      role: UserRole.admin,
      status: 'active',
    );

    await docRef.set({
      ...user.toFirestore(),
      'passwordHash': _hashPassword(password),
    });

    _currentUser = user;
    debugPrint('AuthService: Admin registered: ${user.email}');
    return user;
  }

  /// Register a new resident (called by admin)
  Future<UserModel> registerResident({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    // Check if email is already registered
    final existing = await _db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }

    final docRef = _db.collection('users').doc();
    final user = UserModel(
      uid: docRef.id,
      name: name.trim(),
      email: email.toLowerCase().trim(),
      phone: phone.trim(),
      address: address.trim(),
      role: UserRole.resident,
      status: 'active',
    );

    await docRef.set({
      ...user.toFirestore(),
      'passwordHash': _hashPassword(password),
    });

    debugPrint('AuthService: Resident registered: ${user.email}');
    return user;
  }

  /// Login with email and password for a specific role
  Future<UserModel> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase().trim())
        .where('role', isEqualTo: role.name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No ${role.name} account found with this email.');
    }

    final doc = querySnapshot.docs.first;
    final data = doc.data();
    final storedHash = data['passwordHash'] as String? ?? '';

    if (storedHash != _hashPassword(password)) {
      throw Exception('Incorrect password.');
    }

    _currentUser = UserModel.fromFirestore(doc);
    debugPrint('AuthService: Logged in as ${_currentUser!.role.name}: ${_currentUser!.email}');
    return _currentUser!;
  }

  /// Update the current user's profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? alertProximity,
    bool? quietHoursEnabled,
  }) async {
    if (_currentUser == null) throw Exception('Not logged in.');

    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (alertProximity != null) updates['alertProximity'] = alertProximity;
    if (quietHoursEnabled != null) updates['quietHoursEnabled'] = quietHoursEnabled;

    await _db.collection('users').doc(_currentUser!.uid).update(updates);

    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      address: address,
      alertProximity: alertProximity,
      quietHoursEnabled: quietHoursEnabled,
    );
  }

  /// Logout the current user
  void logout() {
    debugPrint('AuthService: Logged out ${_currentUser?.email}');
    _currentUser = null;
  }
}
