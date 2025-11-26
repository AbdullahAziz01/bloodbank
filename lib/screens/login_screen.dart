import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../utils/localization.dart';

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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      // TODO: Connect Firebase Auth for login
      // TODO: Validate credentials with backend
      // TODO: Store user session/token

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.get('loginSuccess')),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to appropriate dashboard
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (widget.role == 'donor') {
          Navigator.of(context).pushReplacementNamed(AppRoutes.donorDashboard);
        } else {
          Navigator.of(context)
              .pushReplacementNamed(AppRoutes.recipientDashboard);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5F5),
              AppTheme.background,
            ],
          ),
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
                    style: AppTheme.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${Localization.get('welcome')} ${Localization.get(widget.role)}',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
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
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'login',
                    onPressed: _handleLogin,
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
                      style: AppTheme.bodyLarge.copyWith(
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

