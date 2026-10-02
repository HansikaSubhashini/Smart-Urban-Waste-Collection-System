import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterId;   // uid of the resident
  final String reporterName;
  final String type;          // 'missed_collection', 'canal_pollution', 'delay'
  final String title;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String status;        // 'submitted', 'under_review', 'in_transit', 'resolved'
  final int progressStep;     // 1=submitted, 2=reviewed, 3=resolved
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? imageUrl;

  ReportModel({
    required this.id,
    this.reporterId = '',
    this.reporterName = '',
    required this.type,
    this.title = '',
    this.description = '',
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.status = 'submitted',
    this.progressStep = 1,
    DateTime? createdAt,
    this.resolvedAt,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? '',
      type: data['type'] ?? 'missed_collection',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'submitted',
      progressStep: data['progressStep'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'type': type,
      'title': title,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'progressStep': progressStep,
      'createdAt': Timestamp.fromDate(createdAt),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  /// Display-friendly type string
  String get displayType {
    switch (type) {
      case 'missed_collection':
        return 'MISSED COLLECTION';
      case 'canal_pollution':
        return 'CANAL POLLUTION';
      case 'delay':
        return 'DELAY REPORT';
      default:
        return type.toUpperCase();
    }
  }

  /// Display-friendly status string
  String get displayStatus {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'in_transit':
        return 'In Transit';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }
}
