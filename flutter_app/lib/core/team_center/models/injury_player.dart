/// Model representing a player on the injury report.
class InjuryPlayer {
  final String id;
  final String name;
  final String position;
  final String number;
  final String imageUrl;
  final String status;        // OUT, DOUBTFUL, QUESTIONABLE
  final String injuryType;    // Knee, Achilles, Hamstring, etc.
  final String participation; // DNP (Did Not Practice), LP (Limited), FP (Full)

  const InjuryPlayer({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    required this.imageUrl,
    required this.status,
    required this.injuryType,
    required this.participation,
  });

  factory InjuryPlayer.fromJson(Map<String, dynamic> json) {
    return InjuryPlayer(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown',
      position: json['position'] as String? ?? '',
      number: json['number']?.toString() ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'OUT',
      injuryType: json['injuryType'] as String? ?? 'Undisclosed',
      participation: json['participation'] as String? ?? 'DNP',
    );
  }

  /// Short status badge label
  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'OUT':
        return 'OUT';
      case 'DOUBTFUL':
        return 'DBT';
      case 'QUESTIONABLE':
        return 'QST';
      default:
        return status;
    }
  }
}
