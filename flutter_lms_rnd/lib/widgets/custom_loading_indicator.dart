import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color color1; // Color for the outer border
  final Color color2; // Color for the inner border
  final double size; // Size of the indicator

  // Constructor to accept colors and size
  const CustomLoadingIndicator({
    Key? key,
    this.color1 = Colors.blue, // Default color1
    this.color2 = Colors.red,   // Default color2
    this.size = 50.0,          // Default size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer circular progress indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(color1),
              strokeWidth: 8.0, // Adjust the width of the outer border
              value: null, // Indeterminate
            ),
            // Inner circular progress indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(color2),
              strokeWidth: 5.0, // Adjust the width of the inner border
              value: null, // Indeterminate
            ),
          ],
        ),
      ),
    );
  }
}