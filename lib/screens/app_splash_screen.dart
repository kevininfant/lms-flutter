import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _imageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _imageRotationAnimation;
  late Animation<double> _imageScaleAnimation;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkFirstTime();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _imageRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _imageScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _imageAnimationController.repeat(reverse: true);
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenSplash = prefs.getBool('has_seen_splash') ?? false;

    setState(() {
      _isFirstTime = !hasSeenSplash;
    });

    // Wait for animation to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 5500));

    if (!mounted) return;

    if (_isFirstTime) {
      // Mark that user has seen the splash
      await prefs.setBool('has_seen_splash', true);
    }

    // Navigate to main app
    _navigateToMainApp();
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return DashboardScreen(user: state.user);
              } else {
                return LoginScreen();
              }
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildAnimatedImage() {
    // Try to load custom image first, fallback to animated icon
    try {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/splashscreen.png',
            ), // Replace with your image path
            fit: BoxFit.contain,
          ),
        ),
      );
    } catch (e) {
      // Fallback to animated icon if image doesn't exist
      return _buildFallbackAnimatedIcon();
    }
  }

  Widget _buildFallbackAnimatedIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: Icon(Icons.school, size: 60, color: Colors.white)),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade400,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo/Image
            AnimatedBuilder(
              animation: Listenable.merge([
                _animationController,
                _imageAnimationController,
              ]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: _imageScaleAnimation.value,
                          child: Transform.rotate(
                            angle:
                                _imageRotationAnimation.value *
                                0.1, // Subtle rotation
                            child: Container(
                              width: 120,
                              height: 120,
                              child: _buildAnimatedImage(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // App Name with Animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'LMS Product',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Learn More • Experience More',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // Loading Indicator
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        _isFirstTime ? 'Welcome to LMS Product!' : 'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
