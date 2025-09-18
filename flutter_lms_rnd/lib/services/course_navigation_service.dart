import 'package:flutter/material.dart';
import '../models/course.dart';
import '../screens/screen/course_details_screen.dart';
import '../screens/scorm_screen.dart';

class CourseNavigationService {
  /// Navigate to the appropriate screen based on course type
  static Future<void> navigateToCourse(
    BuildContext context,
    Course course,
  ) async {
    switch (course.type) {
      case CourseType.video:
        await _navigateToVideoCourse(context, course);
        break;
      case CourseType.scorm:
        await _navigateToScormCourse(context, course);
        break;
      case CourseType.url:
        await _navigateToUrlCourse(context, course);
        break;
    }
  }

  /// Navigate to SCORM course
  static Future<void> _navigateToScormCourse(
    BuildContext context,
    Course course,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScormScreen()),
    );
  }

  /// Navigate to video course
  static Future<void> _navigateToVideoCourse(
    BuildContext context,
    Course course,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(course: course),
      ),
    );
  }

  /// Navigate to URL course
  static Future<void> _navigateToUrlCourse(
    BuildContext context,
    Course course,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(course: course),
      ),
    );
  }

  /// Get course type icon
  static IconData getCourseTypeIcon(CourseType type) {
    switch (type) {
      case CourseType.video:
        return Icons.play_circle;
      case CourseType.scorm:
        return Icons.school;
      case CourseType.url:
        return Icons.link;
    }
  }

  /// Get course type color
  static Color getCourseTypeColor(CourseType type) {
    switch (type) {
      case CourseType.video:
        return Colors.blue;
      case CourseType.scorm:
        return Colors.purple;
      case CourseType.url:
        return Colors.green;
    }
  }

  /// Get course type label
  static String getCourseTypeLabel(CourseType type) {
    switch (type) {
      case CourseType.video:
        return 'Video';
      case CourseType.scorm:
        return 'SCORM';
      case CourseType.url:
        return 'Web';
    }
  }

  /// Check if course is available offline
  static bool isCourseOfflineAvailable(Course course) {
    switch (course.type) {
      case CourseType.video:
        return course.isOfflineAvailable;
      case CourseType.scorm:
        return course.isOfflineAvailable && course.scormAssetPath != null;
      case CourseType.url:
        return false; // URL courses are always online
    }
  }

  /// Get course availability status
  static String getCourseAvailabilityStatus(Course course) {
    if (isCourseOfflineAvailable(course)) {
      return 'Available Offline';
    } else {
      return 'Online Only';
    }
  }
}
