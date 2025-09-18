import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lms_rnd/blocs/course/course_bloc.dart';
import 'package:flutter_lms_rnd/blocs/course/course_state.dart';
import 'package:flutter_lms_rnd/widgets/course_card_list.dart';
import 'package:flutter_lms_rnd/widgets/curosial_widgets.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: Column(
        children: [
          CarouselWidgets(), // Carousel at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Courses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Wrap BlocBuilder in Expanded to take the remaining space
          Expanded(
            child: BlocBuilder<CourseBloc, CourseState>(
              builder: (context, state) {
                if (state is CourseLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is CourseLoaded) {
                  return CourseCardList(courses: state.courses);
                } else if (state is CourseError) {
                  return Center(child: Text(state.message));
                }
                return Center(child: Text('No courses available.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}