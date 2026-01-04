/// Deterministic keyword-based intent detection.
/// 100% reliable - no AI model needed for intent parsing.
class IntentDetector {
  /// Detects the user's intent from their query.
  /// Returns one of: get_game_recap, get_stats_breakdown, 
  /// get_player_highlights, get_mvp_analysis, get_team_article
  static String detectIntent(String query) {
    final lower = query.toLowerCase().trim();
    
    // Priority order matters - check most specific first
    
    // 1. MVP Analysis
    if (_matchesMvp(lower)) return 'get_mvp_analysis';
    
    // 2. Player-specific questions
    if (_matchesPlayer(lower)) return 'get_player_highlights';
    
    // 3. Stats/numbers focus
    if (_matchesStats(lower)) return 'get_stats_breakdown';
    
    // 4. AI article request (premium)
    if (_matchesArticle(lower)) return 'get_team_article';
    
    // 5. Default: Game recap (most common request)
    return 'get_game_recap';
  }

  /// Check if query is asking about MVP
  static bool _matchesMvp(String q) {
    return q.contains('mvp') ||
           q.contains('best player') ||
           q.contains('star of') ||
           q.contains('who stood out') ||
           q.contains('top performer');
  }

  /// Check if query is about a specific player
  static bool _matchesPlayer(String q) {
    // Look for player-related keywords
    final playerKeywords = [
      'player', 'quarterback', 'qb', 'receiver', 'running back',
      'defense', 'touched', 'catch', 'throw', 'pass', 'rush',
      'how did', 'tell me about', 'performance of',
    ];
    
    for (final keyword in playerKeywords) {
      if (q.contains(keyword)) return true;
    }
    
    return false;
  }

  /// Check if query is about statistics
  static bool _matchesStats(String q) {
    return q.contains('stat') ||
           q.contains('number') ||
           q.contains('score') ||
           q.contains('yard') ||
           q.contains('touchdown') ||
           q.contains('breakdown') ||
           q.contains('data') ||
           q.contains('how many');
  }

  /// Check if query wants a full AI-written article
  static bool _matchesArticle(String q) {
    return q.contains('article') ||
           q.contains('write me') ||
           q.contains('full story') ||
           q.contains('detailed report') ||
           q.contains('in-depth');
  }

  // No longer needed but kept as comment reference if logic changes
  // static bool _matchesRecap(String q) { ... }
}
