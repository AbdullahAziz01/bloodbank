import 'package:cloud_firestore/cloud_firestore.dart';

/// User Model
/// Represents a user in the BloodBank application
/// Fields match the registration form and Firestore structure
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String city;
  final String bloodGroup;
  final String role; // 'donor' or 'recipient'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isAvailable; // For donors - availability status
  final DateTime? lastDonation; // For donors - last donation date
  final String? profileImageUrl; // Optional profile image
  final double? lat; // Latitude for location tracking
  final double? lng; // Longitude for location tracking
  final String? fcmToken; // Firebase Cloud Messaging token
  final DateTime? lastActive; // Last activity timestamp

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.city,
    required this.bloodGroup,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.isAvailable = false,
    this.lastDonation,
    this.profileImageUrl,
    this.lat,
    this.lng,
    this.fcmToken,
    this.lastActive,
  });

  /// Create UserModel from Firestore document data
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      city: map['city'] as String? ?? '',
      bloodGroup: map['bloodGroup'] as String? ?? '',
      role: map['role'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      isAvailable: map['isAvailable'] as bool? ?? false,
      lastDonation: map['lastDonation'] != null
          ? (map['lastDonation'] as Timestamp).toDate()
          : null,
      profileImageUrl: map['profileImageUrl'] as String?,
      lat: map['lat'] as double?,
      lng: map['lng'] as double?,
      fcmToken: map['fcmToken'] as String?,
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert UserModel to Firestore document data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'city': city,
      'bloodGroup': bloodGroup,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'isAvailable': isAvailable,
      'lastDonation': lastDonation != null ? Timestamp.fromDate(lastDonation!) : null,
      'profileImageUrl': profileImageUrl,
      'lat': lat,
      'lng': lng,
      'fcmToken': fcmToken,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  /// Create a copy of UserModel with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? city,
    String? bloodGroup,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAvailable,
    DateTime? lastDonation,
    String? profileImageUrl,
    double? lat,
    double? lng,
    String? fcmToken,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonation: lastDonation ?? this.lastDonation,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      fcmToken: fcmToken ?? this.fcmToken,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// Check if user is a donor
  bool get isDonor => role == 'donor';

  /// Check if user is a recipient
  bool get isRecipient => role == 'recipient';

  /// Get display name (first name only)
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }

  /// Get formatted phone number
  String get formattedPhone {
    // Already in +92XXXXXXXXXX format from validation
    return phone;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role, bloodGroup: $bloodGroup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.phone == phone &&
        other.city == city &&
        other.bloodGroup == bloodGroup &&
        other.role == role;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        city.hashCode ^
        bloodGroup.hashCode ^
        role.hashCode;
  }
}
