import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/rounded_card.dart';
import '../utils/localization.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
// themeNotifier is now exposed by theme_service.dart


/// User profile screen with settings
class ProfileScreen extends StatefulWidget {
  final String role;

  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();
  Map<String, dynamic>? _userData;
  bool _isUrdu = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isUrdu = Localization.currentLanguage == 'ur';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _authService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isUrdu = !_isUrdu;
      Localization.setLanguage(_isUrdu ? 'ur' : 'en');
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final isDark = await _themeService.toggleTheme(); 
    themeNotifier.value = isDark;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

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
                      onPressed: () async {
                        if (_userData != null) {
                          debugPrint('Navigating to Edit Profile with data: $_userData');
                          final result = await Navigator.of(context).pushNamed(
                            AppRoutes.editProfile,
                            arguments: _userData,
                          );
                          if (result == true) {
                            debugPrint('Edit Profile returned true, reloading data...');
                            _loadUserData();
                          }
                        } else {
                          debugPrint('Cannot navigate to Edit Profile: _userData is null');
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Profile Card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
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
                                _userData?['name'] ?? 'User',
                                style: Theme.of(context).textTheme.displayMedium,
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
                                    _userData?['bloodGroup'] ?? 'N/A',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.primaryRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Theme.of(context).dividerColor),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.location_on,
                                Localization.get('city'),
                                _userData?['city'] ?? 'Unknown',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.phone,
                                Localization.get('phoneNumber'),
                                _userData?['phone'] ?? 'N/A',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.email,
                                Localization.get('email'),
                                _userData?['email'] ?? 'N/A',
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
                                style: Theme.of(context).textTheme.displaySmall,
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
                              Divider(color: Theme.of(context).dividerColor),
                              _buildSettingTile(
                                icon: Icons.dark_mode,
                                title: Localization.get('darkMode'),
                                subtitle: 'Toggle dark theme',
                                trailing: Switch(
                                  value: Theme.of(context).brightness == Brightness.dark,
                                  onChanged: _toggleDarkMode,
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
                              if (widget.role == 'recipient') ...[
                                ListTile(
                                  leading: const Icon(
                                    Icons.list_alt,
                                    color: AppTheme.primaryRed,
                                  ),
                                  title: Text('My Requests', style: Theme.of(context).textTheme.bodyLarge),
                                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(AppRoutes.myRequests);
                                  },
                                ),
                                Divider(color: Theme.of(context).dividerColor),
                              ],
                                ListTile(
                                  leading: const Icon(
                                    Icons.edit,
                                    color: AppTheme.primaryRed,
                                  ),
                                  title: Text(Localization.get('editProfile'), style: Theme.of(context).textTheme.bodyLarge),
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Theme.of(context).iconTheme.color),
                                  onTap: () async {
                                    if (_userData != null) {
                                      final result = await Navigator.of(context).pushNamed(
                                        AppRoutes.editProfile,
                                        arguments: _userData,
                                      );
                                      if (result == true) {
                                        _loadUserData(); // Reload data if updated
                                      }
                                    }
                                  },
                                ),
                              Divider(color: Theme.of(context).dividerColor),
                              ListTile(
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  Localization.get('logout'),
                                  style: const TextStyle(color: Colors.red),
                                ),
                                onTap: () async {
                                  final navigator = Navigator.of(context);
                                  await _authService.logout();
                                  if (!mounted) return;
                                  navigator.pushNamedAndRemoveUntil(
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
        Icon(icon, size: 20, color: Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}
