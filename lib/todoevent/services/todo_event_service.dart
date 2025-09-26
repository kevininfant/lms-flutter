import '../models/todo_event.dart';
import '../models/calendar_month.dart';

class TodoEventService {
  static final TodoEventService _instance = TodoEventService._internal();
  factory TodoEventService() => _instance;
  TodoEventService._internal();

  final List<TodoEvent> _events = [];

  // Sample data based on the calendar image
  void initializeSampleData() {
    _events.clear();

    // August 2, 2023 - Completed course
    _events.add(
      TodoEvent(
        id: '1',
        title: 'Working Capital Products',
        description: 'Complete this course and the followings.',
        date: DateTime(2023, 8, 2),
        type: TodoEventType.course,
        status: TodoEventStatus.completed,
        thumbnailPath: 'assets/images/course_lightbulb.png',
      ),
    );

    // August 5, 2023 - Overdue course
    _events.add(
      TodoEvent(
        id: '2',
        title: 'Working Capital Products',
        description: 'Complete this course and the followings.',
        date: DateTime(2023, 8, 5),
        type: TodoEventType.course,
        status: TodoEventStatus.overdue,
        thumbnailPath: 'assets/images/course_laptop.png',
      ),
    );

    // August 5, 2023 - Due reminder
    _events.add(
      TodoEvent(
        id: '3',
        title: 'Working Capital Products',
        description: 'Complete this course and the followings.',
        date: DateTime(2023, 8, 5),
        type: TodoEventType.reminder,
        status: TodoEventStatus.due,
        thumbnailPath: 'assets/images/reminder_keyboard.png',
      ),
    );

    // August 21, 2023 - Reminder
    _events.add(
      TodoEvent(
        id: '4',
        title: 'Working Capital Products',
        description: 'Complete this course and the followings.',
        date: DateTime(2023, 8, 21),
        type: TodoEventType.reminder,
        status: TodoEventStatus.pending,
        thumbnailPath: 'assets/images/reminder_notes.png',
      ),
    );
  }

  List<TodoEvent> getAllEvents() {
    return List.from(_events);
  }

  List<TodoEvent> getEventsForMonth(int year, int month) {
    return _events.where((event) {
      return event.date.year == year && event.date.month == month;
    }).toList();
  }

  List<TodoEvent> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  CalendarMonth getCalendarMonth(int year, int month) {
    final monthEvents = getEventsForMonth(year, month);
    return CalendarMonth(
      year: year,
      month: month,
      events: monthEvents,
      totalActivities: monthEvents.length,
    );
  }

  void addEvent(TodoEvent event) {
    _events.add(event);
  }

  void updateEvent(TodoEvent event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
    }
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
  }

  TodoEvent? getEventById(String eventId) {
    try {
      return _events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  List<TodoEvent> getEventsByStatus(TodoEventStatus status) {
    return _events.where((event) => event.status == status).toList();
  }

  List<TodoEvent> getEventsByType(TodoEventType type) {
    return _events.where((event) => event.type == type).toList();
  }
}
