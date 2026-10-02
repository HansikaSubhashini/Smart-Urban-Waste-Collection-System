import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import 'admin_register_resident_screen.dart';

class AdminResidentsScreen extends StatefulWidget {
  const AdminResidentsScreen({super.key});

  @override
  State<AdminResidentsScreen> createState() => _AdminResidentsScreenState();
}

class _AdminResidentsScreenState extends State<AdminResidentsScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Resident Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppTheme.darkGreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminRegisterResidentScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name, ID, email, phone or address...',
                hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                filled: true,
                fillColor: AppTheme.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // ── Filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Inactive', 'inactive'),
              ],
            ),
          ),

          // ── Resident list ──
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _adminService.getResidentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allResidents = snapshot.data ?? [];
                var residents = List<UserModel>.from(allResidents);

                // Apply status filter
                if (_statusFilter != 'all') {
                  residents = residents.where((r) => r.status == _statusFilter).toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  residents = residents.where((r) =>
                    r.name.toLowerCase().contains(_searchQuery) ||
                    r.uid.toLowerCase().contains(_searchQuery) ||
                    r.email.toLowerCase().contains(_searchQuery) ||
                    r.phone.toLowerCase().contains(_searchQuery) ||
                    r.address.toLowerCase().contains(_searchQuery)
                  ).toList();
                }

                if (residents.isEmpty && allResidents.isEmpty) {
                  return _buildEmptyState();
                }

                // Stats from all residents (unfiltered)
                final total = allResidents.length;
                final active = allResidents.where((r) => r.status == 'active').length;
                final pending = allResidents.where((r) => r.status == 'pending').length;
                final inactive = allResidents.where((r) => r.status == 'inactive').length;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // ── Summary row ──
                    _buildSummaryRow(total, active, pending, inactive),
                    const SizedBox(height: 6),

                    // ── Results count ──
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${residents.length} resident${residents.length != 1 ? 's' : ''} found',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                      ),
                    ),

                    if (residents.isEmpty)
                      _buildEmptyState()
                    else
                      // ── Resident cards ──
                      ...residents.asMap().entries.map((entry) {
                        final index = entry.key;
                        final resident = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildResidentCard(resident, index + 1),
                        );
                      }),

                    const SizedBox(height: 80), // space for FAB
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminRegisterResidentScreen()),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Register New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── Summary Row ──
  Widget _buildSummaryRow(int total, int active, int pending, int inactive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildStatItem('Total', total, AppTheme.textDark, Icons.people),
          _buildVerticalDivider(),
          _buildStatItem('Active', active, AppTheme.primaryGreen, Icons.check_circle),
          _buildVerticalDivider(),
          _buildStatItem('Pending', pending, Colors.orange, Icons.schedule),
          _buildVerticalDivider(),
          _buildStatItem('Inactive', inactive, Colors.grey, Icons.block),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  // ── Resident Card ──
  Widget _buildResidentCard(UserModel resident, int index) {
    final statusColor = _getStatusColor(resident.status);

    final timeDiff = DateTime.now().difference(resident.createdAt);
    String registeredText;
    if (timeDiff.inDays > 0) {
      registeredText = '${timeDiff.inDays} day${timeDiff.inDays > 1 ? 's' : ''} ago';
    } else if (timeDiff.inHours > 0) {
      registeredText = '${timeDiff.inHours}h ago';
    } else {
      registeredText = '${timeDiff.inMinutes}m ago';
    }

    return GestureDetector(
      onTap: () => _showResidentDetails(resident),
      child: Container(
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
          border: Border.all(
            color: resident.status == 'pending'
                ? Colors.orange.withValues(alpha: 0.3)
                : Colors.transparent,
            width: resident.status == 'pending' ? 1.5 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: Avatar + Name + Status ──
            Row(
              children: [
                // Index number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlueBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#$index',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  child: Text(
                    resident.name.isNotEmpty ? resident.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resident.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${resident.uid}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryGreen.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        resident.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Info grid ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.email_outlined, 'Email', resident.email),
                  if (resident.phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone_outlined, 'Phone', resident.phone),
                  ],
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Address',
                    resident.address.isNotEmpty ? resident.address : 'Not provided',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          Icons.notifications_outlined,
                          'Alert',
                          resident.alertProximity ?? '500m',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Joined',
                          registeredText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Action buttons ──
            Row(
              children: [
                // View details
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showResidentDetails(resident),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (resident.status == 'pending') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(resident.uid, 'active'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(
                      resident.uid,
                      resident.status == 'active' ? 'inactive' : 'active',
                    ),
                    icon: Icon(
                      resident.status == 'active' ? Icons.block : Icons.check_circle_outline,
                      size: 16,
                    ),
                    label: Text(
                      resident.status == 'active' ? 'Deactivate' : 'Activate',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: resident.status == 'active' ? Colors.red : AppTheme.primaryGreen,
                      side: BorderSide(
                        color: resident.status == 'active' ? Colors.red.shade300 : AppTheme.primaryGreen,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Row ──
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Resident Detail Bottom Sheet ──
  void _showResidentDetails(UserModel resident) {
    final statusColor = _getStatusColor(resident.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Avatar + Name
                CircleAvatar(
                  radius: 36,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  child: Text(
                    resident.name.isNotEmpty ? resident.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  resident.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        resident.status.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Details Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.badge_outlined, 'Resident ID', resident.uid),
                      _buildDetailDivider(),
                      _buildDetailRow(Icons.email_outlined, 'Email', resident.email),
                      _buildDetailDivider(),
                      _buildDetailRow(Icons.phone_outlined, 'Phone', resident.phone.isNotEmpty ? resident.phone : 'Not provided'),
                      _buildDetailDivider(),
                      _buildDetailRow(Icons.location_on_outlined, 'Address', resident.address.isNotEmpty ? resident.address : 'Not provided'),
                      _buildDetailDivider(),
                      _buildDetailRow(Icons.notifications_outlined, 'Alert Proximity', resident.alertProximity ?? '500m'),
                      _buildDetailDivider(),
                      _buildDetailRow(
                        Icons.do_not_disturb_on_outlined,
                        'Quiet Hours',
                        resident.quietHoursEnabled ? 'Enabled' : 'Disabled',
                      ),
                      _buildDetailDivider(),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Registered',
                        '${resident.createdAt.day}/${resident.createdAt.month}/${resident.createdAt.year}',
                      ),
                      _buildDetailDivider(),
                      _buildDetailRow(
                        Icons.update,
                        'Last Updated',
                        '${resident.updatedAt.day}/${resident.updatedAt.month}/${resident.updatedAt.year}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Bottom sheet actions ──
                Row(
                  children: [
                    if (resident.status == 'pending')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _updateStatus(resident.uid, 'active');
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    if (resident.status == 'pending')
                      const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _updateStatus(
                            resident.uid,
                            resident.status == 'active' ? 'inactive' : 'active',
                          );
                        },
                        icon: Icon(
                          resident.status == 'active' ? Icons.block : Icons.check_circle_outline,
                          size: 18,
                        ),
                        label: Text(resident.status == 'active' ? 'Deactivate' : 'Activate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: resident.status == 'active' ? Colors.red : AppTheme.primaryGreen,
                          side: BorderSide(
                            color: resident.status == 'active' ? Colors.red.shade300 : AppTheme.primaryGreen,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailDivider() {
    return Divider(height: 1, color: Colors.grey.shade200, indent: 44);
  }

  // ── Filter Chip ──
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
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

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No residents found',
            style: TextStyle(color: AppTheme.textLight, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Registered residents will appear here',
            style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.primaryGreen;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      default:
        return AppTheme.textLight;
    }
  }

  Future<void> _updateStatus(String userId, String status) async {
    try {
      await _adminService.updateUserStatus(userId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resident status updated to $status'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
