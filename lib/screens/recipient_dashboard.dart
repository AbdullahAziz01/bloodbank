import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/donor_item.dart';
import '../utils/localization.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

/// Recipient dashboard showing available donors
class RecipientDashboard extends StatefulWidget {
  const RecipientDashboard({super.key});

  @override
  State<RecipientDashboard> createState() => _RecipientDashboardState();
}

class _RecipientDashboardState extends State<RecipientDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  String? _selectedBloodGroup;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (mounted && position != null) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

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

  List<Map<String, dynamic>> _filterDonors(List<Map<String, dynamic>> donors) {
    if (_selectedBloodGroup == null || _selectedBloodGroup == 'All') {
      return donors;
    }
    return donors
        .where((donor) => donor['bloodGroup'] == _selectedBloodGroup)
        .toList();
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
                      icon: const Icon(Icons.map, color: Colors.white),
                      tooltip: 'View Map',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.map);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.list_alt, color: Colors.white),
                      tooltip: 'Your Requests',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.myRequests);
                      },
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedBloodGroup ?? 'All',
                        isExpanded: true,
                        dropdownColor: Theme.of(context).cardTheme.color,
                        style: Theme.of(context).textTheme.bodyMedium,
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firestoreService.getDonorsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading donors',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final allDonors = snapshot.data ?? [];
                      final donors = _filterDonors(allDonors);

                      if (donors.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No donors found',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: donors.length,
                        itemBuilder: (context, index) {
                          try {
                            final donor = donors[index];
                            final isAvailable = (donor['isAvailable'] ?? false) as bool;
                            
                            // Calculate real distance if we have current location and donor location
                            double distanceKm = (donor['distanceKm'] ?? 0.0) as double;
                            if (_currentPosition != null && donor['lat'] != null && donor['lng'] != null) {
                                distanceKm = LocationService().calculateDistanceInKm(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                  (donor['lat'] as num).toDouble(),
                                  (donor['lng'] as num).toDouble(),
                                );
                            }

                            return DonorItem(
                              name: (donor['name'] ?? 'Unknown') as String,
                              bloodGroup: (donor['bloodGroup'] ?? 'N/A') as String,
                              distanceKm: distanceKm,
                              city: (donor['city'] ?? 'Unknown') as String,
                              isAvailable: isAvailable,
                              phone: (donor['phone'] ?? 'N/A') as String,
                              lastDonation: (donor['lastDonation'] ?? 'Unknown') as String,
                              onContact: isAvailable
                                  ? () {
                                      // Create a copy of donor data with updated distance
                                      final updatedDonor = Map<String, dynamic>.from(donor);
                                      updatedDonor['distanceKm'] = distanceKm;
                                      _showDonorDetails(updatedDonor);
                                    }
                                  : null,
                            );
                          } catch (e) {
                            // Handle any data parsing errors gracefully
                            return const SizedBox.shrink();
                          }
                        },
                      );
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
          color: Theme.of(context).cardTheme.color,
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
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await _authService.logout();
                    if (!mounted) return;
                    navigator.pushNamedAndRemoveUntil(
                      AppRoutes.selectRole,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(Localization.get('logout')),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDonorDetails(Map<String, dynamic> donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    donor['bloodGroup'] ?? '?',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor['name'] ?? 'Unknown Donor',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                          const SizedBox(width: 4),
                          Text(
                            '${donor['city'] ?? 'Unknown'} • ${donor['distanceKm']?.toStringAsFixed(1) ?? '0'} km away',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoRow(
              Icons.email_outlined,
              Localization.get('email'),
              donor['email'] ?? 'Not available',
              onTap: donor['email'] != null 
                  ? () => _launchUrl('mailto:${donor['email']}')
                  : null,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.phone_outlined,
              Localization.get('phoneNumber'),
              donor['phone'] ?? 'Not available',
              onTap: donor['phone'] != null 
                  ? () => _launchUrl('tel:${donor['phone']}')
                  : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: donor['phone'] != null 
                    ? () => _launchUrl('tel:${donor['phone']}')
                    : null,
                icon: const Icon(Icons.call),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[800] 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: onTap != null ? AppTheme.primaryRed : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch details')),
        );
      }
    }
  }
}

