import 'package:flutter/material.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';

class UnifiedCourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool showProgress;

  const UnifiedCourseCard({
    Key? key,
    required this.course,
    this.onTap,
    this.showProgress = true,
  }) : super(key: key);

  @override
  State<UnifiedCourseCard> createState() => _UnifiedCourseCardState();
}

class _UnifiedCourseCardState extends State<UnifiedCourseCard> {
  @override
  Widget build(BuildContext context) {
    return CourseCard(course: widget.course);
  }
}
