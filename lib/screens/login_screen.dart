import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import 'resident_login_screen.dart';
import 'admin_login_screen.dart';
import 'driver_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context, UserRole role) {
    Widget destination;
    switch (role) {
      case UserRole.resident:
        destination = const ResidentLoginScreen();
        break;
      case UserRole.admin:
        destination = const AdminLoginScreen();
        break;
      case UserRole.driver:
        destination = const DriverLoginScreen();
        break;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          children: [
            // ── Green Header (separate) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 107, 86, 1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'EcoTrack',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                 // const SizedBox(height: 6),
                  //Text(
                  //  'Smart Urban Waste Management',
                   // style: TextStyle(
                    //  fontSize: 14,
                      //color: Colors.white.withOpacity(0.8),
                    //),
                  //),
                ],
              ),
            ),

            // ── Sign In green card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 107, 86, 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(0, 107, 86, 1),

                      ),
                    ),
                    const SizedBox(height: 6),
                  Text(
                    'Select Your Role To Continue',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(0, 107, 86, 1),
                    ),
                  ),

                  const SizedBox(height: 50),

                    _AnimatedRoleButton(
                      icon: Icons.person_rounded,
                      label: 'Resident',
                      onTap: () => _navigateToLogin(context, UserRole.resident),
                    ),
                    const SizedBox(height: 40),

                    _AnimatedRoleButton(
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'Admin',
                      onTap: () => _navigateToLogin(context, UserRole.admin),
                    ),
                    const SizedBox(height: 40),

                    _AnimatedRoleButton(
                      icon: Icons.local_shipping_rounded,
                      label: 'Driver',
                      onTap: () => _navigateToLogin(context, UserRole.driver),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated role button with pop-up effect ──
class _AnimatedRoleButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedRoleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_AnimatedRoleButton> createState() => _AnimatedRoleButtonState();
}

class _AnimatedRoleButtonState extends State<_AnimatedRoleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse().then((_) => widget.onTap());
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 107, 86, 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
