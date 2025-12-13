import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../utils/localization.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

/// Login screen with email and password
class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔵 Login button pressed');
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('🔵 Login result: ${result['success']}');
      if (result['success'] == true) {
        // Get user data to check role
        final user = result['user'];
        if (user != null) {
          try {
            debugPrint('🔵 User logged in, checking verification status...');
            // Reload user to get latest verification status
            await _authService.reloadUser();

            // Update location on login
            debugPrint('🔵 Updating location on login...');
            await _locationService.updateUserLocationOnLogin();
            
            // Check if email is verified (OPTIONAL - can be disabled for testing)
            final isVerified = _authService.isEmailVerified();
            debugPrint('🔵 Email verified: $isVerified');
            
            // TEMPORARILY DISABLED: Email verification check for testing
            // Uncomment the block below to re-enable email verification requirement
            /*
            if (!isVerified) {
              if (mounted) {
                debugPrint('⚠️ Email not verified, showing dialog');
                _showEmailVerificationDialog();
              }
              return;
            }
            */

            debugPrint('🔵 Fetching user profile from Firestore...');
            // Get user model for type-safe access
            final userModel = await _authService.getUserModel(user.uid);
            final userRole = userModel?.role ?? widget.role;
            debugPrint('🔵 User role: $userRole');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Localization.get('loginSuccess')),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to appropriate dashboard based on actual role
              debugPrint('🔵 Navigating to dashboard for role: $userRole');
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                if (userRole == 'donor') {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.donorDashboard);
                } else {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.recipientDashboard);
                }
              });
            }
          } catch (e) {
            debugPrint('❌ Error fetching user data: $e');
            // Fallback to widget role if error
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Localization.get('loginSuccess')),
                  backgroundColor: Colors.green,
                ),
              );
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                debugPrint('🔵 Using fallback role: ${widget.role}');
                if (widget.role == 'donor') {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.donorDashboard);
                } else {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.recipientDashboard);
                }
              });
            }
          }
        }
      } else {
        debugPrint('❌ Login failed: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? Localization.get('invalidCredentials')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.bloodtype,
                    size: 64,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Localization.get('login'),
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${Localization.get('welcome')} ${Localization.get(widget.role)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: Localization.get('email'),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Localization.get('fillAllFields');
                      }
                      // Proper email validation with regex
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email (e.g., user@example.com)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: Localization.get('password'),
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Localization.get('fillAllFields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'login',
                    onPressed: _isLoading ? null : _handleLogin,
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.register,
                        arguments: widget.role,
                      );
                    },
                    child: Text(
                      Localization.get('register'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

