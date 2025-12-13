import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Firebase Authentication Service
/// Handles user registration, login, logout, and auth state management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user with email and password
  /// Saves user data to Firestore based on registration form fields
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String city,
    required String bloodGroup,
    required String role,
  }) async {
    try {
      debugPrint('🔵 Starting registration for email: $email');
      
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        debugPrint('❌ Empty email or password');
        return {
          'success': false,
          'message': 'Email and password cannot be empty',
        };
      }

      // Create user with email and password
      debugPrint('🔵 Creating Firebase Auth account...');
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;
      debugPrint('🔵 Firebase Auth account created. UID: ${user?.uid}');

      if (user != null) {
        try {
          // Save user data to Firestore
          debugPrint('🔵 Creating Firestore user document...');
          final userData = {
            'uid': user.uid,
            'email': email.trim(),
            'name': name.trim(),
            'phone': phone.trim(),
            'city': city.trim(),
            'bloodGroup': bloodGroup,
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isAvailable': role == 'donor',
            'lastDonation': null,
            'profileImageUrl': null,
          };

          await _firestore.collection('users').doc(user.uid).set(userData);
          debugPrint('✅ Firestore user document created successfully');

          // Note: Location and FCM token will be set after registration
          // when user grants permissions in the registration flow

          // Send email verification
          try {
            debugPrint('🔵 Sending email verification...');
            await user.sendEmailVerification();
            debugPrint('✅ Email verification sent');
          } catch (e) {
            debugPrint('⚠️ Failed to send verification email: $e');
            // Don't fail registration if email verification fails
          }

          return {
            'success': true,
            'user': user,
            'message': 'Registration successful. Please check your email to verify your account.',
          };
        } catch (firestoreError) {
          debugPrint('❌ Firestore error: $firestoreError');
          // If Firestore fails, delete the auth account to maintain consistency
          try {
            await user.delete();
            debugPrint('🔵 Deleted auth account due to Firestore error');
          } catch (deleteError) {
            debugPrint('⚠️ Could not delete auth account: $deleteError');
          }
          return {
            'success': false,
            'message': 'Failed to create user profile: ${firestoreError.toString()}',
          };
        }
      } else {
        debugPrint('❌ User credential returned null');
        return {
          'success': false,
          'message': 'Failed to create user account',
        };
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      String message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'Password is too weak. Use at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please login instead.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address format';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are not enabled';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please check your internet connection.';
      } else {
        message = 'Registration failed: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔵 Starting login for email: $email');
      
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        debugPrint('❌ Empty email or password');
        return {
          'success': false,
          'message': 'Email and password cannot be empty',
        };
      }

      debugPrint('🔵 Attempting Firebase Auth sign in...');
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;
      debugPrint('🔵 Login successful. UID: ${user?.uid}');

      if (user != null) {
        debugPrint('✅ User logged in successfully');
        return {
          'success': true,
          'user': user,
          'message': 'Login successful',
        };
      } else {
        debugPrint('❌ User credential returned null');
        return {
          'success': false,
          'message': 'Login failed - no user data',
        };
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email. Please register first.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address format';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please check your internet connection.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many failed attempts. Please try again later.';
      } else {
        message = 'Login failed: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Send email verification to current user
  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user is currently signed in',
        };
      }

      if (user.emailVerified) {
        return {
          'success': false,
          'message': 'Email is already verified',
        };
      }

      await user.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send verification email';
      if (e.code == 'too-many-requests') {
        message = 'Too many requests. Please try again later';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Send password reset email
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send password reset email';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Check if current user's email is verified
  bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Reload current user to get latest verification status
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// Get current user as UserModel
  /// Returns null if no user is logged in or user data doesn't exist
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user model: $e');
      return null;
    }
  }

  /// Get user model by UID
  /// Returns null if user doesn't exist
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user model: $e');
      return null;
    }
  }

  /// Stream of current user model
  /// Updates automatically when user data changes in Firestore
  Stream<UserModel?> get currentUserModelStream {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }
}

