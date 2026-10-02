import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/collection_model.dart';

/// Service for managing waste collection schedules in Firestore.
class CollectionService {
  static final CollectionService _instance = CollectionService._internal();
  factory CollectionService() => _instance;
  CollectionService._internal();

  final CollectionReference _collectionsRef =
      FirebaseFirestore.instance.collection('collections');

  /// Get all collection schedules as a stream
  Stream<List<CollectionSchedule>> getCollectionsStream() {
    return _collectionsRef
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionSchedule.fromFirestore(doc))
            .toList());
  }

  /// Get upcoming collection for a specific area/address
  Future<CollectionSchedule?> getNextCollection(String area) async {
    final now = DateTime.now();
    final snapshot = await _collectionsRef
        .where('area', isEqualTo: area)
        .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('status', isEqualTo: 'scheduled')
        .orderBy('scheduledDate')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CollectionSchedule.fromFirestore(snapshot.docs.first);
  }

  /// Get today's collections for a driver
  Stream<List<CollectionSchedule>> getDriverCollections(String driverId) {
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _collectionsRef
        .where('driverId', isEqualTo: driverId)
        .where('scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('scheduledDate', isLessThan: Timestamp.fromDate(todayEnd))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionSchedule.fromFirestore(doc))
            .toList());
  }

  /// Get today's missed collections count
  Future<int> getMissedCollectionsCount() async {
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final snapshot = await _collectionsRef
        .where('status', isEqualTo: 'missed')
        .where('scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();
    return snapshot.docs.length;
  }

  /// Create a new collection schedule
  Future<String> createCollection(CollectionSchedule collection) async {
    final docRef = await _collectionsRef.add(collection.toFirestore());
    debugPrint('CollectionService: Created collection ${docRef.id}');
    return docRef.id;
  }

  /// Update collection status
  Future<void> updateCollectionStatus(String collectionId, String status) async {
    final updates = <String, dynamic>{
      'status': status,
    };
    if (status == 'completed') {
      updates['completedAt'] = Timestamp.fromDate(DateTime.now());
    }
    await _collectionsRef.doc(collectionId).update(updates);
    debugPrint('CollectionService: Updated status of $collectionId to $status');
  }

  /// Update a route stop's completion status
  Future<void> updateRouteStop(
    String collectionId,
    int stopIndex,
    bool isCompleted,
  ) async {
    final doc = await _collectionsRef.doc(collectionId).get();
    if (!doc.exists) return;

    final collection = CollectionSchedule.fromFirestore(doc);
    final updatedStops = List<RouteStop>.from(collection.stops);

    if (stopIndex < updatedStops.length) {
      updatedStops[stopIndex] = RouteStop(
        time: updatedStops[stopIndex].time,
        title: updatedStops[stopIndex].title,
        location: updatedStops[stopIndex].location,
        isCompleted: isCompleted,
      );
    }

    await _collectionsRef.doc(collectionId).update({
      'stops': updatedStops.map((s) => s.toMap()).toList(),
    });
  }

  /// Get collection history for a resident
  Stream<List<CollectionSchedule>> getResidentHistory(String area) {
    return _collectionsRef
        .where('area', isEqualTo: area)
        .orderBy('scheduledDate', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionSchedule.fromFirestore(doc))
            .toList());
  }
}
