import 'package:flutter/material.dart';
import '../models/todo_event.dart';
import 'event_card.dart';

class DateSection extends StatelessWidget {
  final DateTime date;
  final List<TodoEvent> events;
  final bool isToday;
  final String? selectedEventId;
  final Function(TodoEvent)? onEventTap;

  const DateSection({
    super.key,
    required this.date,
    required this.events,
    this.isToday = false,
    this.selectedEventId,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        _buildDateHeader(),

        const SizedBox(height: 12),

        // Events for this date
        ...events.map(
          (event) => EventCard(
            event: event,
            isSelected: selectedEventId == event.id,
            onTap: () => onEventTap?.call(event),
          ),
        ),

        // Add new event button (only show on today or future dates)
        if (_shouldShowAddButton()) _buildAddEventButton(),
      ],
    );
  }

  Widget _buildDateHeader() {
    final dayName = _getDayName(date.weekday);
    final dayNumber = date.day;

    return Row(
      children: [
        // Day number
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isToday ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              dayNumber.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Day name and "Today" indicator
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isToday)
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddEventButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement add new event functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Add New Event',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  bool _shouldShowAddButton() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);

    // Show add button on today or future dates
    return eventDate.isAtSameMomentAs(today) || eventDate.isAfter(today);
  }
}
