import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'intent_model.dart';

/// Anthropic API configuration used by [IntentClassifier].
class _ClaudeConfig {
  static const baseUrl = 'https://api.anthropic.com/v1/messages';
  static const model = 'claude-haiku-4-5-20251001';
  static const maxTokens = 200;

  static const timeout = Duration(seconds: 10);
}

/// Builds the prompt that constrains model output to strict task-intent JSON.
class _PromptBuilder {
  static String build(String rawInput) {
    return '''
Classify this task input into JSON only.
No explanation. JSON only.

Input: "$rawInput"

Rules:
- high priority: urgent/asap/critical/bug/crash
- low priority: maybe/someday/later
- medium priority: everything else

Response format:
{"intent":"ADD_TASK","title":"...","priority":"high|medium|low"}
{"intent":"COMPLETE_TASK","taskId":"..."}
{"intent":"DELETE_TASK","taskId":"..."}
{"intent":"FILTER_TASK","filter":"all|completed|pending"}
''';
  }
}

class IntentClassificationException implements Exception {
  final String message;
  final Object? cause;
  IntentClassificationException(this.message, {this.cause});

  @override
  String toString() =>
      'IntentClassificationException: $message'
      '${cause != null ? ' caused by: $cause' : ''}';
}

/// Converts free-text user input into typed [TaskIntent] objects.
///
/// Responsibilities are intentionally split into private stages:
/// 1) HTTP call
/// 2) response parsing
/// 3) domain mapping
class IntentClassifier {
  final String authToken;
  final http.Client _client;

  IntentClassifier({required this.authToken, http.Client? client}) : _client = client ?? http.Client();
  // Uses a real client by default, but supports test injection.

  /// Main entry point used by router to classify raw text.
  Future<TaskIntent> classify(String rawInput) async {
    final sanitized = rawInput.trim();
    if (sanitized.isEmpty) {
      return AddTaskIntent(title: '', priority: 'medium');
    }

    if (authToken.trim().isEmpty) {
      throw IntentClassificationException(
        'Missing ANTHROPIC_TOKEN. Start app with '
        '--dart-define=ANTHROPIC_TOKEN=your_token',
      );
    }

    try {
      final response = await _makeApiCall(sanitized);
      final json = _parseResponse(response);
      return _mapToIntent(json);
    } on IntentClassificationException {
      // Preserve typed error semantics for caller handling.
      rethrow;
    } catch (e) {
      // Normalize unknown failures to a typed domain exception.
      throw IntentClassificationException('Unexpected error during classification', cause: e);
    }
  }

  /// Executes the Anthropic API request and validates response status.
  Future<http.Response> _makeApiCall(String rawInput) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_ClaudeConfig.baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': authToken,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': _ClaudeConfig.model,
              'max_tokens': _ClaudeConfig.maxTokens,
              'messages': [
                {'role': 'user', 'content': _PromptBuilder.build(rawInput)},
              ],
            }),
            // Timeout prevents hung requests from blocking UI flow.
          )
          .timeout(_ClaudeConfig.timeout);
      debugPrint('Claude error body: ${response.body}');
      // Keep HTTP status validation separate from response parsing.
      if (response.statusCode != 200) {
        throw IntentClassificationException('API call failed: ${response.statusCode}');
      }

      return response;
    } on IntentClassificationException {
      rethrow;
    } catch (e) {
      throw IntentClassificationException('Network error', cause: e);
    }
  }

  /// Parses Anthropic response and returns decoded intent JSON payload.
  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Debug logs are helpful while iterating on prompt reliability.
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');
      // Validate shape before reading nested fields.
      if (data['content'] == null || (data['content'] as List).isEmpty) {
        throw IntentClassificationException('Empty response from Claude');
      }

      final text = data['content'][0]['text'] as String;

      // Models occasionally wrap JSON in markdown fences.
      final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw IntentClassificationException('Failed to parse Claude response', cause: e);
    }
  }

  /// Maps decoded JSON to a concrete [TaskIntent] type.
  TaskIntent _mapToIntent(Map<String, dynamic> json) {
    // Intent field is required for route dispatch.
    final intent = json['intent'] as String?;
    if (intent == null) {
      throw IntentClassificationException('Missing intent field in response');
    }

    return switch (intent) {
      'ADD_TASK' => AddTaskIntent(
        // Safe fallback values protect against partial model outputs.
        title: (json['title'] as String?) ?? 'Untitled task',
        priority: (json['priority'] as String?) ?? 'medium',
      ),

      'COMPLETE_TASK' => CompleteTaskIntent(taskId: (json['taskId'] as String?) ?? ''),

      'DELETE_TASK' => DeleteTaskIntent(taskId: (json['taskId'] as String?) ?? ''),

      'FILTER_TASK' => FilterTaskIntent(filter: (json['filter'] as String?) ?? 'all'),

      _ => throw IntentClassificationException('Unknown intent: $intent'),
    };
  }

  /// Releases the underlying HTTP client.
  void dispose() => _client.close();
}
