import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../state/task_model.dart';
import '../state/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final _uuid = const Uuid();

  TaskCubit() : super(const TaskState());

  // Method 1 — Add task
  void addTask(String title) {
    if (title.isEmpty) {
      emit(state.copyWith(errorMessage: 'Task cannot be empty'));
      return;
    }

    final newTask = Task(id: _uuid.v4(), title: title);

    emit(state.copyWith(tasks: [...state.tasks, newTask], isTaskAdded: true, errorMessage: null));
  }

  // Method 2 — Complete task
  void completeTask(String id) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: true);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedTasks));
  }

  // Method 3 — Delete task
  void deleteTask(String id) {
    final updatedTasks = state.tasks.where((task) => task.id != id).toList();

    emit(state.copyWith(tasks: updatedTasks));
  }

  // Method 4 — Filter tasks
  void filterTasks(String filter) {
    emit(state.copyWith(filter: filter));
  }

  // Method 5 — Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  // Method 6 — Reset task added flag
  void resetTaskAdded() {
    emit(state.copyWith(isTaskAdded: false));
  }
}

/**
Pain 1 — Leaky boundary
   isTaskAdded → UI concern in state
   errorMessage → UI concern in state
   Both cause double fire in BlocBuilder

Pain 2 — No event trace
   addTask() → method, gone
   deleteTask() → method, gone
   "What happened?" → nobody knows
   BlocObserver cannot help you

Pain 3 — Boilerplate chain
   New feature →
   New method in cubit →
   New field in state →
   New param in copyWith →
   New condition in UI →
   4 files touched for 1 feature
 */
