import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';

/// Service for managing driver feedback in Firestore.
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final CollectionReference _feedbackRef =
      FirebaseFirestore.instance.collection('driver_feedback');

  /// Submit feedback from a resident to a driver
  Future<String> submitFeedback(DriverFeedback feedback) async {
    final docRef = await _feedbackRef.add(feedback.toFirestore());
    debugPrint('FeedbackService: Submitted feedback ${docRef.id}');
    return docRef.id;
  }

  /// Stream all feedback for a specific driver (newest first)
  Stream<List<DriverFeedback>> getDriverFeedbackStream(String driverId) {
    return _feedbackRef
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DriverFeedback.fromFirestore(doc))
            .toList());
  }

  /// Get all feedback (newest first) — useful for drivers without filter
  Stream<List<DriverFeedback>> getAllFeedbackStream() {
    return _feedbackRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DriverFeedback.fromFirestore(doc))
            .toList());
  }

  /// Get average rating for a driver
  Future<double> getDriverAverageRating(String driverId) async {
    final snapshot = await _feedbackRef
        .where('driverId', isEqualTo: driverId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final total = snapshot.docs.fold<int>(0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + (data['rating'] as int? ?? 0);
    });

    return total / snapshot.docs.length;
  }

  /// Get feedback count for a driver
  Future<int> getDriverFeedbackCount(String driverId) async {
    final snapshot = await _feedbackRef
        .where('driverId', isEqualTo: driverId)
        .get();
    return snapshot.docs.length;
  }

  /// Get all available drivers for feedback selection
  Future<List<Map<String, String>>> getAvailableDrivers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'driver')
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] as String? ?? 'Unknown Driver',
        'zone': data['zone'] as String? ?? 'N/A',
        'truckId': data['truckId'] as String? ?? 'N/A',
      };
    }).toList();
  }
}
