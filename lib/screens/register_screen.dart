import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../utils/localization.dart';

/// Registration screen with user details
class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBloodGroup;
  bool _obscurePassword = true;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate() && _selectedBloodGroup != null) {
      // TODO: Connect Firebase Auth for registration
      // TODO: Store user data in Firestore
      // TODO: Send verification email
      // TODO: Add user profile image upload

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.get('registerSuccess')),
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
    } else if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.get('fillAllFields')),
          backgroundColor: Colors.red,
        ),
      );
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
                  const SizedBox(height: 20),
                  Icon(
                    Icons.person_add,
                    size: 64,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Localization.get('register'),
                    style: AppTheme.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: Localization.get('fullName'),
                      prefixIcon: const Icon(Icons.person_outlined),
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
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: Localization.get('phoneNumber'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Localization.get('fillAllFields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBloodGroup,
                    decoration: InputDecoration(
                      labelText: Localization.get('selectBloodGroup'),
                      prefixIcon: const Icon(Icons.bloodtype),
                    ),
                    items: _bloodGroups.map((String group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedBloodGroup = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return Localization.get('fillAllFields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: Localization.get('city'),
                      prefixIcon: const Icon(Icons.location_city_outlined),
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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'register',
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      Localization.get('login'),
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

