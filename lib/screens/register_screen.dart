import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../utils/localization.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';
import 'package:geolocator/geolocator.dart';

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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final UserService _userService = UserService();
  String? _selectedBloodGroup;
  bool _obscurePassword = true;
  bool _isLoading = false;

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
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate() && _selectedBloodGroup != null) {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔵 Registration button pressed');
      debugPrint('🔵 Email: ${_emailController.text.trim()}');
      debugPrint('🔵 Name: ${_nameController.text.trim()}');
      debugPrint('🔵 Phone: ${_phoneController.text.trim()}');
      debugPrint('🔵 City: ${_cityController.text.trim()}');
      debugPrint('🔵 Blood Group: $_selectedBloodGroup');
      debugPrint('🔵 Role: ${widget.role}');

      final result = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        bloodGroup: _selectedBloodGroup!,
        role: widget.role,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('🔵 Registration result: ${result['success']}');
      debugPrint('🔵 Registration message: ${result['message']}');

      if (result['success'] == true) {
        if (mounted) {
          debugPrint('✅ Registration successful, getting location...');
          
          // Request and save location
          try {
            Position? position = await _locationService.getCurrentLocation();
            if (position != null) {
              await _userService.updateLocation(position.latitude, position.longitude);
              debugPrint('✅ Location saved during registration');
            }
          } catch (e) {
            debugPrint('⚠️ Could not save location during registration: $e');
            // Continue anyway, don't block registration success
          }

          debugPrint('✅ Showing verification dialog');
          // Show email verification dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Registration Successful!'),
              content: const Text(
                'Please check your email and click the verification link to activate your account.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final verifyResult = await _authService.sendEmailVerification();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(verifyResult['message'] ?? 'Email sent'),
                          backgroundColor: verifyResult['success'] == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text('Resend Email'),
                ),
                TextButton(
                  onPressed: () async {
                    await _authService.logout();
                    if (mounted) {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to login
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        debugPrint('❌ Registration failed: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_selectedBloodGroup == null) {
      debugPrint('⚠️ Blood group not selected');
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
                  const SizedBox(height: 20),
                  Icon(
                    Icons.person_add,
                    size: 64,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Localization.get('register'),
                    style: Theme.of(context).textTheme.displayLarge,
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
                        return 'Please enter a valid email address (e.g., user@example.com)';
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
                      // Pakistan phone number validation: +92 followed by 10 digits
                      final phoneRegex = RegExp(r'^\+92\d{10}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Enter valid Pakistan number (+92 followed by 10 digits)';
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
                    onPressed: _isLoading ? null : _handleRegister,
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      Localization.get('login'),
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

