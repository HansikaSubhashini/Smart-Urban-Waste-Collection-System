import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Seeds Firestore with realistic demo data for all collections.
/// Only seeds if data doesn't already exist (idempotent).
class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _hash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Seed all demo data
  Future<void> seedAll() async {
    await _seedUsers();
    await _seedTrucks();
    await _seedCollections();
    await _seedReports();
    await _seedMetrics();
    debugPrint('SeedService: All demo data seeded.');
  }

  Future<void> _seedUsers() async {
    final existing = await _db.collection('users').limit(1).get();
    if (existing.docs.isNotEmpty) {
      debugPrint('SeedService: Users already exist, skipping.');
      return;
    }

    final batch = _db.batch();

    // Admin
    final adminRef = _db.collection('users').doc('admin-001');
    batch.set(adminRef, {
      'name': 'Admin Colombo',
      'email': 'admin@ecotrack.lk',
      'phone': '+94 11 234 5678',
      'address': 'Municipal Office, Colombo 07',
      'role': 'admin',
      'status': 'active',
      'passwordHash': _hash('admin123'),
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 90))),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Residents
    final residents = [
      {
        'id': 'resident-001',
        'name': 'Arjuna Perera',
        'email': 'arjuna@gmail.com',
        'phone': '+94 77 123 4567',
        'address': '42/1 Hospital Road, Kalubowila, Colombo 07',
        'alertProximity': '500m',
      },
      {
        'id': 'resident-002',
        'name': 'Nihal Perera',
        'email': 'nihal@gmail.com',
        'phone': '+94 77 234 5678',
        'address': 'Bambalapitiya Flats, D-14',
        'alertProximity': '1km',
      },
      {
        'id': 'resident-003',
        'name': 'Samantha de Silva',
        'email': 'samantha@gmail.com',
        'phone': '+94 77 345 6789',
        'address': 'Ward Place, Colombo 07',
        'alertProximity': '500m',
      },
    ];

    for (final r in residents) {
      final ref = _db.collection('users').doc(r['id'] as String);
      batch.set(ref, {
        'name': r['name'],
        'email': r['email'],
        'phone': r['phone'],
        'address': r['address'],
        'role': 'resident',
        'status': 'active',
        'alertProximity': r['alertProximity'],
        'quietHoursEnabled': false,
        'passwordHash': _hash('resident123'),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    // Drivers
    final drivers = [
      {
        'id': 'driver-001',
        'name': 'John Doe',
        'email': 'john@ecotrack.lk',
        'truckId': 'TRK-2024-C1',
        'zone': 'Colombo South',
        'licenseNumber': 'DL-2024-7891',
      },
      {
        'id': 'driver-002',
        'name': 'Kamal Wijeratne',
        'email': 'kamal@ecotrack.lk',
        'truckId': 'TRK-2024-C8',
        'zone': 'Colombo Central',
        'licenseNumber': 'DL-2024-4523',
      },
      {
        'id': 'driver-003',
        'name': 'Ranjith Fernando',
        'email': 'ranjith@ecotrack.lk',
        'truckId': 'TRK-2024-B4',
        'zone': 'Colombo Fort',
        'licenseNumber': 'DL-2024-6678',
      },
    ];

    for (final d in drivers) {
      final ref = _db.collection('users').doc(d['id'] as String);
      batch.set(ref, {
        'name': d['name'],
        'email': d['email'],
        'phone': '+94 77 000 0000',
        'address': 'Municipal Depot, Colombo',
        'role': 'driver',
        'status': 'active',
        'truckId': d['truckId'],
        'zone': d['zone'],
        'licenseNumber': d['licenseNumber'],
        'passwordHash': _hash('driver123'),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 60))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    await batch.commit();
    debugPrint('SeedService: Users seeded.');
  }

  Future<void> _seedTrucks() async {
    final existing = await _db.collection('trucks').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();

    final trucks = [
      {
        'id': 'TRK-2024-C1',
        'licensePlate': 'WP-4532',
        'driverId': 'driver-001',
        'driverName': 'John Doe',
        'currentLocation': 'Marine Drive, Bambalapitiya',
        'latitude': 6.8930,
        'longitude': 79.8560,
        'status': 'on_route',
        'currentRoute': 'Route 1: Bambalapitiya',
        'speedKmh': 30.0,
        'prediction': '-2 min Early',
      },
      {
        'id': 'TRK-2024-C8',
        'licensePlate': 'WP-6781',
        'driverId': 'driver-002',
        'driverName': 'Kamal Wijeratne',
        'currentLocation': 'Duplication Road, Kollupitiya',
        'latitude': 6.8990,
        'longitude': 79.8510,
        'status': 'delayed',
        'currentRoute': 'Route 3: Kollupitiya',
        'speedKmh': 12.0,
        'prediction': '+12 min (Traffic)',
      },
      {
        'id': 'TRK-2024-B4',
        'licensePlate': 'WP-3344',
        'driverId': 'driver-003',
        'driverName': 'Ranjith Fernando',
        'currentLocation': 'Reclamation Road, Fort',
        'latitude': 6.9340,
        'longitude': 79.8430,
        'status': 'on_route',
        'currentRoute': 'Route 5: Fort Area',
        'speedKmh': 25.0,
        'prediction': 'On Time',
      },
      {
        'id': 'TRK-2024-D2',
        'licensePlate': 'WP-9012',
        'driverId': '',
        'driverName': '',
        'currentLocation': 'Thurstan Road, Cinnamon Gardens',
        'latitude': 6.9060,
        'longitude': 79.8620,
        'status': 'maintenance',
        'currentRoute': '',
        'speedKmh': 0.0,
        'prediction': '—',
      },
    ];

    for (final t in trucks) {
      final ref = _db.collection('trucks').doc(t['id'] as String);
      batch.set(ref, {
        ...t,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      }..remove('id'));
    }

    await batch.commit();
    debugPrint('SeedService: Trucks seeded.');
  }

  Future<void> _seedCollections() async {
    final existing = await _db.collection('collections').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();

    // Today's schedule for driver-001
    final col1 = _db.collection('collections').doc();
    batch.set(col1, {
      'routeId': 'route-4',
      'routeName': 'Route 4: Kalubowila Area',
      'area': 'Kalubowila',
      'truckId': 'TRK-2024-C1',
      'driverId': 'driver-001',
      'collectionType': 'general',
      'scheduledDate': Timestamp.fromDate(DateTime(now.year, now.month, now.day, 8, 0)),
      'scheduledTime': '08:00 AM',
      'status': 'in_progress',
      'stops': [
        {'time': '08:00 AM', 'title': 'Start Point', 'location': 'Municipal Depot', 'isCompleted': true},
        {'time': '08:30 AM', 'title': 'Collection 1', 'location': 'Hospital Road', 'isCompleted': false},
        {'time': '10:00 AM', 'title': 'Collection 2', 'location': 'Anderson Road', 'isCompleted': false},
        {'time': '12:00 PM', 'title': 'End Point', 'location': 'Waste Management Center', 'isCompleted': false},
      ],
    });

    // Next collection for residents
    final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
    final col2 = _db.collection('collections').doc();
    batch.set(col2, {
      'routeId': 'route-1',
      'routeName': 'Route 1: Bambalapitiya',
      'area': 'Bambalapitiya',
      'truckId': 'TRK-2024-C1',
      'driverId': 'driver-001',
      'collectionType': 'general',
      'scheduledDate': Timestamp.fromDate(DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 7, 45)),
      'scheduledTime': '07:45 AM',
      'status': 'scheduled',
      'stops': [
        {'time': '07:45 AM', 'title': 'Start', 'location': 'Depot', 'isCompleted': false},
        {'time': '08:15 AM', 'title': 'Hathbodhiya Road', 'location': 'Hathbodhiya Road', 'isCompleted': false},
        {'time': '09:00 AM', 'title': 'Marine Drive', 'location': 'Marine Drive', 'isCompleted': false},
      ],
    });

    // A missed collection (yesterday)
    final col3 = _db.collection('collections').doc();
    batch.set(col3, {
      'routeId': 'route-3',
      'routeName': 'Route 3: Kollupitiya',
      'area': 'Kollupitiya',
      'truckId': 'TRK-2024-C8',
      'driverId': 'driver-002',
      'collectionType': 'recyclable',
      'scheduledDate': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      'scheduledTime': '09:00 AM',
      'status': 'missed',
      'stops': [],
    });

    // Past completed collection
    final col4 = _db.collection('collections').doc();
    batch.set(col4, {
      'routeId': 'route-1',
      'routeName': 'Route 1: Bambalapitiya',
      'area': 'Bambalapitiya',
      'truckId': 'TRK-2024-C1',
      'driverId': 'driver-001',
      'collectionType': 'general',
      'scheduledDate': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      'scheduledTime': '07:45 AM',
      'status': 'completed',
      'completedAt': Timestamp.fromDate(now.subtract(const Duration(days: 7, hours: -2))),
      'stops': [
        {'time': '07:45 AM', 'title': 'Start', 'location': 'Depot', 'isCompleted': true},
        {'time': '07:58 AM', 'title': 'Hospital Road', 'location': 'Hospital Road', 'isCompleted': true},
      ],
    });

    await batch.commit();
    debugPrint('SeedService: Collections seeded.');
  }

  Future<void> _seedReports() async {
    final existing = await _db.collection('reports').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();

    final r1 = _db.collection('reports').doc();
    batch.set(r1, {
      'reporterId': 'resident-001',
      'reporterName': 'Arjuna Perera',
      'type': 'missed_collection',
      'title': 'Missed Pickup: 42nd Lane',
      'description': 'Truck did not arrive at scheduled time for general waste collection.',
      'address': '42nd Lane, Kalubowila',
      'latitude': 6.8720,
      'longitude': 79.8630,
      'status': 'in_transit',
      'progressStep': 2,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
    });

    final r2 = _db.collection('reports').doc();
    batch.set(r2, {
      'reporterId': 'resident-002',
      'reporterName': 'Nihal Perera',
      'type': 'missed_collection',
      'title': 'Missed Collection on Flower Road',
      'description': 'No truck arrived this morning.',
      'address': 'Flower Road, Colombo 03',
      'latitude': 6.9000,
      'longitude': 79.8530,
      'status': 'submitted',
      'progressStep': 1,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
    });

    final r3 = _db.collection('reports').doc();
    batch.set(r3, {
      'reporterId': 'resident-003',
      'reporterName': 'Samantha de Silva',
      'type': 'canal_pollution',
      'title': 'Canal Pollution near Beira Lake',
      'description': 'Plastic waste dumped near the canal outlet.',
      'address': 'Beira Lake, Colombo 02',
      'latitude': 6.9220,
      'longitude': 79.8560,
      'status': 'resolved',
      'progressStep': 3,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      'resolvedAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
    });

    await batch.commit();
    debugPrint('SeedService: Reports seeded.');
  }

  Future<void> _seedMetrics() async {
    final existing = await _db.collection('metrics').doc('performance').get();
    if (existing.exists) return;

    await _db.collection('metrics').doc('performance').set({
      'driverPunctuality': 0.92,
      'collectorPoliteness': 0.88,
      'routeEfficiency': 0.74,
      'problemResolution': 0.96,
      'avgRating': 4.82,
      'totalReviews': 12000,
      'aiInsight': 'Morning congestion in District 03 is impacting punctuality by 14%. Recommend shifting start times to 05:30 AM.',
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    debugPrint('SeedService: Metrics seeded.');
  }
}
