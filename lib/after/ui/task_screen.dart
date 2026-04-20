import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_event.dart';
import '../bloc/intent_router_bloc.dart';
import 'widgets/task_input_section.dart';
import 'widgets/task_list_section.dart';
import 'widgets/task_router_listener.dart';

/// Main screen for the "after" flow.
///
/// Composition is intentionally split into focused widgets:
/// - listener (side effects)
/// - input (intent entry)
/// - list (state projection)
class TaskScreenAfter extends StatelessWidget {
  const TaskScreenAfter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks — AFTER'),
        actions: const [_FilterAction(label: 'All', filter: 'all'), _FilterAction(label: 'Done', filter: 'completed'), _FilterAction(label: 'Pending', filter: 'pending')],
      ),
      body: const Column(
        children: [
          TaskRouterListener(),
          TaskInputSection(),
          Expanded(child: TaskListSection()),
        ],
      ),
    );
  }
}

/// Reusable app bar action that dispatches a raw filter event.
class _FilterAction extends StatelessWidget {
  const _FilterAction({required this.label, required this.filter});

  final String label;
  final String filter;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<IntentRouterBloc>().add(RawFilterTapped(filter)),
      child: Text(label),
    );
  }
}
