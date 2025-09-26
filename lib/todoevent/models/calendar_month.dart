import 'package:equatable/equatable.dart';
import 'todo_event.dart';

class CalendarMonth extends Equatable {
  final int year;
  final int month;
  final List<TodoEvent> events;
  final int totalActivities;

  const CalendarMonth({
    required this.year,
    required this.month,
    required this.events,
    required this.totalActivities,
  });

  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String get displayName => '$monthName $year';

  List<TodoEvent> getEventsForDate(DateTime date) {
    return events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  List<DateTime> getDatesWithEvents() {
    return events
        .map(
          (event) =>
              DateTime(event.date.year, event.date.month, event.date.day),
        )
        .toSet()
        .toList()
      ..sort();
  }

  @override
  List<Object?> get props => [year, month, events, totalActivities];
}
