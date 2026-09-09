import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: AppTheme.darkGreen),
            const SizedBox(width: 8),
            Text(
              'EcoTrack Admin',
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
      drawer: _buildDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSystemLiveChip(),
          const SizedBox(height: 24),
          _buildOverviewMetrics(),
          const SizedBox(height: 32),
          _buildSectionHeader(Icons.sensors, 'Fleet Real-time Status', 'View Map'),
          const SizedBox(height: 16),
          _buildFleetStatus(),
          const SizedBox(height: 32),
          _buildSectionHeader(Icons.analytics_outlined, 'Service Performance', null),
          const SizedBox(height: 16),
          _buildServicePerformance(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: AppTheme.lightBlueBackground,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.lightBlueBackground,
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: AppTheme.primaryGreen, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'EcoTrack',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            _buildSidebarItem(Icons.grid_view, 'Overview', isSelected: true),
            _buildSidebarItem(Icons.local_shipping_outlined, 'Fleet Management'),
            _buildSidebarItem(Icons.people_outline, 'Residents'),
            _buildSidebarItem(Icons.bar_chart, 'Reports'),
            _buildSidebarItem(Icons.settings_outlined, 'System Settings'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                    child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Colombo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'SUPER USER',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.white : AppTheme.textDark,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.white : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildSystemLiveChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.lightBlueBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'System Live: All Districts',
              style: TextStyle(
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        _buildMetricCard('Active Trucks', '42', '↑ 94% Capacity', Icons.local_shipping, AppTheme.primaryGreen),
        _buildMetricCard('Missed Col.', '08', 'Colombo 03', Icons.event_busy, Colors.red),
        _buildMetricCard('Avg. Rating', '4.82', '↗ 12k Reviews', Icons.star_border, Colors.blue),
        _buildMetricCard('Residents', '84.2k', '+124 New today', Icons.people, AppTheme.textDark),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: title == 'Missed Col.' ? Colors.red : (title == 'Active Trucks' ? AppTheme.primaryGreen : AppTheme.textLight),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String? actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        if (actionText != null)
          Text(
            actionText,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildFleetStatus() {
    return Column(
      children: [
        _buildFleetCard('TRK-2024-C1', 'Marine Drive, Bambalapitiya', 'ON ROUTE', '-2 min Early'),
        const SizedBox(height: 12),
        _buildFleetCard('TRK-2024-C8', 'Duplication Road, Kollupitiya', 'DELAYED', '+12 min (Traffic)'),
        const SizedBox(height: 12),
        _buildFleetCard('TRK-2024-B4', 'Reclamation Road, Fort', 'ON ROUTE', 'On Time'),
        const SizedBox(height: 12),
        _buildFleetCard('TRK-2024-D2', 'Thurstan Road, Cinnamon Gdns', 'MAINTENANCE', '—'),
      ],
    );
  }

  Widget _buildFleetCard(String truckId, String location, String status, String prediction) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'ON ROUTE':
        bgColor = AppTheme.statusOnRoute;
        textColor = AppTheme.statusOnRouteText;
        break;
      case 'DELAYED':
        bgColor = AppTheme.statusDelayed;
        textColor = AppTheme.statusDelayedText;
        break;
      case 'MAINTENANCE':
        bgColor = AppTheme.statusMaintenance;
        textColor = AppTheme.statusMaintenanceText;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    bool isEarlyOrOnTime = prediction.contains('Early') || prediction.contains('On Time');
    bool isDelayed = prediction.contains('+');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                truckId,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (prediction != '—') ...[
                if (isEarlyOrOnTime) const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 14),
                if (isDelayed) const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
                const SizedBox(width: 4),
              ],
              Text(
                prediction == '—' ? 'No prediction data' : prediction,
                style: TextStyle(
                  color: prediction == '—' ? AppTheme.textLight : (isDelayed ? Colors.red : AppTheme.primaryGreen),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicePerformance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resident rating metrics (Last 30 Days)',
            style: TextStyle(color: AppTheme.textLight, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _buildPerformanceBar('Driver Punctuality', 0.92, '92%', AppTheme.primaryGreen),
          const SizedBox(height: 16),
          _buildPerformanceBar('Collector Politeness', 0.88, '88%', AppTheme.primaryGreen),
          const SizedBox(height: 16),
          _buildPerformanceBar('Route Efficiency', 0.74, '74%', Colors.blue),
          const SizedBox(height: 16),
          _buildPerformanceBar('Problem Resolution', 0.96, '96%', AppTheme.textDark),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.darkGreen, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'AI INSIGHTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Morning congestion in District 03 is impacting punctuality by 14%. Recommend shifting start times to 05:30 AM.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBar(String label, double value, String percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500, fontSize: 13)),
            Text(percentage, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: AppTheme.lightBlueBackground,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
