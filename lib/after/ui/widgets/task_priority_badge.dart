import 'package:flutter/material.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_state.dart';

/// Small badge that visually represents task priority.
class TaskPriorityBadge extends StatelessWidget {
  const TaskPriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      TaskPriority.high => (Colors.red, 'HIGH'),
      TaskPriority.medium => (Colors.orange, 'MED'),
      TaskPriority.low => (Colors.green, 'LOW'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
