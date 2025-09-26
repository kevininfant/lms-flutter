import 'package:flutter/material.dart';
import '../models/todo_event.dart';
import '../models/calendar_month.dart';
import '../services/todo_event_service.dart';
import 'calendar_header.dart';
import 'date_section.dart';

class CalendarTimeline extends StatefulWidget {
  final TodoEventService eventService;
  final Function(TodoEvent)? onEventTap;
  final VoidCallback? onAddEvent;

  const CalendarTimeline({
    super.key,
    required this.eventService,
    this.onEventTap,
    this.onAddEvent,
  });

  @override
  State<CalendarTimeline> createState() => _CalendarTimelineState();
}

class _CalendarTimelineState extends State<CalendarTimeline> {
  late CalendarMonth _currentMonth;
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    _initializeCurrentMonth();
  }

  void _initializeCurrentMonth() {
    final now = DateTime.now();
    _currentMonth = widget.eventService.getCalendarMonth(now.year, now.month);
  }

  void _refreshMonth() {
    setState(() {
      _currentMonth = widget.eventService.getCalendarMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
    });
  }

  void _onEventTap(TodoEvent event) {
    setState(() {
      _selectedEventId = event.id;
    });
    widget.onEventTap?.call(event);
  }

  void _onMonthTap() {
    // TODO: Implement month picker
    _showMonthPicker();
  }

  void _onFilterTap() {
    // TODO: Implement filter options
    _showFilterOptions();
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            selectedDate: DateTime(_currentMonth.year, _currentMonth.month),
            onChanged: (date) {
              setState(() {
                _currentMonth = widget.eventService.getCalendarMonth(
                  date.year,
                  date.month,
                );
              });
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('All Events'),
              onTap: () {
                Navigator.pop(context);
                _refreshMonth();
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.blue),
              title: const Text('Courses Only'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement course filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('Reminders Only'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement reminder filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.purple),
              title: const Text('Tasks Only'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement task filter
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        CalendarHeader(
          monthYear: _currentMonth.displayName,
          totalActivities: _currentMonth.totalActivities,
          onMonthTap: _onMonthTap,
          onFilterTap: _onFilterTap,
        ),

        // Timeline content
        Expanded(child: _buildTimelineContent()),
      ],
    );
  }

  Widget _buildTimelineContent() {
    final datesWithEvents = _currentMonth.getDatesWithEvents();

    if (datesWithEvents.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: datesWithEvents.length,
      itemBuilder: (context, index) {
        final date = datesWithEvents[index];
        final events = _currentMonth.getEventsForDate(date);
        final isToday = _isToday(date);

        return DateSection(
          date: date,
          events: events,
          isToday: isToday,
          selectedEventId: _selectedEventId,
          onEventTap: _onEventTap,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events for ${_currentMonth.displayName}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add New Event" to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
