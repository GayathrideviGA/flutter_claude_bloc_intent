import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_claude_bloc_intent/after/intent/intent_model.dart';
import '../../bloc/intent_router_bloc.dart';

/// Dedicated side-effect listener for router states.
///
/// Keeps snackbars and transient UI reactions out of render widgets.
class TaskRouterListener extends StatelessWidget {
  const TaskRouterListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<IntentRouterBloc, IntentRouterState>(
      listener: (context, state) {
        if (state is RouterError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }

        if (state is RouterClassified) {
          final intent = state.intent;
          if (intent is AddTaskIntent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added: ${intent.title} ✅'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
