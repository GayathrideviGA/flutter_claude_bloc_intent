import 'package:flutter/material.dart';
import 'package:flutter_claude_bloc_intent/before/ui/task_screen.dart';

// BEFORE - entry point
// Simple — but notice
// as app grows this becomes
// MultiBlocProvider with
// 4, 5, 6 providers nested
// That is Pain 3 waiting to happen

void main() {
  runApp(const AppBefore());
}

class AppBefore extends StatelessWidget {
  const AppBefore({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks — BEFORE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      home: const TaskScreenBefore(),
    );
  }
}
