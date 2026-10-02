import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/truck_model.dart';

/// Service for managing truck/fleet data in Firestore.
class TruckService {
  static final TruckService _instance = TruckService._internal();
  factory TruckService() => _instance;
  TruckService._internal();

  final CollectionReference _trucksRef =
      FirebaseFirestore.instance.collection('trucks');

  /// Get all trucks as a real-time stream
  Stream<List<TruckModel>> getTrucksStream() {
    return _trucksRef
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TruckModel.fromFirestore(doc)).toList());
  }

  /// Get all trucks (one-time fetch)
  Future<List<TruckModel>> getAllTrucks() async {
    final snapshot = await _trucksRef.orderBy('lastUpdated', descending: true).get();
    return snapshot.docs.map((doc) => TruckModel.fromFirestore(doc)).toList();
  }

  /// Get a single truck by ID
  Future<TruckModel?> getTruck(String truckId) async {
    final doc = await _trucksRef.doc(truckId).get();
    if (!doc.exists) return null;
    return TruckModel.fromFirestore(doc);
  }

  /// Get trucks by status
  Stream<List<TruckModel>> getTrucksByStatus(String status) {
    return _trucksRef
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TruckModel.fromFirestore(doc)).toList());
  }

  /// Add or update a truck
  Future<void> upsertTruck(TruckModel truck) async {
    await _trucksRef.doc(truck.truckId).set(truck.toFirestore());
    debugPrint('TruckService: Upserted truck ${truck.truckId}');
  }

  /// Update truck location and speed (real-time GPS update)
  Future<void> updateTruckLocation({
    required String truckId,
    required String location,
    required double latitude,
    required double longitude,
    required double speedKmh,
  }) async {
    await _trucksRef.doc(truckId).update({
      'currentLocation': location,
      'latitude': latitude,
      'longitude': longitude,
      'speedKmh': speedKmh,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Update truck status
  Future<void> updateTruckStatus(String truckId, String status) async {
    await _trucksRef.doc(truckId).update({
      'status': status,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Update ML prediction for a truck
  Future<void> updatePrediction(String truckId, String prediction) async {
    await _trucksRef.doc(truckId).update({
      'prediction': prediction,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Get count of active trucks
  Future<int> getActiveTruckCount() async {
    final snapshot = await _trucksRef
        .where('status', isEqualTo: 'on_route')
        .get();
    return snapshot.docs.length;
  }

  /// Delete a truck
  Future<void> deleteTruck(String truckId) async {
    await _trucksRef.doc(truckId).delete();
    debugPrint('TruckService: Deleted truck $truckId');
  }
}
