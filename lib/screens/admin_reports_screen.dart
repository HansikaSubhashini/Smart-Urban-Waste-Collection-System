import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ReportService _reportService = ReportService();
  String _filterStatus = 'all';
  Map<String, int> _counts = {};
  bool _countsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final counts = await _reportService.getReportCounts();
      if (mounted) setState(() { _counts = counts; _countsLoaded = true; });
    } catch (_) {
      if (mounted) setState(() => _countsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.darkGreen),
            onPressed: () {
              _loadCounts();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary strip ──
          if (_countsLoaded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCountBadge('Submitted', _counts['submitted'] ?? 0, Colors.blue),
                    _buildCountBadge('Review', _counts['under_review'] ?? 0, Colors.orange),
                    _buildCountBadge('In Transit', _counts['in_transit'] ?? 0, AppTheme.primaryGreen),
                    _buildCountBadge('Resolved', _counts['resolved'] ?? 0, Colors.grey),
                  ],
                ),
              ),
            ),

          // ── Filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Submitted', 'submitted'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Under Review', 'under_review'),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Transit', 'in_transit'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Resolved', 'resolved'),
                ],
              ),
            ),
          ),

          // ── Report list ──
          Expanded(
            child: StreamBuilder<List<ReportModel>>(
              stream: _reportService.getReportsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var reports = snapshot.data ?? [];

                if (_filterStatus != 'all') {
                  reports = reports.where((r) => r.status == _filterStatus).toList();
                }

                if (reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No reports found', style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReportCard(reports[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    Color statusColor;
    IconData statusIcon;
    switch (report.status) {
      case 'submitted':
        statusColor = Colors.blue;
        statusIcon = Icons.fiber_new_rounded;
        break;
      case 'under_review':
        statusColor = Colors.orange;
        statusIcon = Icons.visibility_outlined;
        break;
      case 'in_transit':
        statusColor = AppTheme.primaryGreen;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case 'resolved':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = AppTheme.textLight;
        statusIcon = Icons.info_outline;
    }

    IconData typeIcon;
    switch (report.type) {
      case 'missed_collection':
        typeIcon = Icons.delete_outline;
        break;
      case 'canal_pollution':
        typeIcon = Icons.water_outlined;
        break;
      case 'delay':
        typeIcon = Icons.schedule;
        break;
      default:
        typeIcon = Icons.report_outlined;
    }

    final timeDiff = DateTime.now().difference(report.createdAt);
    String timeAgo;
    if (timeDiff.inMinutes < 60) {
      timeAgo = '${timeDiff.inMinutes}m ago';
    } else if (timeDiff.inHours < 24) {
      timeAgo = '${timeDiff.inHours}h ago';
    } else {
      timeAgo = '${timeDiff.inDays}d ago';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title.isNotEmpty ? report.title : report.displayType,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report.reporterName.isNotEmpty ? 'By ${report.reporterName}' : 'Anonymous',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          report.displayStatus,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(timeAgo, style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                ],
              ),
            ],
          ),

          // Description
          if (report.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              report.description,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Location
          if (report.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.address,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Progress bar
          const SizedBox(height: 14),
          _buildProgressSteps(report.progressStep),

          // Actions
          if (report.status != 'resolved') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(report),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirm(report),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSteps(int step) {
    return Row(
      children: [
        _buildDot(1, step, 'Submitted'),
        _buildLine(step >= 2),
        _buildDot(2, step, 'Reviewed'),
        _buildLine(step >= 3),
        _buildDot(3, step, 'Resolved'),
      ],
    );
  }

  Widget _buildDot(int dotStep, int currentStep, String label) {
    final isActive = currentStep >= dotStep;
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primaryGreen : Colors.grey.shade300,
          ),
          child: isActive
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 9, color: isActive ? AppTheme.primaryGreen : AppTheme.textLight)),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isActive ? AppTheme.primaryGreen : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildActionButton(ReportModel report) {
    String nextStatus;
    String label;
    int nextStep;

    switch (report.status) {
      case 'submitted':
        nextStatus = 'under_review';
        label = 'Start Review';
        nextStep = 2;
        break;
      case 'under_review':
        nextStatus = 'in_transit';
        label = 'Send Team';
        nextStep = 2;
        break;
      case 'in_transit':
        nextStatus = 'resolved';
        label = 'Mark Resolved';
        nextStep = 3;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () async {
        await _reportService.updateReportStatus(
          report.id,
          status: nextStatus,
          progressStep: nextStep,
        );
        _loadCounts();
      },
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  void _showDeleteConfirm(ReportModel report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Report?'),
        content: Text('Are you sure you want to delete "${report.title.isNotEmpty ? report.title : report.displayType}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _reportService.deleteReport(report.id);
              _loadCounts();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
