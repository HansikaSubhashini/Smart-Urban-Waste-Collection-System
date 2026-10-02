import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/truck_model.dart';
import '../models/user_model.dart';
import '../services/truck_service.dart';
import '../services/admin_service.dart';
import 'admin_register_resident_screen.dart';
import 'admin_fleet_screen.dart';
import 'admin_residents_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final TruckService _truckService = TruckService();
  final AdminService _adminService = AdminService();

  Map<String, dynamic> _metrics = {};
  Map<String, dynamic> _performance = {};
  bool _metricsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final metrics = await _adminService.getDashboardMetrics();
      final performance = await _adminService.getPerformanceMetrics();
      if (mounted) {
        setState(() {
          _metrics = metrics;
          _performance = performance;
          _metricsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading metrics: $e');
      if (mounted) setState(() => _metricsLoaded = true);
    }
  }

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
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSystemLiveChip(),
            const SizedBox(height: 24),
            _buildOverviewMetrics(),
            const SizedBox(height: 32),
            _buildSectionHeader(Icons.sensors, 'Fleet Real-time Status', 'View Map'),
            const SizedBox(height: 16),
            _buildFleetStatusStream(),
            const SizedBox(height: 32),
            _buildSectionHeader(Icons.analytics_outlined, 'Service Performance', null),
            const SizedBox(height: 16),
            _buildServicePerformance(),
            const SizedBox(height: 32),
            _buildResidentManagementStream(context),
            const SizedBox(height: 24),
          ],
        ),
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
            _buildSidebarItem(Icons.local_shipping_outlined, 'Fleet Management', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFleetScreen()));
            }),
            _buildSidebarItem(Icons.people_outline, 'Residents', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminResidentsScreen()));
            }),
            _buildSidebarItem(Icons.bar_chart, 'Reports', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportsScreen()));
            }),
            _buildSidebarItem(Icons.settings_outlined, 'System Settings', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen()));
            }),
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

  Widget _buildSidebarItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
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
        onTap: onTap ?? () {},
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
    if (!_metricsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeTrucks = _metrics['activeTrucks']?.toString() ?? '0';
    final missed = _metrics['missedCollections']?.toString() ?? '0';
    final avgRating = (_performance['avgRating'] ?? 0.0).toStringAsFixed(2);
    final totalResidents = _metrics['totalResidents'] ?? 0;
    final newToday = _metrics['newResidentsToday'] ?? 0;

    final residentDisplay = totalResidents >= 1000
        ? '${(totalResidents / 1000).toStringAsFixed(1)}k'
        : totalResidents.toString();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        _buildMetricCard('Active Trucks', activeTrucks, '↑ On Route', Icons.local_shipping, AppTheme.primaryGreen),
        _buildMetricCard('Missed Col.', missed, 'Today', Icons.event_busy, Colors.red),
        _buildMetricCard('Avg. Rating', avgRating, '↗ ${_performance['totalReviews'] ?? 0} Reviews', Icons.star_border, Colors.blue),
        _buildMetricCard('Residents', residentDisplay, '+$newToday New today', Icons.people, AppTheme.textDark),
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

  /// Real-time fleet status from Firestore
  Widget _buildFleetStatusStream() {
    return StreamBuilder<List<TruckModel>>(
      stream: _truckService.getTrucksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final trucks = snapshot.data ?? [];
        if (trucks.isEmpty) {
          return const Center(
            child: Text('No trucks registered.', style: TextStyle(color: AppTheme.textLight)),
          );
        }

        return Column(
          children: trucks.map((truck) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildFleetCard(
                truck.truckId,
                truck.currentLocation,
                truck.displayStatus,
                truck.prediction,
              ),
            );
          }).toList(),
        );
      },
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
    final punctuality = (_performance['driverPunctuality'] ?? 0.92) as double;
    final politeness = (_performance['collectorPoliteness'] ?? 0.88) as double;
    final efficiency = (_performance['routeEfficiency'] ?? 0.74) as double;
    final resolution = (_performance['problemResolution'] ?? 0.96) as double;
    final aiInsight = _performance['aiInsight'] as String? ??
        'Morning congestion in District 03 is impacting punctuality by 14%. Recommend shifting start times to 05:30 AM.';

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
          _buildPerformanceBar('Driver Punctuality', punctuality, '${(punctuality * 100).round()}%', AppTheme.primaryGreen),
          const SizedBox(height: 16),
          _buildPerformanceBar('Collector Politeness', politeness, '${(politeness * 100).round()}%', AppTheme.primaryGreen),
          const SizedBox(height: 16),
          _buildPerformanceBar('Route Efficiency', efficiency, '${(efficiency * 100).round()}%', Colors.blue),
          const SizedBox(height: 16),
          _buildPerformanceBar('Problem Resolution', resolution, '${(resolution * 100).round()}%', AppTheme.textDark),
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
                Text(
                  aiInsight,
                  style: const TextStyle(
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

  /// Real-time resident list from Firestore
  Widget _buildResidentManagementStream(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
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
                SizedBox(height: 4),
                Text(
                  'Manage household registration',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminRegisterResidentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<UserModel>>(
          stream: _adminService.getResidentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final residents = snapshot.data ?? [];
            if (residents.isEmpty) {
              return const Center(
                child: Text('No residents registered yet.', style: TextStyle(color: AppTheme.textLight)),
              );
            }

            // Show up to 5 most recent residents
            final displayResidents = residents.take(5).toList();
            return Column(
              children: displayResidents.map((resident) {
                final timeDiff = DateTime.now().difference(resident.createdAt);
                String timeAgo;
                if (timeDiff.inMinutes < 60) {
                  timeAgo = '${timeDiff.inMinutes} min ago';
                } else if (timeDiff.inHours < 24) {
                  timeAgo = '${timeDiff.inHours} hrs ago';
                } else {
                  timeAgo = '${timeDiff.inDays} days ago';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildResidentCard(
                    resident.name,
                    resident.address.isNotEmpty ? resident.address : 'No address provided',
                    resident.status.toUpperCase(),
                    timeAgo,
                    Icons.home,
                  ),
                );
              }).toList(),
            );
          },
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.lightBlueBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.textLight, size: 20),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 14),
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
                  children: [
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
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
