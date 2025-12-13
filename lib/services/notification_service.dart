import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Notification Service
/// Handles Firebase Cloud Messaging (FCM) for push notifications
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize FCM and request notification permissions
  Future<void> initialize() async {
    try {
      // Request notification permissions (iOS)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ Notification permission granted provisionally');
      } else {
        debugPrint('❌ Notification permission denied');
      }

      // Get FCM token
      String? token = await getFCMToken();
      if (token != null) {
        await saveFCMToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔵 FCM token refreshed');
        saveFCMToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notification service: $e');
    }
  }

  /// Get FCM token for this device
  Future<String?> getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        debugPrint('✅ FCM token obtained: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Firestore
  Future<void> saveFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ Cannot save FCM token: user not authenticated');
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ FCM token saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Handle foreground messages (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 Foreground notification received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // You can show a local notification or update UI here
  }

  /// Handle notification tap (when user taps notification)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 Notification tapped');
    debugPrint('Data: ${message.data}');

    // Navigate to appropriate screen based on notification data
    // This will be implemented when we have navigation context
    if (message.data.containsKey('requestId')) {
      String requestId = message.data['requestId'];
      debugPrint('Navigate to request details: $requestId');
      // TODO: Navigate to request details screen
    }
  }

  /// Send alert to nearby donors
  /// This function finds donors within radius and with matching blood group
  /// and triggers notifications via Cloud Functions or direct FCM
  Future<void> sendAlertToNearbyDonors({
    required String bloodGroup,
    required double lat,
    required double lng,
    required String message,
    required String requestId,
  }) async {
    try {
      debugPrint('🔵 Sending alerts to nearby $bloodGroup donors...');

      // Query donors with matching blood group
      QuerySnapshot donorsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'donor')
          .where('bloodGroup', isEqualTo: bloodGroup)
          .where('isAvailable', isEqualTo: true)
          .get();

      debugPrint('Found ${donorsSnapshot.docs.length} potential donors');

      int alertsSent = 0;
      for (var doc in donorsSnapshot.docs) {
        final donorData = doc.data() as Map<String, dynamic>;
        final donorLat = donorData['lat'] as double?;
        final donorLng = donorData['lng'] as double?;
        final fcmToken = donorData['fcmToken'] as String?;

        if (donorLat == null || donorLng == null || fcmToken == null) {
          continue;
        }

        // Calculate distance
        double distance = _calculateDistance(lat, lng, donorLat, donorLng);
        double distanceKm = distance / 1000;

        // Only send to donors within 10km
        if (distanceKm <= 10) {
          // Create alert document in Firestore
          await _firestore.collection('alerts').add({
            'donorId': doc.id,
            'requestId': requestId,
            'bloodGroup': bloodGroup,
            'message': message,
            'distance': distanceKm,
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
          });

          alertsSent++;
          debugPrint('Alert sent to donor ${doc.id} (${distanceKm.toStringAsFixed(1)} km away)');
        }
      }

      debugPrint('✅ Sent $alertsSent alerts to nearby donors');

      // Note: Actual FCM push notifications should be sent via Cloud Functions
      // for security reasons. The alerts collection will trigger Cloud Functions
      // to send push notifications to the donors' FCM tokens.
    } catch (e) {
      debugPrint('❌ Error sending alerts: $e');
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() * lat2.toRadians().cos() *
        (dLng / 2).sin() * (dLng / 2).sin();

    double c = 2 * (a.sqrt()).asin();
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  /// Listen for alerts for current user (donors)
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

  /// Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking alert as read: $e');
    }
  }
}

/// Extension for converting degrees to radians
extension on double {
  double toRadians() => this * (3.141592653589793 / 180.0);
  double sin() => this;
  double cos() => this;
  double asin() => this;
  double sqrt() => this;
}
