import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/rounded_card.dart';
import '../utils/localization.dart';

/// User profile screen with settings
class ProfileScreen extends StatefulWidget {
  final String role;

  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _isUrdu = false;

  @override
  void initState() {
    super.initState();
    _isUrdu = Localization.currentLanguage == 'ur';
  }

  void _toggleLanguage() {
    setState(() {
      _isUrdu = !_isUrdu;
      Localization.setLanguage(_isUrdu ? 'ur' : 'en');
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      // TODO: Implement dark mode theme switching
      // TODO: Save preference to SharedPreferences or backend
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch real user data from Firestore
    // TODO: Load user profile image
    // TODO: Implement edit profile functionality

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.gradientStart,
              AppTheme.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        Localization.get('profile'),
                        style: AppTheme.heading2.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // TODO: Navigate to edit profile screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(Localization.get('editProfile')),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Profile Card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // User Info Card
                        RoundedCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'John Doe', // TODO: Replace with real name
                                style: AppTheme.heading2,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bloodtype,
                                    size: 20,
                                    color: AppTheme.primaryRed,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'A+', // TODO: Replace with real blood group
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: AppTheme.primaryRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: AppTheme.borderColor),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.location_on,
                                Localization.get('city'),
                                'Islamabad', // TODO: Replace with real city
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.phone,
                                Localization.get('phoneNumber'),
                                '+92 300 1234567', // TODO: Replace with real phone
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.email,
                                Localization.get('email'),
                                'user@example.com', // TODO: Replace with real email
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Settings Card
                        RoundedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settings',
                                style: AppTheme.heading3,
                              ),
                              const SizedBox(height: 20),
                              _buildSettingTile(
                                icon: Icons.language,
                                title: Localization.get('language'),
                                subtitle: _isUrdu
                                    ? Localization.get('urdu')
                                    : Localization.get('english'),
                                trailing: Switch(
                                  value: _isUrdu,
                                  onChanged: (_) => _toggleLanguage(),
                                  activeThumbColor: AppTheme.primaryRed,
                                ),
                              ),
                              Divider(color: AppTheme.borderColor),
                              _buildSettingTile(
                                icon: Icons.dark_mode,
                                title: Localization.get('darkMode'),
                                subtitle: 'Toggle dark theme',
                                trailing: Switch(
                                  value: _isDarkMode,
                                  onChanged: (_) => _toggleDarkMode(),
                                  activeThumbColor: AppTheme.primaryRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Actions Card
                        RoundedCard(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.edit,
                                  color: AppTheme.primaryRed,
                                ),
                                title: Text(Localization.get('editProfile')),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () {
                                  // TODO: Navigate to edit profile screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(Localization.get('editProfile')),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                },
                              ),
                              Divider(color: AppTheme.borderColor),
                              ListTile(
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  Localization.get('logout'),
                                  style: const TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  // TODO: Clear user session
                                  // TODO: Sign out from Firebase
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                    AppRoutes.selectRole,
                                    (route) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryRed),
      title: Text(title, style: AppTheme.bodyLarge),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}

