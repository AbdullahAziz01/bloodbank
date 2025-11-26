import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../utils/localization.dart';

/// Screen for posting a new blood request
class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _unitsController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedBloodGroup;
  String? _selectedUrgency;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _urgencyLevels = ['High', 'Medium', 'Low'];

  @override
  void dispose() {
    _hospitalController.dispose();
    _unitsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final formState = _formKey.currentState;
    if (formState != null &&
        formState.validate() &&
        _selectedBloodGroup != null &&
        _selectedUrgency != null) {
      // TODO: Post request to Firestore
      // TODO: Send push notifications to nearby compatible donors
      // TODO: Add geolocation for hospital location
      // TODO: Upload supporting documents if needed

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Localization.get('requestPosted')),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Localization.get('fillAllFields')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('postRequest')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5F5),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.bloodtype,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          Localization.get('postRequest'),
                          style: AppTheme.heading2.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help us find the right donor',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBloodGroup,
                    decoration: InputDecoration(
                      labelText: Localization.get('bloodGroup'),
                      prefixIcon: const Icon(Icons.bloodtype),
                    ),
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
                    validator: (value) {
                      if (value == null) {
                        return Localization.get('fillAllFields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _unitsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: Localization.get('units'),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Localization.get('fillAllFields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _hospitalController,
                    decoration: InputDecoration(
                      labelText: Localization.get('hospitalName'),
                      prefixIcon: const Icon(Icons.local_hospital),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Localization.get('fillAllFields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUrgency,
                    decoration: InputDecoration(
                      labelText: Localization.get('urgency'),
                      prefixIcon: const Icon(Icons.priority_high),
                    ),
                    items: _urgencyLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(Localization.get(level.toLowerCase())),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedUrgency = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return Localization.get('fillAllFields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: Localization.get('note'),
                      prefixIcon: const Icon(Icons.note_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'submit',
                    onPressed: _handleSubmit,
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

