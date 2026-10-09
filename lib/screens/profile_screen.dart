import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'municipal_dashboard.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  bool _quietHoursEnabled = false;
  String _alertProximity = '500m';
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Sinhala', 'Tamil'];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _quietHoursEnabled = user.quietHoursEnabled;
      _alertProximity = user.alertProximity ?? '500m';
    }
  }

  Future<void> _updateAlertProximity(String proximity) async {
    setState(() => _alertProximity = proximity);
    try {
      await _auth.updateProfile(alertProximity: proximity);
    } catch (e) {
      debugPrint('Error updating proximity: $e');
    }
  }

  Future<void> _toggleQuietHours(bool val) async {
    setState(() => _quietHoursEnabled = val);
    try {
      await _auth.updateProfile(quietHoursEnabled: val);
    } catch (e) {
      debugPrint('Error updating quiet hours: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: AppTheme.darkGreen),
            const SizedBox(width: 8),
            Text(
              'My Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_none, color: AppTheme.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileCard(user),
          const SizedBox(height: 24),
          _buildAlertProximitySection(),
          const SizedBox(height: 24),
          _buildImpactCard(),
          const SizedBox(height: 24),
          _buildAppPreferences(context),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {
                _auth.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out from EcoTrack',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(user) {
    final name = user?.name ?? 'User';
    final address = user?.address ?? 'No address set';

    // Split address for display
    final addressParts = address.split(',');
    final mainAddress = addressParts.isNotEmpty ? addressParts.first.trim() : address;
    final subAddress = addressParts.length > 1 ? addressParts.sublist(1).join(',').trim() : '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.lightBlueBackground,
            child: Icon(Icons.person, size: 40, color: AppTheme.primaryGreen),
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
                      style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.edit, color: AppTheme.darkGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppTheme.textLight, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mainAddress,
                            style: const TextStyle(
                                color: AppTheme.textDark, fontSize: 14),
                          ),
                          if (subAddress.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subAddress,
                              style: const TextStyle(
                                  color: AppTheme.textLight, fontSize: 14),
                            ),
                          ],
                        ],
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

  Widget _buildAlertProximitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ALERT PROXIMITY',
              style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'SMART TRACK',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _updateAlertProximity('500m'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _alertProximity == '500m'
                        ? const Color(0xFFE8F5E9)
                        : AppTheme.lightBlueBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: _alertProximity == '500m'
                        ? Border.all(color: AppTheme.primaryGreen, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _alertProximity == '500m'
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: _alertProximity == '500m'
                            ? AppTheme.primaryGreen
                            : AppTheme.textLight,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '500m Away',
                        style: TextStyle(
                          color: _alertProximity == '500m'
                              ? AppTheme.textDark
                              : AppTheme.textLight,
                          fontWeight: _alertProximity == '500m'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _updateAlertProximity('1km'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _alertProximity == '1km'
                        ? const Color(0xFFE8F5E9)
                        : AppTheme.lightBlueBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: _alertProximity == '1km'
                        ? Border.all(color: AppTheme.primaryGreen, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _alertProximity == '1km'
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: _alertProximity == '1km'
                            ? AppTheme.primaryGreen
                            : AppTheme.textLight,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1km Away',
                        style: TextStyle(
                          color: _alertProximity == '1km'
                              ? AppTheme.textDark
                              : AppTheme.textLight,
                          fontWeight: _alertProximity == '1km'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Notifications will trigger automatically as the garbage truck enters your designated radius.',
          style:
              TextStyle(color: AppTheme.textLight, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_outlined, color: Colors.lightGreenAccent),
              SizedBox(width: 8),
              Text(
                'Why this matters',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Proper disposal prevents urban canal blockages and significantly reduces vector-borne diseases in our community.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View Impact Statistics',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.show_chart, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APP PREFERENCES',
          style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightBlueBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: AppTheme.textDark),
                title: const Text('Language',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Preferred interface language'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.darkGreen),
                      items: _languages.map((String lang) {
                        return DropdownMenuItem<String>(
                          value: lang,
                          child: Text(lang, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLanguage = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined,
                    color: AppTheme.textDark),
                title: const Text('App Theme',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Switch between light and dark'),
                trailing: Switch(
                  value: false,
                  onChanged: (val) {},
                  activeColor: AppTheme.darkGreen,
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.do_not_disturb_on_total_silence,
                    color: AppTheme.textDark),
                title: const Text('Quiet Hours',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Disable alerts after 10 PM'),
                trailing: Checkbox(
                  value: _quietHoursEnabled,
                  onChanged: (val) {
                    if (val != null) _toggleQuietHours(val);
                  },
                  activeColor: AppTheme.darkGreen,
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings,
                    color: AppTheme.textDark),
                title: const Text('Admin Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Access municipal management'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MunicipalDashboard()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
