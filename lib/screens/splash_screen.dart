import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _truckController;
  late AnimationController _pulseController;

  bool _navigated = false;

  // Truck drive-in animation
  late Animation<Offset> _truckSlide;
  late Animation<double> _truckFade;

  // Logo circle scale
  late Animation<double> _circleScale;

  // Text animations
  late Animation<double> _welcomeFade;
  late Animation<Offset> _welcomeSlide;

  late Animation<double> _ecoFade;
  late Animation<Offset> _ecoSlide;

  late Animation<double> _trackFade;
  late Animation<Offset> _trackSlide;

  // Tagline
  late Animation<double> _taglineFade;

  // Pulse glow on the truck icon
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // ── Main staggered controller (2.5s) ──
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // ── Truck bounce controller ──
    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // ── Pulse controller (repeating) ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 0.0 – 0.3: Circle scales up
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    // 0.1 – 0.4: Truck slides in from left and fades in
    _truckSlide = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _truckFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.35, curve: Curves.easeIn),
      ),
    );

    // 0.35 – 0.55: "Welcome To" fades + slides up
    _welcomeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );
    _welcomeSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 0.45 – 0.65: "Eco" fades + slides up
    _ecoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.65, curve: Curves.easeOut),
      ),
    );
    _ecoSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // 0.55 – 0.75: "Track" fades + slides up
    _trackFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );
    _trackSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 0.7 – 0.9: Tagline fades in
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOut),
      ),
    );

    // Pulse animation
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _mainController.forward();

    // Start truck bounce after a small delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _truckController.repeat(reverse: true);
      }
    });

    // Start pulse after truck arrives
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _goToLogin() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _truckController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(0, 107, 86, 1),
              Color.fromRGBO(0, 77, 62, 1),
              Color.fromRGBO(0, 54, 44, 1),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _mainController,
            _truckController,
            _pulseController,
          ]),
          builder: (context, _) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // ── Truck Logo ──
                  ScaleTransition(
                    scale: _circleScale,
                    child: ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: SlideTransition(
                          position: _truckSlide,
                          child: FadeTransition(
                            opacity: _truckFade,
                            child: const Icon(
                              Icons.local_shipping_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── "Welcome To" ──
                  SlideTransition(
                    position: _welcomeSlide,
                    child: FadeTransition(
                      opacity: _welcomeFade,
                      child: Text(
                        'Welcome To',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── "Eco Track" ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _ecoSlide,
                        child: FadeTransition(
                          opacity: _ecoFade,
                          child: const Text(
                            'Eco',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SlideTransition(
                        position: _trackSlide,
                        child: FadeTransition(
                          opacity: _trackFade,
                          child: Text(
                            'Track',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: Colors.greenAccent.shade200,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Tagline ──
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      'Smart Urban Waste Management',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Get Started FAB ──
                  FadeTransition(
                    opacity: _taglineFade,
                    child: GestureDetector(
                      onTap: _goToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(0, 107, 86, 1),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Color.fromRGBO(0, 107, 86, 1),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
