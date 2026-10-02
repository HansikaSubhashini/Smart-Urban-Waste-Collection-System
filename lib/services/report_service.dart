import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';

/// Service for managing community reports (missed collections, pollution, etc.)
class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final CollectionReference _reportsRef =
      FirebaseFirestore.instance.collection('reports');

  /// Get all reports as a stream (newest first)
  Stream<List<ReportModel>> getReportsStream() {
    return _reportsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }

  /// Get reports by a specific resident
  Stream<List<ReportModel>> getReportsByResident(String reporterId) {
    return _reportsRef
        .where('reporterId', isEqualTo: reporterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }

  /// Get active (unresolved) reports for a resident
  Stream<List<ReportModel>> getActiveReports(String reporterId) {
    return _reportsRef
        .where('reporterId', isEqualTo: reporterId)
        .where('status', whereNotIn: ['resolved'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }

  /// Get nearby reports (all reports, for community view)
  Stream<List<ReportModel>> getNearbyReports() {
    return _reportsRef
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }

  /// Submit a new report
  Future<String> submitReport(ReportModel report) async {
    final docRef = await _reportsRef.add(report.toFirestore());
    debugPrint('ReportService: Submitted report ${docRef.id}');
    return docRef.id;
  }

  /// Update report status and progress
  Future<void> updateReportStatus(
    String reportId, {
    required String status,
    required int progressStep,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'progressStep': progressStep,
    };
    if (status == 'resolved') {
      updates['resolvedAt'] = Timestamp.fromDate(DateTime.now());
    }
    await _reportsRef.doc(reportId).update(updates);
    debugPrint('ReportService: Updated report $reportId to $status');
  }

  /// Get count of reports by status
  Future<Map<String, int>> getReportCounts() async {
    final snapshot = await _reportsRef.get();
    final counts = <String, int>{
      'submitted': 0,
      'under_review': 0,
      'in_transit': 0,
      'resolved': 0,
    };
    for (final doc in snapshot.docs) {
      final status = (doc.data() as Map<String, dynamic>)['status'] as String? ?? 'submitted';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Delete a report
  Future<void> deleteReport(String reportId) async {
    await _reportsRef.doc(reportId).delete();
    debugPrint('ReportService: Deleted report $reportId');
  }
}
