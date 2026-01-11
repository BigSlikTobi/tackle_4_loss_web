import 'package:flutter/material.dart';
import '../models/team_model.dart';
import 'team_logo_service.dart';

class TeamService {
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  List<Team> getTeams() {
    return [
      Team(
        id: 'ari',
        name: 'Arizona Cardinals',
        logoUrl: TeamLogoService.getLogoPath('ari'),
        primaryColor: Color(0xFF97233F),
        secondaryColor: Color(0xFFFFFFFF), // White
      ),
      Team(
        id: 'atl',
        name: 'Atlanta Falcons',
        logoUrl: TeamLogoService.getLogoPath('atl'),
        primaryColor: Color(0xFFA71930),
        secondaryColor: Color(0xFF000000), // Black
      ),
      Team(
        id: 'bal',
        name: 'Baltimore Ravens',
        logoUrl: TeamLogoService.getLogoPath('bal'),
        primaryColor: Color(0xFF241773),
        secondaryColor: Color(0xFF9E7C0C), // Gold
      ),
      Team(
        id: 'buf',
        name: 'Buffalo Bills',
        logoUrl: TeamLogoService.getLogoPath('buf'),
        primaryColor: Color(0xFF00338D),
        secondaryColor: Color(0xFFC60C30), // Red
      ),
      Team(
        id: 'car',
        name: 'Carolina Panthers',
        logoUrl: TeamLogoService.getLogoPath('car'),
        primaryColor: Color(0xFF0085CA),
        secondaryColor: Color(0xFF101820), // Black
      ),
      Team(
        id: 'chi',
        name: 'Chicago Bears',
        logoUrl: TeamLogoService.getLogoPath('chi'),
        primaryColor: Color(0xFF0B162A),
        secondaryColor: Color(0xFFC83803), // Orange
      ),
      Team(
        id: 'cin',
        name: 'Cincinnati Bengals',
        logoUrl: TeamLogoService.getLogoPath('cin'),
        primaryColor: Color(0xFFFB4F14),
        secondaryColor: Color(0xFF000000), // Black
      ),
      Team(
        id: 'cle',
        name: 'Cleveland Browns',
        logoUrl: TeamLogoService.getLogoPath('cle'),
        primaryColor: Color(0xFF311D00),
        secondaryColor: Color(0xFFFF3C00), // Orange
      ),
      Team(
        id: 'dal',
        name: 'Dallas Cowboys',
        logoUrl: TeamLogoService.getLogoPath('dal'),
        primaryColor: Color(0xFF003594),
        secondaryColor: Color(0xFF869397), // Silver
      ),
      Team(
        id: 'den',
        name: 'Denver Broncos',
        logoUrl: TeamLogoService.getLogoPath('den'),
        primaryColor: Color(0xFFFB4F14),
        secondaryColor: Color(0xFF002244), // Navy
      ),
      Team(
        id: 'det',
        name: 'Detroit Lions',
        logoUrl: TeamLogoService.getLogoPath('det'),
        primaryColor: Color(0xFF0076B6),
        secondaryColor: Color(0xFFB0B7BC), // Silver
      ),
      Team(
        id: 'gb',
        name: 'Green Bay Packers',
        logoUrl: TeamLogoService.getLogoPath('gb'),
        primaryColor: Color(0xFF203731),
        secondaryColor: Color(0xFFFFB612), // Gold
      ),
      Team(
        id: 'hou',
        name: 'Houston Texans',
        logoUrl: TeamLogoService.getLogoPath('hou'),
        primaryColor: Color(0xFF03202F),
        secondaryColor: Color(0xFFA71930), // Red
      ),
      Team(
        id: 'ind',
        name: 'Indianapolis Colts',
        logoUrl: TeamLogoService.getLogoPath('ind'),
        primaryColor: Color(0xFF002C5F),
        secondaryColor: Color(0xFFA2AAAD), // Gray
      ),
      Team(
        id: 'jax',
        name: 'Jacksonville Jaguars',
        logoUrl: TeamLogoService.getLogoPath('jax'),
        primaryColor: Color(0xFF006778),
        secondaryColor: Color(0xFF9F792C), // Gold
      ),
      Team(
        id: 'kc',
        name: 'Kansas City Chiefs',
        logoUrl: TeamLogoService.getLogoPath('kc'),
        primaryColor: Color(0xFFE31837),
        secondaryColor: Color(0xFFFFB81C), // Gold
      ),
      Team(
        id: 'lac',
        name: 'Los Angeles Chargers',
        logoUrl: TeamLogoService.getLogoPath('lac'),
        primaryColor: Color(0xFF0080C6),
        secondaryColor: Color(0xFFFFC20E), // Gold
      ),
      Team(
        id: 'lar',
        name: 'Los Angeles Rams',
        logoUrl: TeamLogoService.getLogoPath('lar'),
        primaryColor: Color(0xFF003594),
        secondaryColor: Color(0xFFFFA300), // Sol
      ),
      Team(
        id: 'la', // Alias for Rams
        name: 'Los Angeles Rams',
        logoUrl: TeamLogoService.getLogoPath('lar'),
        primaryColor: Color(0xFF003594),
        secondaryColor: Color(0xFFFFA300), // Sol
      ),
      Team(
        id: 'lv',
        name: 'Las Vegas Raiders',
        logoUrl: TeamLogoService.getLogoPath('lv'),
        primaryColor: Color(0xFF000000),
        secondaryColor: Color(0xFFA5ACAF), // Silver
      ),
      Team(
        id: 'mia',
        name: 'Miami Dolphins',
        logoUrl: TeamLogoService.getLogoPath('mia'),
        primaryColor: Color(0xFF008E97),
        secondaryColor: Color(0xFFFC4C02), // Orange
      ),
      Team(
        id: 'min',
        name: 'Minnesota Vikings',
        logoUrl: TeamLogoService.getLogoPath('min'),
        primaryColor: Color(0xFF4F2683),
        secondaryColor: Color(0xFFFFC62F), // Gold
      ),
      Team(
        id: 'ne',
        name: 'New England Patriots',
        logoUrl: TeamLogoService.getLogoPath('ne'),
        primaryColor: Color(0xFF002244),
        secondaryColor: Color(0xFFC60C30), // Red
      ),
      Team(
        id: 'no',
        name: 'New Orleans Saints',
        logoUrl: TeamLogoService.getLogoPath('no'),
        primaryColor: Color(0xFFD3BC8D),
        secondaryColor: Color(0xFF101820), // Black
      ),
      Team(
        id: 'nyg',
        name: 'New York Giants',
        logoUrl: TeamLogoService.getLogoPath('nyg'),
        primaryColor: Color(0xFF0B2265),
        secondaryColor: Color(0xFFA71930), // Red
      ),
      Team(
        id: 'nyj',
        name: 'New York Jets',
        logoUrl: TeamLogoService.getLogoPath('nyj'),
        primaryColor: Color(0xFF125740),
        secondaryColor: Color(0xFFB0B7BC), // Silver/Light
      ),
      Team(
        id: 'phi',
        name: 'Philadelphia Eagles',
        logoUrl: TeamLogoService.getLogoPath('phi'),
        primaryColor: Color(0xFF004C54),
        secondaryColor: Color(0xFFA5ACAF), // Silver
      ),
      Team(
        id: 'pit',
        name: 'Pittsburgh Steelers',
        logoUrl: TeamLogoService.getLogoPath('pit'),
        primaryColor: Color(0xFFFFB612),
        secondaryColor: Color(0xFF101820), // Black
      ),
      Team(
        id: 'sea',
        name: 'Seattle Seahawks',
        logoUrl: TeamLogoService.getLogoPath('sea'),
        primaryColor: Color(0xFF002244),
        secondaryColor: Color(0xFF69BE28), // Green
      ),
      Team(
        id: 'sf',
        name: 'San Francisco 49ers',
        logoUrl: TeamLogoService.getLogoPath('sf'),
        primaryColor: Color(0xFFAA0000),
        secondaryColor: Color(0xFFB3995D), // Gold
      ),
      Team(
        id: 'tb',
        name: 'Tampa Bay Buccaneers',
        logoUrl: TeamLogoService.getLogoPath('tb'),
        primaryColor: Color(0xFFD50A0A),
        secondaryColor: Color(0xFF34302B), // Pewter
      ),
      Team(
        id: 'ten',
        name: 'Tennessee Titans',
        logoUrl: TeamLogoService.getLogoPath('ten'),
        primaryColor: Color(0xFF0C2340),
        secondaryColor: Color(0xFF4B92DB), // Titans Blue
      ),
      Team(
        id: 'was',
        name: 'Washington Commanders',
        logoUrl: TeamLogoService.getLogoPath('was'),
        primaryColor: Color(0xFF5A1414),
        secondaryColor: Color(0xFFFFB612), // Gold
      ),
    ];
  }
}
