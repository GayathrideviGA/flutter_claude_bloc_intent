import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_claude_bloc_intent/after/intent/task_event.dart';
import '../intent/intent_classifier.dart';
import '../intent/intent_model.dart';

import 'task_bloc.dart';

/// States emitted by [IntentRouterBloc].
sealed class IntentRouterState extends Equatable {
  const IntentRouterState();
}

/// Router is idle and ready to process incoming UI events.
class RouterIdle extends IntentRouterState {
  const RouterIdle();

  @override
  List<Object?> get props => [];
}

/// Router is classifying free-text input via the AI classifier.
///
/// UI can use this state to disable submit and show progress feedback.
class RouterClassifying extends IntentRouterState {
  final String rawInput;

  const RouterClassifying({required this.rawInput});

  @override
  List<Object?> get props => [rawInput];
}

/// Router finished classification and dispatched an intent.
///
/// UI side effects (snackbars/toasts) can react to this state.
class RouterClassified extends IntentRouterState {
  // What intent was produced
  final TaskIntent intent;

  const RouterClassified({required this.intent});

  @override
  List<Object?> get props => [intent];
}

/// Router failed to classify or validate incoming input.
class RouterError extends IntentRouterState {
  final String message;

  const RouterError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Application-level orchestration BLoC.
///
/// Responsibilities:
/// - Accept raw UI events
/// - Classify free-form text into domain intents
/// - Forward typed intents to the appropriate domain BLoC ([TaskBloc])
class IntentRouterBloc extends Bloc<RawUIEvent, IntentRouterState> {
  /// AI-backed classifier used only for ambiguous free-text input.
  final IntentClassifier _classifier;

  /// Domain bloc that applies task mutations.
  final TaskBloc taskBloc;

  IntentRouterBloc({required IntentClassifier classifier, required this.taskBloc})
    : _classifier = classifier,
      super(const RouterIdle()) {
    on<RawTextSubmitted>(_onRawTextSubmitted);

    on<RawTaskCompleteTapped>(_onRawTaskCompleteTapped);

    on<RawTaskDeleteTapped>(_onRawTaskDeleteTapped);

    on<RawFilterTapped>(_onRawFilterTapped);
  }

  Future<void> _onRawTextSubmitted(RawTextSubmitted event, Emitter<IntentRouterState> emit) async {
    // Avoid calling classifier for empty input.
    if (event.text.trim().isEmpty) {
      emit(const RouterError(message: 'Please enter something'));

      emit(const RouterIdle());
      return;
    }

    // Notify UI to render loading/progress state.
    emit(RouterClassifying(rawInput: event.text));

    try {
      final intent = await _classifier.classify(event.text);

      _routeIntent(intent);

      // Notify UI that routing completed for this input.
      emit(RouterClassified(intent: intent));

      emit(const RouterIdle());
    } on IntentClassificationException catch (e) {
      emit(RouterError(message: e.message));
      emit(const RouterIdle());
    }
  }

  /// Handles complete/uncomplete taps (no AI required).
  void _onRawTaskCompleteTapped(RawTaskCompleteTapped event, Emitter<IntentRouterState> emit) {
    taskBloc.add(CompleteTaskIntent(taskId: event.taskId, markComplete: event.markComplete));

    emit(
      RouterClassified(
        intent: CompleteTaskIntent(taskId: event.taskId, markComplete: event.markComplete),
      ),
    );
    emit(const RouterIdle());
  }

  /// Handles delete taps (no AI required).
  void _onRawTaskDeleteTapped(RawTaskDeleteTapped event, Emitter<IntentRouterState> emit) {
    taskBloc.add(DeleteTaskIntent(taskId: event.taskId));

    emit(RouterClassified(intent: DeleteTaskIntent(taskId: event.taskId)));
    emit(const RouterIdle());
  }

  /// Handles filter toggles from UI labels.
  void _onRawFilterTapped(RawFilterTapped event, Emitter<IntentRouterState> emit) {
    // Normalize UI labels into domain filter keys.
    final filter = switch (event.filterLabel.toLowerCase()) {
      'done' || 'completed' => 'completed',
      'pending' => 'pending',
      _ => 'all',
    };

    taskBloc.add(FilterTaskIntent(filter: filter));

    emit(RouterClassified(intent: FilterTaskIntent(filter: filter)));
    emit(const RouterIdle());
  }

  /// For now all routed intents target [TaskBloc].
  ///
  /// If the app grows to multiple domains, this becomes a dispatch table.
  void _routeIntent(TaskIntent intent) {
    taskBloc.add(intent);
  }

  @override
  Future<void> close() {
    taskBloc.close();
    _classifier.dispose();
    return super.close();
  }
}
