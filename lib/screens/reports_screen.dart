import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  final AuthService _auth = AuthService();
  final _addressController = TextEditingController();
  String _selectedReportType = 'missed_collection';
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an address.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      final report = ReportModel(
        id: '',
        reporterId: user?.uid ?? '',
        reporterName: user?.name ?? 'Anonymous',
        type: _selectedReportType,
        title: _selectedReportType == 'missed_collection'
            ? 'Missed Collection: $address'
            : 'Canal Pollution: $address',
        description: 'Report submitted via EcoTrack app.',
        address: address,
        status: 'submitted',
        progressStep: 1,
      );

      await _reportService.submitReport(report);

      if (!mounted) return;

      _addressController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: Color.fromARGB(255, 43, 150, 132)),
            const SizedBox(width: 8),
            Text(
              'Community Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildActionCard(
            title: 'Report Missed Collection',
            subtitle: 'Flag a skipped pickup on your route',
            icon: Icons.delete_outline,
            backgroundColor: AppTheme.darkGreen,
            onTap: () => setState(() => _selectedReportType = 'missed_collection'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Report Canal Pollution',
            subtitle: 'Help keep Colombo\'s waterways clean',
            icon: Icons.water_drop_outlined,
            backgroundColor: const Color(0xFF1565C0),
            onTap: () => setState(() => _selectedReportType = 'canal_pollution'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Your Active Reports', Icons.radar),
          const SizedBox(height: 12),
          _buildActiveReportsStream(),
          const SizedBox(height: 24),
          _buildNewReportDetails(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Nearby Reports', Icons.people_alt_outlined),
          const SizedBox(height: 12),
          _buildNearbyReportsStream(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.darkGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stream active reports for the current user
  Widget _buildActiveReportsStream() {
    final userId = _auth.currentUser?.uid ?? '';

    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.getReportsByResident(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ));
        }

        final reports = (snapshot.data ?? [])
            .where((r) => r.status != 'resolved')
            .toList();

        if (reports.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.lightBlueBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No active reports.',
                style: TextStyle(color: AppTheme.textLight),
              ),
            ),
          );
        }

        return Column(
          children: reports.map((report) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActiveReportCard(report),
          )).toList(),
        );
      },
    );
  }

  Widget _buildActiveReportCard(ReportModel report) {
    final dateStr = DateFormat('MMM d, h:mm a').format(report.createdAt);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightBlueBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF90CAF9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.displayStatus,
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Submitted $dateStr',
            style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildProgressTracker(report.progressStep),
        ],
      ),
    );
  }

  Widget _buildProgressTracker(int currentStep) {
    return Column(
      children: [
        Row(
          children: [
            _buildProgressNode(currentStep >= 1, '1'),
            Expanded(child: _buildProgressLine(currentStep >= 2)),
            _buildProgressNode(currentStep >= 2, '2'),
            Expanded(child: _buildProgressLine(currentStep >= 3)),
            _buildProgressNode(currentStep >= 3, '3'),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Under Review', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Text('Collector Notified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Text('Resolved', style: TextStyle(fontSize: 10, color: AppTheme.textLight)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressNode(bool isCompleted, String step) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.darkGreen : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        step,
        style: TextStyle(
          color: isCompleted ? Colors.white : AppTheme.textLight,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Container(
      height: 2,
      color: isCompleted ? AppTheme.darkGreen : Colors.grey[300],
    );
  }

  Widget _buildNewReportDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightBlueBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Report Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedReportType == 'missed_collection'
                  ? AppTheme.darkGreen
                  : const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selectedReportType == 'missed_collection'
                  ? 'Missed Collection'
                  : 'Canal Pollution',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Location of Incident', style: TextStyle(color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=Colombo&zoom=15&size=600x300&maptype=satellite&key=PLACEHOLDER'),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.my_location, size: 16, color: AppTheme.darkGreen),
              label: const Text('Select Current', style: TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Confirm Address (e.g., Ward Place, Colombo 07)',
              hintStyle: const TextStyle(color: AppTheme.textLight),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Upload Evidence (Photo)', style: TextStyle(color: AppTheme.textDark)),
          const SizedBox(height: 8),
          CustomPaint(
            painter: DashedRectPainter(color: Colors.grey.withOpacity(0.5), strokeWidth: 2, gap: 5),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 40, color: AppTheme.textLight),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to take a photo or upload',
                    style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Helps prioritize urgent requests',
                    style: TextStyle(color: AppTheme.textLight.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReport,
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSubmitting ? 'Submitting...' : 'Submit Community Report',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Stream nearby (all) reports
  Widget _buildNearbyReportsStream() {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.getNearbyReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ));
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return const Center(
            child: Text('No nearby reports.', style: TextStyle(color: AppTheme.textLight)),
          );
        }

        return Column(
          children: reports.take(5).map((report) {
            final timeStr = report.status == 'resolved'
                ? 'Resolved'
                : _formatTimeAgo(report.createdAt);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildNearbyReport(
                title: report.displayType,
                distance: report.address,
                time: timeStr,
                isResolved: report.status == 'resolved',
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Widget _buildNearbyReport({
    required String title,
    required String distance,
    required String time,
    required bool isResolved,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isResolved
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isResolved ? Icons.check_circle : Icons.warning_amber,
              color: isResolved ? AppTheme.primaryGreen : Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isResolved)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_circle, color: AppTheme.darkGreen, size: 16),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.access_time, color: AppTheme.textLight, size: 16),
                      ),
                    Text(
                      time,
                      style: TextStyle(
                        color: isResolved ? AppTheme.darkGreen : AppTheme.textLight,
                        fontWeight: isResolved ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, required this.strokeWidth, required this.gap});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    _drawDashedLine(canvas, paint, const Offset(0, 0), Offset(width, 0));
    _drawDashedLine(canvas, paint, Offset(width, 0), Offset(width, height));
    _drawDashedLine(canvas, paint, Offset(width, height), Offset(0, height));
    _drawDashedLine(canvas, paint, Offset(0, height), const Offset(0, 0));
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final double distance = (end - start).distance;
    final double dx = (end.dx - start.dx) / distance;
    final double dy = (end.dy - start.dy) / distance;

    double drawnLength = 0.0;
    while (drawnLength < distance) {
      final double dashLength = (drawnLength + gap > distance) ? distance - drawnLength : gap;
      final Offset dashStart = Offset(start.dx + dx * drawnLength, start.dy + dy * drawnLength);
      final Offset dashEnd = Offset(dashStart.dx + dx * dashLength, dashStart.dy + dy * dashLength);
      canvas.drawLine(dashStart, dashEnd, paint);
      drawnLength += gap * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
