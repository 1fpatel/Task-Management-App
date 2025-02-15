import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/screens/LoginScreen/login.dart';
import 'package:task_management/screens/dashboard/dashboard.dart';
import 'package:task_management/services/auth.dart';
import 'package:task_management/utils/firestoreconstants.dart';

class AuthenticationProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;



  /// Check login status when app starts
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(FirestoreConstants.userid);

    print("prefs: ${prefs}");
    print("userId: ${userId}");
    if (userId != null) {
      _user = FirebaseAuth.instance.currentUser;
      print("_user: ${_user}");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    User? user = await AuthServices().signInWithGoogle();
    if (user != null) {
      _user = user;
      notifyListeners();

      // Navigate to BottomNavigationScreen and remove previous screens
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavScreen()),
            (route) => false, // Removes all previous screens from the stack
      );
    }
  }

  /// Logout and clear user data
  Future<void> signOut(BuildContext context) async {
    await AuthServices().signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();

    // Navigate to login screen and remove all previous screens from stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }
}
