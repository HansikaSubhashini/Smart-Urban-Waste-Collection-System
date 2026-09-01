import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildAlertProximitySection(),
          const SizedBox(height: 24),
          _buildImpactCard(),
          const SizedBox(height: 24),
          _buildAppPreferences(),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {},
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
            // backgroundImage: NetworkImage('...'), // Placeholder
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
                      'Arjuna Perera',
                      style: TextStyle(color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.edit, color: AppTheme.darkGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kalubowila,\nColombo',
                            style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '42/1 Hospital Road',
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

  Widget _buildAlertProximitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ALERT PROXIMITY',
              style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'SMART TRACK',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGreen, width: 2),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.notifications_active, color: AppTheme.primaryGreen),
                    SizedBox(height: 8),
                    Text('500m Away', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlueBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.notifications_none, color: AppTheme.textLight),
                    SizedBox(height: 8),
                    Text('1km Away', style: TextStyle(color: AppTheme.textLight)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Notifications will trigger automatically as the garbage truck enters your designated radius.',
          style: TextStyle(color: AppTheme.textLight, fontStyle: FontStyle.italic),
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
          Row(
            children: [
              const Icon(Icons.eco_outlined, color: Colors.lightGreenAccent),
              const SizedBox(width: 8),
              const Text(
                'Why this matters',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('View Impact Statistics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.show_chart, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences() {
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
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.do_not_disturb_on_total_silence, color: AppTheme.textDark),
                title: const Text('Quiet Hours', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Disable alerts after 10 PM'),
                trailing: Checkbox(
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
