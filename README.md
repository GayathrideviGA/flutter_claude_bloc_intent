# flutter-claude-bloc-intent

> Claude AI as an intent layer between raw UI events and BLoC.
> Same app. Same features. Different pattern. Different code quality.

---

## The Problem

Every Flutter BLoC developer hits these walls:

| Pain | What happens |
|---|---|
| Side effects in `BlocBuilder` | Snackbar double fires |
| Cubit everywhere | No event trace, nothing to log |
| Multi-cubit wiring | 4+ providers, unclear ownership |

---

## Before vs After

### Provider Wiring

```dart
// BEFORE — grows every feature
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => TaskCubit()),
    BlocProvider(create: (_) => FilterCubit()),
    BlocProvider(create: (_) => SearchCubit()),
    BlocProvider(create: (_) => SortCubit()),
  ],
)

// AFTER — always one
BlocProvider(
  create: (_) => IntentRouterBloc(
    classifier: IntentClassifier(authToken: token),
    taskBloc: TaskBloc(),
  ),
)
```

---

### Event Trace

```dart
// BEFORE — method call, gone into void
taskCubit.addTask(text);
taskCubit.deleteTask(id);
// What happened? Nobody knows.

// AFTER — full trace via BlocObserver
// EVENT: IntentRouterBloc → RawTextSubmitted
// STATE: RouterIdle → RouterClassifying
// EVENT: TaskBloc → AddTaskIntent
// STATE: TaskLoaded(1 task)
```

---

### Side Effects

```dart
// BEFORE — side effect in BlocBuilder
// Double fires. Unpredictable timing.
BlocBuilder<TaskCubit, TaskState>(
  builder: (context, state) {
    if (state.errorMessage != null) {
      WidgetsBinding.instance
        .addPostFrameCallback((_) {
          showSnackBar(state.errorMessage!);
          cubit.clearError(); // extra cleanup
        });
    }
    return TaskList();
  }
)

// AFTER — side effect in BlocListener
// Fires once. Atomic. No cleanup needed.
BlocListener<IntentRouterBloc, IntentRouterState>(
  listener: (context, state) {
    if (state is RouterError) {
      showSnackBar(state.message);
      // No cleanup method needed
      // State transition handles it
    }
  },
)
```

---

### BLoC Size

```dart
// BEFORE — fat cubit
// 6 methods, 2 are just UI cleanup
void addTask(String title) { }
void completeTask(String id) { }
void deleteTask(String id) { }
void filterTasks(String filter) { }
void clearError() { }        // ← UI cleanup
void resetTaskAdded() { }    // ← UI cleanup

// AFTER — thin bloc
// 4 handlers, zero UI concerns
on<AddTaskIntent>((event, emit) { });
on<CompleteTaskIntent>((event, emit) { });
on<DeleteTaskIntent>((event, emit) { });
on<FilterTaskIntent>((event, emit) { });
```

---

## Architecture

```
UI Layer
────────────────────────────────────────
User types anything naturally
  "fix login crash urgent"
  "add dark mode maybe"
  "show completed tasks"
        ↓
RawUIEvent fired to IntentRouterBloc
        ↓
────────────────────────────────────────
Intent Layer (Claude API)
────────────────────────────────────────
Claude classifies raw input
  → AddTaskIntent(title, priority)
  → FilterTaskIntent(filter)
  → CompleteTaskIntent(taskId)
        ↓
IntentRouterBloc routes to
correct domain BLoC
        ↓
────────────────────────────────────────
Domain Layer (TaskBloc)
────────────────────────────────────────
Pure business logic only
  Zero raw input handling
  Zero language detection
  Zero UI concerns
        ↓
TaskState emitted
        ↓
────────────────────────────────────────
UI Layer
────────────────────────────────────────
BlocBuilder  → rebuilds UI
BlocListener → handles side effects
```

---

## Folder Structure

```
lib/
├── before/                          ← painful pattern
│   ├── cubit/
│   │   └── task_cubit.dart          ← methods, no trace
│   ├── state/
│   │   ├── task_model.dart
│   │   └── task_state.dart          ← heavy, UI concerns
│   └── ui/
│       └── task_screen.dart         ← leaky boundary
│
├── after/                           ← clean pattern
│   ├── intent/
│   │   ├── intent_classifier.dart   ← Claude lives here
│   │   ├── intent_model.dart        ← sealed intents
│   │   ├── task_event.dart          ← raw UI events
│   │   └── task_state.dart          ← pure domain state
│   ├── bloc/
│   │   ├── intent_router_bloc.dart  ← central command
│   │   └── task_bloc.dart           ← pure domain logic
│   └── ui/
│       ├── task_screen.dart
│       └── widgets/
│           ├── task_input_section.dart
│           ├── task_list_section.dart
│           ├── task_priority_badge.dart
│           ├── task_router_listener.dart
│           └── task_tile.dart
│
└── main.dart
```

---

## Run

```bash
# See the pain
flutter run -t lib/before/main_before.dart -d chrome

# See the solution
flutter run -t lib/after/main_after.dart \
  --dart-define=ANTHROPIC_TOKEN=your_token_here
```

---

## Key Concepts

| Concept | File | What it does |
|---|---|---|
| `IntentRouterBloc` | `after/bloc/intent_router_bloc.dart` | Central command — routes all intents |
| `IntentClassifier` | `after/intent/intent_classifier.dart` | Claude API — classifies raw input |
| `TaskIntent` | `after/intent/intent_model.dart` | Sealed domain intents |
| `RawUIEvent` | `after/intent/task_event.dart` | Raw UI events — no business logic |
| `TaskBloc` | `after/bloc/task_bloc.dart` | Pure domain — never sees raw input |

---

## What Claude Does Here

Claude is not a chatbot here.
Claude is an architectural boundary.

```
Without Claude:
BLoC understands language   → BLoC changes when language changes
BLoC understands UI events  → BLoC changes when UI changes
BLoC changes always         → fragile

With Claude:
BLoC understands domain only        → BLoC changes only when
business logic changes              → correct behavior
```

---

## The Numbers

| | Before | After |
|---|---|---|
| Providers | 4+ | 1 |
| BLoC handlers | 6 methods | 4 handlers |
| UI cleanup methods | 2 | 0 |
| if/else blocks | 20+ | 0 |
| Event trace | None | Full |
| Languages supported | 1 | Any |
| Double fire risk | High | Zero |
| Testable | Hard | Easy |

---
