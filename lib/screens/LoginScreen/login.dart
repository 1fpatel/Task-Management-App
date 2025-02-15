import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_management/provider/AuthProvider.dart';
import 'package:task_management/utils/app_icons.dart';
import 'package:task_management/utils/app_images.dart';
import 'package:task_management/utils/color.dart';
import 'package:task_management/utils/strings.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> circleAnimation;
  late Animation<double> fadeAnimation;
  late AuthenticationProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthenticationProvider>(context,listen: false);
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    circleAnimation = Tween<double>(begin: -0.4, end: -0.2).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Animated Background Circle
              Positioned(
                top: circleAnimation.value * height,
                left: circleAnimation.value * height,
                child: Container(
                  height: height * 0.6,
                  width: height * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [darkGray, colorPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: fadeAnimation.value,
                        duration: Duration(seconds: 1),
                        child: Image.asset(login_illustration, height: height * 0.3),
                      ),

                      SizedBox(height: 20),

                      AnimatedOpacity(
                        opacity: fadeAnimation.value,
                        duration: Duration(seconds: 1),
                        child: Text(Welcome,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: black.withOpacity(0.9),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      AnimatedOpacity(
                        opacity: fadeAnimation.value,
                        duration: Duration(seconds: 1),
                        child: Text(WelcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: lightgrey,
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Google Sign-In Button
                      AnimatedOpacity(
                        opacity: fadeAnimation.value,
                        duration: Duration(seconds: 1),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Google Login Function
                            authProvider.signInWithGoogle(context);
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BottomNavScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Outlinedark,
                            foregroundColor: white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            elevation: 3,
                          ),
                          icon: Image.asset(google_icn, height: 30,), // Google icon
                          label: Text(
                            SigninwithGoogle,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
