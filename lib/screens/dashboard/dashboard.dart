import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_management/screens/HomeScreen/home.dart';
import 'package:task_management/screens/ProfileScreen/profile.dart';
import 'package:task_management/utils/app_icons.dart';
import 'package:task_management/utils/color.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TaskManagerHome(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // color: colorPrimary,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorPrimaryDark,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          backgroundColor: white,
          // showSelectedLabels: false,
          items: [
            BottomNavigationBarItem(
                activeIcon: Image.asset(icn_home, height: 20, width: 20, color: colorPrimaryDark,),
                label: "Home",
                icon: Image.asset(icn_home, height: 20, width: 20,)
            ),
            BottomNavigationBarItem(
                activeIcon: Image.asset(icn_profile , height: 20, width: 20, color: colorPrimaryDark,),

                label: "Profile",
                icon: Image.asset(icn_profile, height: 20, width: 20,)
            ),

          ],
        ),
      ),

    );
  }
}