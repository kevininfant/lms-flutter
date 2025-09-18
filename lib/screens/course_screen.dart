import 'package:flutter/material.dart';
import '../models/user.dart';

class CourseScreen extends StatelessWidget {
  final User user;

  const CourseScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Course List'),
        backgroundColor: Colors.yellow.shade400,
        elevation: 0,
      ),
      body: _buildCourseList(context),
    );
  }

  Widget _buildCourseList(BuildContext context) {
    final courses = [
      {
        'title': 'Web Development Fundamentals',
        'type': 'SCORM',
        'icon': Icons.school,
        'color': Colors.blue,
      },
      {
        'title': 'JavaScript Tutorial Series',
        'type': 'Videos',
        'icon': Icons.video_library,
        'color': Colors.red,
      },
      {
        'title': 'Programming Podcasts',
        'type': 'Audios',
        'icon': Icons.headphones,
        'color': Colors.green,
      },
      {
        'title': 'API Documentation',
        'type': 'Docs',
        'icon': Icons.description,
        'color': Colors.orange,
      },
      {
        'title': 'Interactive Coding Exercise',
        'type': 'H5P',
        'icon': Icons.quiz,
        'color': Colors.purple,
      },
      {
        'title': 'Database Design Course',
        'type': 'SCORM',
        'icon': Icons.school,
        'color': Colors.blue,
      },
      {
        'title': 'React Native Tutorials',
        'type': 'Videos',
        'icon': Icons.video_library,
        'color': Colors.red,
      },
      {
        'title': 'Tech Talk Podcasts',
        'type': 'Audios',
        'icon': Icons.headphones,
        'color': Colors.green,
      },
      {
        'title': 'Flutter Guide',
        'type': 'Docs',
        'icon': Icons.description,
        'color': Colors.orange,
      },
      {
        'title': 'Mobile App Quiz',
        'type': 'H5P',
        'icon': Icons.quiz,
        'color': Colors.purple,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Course Type Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (course['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    course['icon'] as IconData,
                    color: course['color'] as Color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (course['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course['type'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: course['color'] as Color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Button
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opening ${course['title']} (${course['type']})',
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: course['color'] as Color,
                    size: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
