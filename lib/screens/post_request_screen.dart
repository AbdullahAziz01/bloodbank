import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme.dart';
import '../utils/localization.dart';
import '../widgets/primary_button.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _messageController = TextEditingController();
  final _hospitalController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isLoading = false;
  String? _selectedBloodGroup;
  int _units = 1; // Default to 1 unit
  String _urgency = 'High';
  Position? _currentPosition;
  bool _isLocating = true;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  final List<String> _urgencyLevels = [
    'Critical', 'High', 'Moderate'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _currentPosition = position;
        _isLocating = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Localization.get('fillAllFields'))),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required. Please enable GPS.')),
      );
      await _getCurrentLocation();
      return;
    }

    setState(() => _isLoading = true);

    try {

      // ignore: unused_local_variable
      final user = _authService.currentUser;
      
      final result = await _firestoreService.createBloodRequest(
        bloodGroup: _selectedBloodGroup!,
        units: _units,
        hospital: _hospitalController.text.trim(),
        urgency: _urgency,
        note: _messageController.text.trim(),
      );

      if (result['success'] == true) {
        // Send alerts to nearby donors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request posted! Notifying nearby donors...'),
              backgroundColor: Colors.blue,
            ),
          );
        }

        await _notificationService.sendAlertToNearbyDonors(
          bloodGroup: _selectedBloodGroup!,
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          message: _messageController.text.trim().isNotEmpty 
              ? _messageController.text.trim() 
              : 'Urgent blood needed: $_selectedBloodGroup',
          requestId: result['id'],
        );
      
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request posted successfully! Donors have been notified.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      debugPrint('Error posting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Blood Request'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentPosition != null ? Icons.location_on : Icons.location_off,
                      color: _currentPosition != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isLocating 
                            ? 'Detecting location...' 
                            : (_currentPosition != null 
                                ? 'Location detected' 
                                : 'Location not found'),
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                    if (!_isLocating && _currentPosition == null)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _getCurrentLocation,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Blood Group
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: Localization.get('selectBloodGroup'),
                  prefixIcon: const Icon(Icons.bloodtype),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _bloodGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Units Dropdown
              DropdownButtonFormField<int>(
                value: _units,
                decoration: InputDecoration(
                  labelText: Localization.get('units'),
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: List.generate(10, (index) => index + 1).map((unit) {
                  return DropdownMenuItem(value: unit, child: Text('$unit ${Localization.get('units')}'));
                }).toList(),
                onChanged: (value) => setState(() => _units = value!),
              ),
              const SizedBox(height: 16),

              // Urgency
              DropdownButtonFormField<String>(
                value: _urgency,
                decoration: InputDecoration(
                  labelText: 'Urgency Level',
                  prefixIcon: const Icon(Icons.warning_amber),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _urgencyLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) => setState(() => _urgency = value!),
              ),
              const SizedBox(height: 16),
              
              // Hospital
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: Localization.get('hospital'),
                  prefixIcon: const Icon(Icons.local_hospital),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Localization.get('fillAllFields');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message (Optional)',
                  hintText: 'e.g., Surgery scheduled for tomorrow...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              PrimaryButton(
                text: 'Post Request',
                onPressed: _isLoading ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
