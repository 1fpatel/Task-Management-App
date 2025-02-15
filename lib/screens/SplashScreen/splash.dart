import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/provider/AuthProvider.dart';
import 'dart:async';
import 'package:task_management/screens/LoginScreen/login.dart';
import 'package:task_management/screens/dashboard/dashboard.dart';
import 'package:task_management/utils/color.dart';
import 'package:task_management/utils/constant.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  late Future<void> _authCheckFuture; // ✅ Future for authentication check

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.elasticInOut,
    );

    controller.forward();

    // ✅ Wait for authentication check before navigating
    _authCheckFuture = _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    await authProvider.checkLoginStatus(); // ✅ Ensure it completes before checking user
    await Future.delayed(Duration(seconds: 3)); // ✅ Ensure animation completes

    if (authProvider.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authCheckFuture, // ✅ Wait until authentication check is done
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: colorPrimary,
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPrimary, darkGray],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.task_alt, size: 80, color: Colors.white), // App Icon
                      SizedBox(height: 20),
                      Text(
                        Constant.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
