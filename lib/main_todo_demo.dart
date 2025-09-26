import 'package:flutter/material.dart';
import 'todoevent/todoevent.dart';

void main() {
  runApp(const TodoEventDemoApp());
}

class TodoEventDemoApp extends StatelessWidget {
  const TodoEventDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TodoEvent Calendar Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CalendarScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
