import 'package:flutter/material.dart';
import 'package:flutter_lms_rnd/widgets/cutom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isForgotPassword = false;
  bool resetPasswordSent = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      isForgotPassword = false;
      resetPasswordSent = false;
    });
  }

  void toggleForgotPassword() {
    setState(() {
      isForgotPassword = !isForgotPassword;
      resetPasswordSent = false;
      isLogin = true;
    });
  }

  void backToLogin() {
    setState(() {
      isForgotPassword = false;
      resetPasswordSent = false;
      isLogin = true;
    });
  }

  void resetPassword() {
    setState(() {
      isLogin = false;
      resetPasswordSent = true;
      isForgotPassword = false;
    });
  }

  void sendResetLink() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Email Sent'),
          content: Text(
            'A password reset link has been sent to ${emailController.text}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetPassword(); // Go back to login
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    setState(() {
      resetPasswordSent = true;
      isForgotPassword = false;
    });
  }

  void checkResetPassword() {
    if (newPasswordController.text == confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Password Reset'),
            content: Text(
              'Your password has been reset successfully. You can now log in.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  backToLogin(); // Go back to login
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        isForgotPassword = false;
        resetPasswordSent = false;
        isLogin = true;
      });
    } else {
      // Show error if passwords do not match
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Passwords do not match. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _validateLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email == 'admin@gmail.com' && password == 'Welcome@101') {
      // Valid credentials - show success dialog then navigate
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Login Successful'),
              ],
            ),
            content: Text('Welcome back! You have successfully logged in.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushReplacementNamed(
                    context,
                    '/homescreen',
                  ); // Navigate to dashboard
                },
                child: Text('Continue'),
              ),
            ],
          );
        },
      );
    } else {
      // Invalid credentials - show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text('Login Failed'),
              ],
            ),
            content: Text('Invalid email or password. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset("assets/images/splashscreen.png", fit: BoxFit.cover),
          // Overlay for the form
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display appropriate title based on the state
                  Text(
                    isForgotPassword
                        ? "Reset Password"
                        : resetPasswordSent
                        ? "update Your Password"
                        : (isLogin ? "Welcome Back" : "Create Account"),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Signup form fields (hidden during password reset)
                  if (!isLogin && !isForgotPassword && !resetPasswordSent) ...[
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                  ],
                  if (!resetPasswordSent) ...[
                    // Email field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Password field (only for login)
                  if (!isForgotPassword && !resetPasswordSent) ...[
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Show Forgot Password link only for login
                  if (isLogin && !isForgotPassword && !resetPasswordSent)
                    TextButton(
                      onPressed: toggleForgotPassword,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),

                  const SizedBox(height: 20),
                  // Use CustomButton here
                  if (!resetPasswordSent)
                    CustomButton(
                      color: Color(0xff000000),
                      fontColor: Color(0xffffffff),
                      text: isForgotPassword
                          ? 'Send Reset password'
                          : (isLogin ? 'Login' : 'Sign Up'),
                      onPressed: () {
                        if (isForgotPassword) {
                          sendResetLink();
                        } else if (isLogin) {
                          _validateLogin();
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            '/homescreen',
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 20),
                  // Toggle button for switching between forms
                  if (!isForgotPassword && !resetPasswordSent) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextButton(
                          onPressed: toggleForm,
                          child: Text(
                            isLogin ? "Sign Up" : "Login",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Reset Password Form
                  if (!isForgotPassword && resetPasswordSent) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: newPasswordController,
                      decoration: InputDecoration(labelText: 'New Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Reset Password',
                      color: Color(0xff000000),
                      fontColor: Color(0xffffffff),
                      onPressed: checkResetPassword,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: backToLogin,
                      child: Text(
                        "Back to Login",
                        style: TextStyle(color: Color(0xff000000)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Additional text
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Text(
              "Learn More Experience More",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
