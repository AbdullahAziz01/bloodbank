import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firestore Service for Blood Requests and Donors
/// Handles real-time data streaming for requests and donors
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of all blood requests (for donors)
  Stream<List<Map<String, dynamic>>> getBloodRequestsStream() {
    try {
      return _firestore
          .collection('bloodRequests')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
            // Calculate time ago
            'timeAgo': _calculateTimeAgo(
              data['createdAt'] as Timestamp?,
            ),
          };
        }).toList();
      }).handleError((error) {
        debugPrint('Error in getBloodRequestsStream: $error');
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      debugPrint('Error setting up getBloodRequestsStream: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  /// Stream of all donors (for recipients)
  Stream<List<Map<String, dynamic>>> getDonorsStream() {
    try {
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'donor')
          .where('isAvailable', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      }).handleError((error) {
        debugPrint('Error in getDonorsStream: $error');
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      debugPrint('Error setting up getDonorsStream: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  /// Create a new blood request
  /// Fields match the post request screen form
  Future<Map<String, dynamic>> createBloodRequest({
    required String bloodGroup,
    required int units,
    required String hospital,
    required String urgency,
    String? note,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      // Get user data to include recipient info
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      final requestData = {
        'recipientId': user.uid,
        'recipientName': userData?['name'] ?? 'Unknown',
        'recipientPhone': userData?['phone'] ?? '',
        'recipientEmail': userData?['email'] ?? '', // Added email
        'recipientCity': userData?['city'] ?? '',
        'bloodGroup': bloodGroup,
        'units': units,
        'hospital': hospital,
        'urgency': urgency,
        'note': note ?? '',
        'status': 'active', // active, fulfilled, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Distance calculation will be done on client side
        // TODO: Add geolocation for distance calculation
      };

      final docRef = await _firestore
          .collection('bloodRequests')
          .add(requestData);

      return {
        'success': true,
        'id': docRef.id,
        'message': 'Request posted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to post request: ${e.toString()}',
      };
    }
  }

  /// Update user profile data
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Get user's own requests (for recipients)
  Stream<List<Map<String, dynamic>>> getUserRequestsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bloodRequests')
        .where('recipientId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'timeAgo': _calculateTimeAgo(
            data['createdAt'] as Timestamp?,
          ),
        };
      }).toList();
    });
  }

  /// Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('bloodRequests').doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update donor availability
  Future<void> updateDonorAvailability(bool isAvailable) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Calculate time ago string from timestamp
  String _calculateTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';

    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}

