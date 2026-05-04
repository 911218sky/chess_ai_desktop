import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/session_config.dart';

class LlmCommentaryService {
  LlmCommentaryService({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  Future<List<String>> fetchModels(LlmSettings settings) async {
    return switch (settings.providerKind) {
      LlmProviderKind.anthropicClaude => _fetchAnthropicModels(settings),
      _ => _fetchOpenAiCompatibleModels(settings),
    };
  }

  Future<void> testConnection(LlmSettings settings) async {
    final models = await fetchModels(settings);
    if (models.isEmpty) {
      throw const LlmException(
        'Connection worked, but no models were returned.',
      );
    }
  }

  Future<LlmCompletionResult> complete({
    required LlmSettings settings,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    return switch (settings.providerKind) {
      LlmProviderKind.anthropicClaude => _completeAnthropic(
        settings: settings,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      ),
      _ => _completeOpenAiCompatible(
        settings: settings,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      ),
    };
  }

  Future<List<String>> _fetchOpenAiCompatibleModels(
    LlmSettings settings,
  ) async {
    final payload = await _sendJson(
      method: 'GET',
      uri: _uri(settings.baseUrl, 'models'),
      settings: settings,
      timeout: const Duration(seconds: 20),
    );

    final data = payload is Map<String, Object?> ? payload['data'] : null;
    if (data is! List) {
      throw const LlmException('Models response did not include a data list.');
    }

    final models = <String>[];
    for (final item in data) {
      if (item is Map<String, Object?> && item['id'] is String) {
        models.add(item['id']! as String);
      }
    }
    models.sort();
    return models;
  }

  Future<List<String>> _fetchAnthropicModels(LlmSettings settings) async {
    final payload = await _sendJson(
      method: 'GET',
      uri: _uri(settings.baseUrl, 'models'),
      settings: settings,
      timeout: const Duration(seconds: 20),
    );

    final data = payload is Map<String, Object?> ? payload['data'] : null;
    if (data is! List) {
      throw const LlmException('Models response did not include a data list.');
    }

    final models = <String>[];
    for (final item in data) {
      if (item is Map<String, Object?> && item['id'] is String) {
        models.add(item['id']! as String);
      }
    }
    models.sort();
    return models;
  }

  Future<LlmCompletionResult> _completeOpenAiCompatible({
    required LlmSettings settings,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final startedAt = DateTime.now();
    final payload = await _sendJson(
      method: 'POST',
      uri: _uri(settings.baseUrl, 'chat/completions'),
      settings: settings,
      timeout: const Duration(seconds: 24),
      body: {
        'model': settings.model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.8,
        'max_tokens': 90,
      },
    );

    final choices = payload is Map<String, Object?> ? payload['choices'] : null;
    if (choices is! List || choices.isEmpty) {
      throw const LlmException('Chat response did not include choices.');
    }
    final latencyMs = DateTime.now().difference(startedAt).inMilliseconds;
    final usage = payload is Map<String, Object?>
        ? LlmTokenUsage.fromJson(payload['usage'])
        : null;

    final first = choices.first;
    if (first is! Map<String, Object?>) {
      throw const LlmException('Chat choice format was not recognized.');
    }

    final message = first['message'];
    if (message is Map<String, Object?> && message['content'] is String) {
      final content = (message['content']! as String).trim();
      if (content.isNotEmpty) {
        return LlmCompletionResult(
          text: content,
          usage: usage,
          latencyMs: latencyMs,
        );
      }
    }

    final text = first['text'];
    if (text is String && text.trim().isNotEmpty) {
      return LlmCompletionResult(
        text: text.trim(),
        usage: usage,
        latencyMs: latencyMs,
      );
    }

    throw const LlmException('Chat response was empty.');
  }

  Future<LlmCompletionResult> _completeAnthropic({
    required LlmSettings settings,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final startedAt = DateTime.now();
    final payload = await _sendJson(
      method: 'POST',
      uri: _uri(settings.baseUrl, 'messages'),
      settings: settings,
      timeout: const Duration(seconds: 24),
      body: {
        'model': settings.model,
        'system': systemPrompt,
        'max_tokens': 90,
        'temperature': 0.8,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      },
    );

    final latencyMs = DateTime.now().difference(startedAt).inMilliseconds;
    final usage = payload is Map<String, Object?>
        ? LlmTokenUsage.fromAnthropicJson(payload['usage'])
        : null;

    final content = payload is Map<String, Object?> ? payload['content'] : null;
    if (content is! List || content.isEmpty) {
      throw const LlmException('Claude response did not include content.');
    }

    for (final block in content) {
      if (block is Map<String, Object?> &&
          block['type'] == 'text' &&
          block['text'] is String) {
        final text = (block['text']! as String).trim();
        if (text.isNotEmpty) {
          return LlmCompletionResult(
            text: text,
            usage: usage,
            latencyMs: latencyMs,
          );
        }
      }
    }

    throw const LlmException('Claude response was empty.');
  }

  Future<Object?> _sendJson({
    required String method,
    required Uri uri,
    required LlmSettings settings,
    required Duration timeout,
    Map<String, Object?>? body,
  }) async {
    final request = await _client.openUrl(method, uri).timeout(timeout);
    request.headers.contentType = ContentType.json;
    final apiKey = settings.apiKey.trim();
    if (settings.providerKind.usesAnthropicApi) {
      if (apiKey.isNotEmpty) {
        request.headers.set('x-api-key', apiKey);
      }
      request.headers.set('anthropic-version', '2023-06-01');
    } else if (apiKey.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
    }
    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close().timeout(timeout);
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final endpoint = uri.pathSegments.isEmpty
          ? uri.path
          : uri.pathSegments.last;
      throw LlmException(
        '$endpoint request failed: ${response.statusCode} $responseBody',
      );
    }
    return jsonDecode(responseBody);
  }

  Uri _uri(String baseUrl, String path) {
    final trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$trimmed/$path');
  }

  void dispose() {
    _client.close(force: true);
  }
}

class LlmCompletionResult {
  const LlmCompletionResult({
    required this.text,
    required this.usage,
    required this.latencyMs,
  });

  final String text;
  final LlmTokenUsage? usage;
  final int latencyMs;
}

class LlmTokenUsage {
  const LlmTokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  factory LlmTokenUsage.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      return const LlmTokenUsage(
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
      );
    }
    final prompt = _intValue(json['prompt_tokens']);
    final completion = _intValue(json['completion_tokens']);
    final total = json.containsKey('total_tokens')
        ? _intValue(json['total_tokens'])
        : prompt + completion;
    return LlmTokenUsage(
      promptTokens: prompt,
      completionTokens: completion,
      totalTokens: total,
    );
  }

  factory LlmTokenUsage.fromAnthropicJson(Object? json) {
    if (json is! Map<String, Object?>) {
      return const LlmTokenUsage(
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
      );
    }
    final prompt = _intValue(json['input_tokens']);
    final completion = _intValue(json['output_tokens']);
    return LlmTokenUsage(
      promptTokens: prompt,
      completionTokens: completion,
      totalTokens: prompt + completion,
    );
  }
}

int _intValue(Object? value) {
  return switch (value) {
    final int number => number,
    final num number => number.round(),
    final String text => int.tryParse(text) ?? 0,
    _ => 0,
  };
}

class LlmException implements Exception {
  const LlmException(this.message);

  final String message;

  @override
  String toString() => message;
}
