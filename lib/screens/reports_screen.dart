import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: AppTheme.darkGreen),
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
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Report Canal Pollution',
            subtitle: 'Help keep Colombo\'s waterways clean',
            icon: Icons.water_drop_outlined,
            backgroundColor: const Color(0xFF1565C0), // Blue color from design
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Your Active Reports', Icons.radar),
          const SizedBox(height: 12),
          _buildActiveReportCard(),
          const SizedBox(height: 24),
          _buildNewReportDetails(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Nearby Reports', Icons.people_alt_outlined),
          const SizedBox(height: 12),
          _buildNearbyReport(
            title: 'MISSED COLLECTION',
            distance: '200m away • Flower Road',
            time: '2 hours ago',
            isResolved: false,
            imageUrl: 'https://images.unsplash.com/photo-1595278069441-2cf29f8005a4?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
          ),
          const SizedBox(height: 12),
          _buildNearbyReport(
            title: 'CANAL POLLUTION',
            distance: '1.2km away • Beira Lake',
            time: 'Resolved',
            isResolved: true,
            imageUrl: 'https://images.unsplash.com/photo-1594705374479-7d0bc1c78e38?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
          ),
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
  }) {
    return Container(
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
    );
  }

  Widget _buildActiveReportCard() {
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
              const Text(
                'Missed Pickup: 42nd Lane',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF90CAF9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'In Transit',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Submitted Dec 18, 10:24 AM',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildProgressTracker(),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Column(
      children: [
        Row(
          children: [
            _buildProgressNode(true, '1'),
            Expanded(child: _buildProgressLine(true)),
            _buildProgressNode(true, '2'),
            Expanded(child: _buildProgressLine(false)),
            _buildProgressNode(false, '3'),
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
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('Submit Community Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildNearbyReport({
    required String title,
    required String distance,
    required String time,
    required bool isResolved,
    required String imageUrl,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
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
          if (isResolved)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.darkGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
        ],
      ),
    );
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
