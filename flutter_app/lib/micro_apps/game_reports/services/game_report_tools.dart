/// MVP stub: flutter_gemma is removed from pubspec for MVP, so the real
/// [Tool] type is unavailable. This local placeholder keeps the file
/// compiling inside the repo. Replace with the flutter_gemma Tool type when
/// Game Reports is re-enabled.
class GameReportsTool {
  final String name;
  final String description;
  const GameReportsTool({required this.name, required this.description});
}

/// Defines the tools (functions) available for FunctionGemma to call.
/// Dormant in MVP — see [FunctionGemmaService] stub.
class GameReportTools {
  static List<GameReportsTool> get all => const [
        GameReportsTool(
          name: 'get_game_recap',
          description:
              'Get a casual or detailed recap summary of a completed NFL game.',
        ),
        GameReportsTool(
          name: 'get_stats_breakdown',
          description: 'Get key statistics and numbers from the game.',
        ),
        GameReportsTool(
          name: 'get_player_highlights',
          description:
              'Get information about key player performances in the game.',
        ),
        GameReportsTool(
          name: 'get_mvp_analysis',
          description: 'Determine and explain who was the MVP of the game.',
        ),
      ];
}
