/// Represents a request for a game report.
class ReportRequest {
  /// The game ID to generate a report for.
  final String gameId;

  /// Optional team to focus the narrative on.
  final String? focusTeam;

  /// Report style preference.
  final ReportStyle style;

  /// Whether to use cloud enhancement.
  final bool useCloudEnhancement;

  const ReportRequest({
    required this.gameId,
    this.focusTeam,
    this.style = ReportStyle.casual,
    this.useCloudEnhancement = false,
  });
}

/// Available report styles.
enum ReportStyle {
  /// Brief, easy-to-read summary for casual fans.
  casual,

  /// Detailed breakdown with more context.
  detailed,

  /// Stats-focused analysis for analytics enthusiasts.
  stats,
}

extension ReportStyleExtension on ReportStyle {
  String get displayName {
    switch (this) {
      case ReportStyle.casual:
        return 'Casual';
      case ReportStyle.detailed:
        return 'Detailed';
      case ReportStyle.stats:
        return 'Stats Focus';
    }
  }

  String get description {
    switch (this) {
      case ReportStyle.casual:
        return 'Quick summary of key moments';
      case ReportStyle.detailed:
        return 'Full breakdown with context';
      case ReportStyle.stats:
        return 'Numbers and analytics focus';
    }
  }
}
