# TodoEvent Library

A Flutter library for managing calendar events and tasks with a beautiful timeline design.

## Features

- 📅 **Calendar Timeline View**: Beautiful timeline-style calendar showing events by date
- 🎯 **Event Types**: Support for Courses, Reminders, and Tasks
- 📊 **Status Indicators**: Visual status indicators (Completed, Overdue, Due, Pending)
- 🎨 **Modern UI**: Clean, modern design with gradient thumbnails and status colors
- ➕ **Add Events**: Easy event creation with form validation
- 🔍 **Filtering**: Filter events by type and status
- 📱 **Responsive**: Works on all screen sizes

## Quick Start

### 1. Import the library

```dart
import 'package:your_app/todoevent/todoevent.dart';
```

### 2. Use the Calendar Screen

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen(),
    );
  }
}
```

### 3. Or use individual components

```dart
// Create an event service
final eventService = TodoEventService();
eventService.initializeSampleData();

// Use the calendar timeline widget
CalendarTimeline(
  eventService: eventService,
  onEventTap: (event) {
    print('Tapped on: ${event.title}');
  },
  onAddEvent: () {
    // Navigate to add event screen
  },
)
```

## Event Types

- **Course**: Learning courses and training materials (Blue theme)
- **Reminder**: Important reminders and notifications (Orange theme)  
- **Task**: General tasks and assignments (Purple theme)

## Event Status

- **Completed**: Green indicator - Task is finished
- **Overdue**: Red indicator - Task is past due date
- **Due**: Orange indicator - Task is due soon
- **Pending**: Grey indicator - Task is waiting

## Sample Data

The library includes sample data matching the calendar design:
- August 2, 2023: Completed course
- August 5, 2023: Overdue course and due reminder
- August 21, 2023: Pending reminder

## Customization

### Adding Custom Events

```dart
final event = TodoEvent(
  id: 'unique_id',
  title: 'My Event',
  description: 'Event description',
  date: DateTime.now(),
  type: TodoEventType.task,
  status: TodoEventStatus.pending,
);

eventService.addEvent(event);
```

### Customizing Colors

The library uses predefined color schemes for each event type:
- Courses: Blue gradient
- Reminders: Purple gradient  
- Tasks: Pink gradient

## File Structure

```
lib/todoevent/
├── models/
│   ├── todo_event.dart          # Event model
│   └── calendar_month.dart      # Calendar month model
├── services/
│   └── todo_event_service.dart  # Event management service
├── widgets/
│   ├── calendar_header.dart     # Month header with filter
│   ├── event_card.dart          # Individual event card
│   ├── date_section.dart        # Date section with events
│   └── calendar_timeline.dart   # Main timeline widget
├── screens/
│   ├── calendar_screen.dart     # Main calendar screen
│   └── add_event_screen.dart    # Add new event screen
└── todoevent.dart              # Library exports
```

## Demo

Run the demo app:

```bash
flutter run lib/main_todo_demo.dart
```

This will show the calendar with sample data matching the design from your image.

## Integration

To integrate into your existing LMS app, simply add a navigation item to the `TodoCalendarScreen`:

```dart
// In your main navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TodoCalendarScreen(),
  ),
);
```

The library is designed to be self-contained and doesn't interfere with your existing LMS functionality.
