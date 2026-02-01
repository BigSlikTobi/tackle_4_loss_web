/// Model representing a player in the depth chart.
class DepthChartPlayer {
  final String id;
  final String name;
  final String number;
  final String position;
  final int rank;
  final String status; // STARTER, 2ND STRING, 3RD STRING, etc.
  final String imageUrl;
  final bool isHot; // Player trending up (hot icon)
  final bool hasQuest; // Has question mark (uncertain status)

  const DepthChartPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.rank,
    required this.status,
    required this.imageUrl,
    this.isHot = false,
    this.hasQuest = false,
  });

  factory DepthChartPlayer.fromJson(Map<String, dynamic> json) {
    return DepthChartPlayer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      number: json['number'] as String? ?? '',
      position: json['position'] as String? ?? '',
      rank: (json['rank'] is int)
          ? json['rank']
          : int.tryParse(json['rank']?.toString() ?? '1') ?? 1,
      status: json['status'] as String? ?? 'STARTER',
      imageUrl: json['imageUrl'] as String? ?? '',
      isHot: json['isHot'] as bool? ?? false,
      hasQuest: json['hasQuest'] as bool? ?? false,
    );
  }

  /// Whether this player is a starter (rank 1).
  bool get isStarter => rank == 1;
}
