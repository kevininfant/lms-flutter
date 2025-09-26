import 'package:equatable/equatable.dart';

enum TodoEventType { course, reminder, task }

enum TodoEventStatus { completed, overdue, due, pending }

class TodoEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TodoEventType type;
  final TodoEventStatus status;
  final String? thumbnailPath;
  final String? courseId;
  final DateTime? dueDate;
  final DateTime? completedDate;

  const TodoEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.status,
    this.thumbnailPath,
    this.courseId,
    this.dueDate,
    this.completedDate,
  });

  TodoEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TodoEventType? type,
    TodoEventStatus? status,
    String? thumbnailPath,
    String? courseId,
    DateTime? dueDate,
    DateTime? completedDate,
  }) {
    return TodoEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      courseId: courseId ?? this.courseId,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    type,
    status,
    thumbnailPath,
    courseId,
    dueDate,
    completedDate,
  ];
}
