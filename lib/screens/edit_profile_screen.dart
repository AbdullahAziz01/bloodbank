import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../utils/localization.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _emailController;
  late TextEditingController _lastDonationController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _cityController = TextEditingController(text: widget.userData['city']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _lastDonationController = TextEditingController(text: widget.userData['lastDonation'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _lastDonationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _firestoreService.updateUserProfile(uid, {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'city': _cityController.text.trim(),
          'email': _emailController.text.trim(),
          if (widget.userData['role'] == 'donor') 
            'lastDonation': _lastDonationController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Localization.get('profileUpdated')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate update
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('editProfile')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color), // Adapt for theme
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: Localization.get('fullName'),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: Localization.get('phoneNumber'),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: Localization.get('city'),
                  prefixIcon: const Icon(Icons.location_city),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your city' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: Localization.get('email'),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              if (widget.userData['role'] == 'donor') ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme,
                            dialogBackgroundColor: Theme.of(context).cardTheme.color,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                         // Format as YYYY-MM-DD
                        _lastDonationController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _lastDonationController,
                      decoration: InputDecoration(
                        labelText: Localization.get('lastDonation'),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(Localization.get('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
