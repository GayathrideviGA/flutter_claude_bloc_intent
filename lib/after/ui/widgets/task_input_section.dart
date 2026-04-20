import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_event.dart';
import '../../bloc/intent_router_bloc.dart';

/// Text input area where users submit natural-language task commands.
class TaskInputSection extends StatefulWidget {
  const TaskInputSection({super.key});

  @override
  State<TaskInputSection> createState() => _TaskInputSectionState();
}

class _TaskInputSectionState extends State<TaskInputSection> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild only when classifying status changes.
    return BlocBuilder<IntentRouterBloc, IntentRouterState>(
      buildWhen: (previous, current) => current is RouterClassifying || previous is RouterClassifying,
      builder: (context, state) {
        final isClassifying = state is RouterClassifying;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (isClassifying)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Understanding: "${state.rawInput}"',
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !isClassifying,
                      decoration: InputDecoration(
                        hintText: 'Type anything naturally...',
                        hintStyle: const TextStyle(fontSize: 13),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isClassifying ? Colors.blue : Colors.green),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isClassifying ? null : _onSubmitPressed,
                    child: isClassifying
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dispatches raw text to router for classification/routing.
  void _onSubmitPressed() {
    context.read<IntentRouterBloc>().add(RawTextSubmitted(_textController.text));
    _textController.clear();
  }
}
