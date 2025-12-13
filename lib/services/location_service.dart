import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Location Service
/// Handles GPS location tracking, permissions, and distance calculations
class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Request location permission from user
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission denied forever');
        return false;
      }

      debugPrint('✅ Location permission granted');
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Get current device location
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        debugPrint('❌ Cannot get location: permission not granted');
        return null;
      }

      debugPrint('🔵 Getting current location...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('✅ Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in meters
  /// Returns distance in meters
  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// Calculate distance and return in kilometers
  double calculateDistanceInKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    double distanceInMeters = calculateDistance(lat1, lng1, lat2, lng2);
    return distanceInMeters / 1000;
  }

  /// Update user's location in Firestore
  Future<bool> updateUserLocation(double lat, double lng) async {
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

      debugPrint('✅ User location updated: $lat, $lng');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user location: $e');
      return false;
    }
  }

  /// Update user location on login
  /// Gets current location and saves to Firestore
  Future<bool> updateUserLocationOnLogin() async {
    try {
      Position? position = await getCurrentLocation();
      if (position == null) {
        debugPrint('⚠️ Could not get location on login');
        return false;
      }

      return await updateUserLocation(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('❌ Error updating location on login: $e');
      return false;
    }
  }

  /// Check if a point is within a given radius (in kilometers)
  bool isWithinRadius(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
    double radiusKm,
  ) {
    double distanceKm = calculateDistanceInKm(lat1, lng1, lat2, lng2);
    return distanceKm <= radiusKm;
  }

  /// Format distance for display
  /// Returns "X.X km" or "XXX m"
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      double km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}
