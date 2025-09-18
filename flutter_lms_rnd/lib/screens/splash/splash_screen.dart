import 'package:flutter/material.dart';
import 'package:flutter_lms_rnd/widgets/custom_loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // Simulate a loading delay
    await Future.delayed(const Duration(seconds: 3));

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      Navigator.pushReplacementNamed(context, '/authscreen');
    } else {
      Navigator.pushReplacementNamed(context, '/authscreen');
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstLaunch();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with responsive size
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.1), // 10% from the top
            child: Center(
              child: Image.asset(
                'assets/images/splashscreen.png',
                width: screenWidth * 0.8, // 80% of screen width
                height: screenHeight * 0.4, // 40% of screen height
                fit: BoxFit.cover, // Maintain aspect ratio
              ),
            ),
          ),
          // Logo image
          Positioned(
            top: screenHeight * 0.1, // Adjust position as needed
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/lmslogo.png',
                width: screenWidth * 0.6, // 60% of screen width
                height: screenHeight * 0.3, // 30% of screen height
                fit: BoxFit.cover, // Maintain aspect ratio
              ),
            ),
          ),
          // Loading indicator at the bottom
          Positioned(
            bottom: 70, // Adjust this value to position it higher or lower
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomLoadingIndicator(
          color1: const Color.fromARGB(255, 207, 187, 7), // Set your custom color
          color2: const Color.fromARGB(255, 245, 243, 243),
          size: 40.0, // Set your custom size
        ),// Loading indicator
                SizedBox(height: 20), // Space between the indicator and the text
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white), // Change text color as needed
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}