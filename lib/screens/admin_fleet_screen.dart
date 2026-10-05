import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/truck_model.dart';
import '../services/truck_service.dart';
import 'map_screen.dart';

class AdminFleetScreen extends StatefulWidget {
  const AdminFleetScreen({super.key});

  @override
  State<AdminFleetScreen> createState() => _AdminFleetScreenState();
}

class _AdminFleetScreenState extends State<AdminFleetScreen> {
  final TruckService _truckService = TruckService();
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Fleet Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.darkGreen),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('On Route', 'on_route'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Idle', 'idle'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Delayed', 'delayed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Maintenance', 'maintenance'),
                ],
              ),
            ),
          ),

          // ── Truck list ──
          Expanded(
            child: StreamBuilder<List<TruckModel>>(
              stream: _filterStatus == 'all'
                  ? _truckService.getTrucksStream()
                  : _truckService.getTrucksByStatus(_filterStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final trucks = snapshot.data ?? [];
                if (trucks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No trucks found', style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                      ],
                    ),
                  );
                }

                // Summary counts
                final onRoute = trucks.where((t) => t.status == 'on_route').length;
                final idle = trucks.where((t) => t.status == 'idle').length;
                final delayed = trucks.where((t) => t.status == 'delayed').length;
                final maintenance = trucks.where((t) => t.status == 'maintenance').length;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // ── Summary cards ──
                    if (_filterStatus == 'all') ...[
                      Row(
                        children: [
                          _buildMiniStat('On Route', onRoute, AppTheme.statusOnRouteText, AppTheme.statusOnRoute),
                          const SizedBox(width: 8),
                          _buildMiniStat('Idle', idle, AppTheme.textLight, AppTheme.lightBlueBackground),
                          const SizedBox(width: 8),
                          _buildMiniStat('Delayed', delayed, AppTheme.statusDelayedText, AppTheme.statusDelayed),
                          const SizedBox(width: 8),
                          _buildMiniStat('Maint.', maintenance, AppTheme.statusMaintenanceText, AppTheme.statusMaintenance),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Truck cards ──
                    ...trucks.map((truck) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTruckCard(truck),
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
          ),
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

  Widget _buildMiniStat(String label, int count, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTruckCard(TruckModel truck) {
    Color statusBg;
    Color statusText;

    switch (truck.status) {
      case 'on_route':
        statusBg = AppTheme.statusOnRoute;
        statusText = AppTheme.statusOnRouteText;
        break;
      case 'delayed':
        statusBg = AppTheme.statusDelayed;
        statusText = AppTheme.statusDelayedText;
        break;
      case 'maintenance':
        statusBg = AppTheme.statusMaintenance;
        statusText = AppTheme.statusMaintenanceText;
        break;
      default:
        statusBg = AppTheme.lightBlueBackground;
        statusText = AppTheme.textLight;
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
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping, color: AppTheme.primaryGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truck.truckId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                    ),
                    if (truck.licensePlate.isNotEmpty)
                      Text(
                        truck.licensePlate,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  truck.displayStatus,
                  style: TextStyle(color: statusText, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              _buildInfoItem(Icons.person_outline, truck.driverName.isNotEmpty ? truck.driverName : 'Unassigned'),
              const SizedBox(width: 20),
              _buildInfoItem(Icons.route, truck.currentRoute.isNotEmpty ? truck.currentRoute : 'No route'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoItem(Icons.location_on_outlined, truck.currentLocation.isNotEmpty ? truck.currentLocation : 'Unknown'),
              const SizedBox(width: 20),
              _buildInfoItem(Icons.speed, '${truck.speedKmh.toStringAsFixed(0)} km/h'),
            ],
          ),

          // Prediction
          if (truck.prediction != '—') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: truck.prediction.contains('+')
                    ? AppTheme.statusDelayed
                    : AppTheme.statusOnRoute,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    truck.prediction.contains('+') ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    size: 14,
                    color: truck.prediction.contains('+') ? AppTheme.statusDelayedText : AppTheme.statusOnRouteText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ML Prediction: ${truck.prediction}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: truck.prediction.contains('+') ? AppTheme.statusDelayedText : AppTheme.statusOnRouteText,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showStatusDialog(truck),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Update Status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapScreen()),
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Track'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textDark,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppTheme.textLight),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(TruckModel truck) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update ${truck.truckId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(ctx, truck.truckId, 'on_route', 'On Route', Icons.route, AppTheme.statusOnRouteText),
            _buildStatusOption(ctx, truck.truckId, 'idle', 'Idle', Icons.pause_circle_outline, AppTheme.textLight),
            _buildStatusOption(ctx, truck.truckId, 'delayed', 'Delayed', Icons.warning_amber_rounded, AppTheme.statusDelayedText),
            _buildStatusOption(ctx, truck.truckId, 'maintenance', 'Maintenance', Icons.build_outlined, AppTheme.statusMaintenanceText),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext ctx, String truckId, String status, String label, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () async {
        Navigator.pop(ctx);
        await _truckService.updateTruckStatus(truckId, status);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$truckId updated to $label'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
}
