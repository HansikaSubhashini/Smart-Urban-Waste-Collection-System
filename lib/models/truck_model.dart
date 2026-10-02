import 'package:cloud_firestore/cloud_firestore.dart';

class TruckModel {
  final String truckId;       // e.g. 'TRK-2024-C1'
  final String licensePlate;  // e.g. 'WP-4532'
  final String driverId;      // uid of assigned driver
  final String driverName;
  final String currentLocation;
  final double latitude;
  final double longitude;
  final String status;        // 'on_route', 'delayed', 'maintenance', 'idle'
  final String currentRoute;  // route name
  final double speedKmh;
  final String prediction;    // ML prediction e.g. '-2 min Early'
  final DateTime lastUpdated;

  TruckModel({
    required this.truckId,
    this.licensePlate = '',
    this.driverId = '',
    this.driverName = '',
    this.currentLocation = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.status = 'idle',
    this.currentRoute = '',
    this.speedKmh = 0.0,
    this.prediction = '—',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory TruckModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TruckModel(
      truckId: doc.id,
      licensePlate: data['licensePlate'] ?? '',
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      currentLocation: data['currentLocation'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'idle',
      currentRoute: data['currentRoute'] ?? '',
      speedKmh: (data['speedKmh'] ?? 0.0).toDouble(),
      prediction: data['prediction'] ?? '—',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'licensePlate': licensePlate,
      'driverId': driverId,
      'driverName': driverName,
      'currentLocation': currentLocation,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'currentRoute': currentRoute,
      'speedKmh': speedKmh,
      'prediction': prediction,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Converts status string to display format
  String get displayStatus {
    switch (status) {
      case 'on_route':
        return 'ON ROUTE';
      case 'delayed':
        return 'DELAYED';
      case 'maintenance':
        return 'MAINTENANCE';
      case 'idle':
        return 'IDLE';
      default:
        return status.toUpperCase();
    }
  }
}
