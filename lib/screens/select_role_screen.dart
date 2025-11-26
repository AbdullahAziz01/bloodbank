import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/role_card.dart';
import '../utils/localization.dart';

/// Role selection screen (Donor or Recipient)
class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
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
              Color(0xFFF8F9FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bloodtype,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Localization.get('appTitle'),
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Localization.get('selectRole'),
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          RoleCard(
                            role: 'donor',
                            description: 'donorDesc',
                            icon: Icons.favorite,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.login,
                                arguments: 'donor',
                              );
                            },
                          ),
                          RoleCard(
                            role: 'recipient',
                            description: 'recipientDesc',
                            icon: Icons.local_hospital,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.login,
                                arguments: 'recipient',
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
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

