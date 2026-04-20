import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/intent_router_bloc.dart';
import 'bloc/task_bloc.dart';
import 'intent/intent_classifier.dart';
import 'ui/task_screen.dart';

class DevPulseBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('🎯 EVENT: ${bloc.runtimeType} → $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint(
      '🔄 STATE: ${bloc.runtimeType}\n'
      '   FROM: ${change.currentState}\n'
      '   TO:   ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('ERROR: ${bloc.runtimeType} → $error');
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('CREATED: ${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('CLOSED: ${bloc.runtimeType}');
  }
}

void main() {
  const anthropicApiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
  Bloc.observer = DevPulseBlocObserver();

  runApp(const AppAfter(apiKey: anthropicApiKey));
}

class AppAfter extends StatelessWidget {
  const AppAfter({super.key, required this.apiKey});

  final String apiKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks — AFTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),

      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => IntentRouterBloc(
              classifier: IntentClassifier(authToken: apiKey),
              taskBloc: TaskBloc(),
            ),
          ),

          BlocProvider(create: (context) => context.read<IntentRouterBloc>().taskBloc),
        ],
        child: const TaskScreenAfter(),
      ),
    );
  }
}
