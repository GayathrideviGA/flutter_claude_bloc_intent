import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_event.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_state.dart';
import '../../bloc/intent_router_bloc.dart';
import 'task_priority_badge.dart';

/// Presentational tile for a single task item.
///
/// User actions emit raw events back to [IntentRouterBloc].
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TaskPriorityBadge(priority: task.priority),
      title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () =>
                context.read<IntentRouterBloc>().add(RawTaskCompleteTapped(task.id, markComplete: !task.isCompleted)),
            child: Text(task.isCompleted ? '✅' : '⭕', style: const TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => context.read<IntentRouterBloc>().add(RawTaskDeleteTapped(task.id)),
            child: const Text('🗑', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
