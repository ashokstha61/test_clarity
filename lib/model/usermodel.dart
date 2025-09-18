
//to be used to fetch user info from firebase and display it in profile page
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String providerId;
  final DateTime? creationDate;
  final DateTime? lastSignInDate;

  UserModel({
    required this.uid,
    this.email,
    required this.providerId,
    this.creationDate,
    this.lastSignInDate,
  });

  // Convert Firebase User to UserModel
  factory UserModel.fromFirebaseUser(User user) {
    final metadata = user.metadata;
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : "Unknown";

    return UserModel(
      uid: user.uid,
      email: user.email,
      providerId: providerId,
      creationDate: metadata.creationTime,
      lastSignInDate: metadata.lastSignInTime,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      providerId: map['providerId'] ?? 'Unknown',
      creationDate: map['createdAt'] != null
          ? (map['createdAt']).toDate()
          : null,
      lastSignInDate: map['lastSignInDate'] != null
          ? (map['lastSignInDate']).toDate()
          : null,
    );
  }

  // Helper: format date
  String formatDate(DateTime? date) {
    if (date == null) return "Unknown";
    return "${date.toLocal()}".split(".").first; // simple formatting
  }
}
