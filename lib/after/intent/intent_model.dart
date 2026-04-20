sealed class TaskIntent {}

/// Intent to add a new task.
class AddTaskIntent extends TaskIntent {
  final String title;

  final String priority;

  AddTaskIntent({required this.title, required this.priority});
}

/// Intent to mark a task complete/incomplete.
class CompleteTaskIntent extends TaskIntent {
  final String taskId;
  final bool markComplete;

  CompleteTaskIntent({required this.taskId, this.markComplete = true});
}

/// Intent to delete an existing task.
class DeleteTaskIntent extends TaskIntent {
  final String taskId;
  DeleteTaskIntent({required this.taskId});
}

/// Intent to change active task filter.
class FilterTaskIntent extends TaskIntent {
  final String filter;
  FilterTaskIntent({required this.filter});
}

/**
 * BEFORE:
taskCubit.addTask(text)
→ Method call
→ Gone into void
→ Nothing logged
→ Nothing traced

AFTER:
AddTaskIntent(title: "Fix login", priority: "high")
→ Named domain intent
→ Logged by BlocObserver
→ Traced in timeline
→ Testable independently
→ Claude extracted priority automatically
 */
