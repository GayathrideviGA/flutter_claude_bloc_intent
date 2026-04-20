import 'package:equatable/equatable.dart';
import 'task_model.dart';

class TaskState extends Equatable {
  final List<Task> tasks;

  final bool isLoading;

  final String? errorMessage;

  final bool isTaskAdded;

  final String filter;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isTaskAdded = false,
    this.filter = 'all',
  });

  TaskState copyWith({List<Task>? tasks, bool? isLoading, String? errorMessage, bool? isTaskAdded, String? filter}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isTaskAdded: isTaskAdded ?? this.isTaskAdded,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [tasks, isLoading, errorMessage, isTaskAdded, filter];
}
