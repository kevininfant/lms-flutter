import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // For loading JSON files
import 'package:flutter_lms_rnd/models/course.dart';
import 'course_event.dart';
import 'course_state.dart';


class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc() : super(CourseInitial()) {
    // Register the event handler for LoadCourses
    on<LoadCourses>((event, emit) async {
      emit(CourseLoading());
      try {
        final String response = await rootBundle.loadString('assets/data/courses.json');
        final List<dynamic> data = json.decode(response);
        final List<Course> courses = data.map((json) => Course.fromJson(json)).toList();
        emit(CourseLoaded(courses));
      } catch (e) {
        emit(CourseError("Failed to load courses: ${e.toString()}"));
      }
    });
  }
}