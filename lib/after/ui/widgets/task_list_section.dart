import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_state.dart';
import '../../bloc/task_bloc.dart';
import 'task_tile.dart';

/// Renders task list projections from [TaskBloc] state.
class TaskListSection extends StatelessWidget {
  const TaskListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return switch (state) {
          TaskInitial() => const Center(
              child: Text(
                'Type anything to add a task\n'
                '"fix login bug urgent"\n'
                '"add dark mode maybe"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          TaskClassifying() =>
            const Center(child: CircularProgressIndicator()),
          TaskLoaded() => state.filteredTasks.isEmpty
              ? const Center(child: Text('No tasks here'))
              : ListView.builder(
                  itemCount: state.filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = state.filteredTasks[index];
                    return TaskTile(task: task);
                  },
                ),
          TaskError() => Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        };
      },
    );
  }
}
