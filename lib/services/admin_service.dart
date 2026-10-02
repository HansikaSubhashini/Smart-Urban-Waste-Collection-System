import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

/// Service for admin operations on user/resident data.
class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all residents as a stream
  Stream<List<UserModel>> getResidentsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: UserRole.resident.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Get total resident count
  Future<int> getResidentCount() async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: UserRole.resident.name)
        .get();
    return snapshot.docs.length;
  }

  /// Get recently registered residents (last 24h)
  Future<int> getNewResidentsToday() async {
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: UserRole.resident.name)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();
    return snapshot.docs.length;
  }

  /// Get all drivers as a stream
  Stream<List<UserModel>> getDriversStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: UserRole.driver.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Update user status (activate/deactivate)
  Future<void> updateUserStatus(String userId, String status) async {
    await _db.collection('users').doc(userId).update({
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    debugPrint('AdminService: Updated user $userId status to $status');
  }

  /// Get dashboard metrics
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final trucksSnapshot = await _db
        .collection('trucks')
        .where('status', isEqualTo: 'on_route')
        .get();
    
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    
    final missedSnapshot = await _db
        .collection('collections')
        .where('status', isEqualTo: 'missed')
        .where('scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();

    final residentCount = await getResidentCount();
    final newToday = await getNewResidentsToday();

    return {
      'activeTrucks': trucksSnapshot.docs.length,
      'missedCollections': missedSnapshot.docs.length,
      'totalResidents': residentCount,
      'newResidentsToday': newToday,
    };
  }

  /// Get service performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final doc = await _db.collection('metrics').doc('performance').get();
    if (!doc.exists) {
      return {
        'driverPunctuality': 0.92,
        'collectorPoliteness': 0.88,
        'routeEfficiency': 0.74,
        'problemResolution': 0.96,
        'avgRating': 4.82,
        'totalReviews': 12000,
      };
    }
    return doc.data() as Map<String, dynamic>;
  }

  /// Update service performance metrics
  Future<void> updatePerformanceMetrics(Map<String, dynamic> metrics) async {
    await _db.collection('metrics').doc('performance').set(
      metrics,
      SetOptions(merge: true),
    );
  }
}
