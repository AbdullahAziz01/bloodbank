import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/request_item.dart';
import '../utils/mock_data.dart';
import '../utils/localization.dart';

/// Donor dashboard showing blood requests near them
class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  @override
  Widget build(BuildContext context) {
    // TODO: Fetch real requests from Firestore based on user location
    // TODO: Implement geolocation for distance calculation
    // TODO: Add push notifications for new requests
    // TODO: Filter requests by blood group compatibility

    final requests = MockData.requests;

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
                            '${Localization.get('welcome')}, Donor',
                            style: AppTheme.heading2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            Localization.get('requestsNearYou'),
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
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
                          arguments: 'donor',
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Requests List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: requests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No requests found',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            try {
                              final request = requests[index];
                              return RequestItem(
                                name: (request['name'] ?? 'Unknown') as String,
                                bloodGroup: (request['bloodGroup'] ?? 'N/A') as String,
                                units: (request['units'] ?? 0) as int,
                                distanceKm: (request['distanceKm'] ?? 0.0) as double,
                                city: (request['city'] ?? 'Unknown') as String,
                                urgency: (request['urgency'] ?? 'Medium') as String,
                                hospital: (request['hospital'] ?? 'Unknown Hospital') as String,
                                note: (request['note'] ?? '') as String,
                                timeAgo: (request['timeAgo'] ?? 'Unknown') as String,
                                onContact: () {
                                  // TODO: Open contact dialog/phone call
                                  // TODO: Send notification to recipient
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${Localization.get('contact')} ${request['hospital'] ?? 'Hospital'}',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
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
                      arguments: 'donor',
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

