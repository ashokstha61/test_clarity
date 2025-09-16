//To be used in to fetch the user info from firebase and display it in profile page

import 'package:clarity/model/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserViewModel {
  UserModel? userInfo;

  UserViewModel() {
    fetchUserInfo();
  }

  void fetchUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is signed in.");
      return;
    }

    userInfo = UserModel.fromFirebaseUser(user);
  }

  String getFormattedCreatedDate() {
    return userInfo?.formatDate(userInfo?.creationDate) ?? "Unknown";
  }
}