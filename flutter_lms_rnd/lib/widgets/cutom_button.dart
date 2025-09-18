import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text; // Text to display on the button
  final Color color; // Background color of the button
  final Color fontColor; // Text color of the button
  final VoidCallback onPressed; // Function to call when the button is pressed

  const CustomButton({
    Key? key,
    required this.text,
    this.color = Colors.blue, // Default color
    required this.onPressed,
    this.fontColor = Colors.white, // Default font color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Set the background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10, // Vertical padding
          horizontal: screenWidth * 0.04, // Horizontal padding based on screen width
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: fontColor, // Text color
        ),
      ),
    );
  }
}