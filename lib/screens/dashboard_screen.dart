import 'package:flutter/material.dart';
import '../models/user.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import 'course_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(user: widget.user),
      CourseScreen(user: widget.user),
      _buildFavoritesScreen(),
      _buildLibraryScreen(),
      // _buildUsersScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.yellow.shade700,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Course'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'FavList'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }

  // Placeholder screens for other tabs
  Widget _buildFavoritesScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.yellow.shade400,
      ),
      body: const Center(child: Text('Favorites Screen - Coming Soon!')),
    );
  }

  Widget _buildLibraryScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: Colors.yellow.shade400,
      ),
      body: const Center(child: Text('Library Screen - Coming Soon!')),
    );
  }

  // Widget _buildUsersScreen() {
  //   // Check if user is admin
  //   final isAdmin = widget.user.type?.toLowerCase() == 'admin';

  //   if (isAdmin) {
  //     // Navigate to profile screen for admin users
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => ProfileScreen(user: widget.user),
  //         ),
  //       );
  //     });

  //     // Return a loading screen while navigating
  //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
  //   } else {
  //     // Show access denied for non-admin users
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Users'),
  //         backgroundColor: Colors.yellow.shade400,
  //       ),
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
  //             const SizedBox(height: 20),
  //             Text(
  //               'Access Restricted',
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.grey.shade700,
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             Text(
  //               'This section is only available for admin users.',
  //               style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 30),
  //             Text(
  //               'Current User: ${widget.user.type ?? 'Student'}',
  //               style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }

}
