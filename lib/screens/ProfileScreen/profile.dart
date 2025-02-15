import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/provider/AuthProvider.dart';
import 'package:task_management/screens/LoginScreen/login.dart';
import 'package:task_management/utils/color.dart';
import 'package:task_management/utils/strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ConfirmLogout, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(ConfirmLogoutsub),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text(Cancel, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorPrimary),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _logout(); // Logout function
            },
            child: Text(Logout, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    authProvider.signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(Profile, style: TextStyle(color: white, fontWeight: FontWeight.w500),),
        backgroundColor: colorPrimary,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _showLogoutDialog(context),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text(
                Logout,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
