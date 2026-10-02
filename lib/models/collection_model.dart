import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionSchedule {
  final String id;
  final String routeId;
  final String routeName;
  final String area;        // e.g. 'Kalubowila Area'
  final String truckId;
  final String driverId;
  final String collectionType; // 'general', 'recyclable', 'organic'
  final DateTime scheduledDate;
  final String scheduledTime;  // e.g. '08:00 AM'
  final String status;        // 'scheduled', 'in_progress', 'completed', 'missed'
  final DateTime? completedAt;
  final List<RouteStop> stops;

  CollectionSchedule({
    required this.id,
    this.routeId = '',
    this.routeName = '',
    this.area = '',
    this.truckId = '',
    this.driverId = '',
    this.collectionType = 'general',
    required this.scheduledDate,
    this.scheduledTime = '',
    this.status = 'scheduled',
    this.completedAt,
    this.stops = const [],
  });

  factory CollectionSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawStops = data['stops'] as List<dynamic>? ?? [];
    return CollectionSchedule(
      id: doc.id,
      routeId: data['routeId'] ?? '',
      routeName: data['routeName'] ?? '',
      area: data['area'] ?? '',
      truckId: data['truckId'] ?? '',
      driverId: data['driverId'] ?? '',
      collectionType: data['collectionType'] ?? 'general',
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledTime: data['scheduledTime'] ?? '',
      status: data['status'] ?? 'scheduled',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      stops: rawStops.map((s) => RouteStop.fromMap(s as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'area': area,
      'truckId': truckId,
      'driverId': driverId,
      'collectionType': collectionType,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime,
      'status': status,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'stops': stops.map((s) => s.toMap()).toList(),
    };
  }

  /// Returns formatted collection type for display
  String get displayType {
    switch (collectionType) {
      case 'general':
        return 'General Waste';
      case 'recyclable':
        return 'Recyclable';
      case 'organic':
        return 'Organic Waste';
      default:
        return collectionType;
    }
  }
}

class RouteStop {
  final String time;
  final String title;
  final String location;
  final bool isCompleted;

  RouteStop({
    required this.time,
    required this.title,
    required this.location,
    this.isCompleted = false,
  });

  factory RouteStop.fromMap(Map<String, dynamic> data) {
    return RouteStop(
      time: data['time'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'title': title,
      'location': location,
      'isCompleted': isCompleted,
    };
  }
}
