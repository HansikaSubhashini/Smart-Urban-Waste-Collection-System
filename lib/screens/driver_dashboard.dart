import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, color: AppTheme.darkGreen),
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
            icon: const Icon(Icons.notifications_none, color: AppTheme.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildRouteDetailsSection(),
          const SizedBox(height: 24),
          _buildAppPreferences(context),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Handle Sign Out
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out from EcoTrack',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
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
                    const Text(
                      'Driver John Doe',
                      style: TextStyle(color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.edit, color: AppTheme.darkGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: AppTheme.textLight, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Truck: WP-4532',
                            style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Zone: Colombo South',
                            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                          ),
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

  Widget _buildRouteDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TODAY\'S ROUTE DETAILS',
              style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.route, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  const Text('Route 4: Kalubowila Area', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              _buildRouteStop('08:00 AM', 'Start Point', 'Municipal Depot', true),
              _buildRouteStop('08:30 AM', 'Collection 1', 'Hospital Road', false),
              _buildRouteStop('10:00 AM', 'Collection 2', 'Anderson Road', false),
              _buildRouteStop('12:00 PM', 'End Point', 'Waste Management Center', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteStop(String time, String title, String location, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? AppTheme.primaryGreen : AppTheme.textLight,
                size: 20,
              ),
              if (title != 'End Point')
                Container(
                  height: 30,
                  width: 2,
                  color: isCompleted ? AppTheme.primaryGreen : AppTheme.textLight.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppTheme.textDark : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? AppTheme.textDark : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? AppTheme.textDark : AppTheme.textLight,
                  ),
                ),
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
          style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
                title: const Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Preferred interface language'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('English'),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: AppTheme.textDark),
                title: const Text('App Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Switch between light and dark'),
                trailing: Switch(
                  value: false,
                  onChanged: (val) {},
                  activeColor: AppTheme.darkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
