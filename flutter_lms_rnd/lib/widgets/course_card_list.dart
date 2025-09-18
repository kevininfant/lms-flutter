import 'package:flutter/material.dart';
import '../models/course.dart';
import 'course_card.dart';

class CourseCardList extends StatelessWidget {
  final List<Course> courses;

  const CourseCardList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return CourseCard(course: courses[index]);
      },
    );
  }
}