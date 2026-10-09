import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'notification_service.dart';

class GeofenceSimulationService {
  static final GeofenceSimulationService _instance = GeofenceSimulationService._internal();
  factory GeofenceSimulationService() => _instance;
  GeofenceSimulationService._internal();

  Timer? _timer;
  LatLng? currentTruckLocation;
  final LatLng residentLocation = const LatLng(6.9271, 79.8612); // Mock resident location
  bool _notificationSent = false;
  
  // Callback to update UI if needed
  Function(LatLng, double)? onLocationUpdated;

  void startSimulation() {
    stopSimulation(); // Ensure previous is stopped
    _notificationSent = false;
    
    // Start the truck somewhat far away (~2km)
    currentTruckLocation = const LatLng(6.9080, 79.8550); 
    
    final Distance distanceCalculator = const Distance();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentTruckLocation == null) return;

      // Move the truck slightly closer to the resident
      final latDiff = (residentLocation.latitude - currentTruckLocation!.latitude) * 0.1;
      final lngDiff = (residentLocation.longitude - currentTruckLocation!.longitude) * 0.1;
      
      currentTruckLocation = LatLng(
        currentTruckLocation!.latitude + latDiff,
        currentTruckLocation!.longitude + lngDiff,
      );

      // Calculate distance in meters
      final distance = distanceCalculator(residentLocation, currentTruckLocation!);
      
      if (onLocationUpdated != null) {
        onLocationUpdated!(currentTruckLocation!, distance);
      }

      if (kDebugMode) {
        print('Truck distance: ${distance.toStringAsFixed(2)}m');
      }

      // Check geofence condition (e.g., within 500 meters)
      if (distance < 500 && !_notificationSent) {
        _notificationSent = true;
        NotificationService().showNotification(
          id: 1,
          title: 'Garbage Truck Approaching!',
          body: 'The garbage truck is within 500m of your location. Please keep your bins ready.',
        );
        stopSimulation(); // Stop simulation after arrival
      }
    });
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }
}
