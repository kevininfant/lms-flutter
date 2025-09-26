import 'package:flutter/material.dart';
import '../models/todo_event.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddEventScreen({super.key, this.initialDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TodoEventType _selectedType = TodoEventType.task;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = TodoEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        type: _selectedType,
        status: TodoEventStatus.pending,
        dueDate: _dueDate,
      );

      // TODO: Save event to service
      Navigator.of(context).pop(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Event',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Selection
              _buildSectionTitle('Event Type'),
              _buildTypeSelector(),

              const SizedBox(height: 24),

              // Title Field
              _buildSectionTitle('Title'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter event title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description Field
              _buildSectionTitle('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter event description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Date Selection
              _buildSectionTitle('Event Date'),
              _buildDateSelector('Event Date', _selectedDate, _selectDate),

              const SizedBox(height: 16),

              // Due Date Selection (optional)
              _buildSectionTitle('Due Date (Optional)'),
              _buildDateSelector(
                _dueDate != null
                    ? 'Due: ${_formatDate(_dueDate!)}'
                    : 'Select due date',
                _dueDate,
                _selectDueDate,
                isOptional: true,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Event',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: TodoEventType.values.map((type) {
          return RadioListTile<TodoEventType>(
            title: Text(_getTypeLabel(type)),
            subtitle: Text(_getTypeDescription(type)),
            value: type,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
            activeColor: _getTypeColor(type),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    VoidCallback onTap, {
    bool isOptional = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null ? _formatDate(date) : label,
                style: TextStyle(
                  fontSize: 16,
                  color: date != null ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
            if (isOptional && date != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _dueDate = null;
                  });
                },
                icon: const Icon(Icons.clear, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(TodoEventType type) {
    switch (type) {
      case TodoEventType.course:
        return 'Course';
      case TodoEventType.reminder:
        return 'Reminder';
      case TodoEventType.task:
        return 'Task';
    }
  }

  String _getTypeDescription(TodoEventType type) {
    switch (type) {
      case TodoEventType.course:
        return 'Learning course or training material';
      case TodoEventType.reminder:
        return 'Important reminder or notification';
      case TodoEventType.task:
        return 'General task or assignment';
    }
  }

  Color _getTypeColor(TodoEventType type) {
    switch (type) {
      case TodoEventType.course:
        return Colors.blue;
      case TodoEventType.reminder:
        return Colors.orange;
      case TodoEventType.task:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
