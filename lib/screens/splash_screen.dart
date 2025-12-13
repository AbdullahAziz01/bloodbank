import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../routes.dart';
import '../theme.dart';
import '../utils/localization.dart';
import '../services/auth_service.dart';

/// Splash screen with animated logo and auto-navigation
/// Checks auth state and redirects accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Check auth state and navigate accordingly
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // User is logged in, get their role and navigate to dashboard
        try {
          final userData = await _authService.getUserData(user.uid);
          final role = userData?['role'] as String? ?? 'donor';
          
          if (mounted) {
            final navigator = Navigator.of(context);
            if (role == 'donor') {
              navigator.pushReplacementNamed(AppRoutes.donorDashboard);
            } else {
              navigator.pushReplacementNamed(AppRoutes.recipientDashboard);
            }
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
          // If error, go to select role
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.selectRole);
          }
        }
      } else {
        // User not logged in, go to select role
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.selectRole);
        }
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
      // On any error, go to select role
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.selectRole);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bloodtype,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    Localization.get('appTitle'),
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Localization.get('tagline'),
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

