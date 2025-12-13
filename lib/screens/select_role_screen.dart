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
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Localization.get('selectRole'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
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

