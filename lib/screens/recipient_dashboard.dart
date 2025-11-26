import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/donor_item.dart';
import '../utils/mock_data.dart';
import '../utils/localization.dart';

/// Recipient dashboard showing available donors
class RecipientDashboard extends StatefulWidget {
  const RecipientDashboard({super.key});

  @override
  State<RecipientDashboard> createState() => _RecipientDashboardState();
}

class _RecipientDashboardState extends State<RecipientDashboard> {
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  List<Map<String, dynamic>> get _filteredDonors {
    // TODO: Fetch real donors from Firestore
    // TODO: Filter by location using geolocation
    // TODO: Filter by blood group compatibility
    // TODO: Sort by distance

    if (_selectedBloodGroup == null || _selectedBloodGroup == 'All') {
      return MockData.donors;
    }
    return MockData.donors
        .where((donor) => donor['bloodGroup'] == _selectedBloodGroup)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final donors = _filteredDonors;

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
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bloodtype,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Localization.get('findDonors'),
                            style: AppTheme.heading2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.profile,
                          arguments: 'recipient',
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Filter Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      '${Localization.get('bloodGroup')}:',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedBloodGroup ?? 'All',
                        isExpanded: true,
                        dropdownColor: AppTheme.cardBackground,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                        underline: const SizedBox(),
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Donors List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: donors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                size: 64,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No donors found',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: donors.length,
                          itemBuilder: (context, index) {
                            try {
                              final donor = donors[index];
                              final isAvailable = (donor['isAvailable'] ?? false) as bool;
                              return DonorItem(
                                name: (donor['name'] ?? 'Unknown') as String,
                                bloodGroup: (donor['bloodGroup'] ?? 'N/A') as String,
                                distanceKm: (donor['distanceKm'] ?? 0.0) as double,
                                city: (donor['city'] ?? 'Unknown') as String,
                                isAvailable: isAvailable,
                                phone: (donor['phone'] ?? 'N/A') as String,
                                lastDonation: (donor['lastDonation'] ?? 'Unknown') as String,
                                onContact: isAvailable
                                    ? () {
                                        // TODO: Open contact dialog/phone call
                                        // TODO: Send notification to donor
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${Localization.get('contact')} ${donor['name'] ?? 'Donor'}',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                              );
                            } catch (e) {
                              // Handle any data parsing errors gracefully
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.postRequest);
        },
        backgroundColor: AppTheme.primaryRed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          Localization.get('postRequest'),
          style: AppTheme.buttonText,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.profile,
                      arguments: 'recipient',
                    );
                  },
                  icon: const Icon(Icons.person_outline),
                  label: Text(Localization.get('profile')),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryRed,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Clear user session
                    // TODO: Sign out from Firebase
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.selectRole,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(Localization.get('logout')),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

