import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for calling the team_article_generation cloud function.
/// This provides AI-generated narrative text using GPT-5-nano.
class TeamArticleService {
  static const String _endpoint = 
      'https://team-article-generation-hjm4dt4a5q-uc.a.run.app';

  /// Generate an AI-written article about a game or team.
  /// Returns null if the request fails or quality validation fails.
  Future<String?> generateArticle({
    required String teamCode,
    String? gameId,
    String style = 'recap',
  }) async {
    try {
      final body = {
        'team': teamCode,
        if (gameId != null) 'game_id': gameId,
        'style': style,
      };

      debugPrint('Calling team_article_generation for $teamCode...');

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final article = json['article']?.toString() ?? 
                        json['content']?.toString() ??
                        json['text']?.toString();
        
        if (article != null && _validateQuality(article)) {
          debugPrint('AI article generated successfully (${article.length} chars)');
          return article;
        } else {
          debugPrint('AI article failed quality validation');
          return null;
        }
      } else {
        debugPrint('Team article generation error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Team article generation failed: $e');
      return null;
    }
  }

  /// Validate that the generated content meets quality standards.
  bool _validateQuality(String text) {
    // Minimum length check
    if (text.length < 100) {
      debugPrint('Quality check failed: too short (${text.length} chars)');
      return false;
    }

    // Check for error phrases
    final errorPhrases = [
      'cannot assist',
      'unable to',
      'error occurred',
      'i apologize',
      'i cannot',
      'not available',
    ];

    for (final phrase in errorPhrases) {
      if (text.toLowerCase().contains(phrase)) {
        debugPrint('Quality check failed: contains error phrase "$phrase"');
        return false;
      }
    }

    return true;
  }

  /// Check if the service is available.
  Future<bool> isAvailable() async {
    try {
      final response = await http.get(
        Uri.parse(_endpoint),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
}
