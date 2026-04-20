import 'package:equatable/equatable.dart';

/// Raw events emitted by UI components before intent classification/routing.
sealed class RawUIEvent extends Equatable {
  const RawUIEvent();
}

/// User submitted free-form text that requires classification.
class RawTextSubmitted extends RawUIEvent {
  /// Raw user input sent to the classifier as-is.
  final String text;

  const RawTextSubmitted(this.text);

  @override
  List<Object?> get props => [text];
}

/// User tapped complete/uncomplete for a specific task.
class RawTaskCompleteTapped extends RawUIEvent {
  final String taskId;
  final bool markComplete;

  const RawTaskCompleteTapped(this.taskId, {required this.markComplete});

  @override
  List<Object?> get props => [taskId, markComplete];
}

/// User tapped delete for a specific task.
class RawTaskDeleteTapped extends RawUIEvent {
  final String taskId;

  const RawTaskDeleteTapped(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// User selected a filter from the UI ("All", "Done", "Pending").
class RawFilterTapped extends RawUIEvent {
  final String filterLabel;

  const RawFilterTapped(this.filterLabel);

  @override
  List<Object?> get props => [filterLabel];
}
