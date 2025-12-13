import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'location_service.dart';

/// User Service
/// Handles user-related Firestore operations
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();

  /// Create user document in Firestore
  Future<bool> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      debugPrint('✅ User document created: ${user.uid}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      return false;
    }
  }

  /// Get user by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      return null;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUser(user.uid);
  }

  /// Update user location
  Future<bool> updateLocation(double lat, double lng) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ Cannot update location: user not authenticated');
        return false;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'lat': lat,
        'lng': lng,
        'lastActive': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ User location updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating location: $e');
      return false;
    }
  }

  /// Get nearby donors within radius and optionally filter by blood group
  Future<List<UserModel>> getNearbyDonors({
    required double lat,
    required double lng,
    required double radiusKm,
    String? bloodGroup,
  }) async {
    try {
      debugPrint('🔵 Searching for donors within ${radiusKm}km...');

      // Build query
      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'donor')
          .where('isAvailable', isEqualTo: true);

      // Add blood group filter if specified
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        query = query.where('bloodGroup', isEqualTo: bloodGroup);
      }

      QuerySnapshot snapshot = await query.get();
      debugPrint('Found ${snapshot.docs.length} potential donors');

      List<UserModel> nearbyDonors = [];

      for (var doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final donorLat = userData['lat'] as double?;
        final donorLng = userData['lng'] as double?;

        if (donorLat == null || donorLng == null) {
          continue; // Skip donors without location
        }

        // Calculate distance
        double distanceKm = _locationService.calculateDistanceInKm(
          lat,
          lng,
          donorLat,
          donorLng,
        );

        // Check if within radius
        if (distanceKm <= radiusKm) {
          UserModel donor = UserModel.fromMap(userData);
          nearbyDonors.add(donor);
          debugPrint('Found donor: ${donor.name} (${distanceKm.toStringAsFixed(1)} km)');
        }
      }

      debugPrint('✅ Found ${nearbyDonors.length} donors within ${radiusKm}km');
      return nearbyDonors;
    } catch (e) {
      debugPrint('❌ Error getting nearby donors: $e');
      return [];
    }
  }

  /// Get all donors (for map display)
  Future<List<UserModel>> getAllDonors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'donor')
          .where('isAvailable', isEqualTo: true)
          .get();

      List<UserModel> donors = [];
      for (var doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        // Only include donors with location
        if (userData['lat'] != null && userData['lng'] != null) {
          donors.add(UserModel.fromMap(userData));
        }
      }

      return donors;
    } catch (e) {
      debugPrint('❌ Error getting all donors: $e');
      return [];
    }
  }

  /// Stream of nearby donors (real-time updates)
  Stream<List<UserModel>> getNearbyDonorsStream({
    required double lat,
    required double lng,
    required double radiusKm,
    String? bloodGroup,
  }) {
    Query query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'donor')
        .where('isAvailable', isEqualTo: true);

    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    return query.snapshots().map((snapshot) {
      List<UserModel> nearbyDonors = [];

      for (var doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final donorLat = userData['lat'] as double?;
        final donorLng = userData['lng'] as double?;

        if (donorLat == null || donorLng == null) {
          continue;
        }

        double distanceKm = _locationService.calculateDistanceInKm(
          lat,
          lng,
          donorLat,
          donorLng,
        );

        if (distanceKm <= radiusKm) {
          nearbyDonors.add(UserModel.fromMap(userData));
        }
      }

      return nearbyDonors;
    });
  }

  /// Update user data
  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
      debugPrint('✅ User updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      return false;
    }
  }

  /// Update donor availability
  Future<bool> updateDonorAvailability(bool isAvailable) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Donor availability updated: $isAvailable');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating availability: $e');
      return false;
    }
  }

  /// Listen for alerts (for donors)
  Stream<List<Map<String, dynamic>>> listenForAlerts() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('alerts')
        .where('donorId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }
}
