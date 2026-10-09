import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/collection_service.dart';
import '../models/collection_model.dart';
import '../utils/translations.dart';
import 'login_screen.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Sinhala', 'Tamil'];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, color: AppTheme.darkGreen),
            const SizedBox(width: 8),
            Text(
              Translations.t('My Profile', _selectedLanguage),
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
          _buildProfileCard(user),
          const SizedBox(height: 24),
          _buildRouteDetailsSection(user),
          const SizedBox(height: 24),
          _buildAppPreferences(context),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {
                AuthService().logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                Translations.t('Sign Out from EcoTrack', _selectedLanguage),
                style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(user) {
    final name = user?.name ?? Translations.t('Driver', _selectedLanguage);
    final truckId = user?.truckId ?? Translations.t('Not assigned', _selectedLanguage);
    final zone = user?.zone ?? Translations.t('Not assigned', _selectedLanguage);

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
                      '${Translations.t('Driver', _selectedLanguage)} $name',
                      style: const TextStyle(color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.bold),
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
                          Text(
                            '${Translations.t('Truck', _selectedLanguage)}: $truckId',
                            style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${Translations.t('Zone', _selectedLanguage)}: $zone',
                            style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
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

  Widget _buildRouteDetailsSection(user) {
    final driverId = user?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Translations.t('TODAY\'S ROUTE DETAILS', _selectedLanguage),
              style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                Translations.t('ACTIVE', _selectedLanguage),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<CollectionSchedule>>(
          stream: CollectionService().getDriverCollections(driverId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final collections = snapshot.data ?? [];
            if (collections.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen, width: 2),
                ),
                child: Center(
                  child: Text(
                    Translations.t('No routes assigned for today.', _selectedLanguage),
                    style: const TextStyle(color: AppTheme.textLight),
                  ),
                ),
              );
            }

            final route = collections.first;
            return Container(
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
                      Text(
                        route.routeName,
                        style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...route.stops.map((stop) => _buildRouteStop(
                    stop.time,
                    stop.title,
                    stop.location,
                    stop.isCompleted,
                  )),
                ],
              ),
            );
          },
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
        Text(
          Translations.t('APP PREFERENCES', _selectedLanguage),
          style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
                title: Text(Translations.t('Language', _selectedLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(Translations.t('Preferred interface language', _selectedLanguage)),
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
                leading: const Icon(Icons.dark_mode_outlined, color: AppTheme.textDark),
                title: Text(Translations.t('App Theme', _selectedLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(Translations.t('Switch between light and dark', _selectedLanguage)),
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
