import 'package:flutter/material.dart';
import '../services/todo_event_service.dart';
import '../widgets/calendar_timeline.dart';
import '../models/todo_event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TodoEventService _eventService = TodoEventService();

  @override
  void initState() {
    super.initState();
    _eventService.initializeSampleData();
  }

  void _onEventTap(TodoEvent event) {
    // TODO: Navigate to event details or handle event tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on: ${event.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onAddEvent() {
    // TODO: Navigate to add event screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Event'),
        content: const Text('This feature will be implemented soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CalendarTimeline(
        eventService: _eventService,
        onEventTap: _onEventTap,
        onAddEvent: _onAddEvent,
      ),
    );
  }
}
