import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/task_cubit.dart';
import '../state/task_state.dart';
import '../state/task_model.dart';

class TaskScreenBefore extends StatelessWidget {
  const TaskScreenBefore({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => TaskCubit(), child: const _TaskScreenBody());
  }
}

class _TaskScreenBody extends StatefulWidget {
  const _TaskScreenBody();

  @override
  State<_TaskScreenBody> createState() => _TaskScreenBodyState();
}

class _TaskScreenBodyState extends State<_TaskScreenBody> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        if (state.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red));
            context.read<TaskCubit>().clearError();
          });
        }

        if (state.isTaskAdded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Task added successfully'), backgroundColor: Colors.green));
            context.read<TaskCubit>().resetTaskAdded();
          });
        }

        final filteredTasks = state.filter == 'completed'
            ? state.tasks.where((t) => t.isCompleted).toList()
            : state.filter == 'pending'
            ? state.tasks.where((t) => !t.isCompleted).toList()
            : state.tasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks — BEFORE'),
            actions: [
              TextButton(onPressed: () => context.read<TaskCubit>().filterTasks('all'), child: const Text('All')),
              TextButton(
                onPressed: () => context.read<TaskCubit>().filterTasks('completed'),
                child: const Text('Done'),
              ),
              TextButton(
                onPressed: () => context.read<TaskCubit>().filterTasks('pending'),
                child: const Text('Pending'),
              ),
            ],
          ),

          body: Column(
            children: [
              // Input section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(hintText: 'Add a task...', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TaskCubit>().addTask(_textController.text);
                        _textController.clear();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),

              if (state.isLoading) const CircularProgressIndicator(),

              // Task list
              Expanded(
                child: filteredTasks.isEmpty
                    ? const Center(child: Text('No tasks yet'))
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return _TaskTile(task: task);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: task.isCompleted, onChanged: (_) => context.read<TaskCubit>().completeTask(task.id)),
      title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => context.read<TaskCubit>().deleteTask(task.id),
      ),
    );
  }
}

/**
 Pain 1 — Leaky boundary
   Side effects inside BlocBuilder
   addPostFrameCallback workaround
   UI doing filter logic
   Child widget tightly coupled to cubit

Pain 2 — No event trace
   context.read<TaskCubit>().addTask()
   context.read<TaskCubit>().deleteTask()
   context.read<TaskCubit>().completeTask()
   All method calls — nothing logged

Pain 3 — Boilerplate
   clearError() called from UI
   resetTaskAdded() called from UI
   UI managing cubit cleanup
   That is not UI's job
 */
