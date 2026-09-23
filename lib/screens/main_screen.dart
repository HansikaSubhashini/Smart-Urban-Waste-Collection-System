import 'package:flutter/material.dart';
import '../models/user_role.dart';
import 'home_dashboard.dart';
import 'resident_dashboard.dart';
import 'driver_dashboard.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'map_screen.dart';

class MainScreen extends StatefulWidget {
  final UserRole userRole;

  const MainScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _setupScreensAndNav();
  }

  void _setupScreensAndNav() {
    switch (widget.userRole) {
      case UserRole.admin:
        _screens = [
          const HomeDashboard(), // Admin Dashboard (renamed conceptually)
          const MapScreen(),
          const ReportsScreen(),
          const ProfileScreen(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
        break;
      case UserRole.driver:
        _screens = [
          const MapScreen(),
          const DriverDashboard(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
        break;
      case UserRole.resident:
      default:
        _screens = [
          const ResidentDashboard(),
          const MapScreen(),
          const ReportsScreen(),
          const ProfileScreen(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_outlined),
            activeIcon: Icon(Icons.report_problem),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}
