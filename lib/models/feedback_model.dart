import 'package:cloud_firestore/cloud_firestore.dart';

class DriverFeedback {
  final String id;
  final String driverId;
  final String driverName;
  final String residentId;
  final String residentName;
  final String area;
  final int rating; // 1-5 stars
  final String comment;
  final String category; // 'punctuality', 'cleanliness', 'behavior', 'service', 'other'
  final DateTime createdAt;

  DriverFeedback({
    required this.id,
    required this.driverId,
    this.driverName = '',
    required this.residentId,
    this.residentName = '',
    this.area = '',
    required this.rating,
    this.comment = '',
    this.category = 'service',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DriverFeedback.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverFeedback(
      id: doc.id,
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      residentId: data['residentId'] ?? '',
      residentName: data['residentName'] ?? '',
      area: data['area'] ?? '',
      rating: data['rating'] ?? 3,
      comment: data['comment'] ?? '',
      category: data['category'] ?? 'service',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'residentId': residentId,
      'residentName': residentName,
      'area': area,
      'rating': rating,
      'comment': comment,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Returns the display name for the category
  String get displayCategory {
    switch (category) {
      case 'punctuality':
        return 'Punctuality';
      case 'cleanliness':
        return 'Cleanliness';
      case 'behavior':
        return 'Driver Behavior';
      case 'service':
        return 'Overall Service';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  /// Returns the icon for each category
  static String categoryIcon(String category) {
    switch (category) {
      case 'punctuality':
        return '⏰';
      case 'cleanliness':
        return '🧹';
      case 'behavior':
        return '🤝';
      case 'service':
        return '⭐';
      case 'other':
        return '💬';
      default:
        return '📝';
    }
  }
}
