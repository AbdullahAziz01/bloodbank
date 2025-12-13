import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../utils/localization.dart';
import '../widgets/request_item.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  bool _showSolved = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.uid;
  }

  Future<void> _toggleRequestStatus(String requestId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'solved' : 'active';
    await FirebaseFirestore.instance
        .collection('bloodRequests')
        .doc(requestId)
        .update({'status': newStatus});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'solved' ? 'Request marked as Solved' : 'Request reactivated',
          ),
          backgroundColor: newStatus == 'solved' ? Colors.green : Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Requests'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showSolved = !_showSolved;
              });
            },
            icon: Icon(
              _showSolved ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            label: Text(
              _showSolved ? 'Hide Solved' : 'Show Solved',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .where('recipientId', isEqualTo: _currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allRequests = snapshot.data?.docs ?? [];
          final requests = allRequests.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'active';
            return _showSolved ? true : status == 'active';
          }).toList();

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
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
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'active';
              final isSolved = status == 'solved';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    RequestItem(
                      name: data['hospital'] ?? 'Unknown Hospital',
                      bloodGroup: data['bloodGroup'] ?? 'N/A',
                      units: data['units'] ?? 0,
                      distanceKm: 0.0, // Distance not relevant for my requests
                      city: data['city'] ?? 'Unknown',
                      urgency: data['urgency'] ?? 'Medium',
                      hospital: data['hospital'] ?? 'Unknown',
                      note: data['note'] ?? '',
                      timeAgo: 'Posted recently', // Format properly if needed
                      onContact: () {}, // No contact needed for own request
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            isSolved ? 'Case Solved' : 'Still Needed',
                            style: TextStyle(
                              color: isSolved ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: isSolved,
                            activeColor: Colors.green,
                            onChanged: (val) => _toggleRequestStatus(doc.id, status),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
