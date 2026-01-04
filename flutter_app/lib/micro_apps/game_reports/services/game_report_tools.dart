import 'package:flutter_gemma/flutter_gemma.dart';

/// Defines the tools (functions) available for FunctionGemma to call.
/// These match what the model was trained to recognize.
class GameReportTools {
  /// All available tools for game analysis.
  static List<Tool> get all => [
    getGameRecapTool,
    getStatsBreakdownTool,
    getPlayerHighlightsTool,
    getMvpAnalysisTool,
  ];

  /// Tool for getting a game recap.
  static Tool get getGameRecapTool => Tool(
    name: 'get_game_recap',
    description: 'Get a casual or detailed recap summary of a completed NFL game. Use this for requests about recaps, summaries, or game overviews.',
  );

  /// Tool for getting stats breakdown.
  static Tool get getStatsBreakdownTool => Tool(
    name: 'get_stats_breakdown',
    description: 'Get key statistics and numbers from the game. Use this for requests about stats, numbers, scores, or data.',
  );

  /// Tool for getting player highlights.
  static Tool get getPlayerHighlightsTool => Tool(
    name: 'get_player_highlights',
    description: 'Get information about key player performances in the game. Use this for questions about specific players or player stats.',
  );

  /// Tool for MVP analysis.
  static Tool get getMvpAnalysisTool => Tool(
    name: 'get_mvp_analysis',
    description: 'Determine and explain who was the MVP (Most Valuable Player) of the game. Use this for questions about the best player or MVP.',
  );
}
