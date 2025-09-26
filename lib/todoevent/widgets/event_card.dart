import 'package:flutter/material.dart';
import '../models/todo_event.dart';

class EventCard extends StatelessWidget {
  final TodoEvent event;
  final bool isSelected;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              _buildThumbnail(),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type label
                    _buildTypeLabel(),

                    const SizedBox(height: 4),

                    // Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      event.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Status indicator
              _buildStatusIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: _getThumbnailGradient(),
      ),
      child: Icon(_getThumbnailIcon(), color: Colors.white, size: 24),
    );
  }

  Widget _buildTypeLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getTypeLabel(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getStatusText(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _getStatusColor(),
          ),
        ),
      ],
    );
  }

  LinearGradient _getThumbnailGradient() {
    switch (event.type) {
      case TodoEventType.course:
        return const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case TodoEventType.reminder:
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case TodoEventType.task:
        return const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getThumbnailIcon() {
    switch (event.type) {
      case TodoEventType.course:
        return Icons.lightbulb_outline;
      case TodoEventType.reminder:
        return Icons.keyboard;
      case TodoEventType.task:
        return Icons.assignment;
    }
  }

  Color _getTypeColor() {
    switch (event.type) {
      case TodoEventType.course:
        return Colors.blue;
      case TodoEventType.reminder:
        return Colors.orange;
      case TodoEventType.task:
        return Colors.purple;
    }
  }

  String _getTypeLabel() {
    switch (event.type) {
      case TodoEventType.course:
        return 'Course';
      case TodoEventType.reminder:
        return 'Your Reminder';
      case TodoEventType.task:
        return 'Task';
    }
  }

  Color _getStatusColor() {
    switch (event.status) {
      case TodoEventStatus.completed:
        return Colors.green;
      case TodoEventStatus.overdue:
        return Colors.red;
      case TodoEventStatus.due:
        return Colors.orange;
      case TodoEventStatus.pending:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (event.status) {
      case TodoEventStatus.completed:
        return 'Completed';
      case TodoEventStatus.overdue:
        return 'Overdue';
      case TodoEventStatus.due:
        return 'Due';
      case TodoEventStatus.pending:
        return 'Pending';
    }
  }
}
