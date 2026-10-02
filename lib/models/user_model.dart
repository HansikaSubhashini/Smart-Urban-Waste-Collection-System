import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final UserRole role;
  final String status; // 'active', 'pending', 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  // Driver-specific fields
  final String? truckId;
  final String? zone;
  final String? licenseNumber;

  // Resident-specific fields
  final String? alertProximity; // '500m' or '1km'
  final bool quietHoursEnabled;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    required this.role,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.truckId,
    this.zone,
    this.licenseNumber,
    this.alertProximity = '500m',
    this.quietHoursEnabled = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.resident,
      ),
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      truckId: data['truckId'],
      zone: data['zone'],
      licenseNumber: data['licenseNumber'],
      alertProximity: data['alertProximity'] ?? '500m',
      quietHoursEnabled: data['quietHoursEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role.name,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      if (truckId != null) 'truckId': truckId,
      if (zone != null) 'zone': zone,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      'alertProximity': alertProximity,
      'quietHoursEnabled': quietHoursEnabled,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    UserRole? role,
    String? status,
    String? truckId,
    String? zone,
    String? licenseNumber,
    String? alertProximity,
    bool? quietHoursEnabled,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt,
      truckId: truckId ?? this.truckId,
      zone: zone ?? this.zone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      alertProximity: alertProximity ?? this.alertProximity,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    );
  }
}
