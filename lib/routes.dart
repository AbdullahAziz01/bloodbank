import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/select_role_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/donor_dashboard.dart';
import 'screens/recipient_dashboard.dart';
import 'screens/post_request_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart';
import 'screens/my_requests_screen.dart';
import 'screens/edit_profile_screen.dart';

/// App routing configuration with animated transitions
class AppRoutes {
  static const String splash = '/';
  static const String selectRole = '/selectRole';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String donorDashboard = '/donorDashboard';
  static const String recipientDashboard = '/recipientDashboard';
  static const String postRequest = '/postRequest';
  static const String profile = '/profile';
  static const String map = '/map';
  static const String myRequests = '/my-requests';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    String? role;

    // Safe type checking for route arguments
    if (args != null && args is String) {
      role = args;
    }

    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case selectRole:
        return _buildRoute(const SelectRoleScreen(), settings);

      case login:
        return _buildRoute(
          LoginScreen(role: role ?? ''),
          settings,
        );

      case register:
        return _buildRoute(
          RegisterScreen(role: role ?? ''),
          settings,
        );

      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      case donorDashboard:
        return _buildRoute(const DonorDashboard(), settings);

      case recipientDashboard:
        return _buildRoute(const RecipientDashboard(), settings);

      case postRequest:
        return _buildRoute(const PostRequestScreen(), settings);

      case profile:
        return _buildRoute(
          ProfileScreen(role: role ?? ''),
          settings,
        );

      case map:
        return _buildRoute(const MapScreen(), settings);

      case myRequests:
        return _buildRoute(const MyRequestsScreen(), settings);

      case editProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(EditProfileScreen(userData: args), settings);

      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
          settings,
        );
    }
  }

  // Custom animated route builder
  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
