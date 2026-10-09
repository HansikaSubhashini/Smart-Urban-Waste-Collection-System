import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
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

  /// Generate and send OTP via email
  Future<void> sendPasswordResetOTP(String email) async {
    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No account found with this email.');
    }

    // Generate 6-digit OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    // Store OTP in Firestore
    await _db.collection('password_resets').doc(email.toLowerCase().trim()).set({
      'otp': otp,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Send email using mailer
    String username = 'hansikasubhashini50@gmail.com'; // TODO: Replace with your Gmail
    String password = 'ejmdubbgirohmnig'; // TODO: Replace with your App Password

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Smart Waste Management System')
      ..recipients.add(email)
      ..subject = 'Password Reset OTP'
      ..text = 'Your password reset OTP is: $otp\nThis OTP will expire in 10 minutes.'
      ..html = '<h1>Password Reset</h1><p>Your password reset OTP is: <strong>$otp</strong></p><p>This OTP will expire in 10 minutes.</p>';

    try {
      await send(message, smtpServer);
      debugPrint('AuthService: Password reset OTP sent to $email');
    } catch (e) {
      debugPrint('Error sending email: $e');
      throw Exception('Failed to send email. Please check SMTP configuration ($e).');
    }
  }

  /// Verify OTP
  Future<void> verifyOTP(String email, String otp) async {
    final docRef = _db.collection('password_resets').doc(email.toLowerCase().trim());
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception('No OTP request found for this email.');
    }

    final data = docSnapshot.data()!;
    final storedOtp = data['otp'] as String;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    if (createdAt != null) {
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      if (difference.inMinutes > 10) {
        throw Exception('OTP has expired. Please request a new one.');
      }
    }

    if (storedOtp != otp) {
      throw Exception('Invalid OTP.');
    }
  }

  /// Update password by email (without needing to be logged in)
  Future<void> updatePasswordByEmail(String email, String newPassword) async {
    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No account found with this email.');
    }

    final docId = querySnapshot.docs.first.id;

    await _db.collection('users').doc(docId).update({
      'passwordHash': _hashPassword(newPassword),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Clear the OTP
    await _db.collection('password_resets').doc(email.toLowerCase().trim()).delete();

    debugPrint('AuthService: Password updated for $email');
  }

  /// Logout the current user
  void logout() {
    debugPrint('AuthService: Logged out ${_currentUser?.email}');
    _currentUser = null;
  }
}
