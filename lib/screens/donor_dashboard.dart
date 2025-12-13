import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/request_item.dart';
import '../utils/localization.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

/// Donor dashboard showing blood requests near them
class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  // ignore: unused_field
  final LocationService _locationService = LocationService();
  
  Map<String, dynamic>? _userData;
  Position? _currentPosition;
  String _selectedFilter = 'All Requests'; // 'All Requests' or 'My Group'
  String? _selectedUrgency; // 'Critical', 'High', 'Moderate', 'All' or null

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _determinePosition();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _authService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userData = data;
        });
      }
    }
  }

  Future<void> _determinePosition() async {
    try {
      final position = await LocationService().getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _showContactSheet(BuildContext context, String name, String phone, String email) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact Recipient',
                style: AppTheme.heading2,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppTheme.primaryRed),
                ),
                title: Text(name),
                subtitle: const Text('Recipient'),
              ),
              const Divider(),
              if (phone.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: Text(phone),
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: phone,
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    }
                  },
                ),
              if (email.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: Text(email),
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'mailto',
                      path: email,
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    }
                  },
                ),
              if (phone.isEmpty && email.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No contact information provided.'),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryRed : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyChip(String urgency) {
    bool isSelected = _selectedUrgency == urgency;
    Color chipColor;
    
    switch (urgency) {
      case 'Critical': chipColor = Colors.red.shade900; break;
      case 'High': chipColor = Colors.red; break;
      case 'Moderate': chipColor = Colors.orange; break;
      default: chipColor = Colors.grey;
    }

    if (urgency == 'All') chipColor = Colors.blueGrey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUrgency = urgency;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          urgency,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
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
                            '${Localization.get('welcome')}, ${_userData?['name'] ?? 'Donor'}',
                            style: AppTheme.heading2.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
                      icon: const Icon(Icons.map, color: Colors.white),
                      tooltip: 'View Requests Map',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.map);
                      },
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
              // Filter Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Blood Group Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFilterTab('All Requests', _selectedFilter == 'All Requests'),
                          ),
                          Expanded(
                            child: _buildFilterTab('My Group', _selectedFilter == 'My Group'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Urgency Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            '${Localization.get('urgency')}: ',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          _buildUrgencyChip('All'),
                          const SizedBox(width: 8),
                          _buildUrgencyChip('Critical'),
                          const SizedBox(width: 8),
                          _buildUrgencyChip('High'),
                          const SizedBox(width: 8),
                          _buildUrgencyChip('Moderate'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Requests List
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
                    stream: _firestoreService.getBloodRequestsStream(),
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
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading requests',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final requests = snapshot.data ?? [];

                      // Filter logic
                      final filteredRequests = requests.where((req) {
                        // 1. Status Filter - Show active and solved
                        
                        // 2. Blood Group Filter
                        if (_selectedFilter == 'My Group' && _userData != null && _userData!['bloodGroup'] != null) {
                           if (req['bloodGroup'] != _userData!['bloodGroup']) {
                             return false;
                           }
                        }

                        // 3. Urgency Filter
                        if (_selectedUrgency != 'All' && _selectedUrgency != null) {
                          if (req['urgency'] != _selectedUrgency) {
                            return false;
                          }
                        }

                        return true;
                      }).toList();

                      if (filteredRequests.isEmpty) {
                        return Center(
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
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          try {
                            final request = filteredRequests[index];
                            final status = request['status'] ?? 'active';
                            final isSolved = status == 'solved';
                            
                            // Calculate real distance
                            double distanceKm = (request['distanceKm'] ?? 0.0) as double;
                            if (_currentPosition != null && request['lat'] != null && request['lng'] != null) {
                                distanceKm = LocationService().calculateDistanceInKm(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                  (request['lat'] as num).toDouble(),
                                  (request['lng'] as num).toDouble(),
                                );
                            }

                            return RequestItem(
                              name: (request['recipientName'] ?? request['name'] ?? 'Unknown') as String,
                              bloodGroup: (request['bloodGroup'] ?? 'N/A') as String,
                              units: (request['units'] ?? 0) as int,
                              distanceKm: distanceKm,
                              city: (request['recipientCity'] ?? request['city'] ?? 'Unknown') as String,
                              urgency: (request['urgency'] ?? 'Medium') as String,
                              hospital: (request['hospital'] ?? 'Unknown Hospital') as String,
                              note: (request['note'] ?? '') as String,
                              timeAgo: (request['timeAgo'] ?? 'Unknown') as String,
                              status: status,
                              onContact: isSolved ? null : () {
                                _showContactSheet(
                                  context, 
                                  request['recipientName'] as String? ?? 'Recipient',
                                  request['recipientPhone'] as String? ?? '',
                                  request['recipientEmail'] as String? ?? '',
                                );
                              },
                            );
                          } catch (e) {
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
