import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class AiServiceException implements Exception {
  final String message;

  const AiServiceException(this.message);

  @override
  String toString() => message;
}

class TriageResult {
  final String category;
  final String urgency;
  final bool eligible;
  final String? exclusion;
  final String recommendedAction;
  final double minConfidence;
  final List<String> ruleReasons;
  final bool needsStaffReview;

  const TriageResult({
    required this.category,
    required this.urgency,
    required this.eligible,
    required this.exclusion,
    required this.recommendedAction,
    required this.minConfidence,
    required this.ruleReasons,
    required this.needsStaffReview,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('AI response is missing "$key".');
      }
      return value;
    }

    final eligible = json['eligible'];
    if (eligible is! bool) {
      throw const FormatException(
          'AI response has an invalid eligibility value.');
    }

    final exclusionValue = json['exclusion'];
    if (exclusionValue != null && exclusionValue is! String) {
      throw const FormatException(
          'AI response has an invalid exclusion value.');
    }

    final confidenceValue = json['confidence'];
    if (confidenceValue is! Map) {
      throw const FormatException('AI response has no confidence values.');
    }
    final confidences = confidenceValue.values.toList();
    if (confidences.isEmpty || confidences.any((value) => value is! num)) {
      throw const FormatException('AI response has invalid confidence values.');
    }
    final confidenceScores =
        confidences.cast<num>().map((value) => value.toDouble()).toList();
    if (confidenceScores
        .any((value) => !value.isFinite || value < 0 || value > 1)) {
      throw const FormatException('AI response has invalid confidence values.');
    }

    final reasonsValue = json['rule_reasons'];
    if (reasonsValue is! List ||
        reasonsValue.any((value) => value is! String)) {
      throw const FormatException('AI response has invalid rule reasons.');
    }
    final needsStaffReview = json['needs_staff_review'];
    if (needsStaffReview is! bool) {
      throw const FormatException('AI response has an invalid review flag.');
    }

    return TriageResult(
      category: requiredString('category'),
      urgency: requiredString('urgency'),
      eligible: eligible,
      exclusion: exclusionValue as String?,
      recommendedAction: requiredString('recommended_action'),
      minConfidence: confidenceScores.reduce((a, b) => a < b ? a : b),
      ruleReasons: List<String>.from(reasonsValue),
      needsStaffReview: needsStaffReview,
    );
  }
}

class AiService {
  static Future<TriageResult> triage(String text) async {
    final baseUri = Uri.tryParse(AppConfig.apiBaseUrl);
    if (baseUri == null ||
        !{'http', 'https'}.contains(baseUri.scheme) ||
        baseUri.host.isEmpty) {
      throw const AiServiceException('The AI service URL is invalid.');
    }

    late final http.Response response;
    try {
      response = await http
          .post(
            baseUri.resolve('/triage'),
            headers: const {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'text': text}),
          )
          .timeout(AppConfig.apiTimeout);
    } on TimeoutException {
      throw const AiServiceException(
          'AI analysis timed out. The case can still be filed; retry analysis from its tracking page.');
    } on http.ClientException {
      throw const AiServiceException(
          'Could not connect to the AI service. The case can still be filed; retry analysis from its tracking page.');
    }

    if (response.statusCode != 200) {
      throw AiServiceException(
        'The AI service returned status ${response.statusCode}. The case can still be filed; retry analysis from its tracking page.',
      );
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('AI response must be a JSON object.');
      }
      return TriageResult.fromJson(decoded);
    } on FormatException {
      throw const AiServiceException(
          'The AI service returned an invalid response. The case can still be filed; retry analysis from its tracking page.');
    }
  }
}
