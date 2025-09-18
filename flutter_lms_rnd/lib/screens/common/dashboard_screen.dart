import 'package:flutter/material.dart';
import 'package:flutter_lms_rnd/screens/screen/home_screen.dart';
import 'package:flutter_lms_rnd/screens/scorm_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Track the currently selected index

  // List of screens to display
  final List<Widget> _screens = [
    HomeScreen(),
    const ScormScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/lmslogo.png', // Replace with your logo path
                height: screenHeight * 0.4, // 10% of screen height
                width: screenWidth * 0.4, // 40% of screen width
              ),

              SizedBox(width: 40), // Placeholder for alignment

              IconButton(
                icon: Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  // Handle notifications icon press
                  print('Notifications pressed');
                },
              ),

              IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  // Handle menu icon press
                  print('Menu pressed');
                },
              ),
            ],
          ),
        ),
        body: _screens[_selectedIndex], // Display the selected screen
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: GNav(
              rippleColor:
                  Colors.yellow, // Tab button ripple color when pressed
              hoverColor: Colors.black, // Tab button hover color
              haptic: true, // Haptic feedback
              tabBorderRadius: 15,
              // tabActiveBorder: Border.all(color: Colors.black, width: 1), // Active tab border
              // tabBorder: Border.all(color: Colors.grey, width: 1), // Inactive tab border
              tabShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 8),
              ], // Tab shadow
              curve: Curves.easeOutExpo, // Tab animation curves
              duration: Duration(milliseconds: 900), // Tab animation duration
              gap: 8, // The tab button gap between icon and text
              color: Colors.grey[800], // Unselected icon color
              activeColor: Colors.black, // Selected icon and text color
              iconSize: 28, // Tab button icon size
              tabBackgroundColor:
                  Colors.yellow, // Selected tab background color
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ), // Navigation bar padding
              tabs: [
                GButton(icon: LineIcons.home, text: 'Home'),
                GButton(icon: LineIcons.graduationCap, text: 'SCORM'),
                GButton(icon: LineIcons.search, text: 'Search'),
                GButton(icon: LineIcons.user, text: 'Profile'),
              ],
              selectedIndex: _selectedIndex, // Set the current index
              onTabChange: _onItemTapped, // Handle tab change
            ),
          ),
        ),
      ),
    );
  }
}

// Example screen widgets

class LikesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Likes Screen'));
  }
}

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Search Screen'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Screen'));
  }
}
