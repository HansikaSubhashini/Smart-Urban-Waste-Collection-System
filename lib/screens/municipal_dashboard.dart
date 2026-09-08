import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MunicipalDashboard extends StatelessWidget {
  const MunicipalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildOverviewMetrics(),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildFleetStatus(),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: _buildServicePerformance(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildResidentManagement(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: AppTheme.lightBlueBackground,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Text(
                  'EcoTrack',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  child: Icon(Icons.person, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 12),
                Column(
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
        ],
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Municipal Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlueBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'System Live: All Districts',
                    style: TextStyle(
                      color: AppTheme.darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.notifications_none, color: AppTheme.textDark),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewMetrics() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Active Trucks', '42', '↑ 94% Fleet Capacity', Icons.local_shipping, AppTheme.primaryGreen)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Missed Collections', '08', 'Today • Colombo 03 District', Icons.event_busy, Colors.red)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Avg. Rating', '4.82', '↗ 12k Reviews this week', Icons.star_border, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Total Residents', '84.2k', '+124 New today', Icons.people, AppTheme.textDark)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color iconColor) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: title == 'Missed Collections' ? Colors.red : (title == 'Active Trucks' ? AppTheme.primaryGreen : AppTheme.textLight),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Row(
                children: [
                  Icon(Icons.sensors, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Fleet Real-time Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                'View Map',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              _buildTableRow('Truck ID', 'Location', 'Status', 'ML Prediction', isHeader: true),
              _buildTableRow('TRK-2024-C1', 'Marine Drive,\nBambalapitiya', 'ON ROUTE', '-2 min Early'),
              _buildTableRow('TRK-2024-C8', 'Duplication Road,\nKollupitiya', 'DELAYED', '+12 min\n(Traffic)'),
              _buildTableRow('TRK-2024-B4', 'Reclamation Road, Fort', 'ON ROUTE', 'On Time'),
              _buildTableRow('TRK-2024-D2', 'Thurstan Road,\nCinnamon Gdns', 'MAINTENANCE', '—'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String col1, String col2, String col3, String col4, {bool isHeader = false}) {
    TextStyle textStyle = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? AppTheme.textLight : AppTheme.textDark,
      fontSize: 14,
    );

    Widget statusBadge(String status) {
      if (isHeader) return Text(status, style: textStyle);
      
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
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget predictionWidget(String prediction) {
      if (isHeader || prediction == '—') return Text(prediction, style: textStyle);
      
      bool isEarlyOrOnTime = prediction.contains('Early') || prediction.contains('On Time');
      bool isDelayed = prediction.contains('+');
      
      return Row(
        children: [
          if (isEarlyOrOnTime) Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 16),
          if (isDelayed) Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
          if (isEarlyOrOnTime || isDelayed) const SizedBox(width: 4),
          Text(
            prediction,
            style: TextStyle(
              color: isDelayed ? Colors.red : AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(col1, style: textStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(col2, style: textStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: statusBadge(col3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: predictionWidget(col4),
        ),
      ],
    );
  }

  Widget _buildServicePerformance() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Service Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resident rating metrics (Last 30 Days)',
            style: TextStyle(color: AppTheme.textLight, fontSize: 12),
          ),
          const SizedBox(height: 24),
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
                Text(
                  'AI INSIGHTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Morning congestion in District 03 is impacting punctuality by 14%.\nRecommend shifting start times to 05:30 AM.',
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
            Text(label, style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500)),
            Text(percentage, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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

  Widget _buildResidentManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resident Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage household registration and billing data',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add),
              label: const Text('Register New Household'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildResidentCard('Nihal Perera', 'Bambalapitiya\nFlats, D-14', 'ACTIVE', 'Registered Today', Icons.home)),
            const SizedBox(width: 16),
            Expanded(child: _buildResidentCard('SkyGarden Condos', 'Ward Place, Colombo 07', 'ACTIVE', '2 hrs ago', Icons.apartment)),
            const SizedBox(width: 16),
            Expanded(child: _buildResidentCard('Cargills FoodCity', 'Dickman\'s Road Outlet', 'PENDING', '4 hrs ago', Icons.store)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.lightBlueBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'View All 84,212 Residents',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResidentCard(String name, String address, String status, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightBlueBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.textLight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: status == 'ACTIVE' ? AppTheme.primaryGreen : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textLight,
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
}
