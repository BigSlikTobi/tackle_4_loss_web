class RosterPlayer {
  final String id;
  final String name;
  final String number;
  final String position;
  final String experience;
  final String college;
  final String imageUrl;

  const RosterPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.experience,
    required this.college,
    required this.imageUrl,
  });

  factory RosterPlayer.fromJson(Map<String, dynamic> json) {
    return RosterPlayer(
      id: json['id'] as String? ??
          '', // ID might not be in response, use empty string if so
      name: json['name'] as String? ?? 'Unknown',
      number: json['number'] as String? ?? '',
      position: json['position'] as String? ?? '',
      experience: json['experience'] as String? ?? 'R',
      college: json['college'] as String? ?? 'N/A',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  static List<RosterPlayer> getMockOffense(String teamId) {
    return [
      const RosterPlayer(
        id: '1',
        name: 'Aaron Rodgers',
        number: '8',
        position: 'QB',
        experience: '19Y',
        college: 'California',
        imageUrl:
            'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '2',
        name: 'Garrett Wilson',
        number: '17',
        position: 'WR',
        experience: '2Y',
        college: 'Ohio State',
        imageUrl:
            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '3',
        name: 'Breece Hall',
        number: '20',
        position: 'RB',
        experience: '2Y',
        college: 'Iowa State',
        imageUrl:
            'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '4',
        name: 'Tyron Smith',
        number: '77',
        position: 'T',
        experience: '13Y',
        college: 'USC',
        imageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '5',
        name: 'Mike Williams',
        number: '18',
        position: 'WR',
        experience: '7Y',
        college: 'Clemson',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
      ),
    ];
  }

  static List<RosterPlayer> getMockDefense(String teamId) {
    return [
      const RosterPlayer(
        id: '101',
        name: 'Sauce Gardner',
        number: '#1',
        position: 'CB',
        experience: '2Y',
        college: 'Cincinnati',
        imageUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '102',
        name: 'Quinnen Williams',
        number: '#95',
        position: 'DT',
        experience: '5Y',
        college: 'Alabama',
        imageUrl:
            'https://images.unsplash.com/photo-1531384441138-2736e62e0566?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '103',
        name: 'C.J. Mosley',
        number: '#57',
        position: 'LB',
        experience: '10Y',
        college: 'Alabama',
        imageUrl:
            'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '104',
        name: 'D.J. Reed',
        number: '#4',
        position: 'CB',
        experience: '6Y',
        college: 'Kan. State',
        imageUrl:
            'https://images.unsplash.com/photo-1499996860823-5214fcc65f6f?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '105',
        name: 'Jermaine Johnson',
        number: '#11',
        position: 'DE',
        experience: '2Y',
        college: 'Florida St.',
        imageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
      ),
    ];
  }

  static List<RosterPlayer> getMockSpecialTeams(String teamId) {
    return [
      const RosterPlayer(
        id: '201',
        name: 'Greg Zuerlein',
        number: '9',
        position: 'K',
        experience: '12Y',
        college: 'Missouri West.',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
      ),
      const RosterPlayer(
        id: '202',
        name: 'Thomas Morstead',
        number: '6',
        position: 'P',
        experience: '15Y',
        college: 'SMU',
        imageUrl:
            'https://images.unsplash.com/photo-1583195764036-6dc248ac07d9?w=200&h=200&fit=crop',
      ),
    ];
  }
}
