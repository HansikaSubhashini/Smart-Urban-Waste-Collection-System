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
            const Icon(Icons.drive_eta, color: AppTheme.darkGreen),
            const SizedBox(width: 8),
            Text(
              'EcoTrack Driver',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 80, color: AppTheme.primaryGreen.withOpacity(0.5)),
            const SizedBox(height: 24),
            const Text(
              'Driver Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your routes and assignments will appear here.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
