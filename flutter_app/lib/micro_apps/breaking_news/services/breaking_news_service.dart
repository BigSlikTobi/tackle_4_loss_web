
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/breaking_news_article.dart';

class BreakingNewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BreakingNewsArticle>> fetchBreakingNews({String languageCode = 'en'}) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-breaking-news',
        body: {'language_code': languageCode},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => BreakingNewsArticle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load breaking news: $e');
    }
  }
}
