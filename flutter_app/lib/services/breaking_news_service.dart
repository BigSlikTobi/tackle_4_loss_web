import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';

class BreakingNewsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<BreakingNews>> fetchBreakingNews(String languageCode) async {
    try {
      final response = await _client.functions.invoke(
        'get-breaking-news',
        body: {'language_code': languageCode},
      );
      
      final data = response.data as List;
      return data.map((json) => BreakingNews.fromJson(json)).toList();
    } catch (e) {
      // Return empty list on error for now, logging ideally
      return [];
    }
  }

  Future<BreakingNewsDetail> fetchBreakingNewsDetail(String id) async {
    final response = await _client.functions.invoke(
      'get-breaking-news-detail',
      body: {'id': id},
    );
    
    return BreakingNewsDetail.fromJson(response.data);
  }
}
