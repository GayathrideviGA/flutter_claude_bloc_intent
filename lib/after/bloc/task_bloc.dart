import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_state.dart';

import 'package:uuid/uuid.dart';

import '../intent/intent_model.dart';

/// Domain BLoC that applies typed [TaskIntent] actions to [TaskState].
///
/// This bloc does not parse natural language; it only executes already-typed
/// domain intents produced by the router/classifier layer.
class TaskBloc extends Bloc<TaskIntent, TaskState> {
  final _uuid = const Uuid();

  TaskBloc() : super(const TaskInitial()) {
    // Add a new task into current collection.
    on<AddTaskIntent>((event, emit) {
      final currentTasks = state is TaskLoaded ? (state as TaskLoaded).tasks : <TaskItem>[];

      final newTask = TaskItem(id: _uuid.v4(), title: event.title, priority: _mapPriority(event.priority));

      emit(TaskLoaded(tasks: [...currentTasks, newTask], lastIntent: event));
    });

    // Toggle completion status for a specific task.
    on<CompleteTaskIntent>((event, emit) {
      if (state is! TaskLoaded) return;
      final current = state as TaskLoaded;

      final updatedTasks = current.tasks.map((task) {
        if (task.id == event.taskId) {
          return task.copyWith(isCompleted: event.markComplete);
        }
        return task;
      }).toList();

      emit(current.copyWith(tasks: updatedTasks, lastIntent: event));
    });

    // Remove a task by id.
    on<DeleteTaskIntent>((event, emit) {
      if (state is! TaskLoaded) return;
      final current = state as TaskLoaded;

      final updatedTasks = current.tasks.where((task) => task.id != event.taskId).toList();

      emit(current.copyWith(tasks: updatedTasks, lastIntent: event));
    });

    // Update active filter used by UI projections.
    on<FilterTaskIntent>((event, emit) {
      if (state is! TaskLoaded) return;
      final current = state as TaskLoaded;

      final filter = _mapFilter(event.filter);

      emit(current.copyWith(activeFilter: filter, lastIntent: event));
    });
  }

  /// Converts raw classifier priority value into a typed enum.
  TaskPriority _mapPriority(String priority) {
    return switch (priority) {
      'high' => TaskPriority.high,
      'low' => TaskPriority.low,
      _ => TaskPriority.medium,
    };
  }

  /// Converts raw classifier filter value into a typed enum.
  TaskFilter _mapFilter(String filter) {
    return switch (filter) {
      'completed' => TaskFilter.completed,
      'pending' => TaskFilter.pending,
      _ => TaskFilter.all,
    };
  }
}
