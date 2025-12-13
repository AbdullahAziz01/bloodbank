import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../theme.dart';
import '../utils/localization.dart';
import '../widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final UserService _userService = UserService();
  final FirestoreService _firestoreService = FirestoreService();
  
  Set<Marker> _markers = {};
  Set<Marker> _donorMarkers = {};
  Set<Marker> _requestMarkers = {};
  
  Position? _currentPosition;
  double _radiusKm = 10.0;
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadDonors();
    await _loadRequests();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
      _updateUserMarker();
    }
  }

  Future<void> _loadDonors() async {
    if (_currentPosition == null) return;

    final donors = await _userService.getNearbyDonors(
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
      radiusKm: _radiusKm,
      bloodGroup: _selectedBloodGroup == 'All' ? null : _selectedBloodGroup,
    );

    setState(() {
      _donorMarkers = donors.map((donor) {
        return Marker(
          markerId: MarkerId(donor.uid),
          position: LatLng(donor.lat ?? 0.0, donor.lng ?? 0.0),
          infoWindow: InfoWindow(
            title: donor.name,
            snippet: '${donor.bloodGroup} - ${_formatDistance(donor)}',
            onTap: () {
              _showDonorDetails(donor);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).toSet();
      
      _updateAllMarkers();
    });
  }

  Future<void> _loadRequests() async {
    if (_currentPosition == null) return;

    try {
      final requestsStream = _firestoreService.getBloodRequestsStream();
      final requests = await requestsStream.first;

      setState(() {
        _requestMarkers = requests.where((req) {
            // Filter by active status
            final isActive = req['status'] == 'active';
            // Filter by radius
            final lat = req['lat'] as double?;
            final lng = req['lng'] as double?;
            if (lat == null || lng == null) return false;
            
            final distance = _locationService.calculateDistanceInKm(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              lat,
              lng,
            );
            return isActive && distance <= _radiusKm;
        }).map((req) {
          final lat = req['lat'] as double;
          final lng = req['lng'] as double;
          return Marker(
            markerId: MarkerId(req['id']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: 'Request: ${req['bloodGroup']}',
              snippet: '${req['urgency']} - ${req['hospital']}',
              onTap: () {
                _showRequestDetails(req);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          );
        }).toSet();
        
        _updateAllMarkers();
      });
    } catch (e) {
      debugPrint('Error loading requests on map: $e');
    }
  }

  void _updateAllMarkers() {
    setState(() {
      _markers = {..._donorMarkers, ..._requestMarkers};
      _updateUserMarker();
    });
  }

  void _updateUserMarker() {
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_user'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  String _formatDistance(UserModel donor) {
    if (_currentPosition == null || donor.lat == null || donor.lng == null) return '';
    
    final distance = _locationService.calculateDistanceInKm(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      donor.lat!,
      donor.lng!,
    );
    
    return '${distance.toStringAsFixed(1)} km away';
  }

  void _showDonorDetails(UserModel donor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryRed,
                  radius: 30,
                  child: Text(
                    donor.bloodGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        _formatDistance(donor),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.email, donor.email),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, donor.phone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, donor.city),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Call',
                    onPressed: () async {
                      final url = Uri.parse('tel:${donor.phone}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 30,
                  child: Text(
                    request['bloodGroup'] ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request for ${request['bloodGroup']}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
                      ),
                      Text(
                        '${request['hospital']} • ${request['urgency']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              request['message'] ?? 'No additional details',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Contact Recipient',
                onPressed: () async {
                  final phone = request['recipientPhone'];
                  if (phone != null) {
                    final url = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('No phone number available')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
        const SizedBox(width: 12),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('findDonors')),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 12,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedBloodGroup ?? 'All',
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: Theme.of(context).cardTheme.color,
                      style: Theme.of(context).textTheme.bodyMedium,
                      items: _bloodGroups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodGroup = value;
                        });
                        _loadDonors();
                        _loadRequests();
                      },
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Theme.of(context).dividerColor,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Text(
                    '${_radiusKm.toInt()} km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: _radiusKm,
                    min: 5,
                    max: 50,
                    divisions: 10,
                    activeColor: AppTheme.primaryRed,
                    onChanged: (value) {
                      setState(() {
                        _radiusKm = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _loadDonors();
                      _loadRequests();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
