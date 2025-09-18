// lib/bloc/course_state.dart
import 'package:flutter_lms_rnd/models/course.dart';

abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Course> courses;

  CourseLoaded(this.courses);
}

class CourseError extends CourseState {
  final String message;

  CourseError(this.message);
}