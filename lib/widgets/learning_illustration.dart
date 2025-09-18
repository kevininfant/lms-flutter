import 'package:flutter/material.dart';

class LearningIllustration extends StatelessWidget {
  const LearningIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.yellow.shade400,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Decorative squares
          Positioned(
            top: 20,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 50,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Main illustration content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating icons around the person
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFloatingIcon(Icons.lightbulb, Colors.amber),
                    _buildFloatingIcon(Icons.science, Colors.blue),
                    _buildFloatingIcon(Icons.settings, Colors.grey.shade700),
                  ],
                ),
                const SizedBox(height: 20),

                // Main illustration area
                Container(
                  width: 200,
                  height: 120,
                  child: Stack(
                    children: [
                      // Desk
                      Positioned(
                        bottom: 0,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      // Books stack (left side)
                      Positioned(
                        bottom: 40,
                        left: 30,
                        child: Column(
                          children: [
                            _buildBook('ENGLISH', Colors.red),
                            _buildBook('SCIENCE', Colors.green),
                            _buildBook('MATH', Colors.blue),
                          ],
                        ),
                      ),

                      // Person
                      Positioned(
                        bottom: 40,
                        left: 80,
                        child: Container(
                          width: 50,
                          height: 60,
                          child: Column(
                            children: [
                              // Head
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Glasses
                              Container(
                                width: 18,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Body (yellow shirt)
                              Container(
                                width: 30,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade600,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Laptop (right side)
                      Positioned(
                        bottom: 40,
                        right: 30,
                        child: Container(
                          width: 35,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Container(
                              width: 25,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bottom floating icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFloatingIcon(Icons.analytics, Colors.green),
                    _buildFloatingIcon(Icons.calculate, Colors.purple),
                    _buildFloatingIcon(Icons.psychology, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBook(String label, Color color) {
    return Container(
      width: 25,
      height: 8,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
