import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final String monthYear;
  final int totalActivities;
  final VoidCallback? onMonthTap;
  final VoidCallback? onFilterTap;

  const CalendarHeader({
    super.key,
    required this.monthYear,
    required this.totalActivities,
    this.onMonthTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Month/Year with dropdown indicator
          Expanded(
            child: GestureDetector(
              onTap: onMonthTap,
              child: Row(
                children: [
                  Text(
                    monthYear,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black54,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Activities count
          Text(
            '$totalActivities activities available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          const SizedBox(width: 16),

          // Filter/Menu button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune, color: Colors.amber[800], size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
