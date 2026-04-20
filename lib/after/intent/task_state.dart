import 'package:equatable/equatable.dart';
import '../intent/intent_model.dart';

/// Base state for task domain rendering.
sealed class TaskState extends Equatable {
  const TaskState();
}

/// Initial state before any task exists.
class TaskInitial extends TaskState {
  const TaskInitial();

  @override
  List<Object?> get props => [];
}

/// Placeholder for classifying state (currently router-driven in UI).
class TaskClassifying extends TaskState {
  final String rawInput;

  const TaskClassifying({required this.rawInput});

  @override
  List<Object?> get props => [rawInput];
}

/// Main state that stores tasks and projection metadata.
class TaskLoaded extends TaskState {
  final List<TaskItem> tasks;

  final TaskFilter activeFilter;

  final TaskIntent? lastIntent;

  const TaskLoaded({required this.tasks, this.activeFilter = TaskFilter.all, this.lastIntent});

  /// Returns the filtered task projection for the active filter.
  List<TaskItem> get filteredTasks {
    return switch (activeFilter) {
      TaskFilter.all => tasks,
      TaskFilter.completed => tasks.where((t) => t.isCompleted).toList(),
      TaskFilter.pending => tasks.where((t) => !t.isCompleted).toList(),
    };
  }

  /// Immutable update helper for [TaskLoaded].
  TaskLoaded copyWith({List<TaskItem>? tasks, TaskFilter? activeFilter, TaskIntent? lastIntent}) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      activeFilter: activeFilter ?? this.activeFilter,
      lastIntent: lastIntent ?? this.lastIntent,
    );
  }

  @override
  List<Object?> get props => [tasks, activeFilter, lastIntent];
}

/// Error state for domain failures.
class TaskError extends TaskState {
  final String message;

  final TaskIntent? failedIntent;

  const TaskError({required this.message, this.failedIntent});

  @override
  List<Object?> get props => [message, failedIntent];
}

enum TaskFilter { all, completed, pending }

/// Task entity used by list presentation and mutations.
class TaskItem extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  final TaskPriority priority;

  const TaskItem({required this.id, required this.title, required this.priority, this.isCompleted = false});

  TaskItem copyWith({String? id, String? title, bool? isCompleted, TaskPriority? priority}) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, priority];
}

enum TaskPriority { high, medium, low }
