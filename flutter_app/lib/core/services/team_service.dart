import 'package:flutter/material.dart';
import '../models/team_model.dart';

class TeamService {
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  List<Team> getTeams() {
    return const [
      Team(
        id: 'ari',
        name: 'Arizona Cardinals',
        logoUrl: 'assets/logos/teams/ari.png',
        primaryColor: Color(0xFF97233F),
      ),
      Team(
        id: 'atl',
        name: 'Atlanta Falcons',
        logoUrl: 'assets/logos/teams/atl.png',
        primaryColor: Color(0xFFA71930),
      ),
      Team(
        id: 'bal',
        name: 'Baltimore Ravens',
        logoUrl: 'assets/logos/teams/bal.png',
        primaryColor: Color(0xFF241773),
      ),
      Team(
        id: 'buf',
        name: 'Buffalo Bills',
        logoUrl: 'assets/logos/teams/buf.png',
        primaryColor: Color(0xFF00338D),
      ),
      Team(
        id: 'car',
        name: 'Carolina Panthers',
        logoUrl: 'assets/logos/teams/car.png',
        primaryColor: Color(0xFF0085CA),
      ),
      Team(
        id: 'chi',
        name: 'Chicago Bears',
        logoUrl: 'assets/logos/teams/chi.png',
        primaryColor: Color(0xFF0B162A),
      ),
      Team(
        id: 'cin',
        name: 'Cincinnati Bengals',
        logoUrl: 'assets/logos/teams/cin.png',
        primaryColor: Color(0xFFFB4F14),
      ),
      Team(
        id: 'cle',
        name: 'Cleveland Browns',
        logoUrl: 'assets/logos/teams/cle.png',
        primaryColor: Color(0xFF311D00),
      ),
      Team(
        id: 'dal',
        name: 'Dallas Cowboys',
        logoUrl: 'assets/logos/teams/dal.png',
        primaryColor: Color(0xFF003594),
      ),
      Team(
        id: 'den',
        name: 'Denver Broncos',
        logoUrl: 'assets/logos/teams/den.png',
        primaryColor: Color(0xFFFB4F14),
      ),
      Team(
        id: 'det',
        name: 'Detroit Lions',
        logoUrl: 'assets/logos/teams/det.png',
        primaryColor: Color(0xFF0076B6),
      ),
      Team(
        id: 'gb',
        name: 'Green Bay Packers',
        logoUrl: 'assets/logos/teams/gb.png',
        primaryColor: Color(0xFF203731),
      ),
      Team(
        id: 'hou',
        name: 'Houston Texans',
        logoUrl: 'assets/logos/teams/hou.png',
        primaryColor: Color(0xFF03202F),
      ),
      Team(
        id: 'ind',
        name: 'Indianapolis Colts',
        logoUrl: 'assets/logos/teams/ind.png',
        primaryColor: Color(0xFF002C5F),
      ),
      Team(
        id: 'jax',
        name: 'Jacksonville Jaguars',
        logoUrl: 'assets/logos/teams/jax.png',
        primaryColor: Color(0xFF006778),
      ),
      Team(
        id: 'kc',
        name: 'Kansas City Chiefs',
        logoUrl: 'assets/logos/teams/kc.png',
        primaryColor: Color(0xFFE31837),
      ),
      Team(
        id: 'lac',
        name: 'Los Angeles Chargers',
        logoUrl: 'assets/logos/teams/lac.png',
        primaryColor: Color(0xFF0080C6),
      ),
      Team(
        id: 'lar',
        name: 'Los Angeles Rams',
        logoUrl: 'assets/logos/teams/lar.png',
        primaryColor: Color(0xFF003594),
      ),
      Team(
        id: 'lv',
        name: 'Las Vegas Raiders',
        logoUrl: 'assets/logos/teams/lv.png',
        primaryColor: Color(0xFF000000),
      ),
      Team(
        id: 'mia',
        name: 'Miami Dolphins',
        logoUrl: 'assets/logos/teams/mia.png',
        primaryColor: Color(0xFF008E97),
      ),
      Team(
        id: 'min',
        name: 'Minnesota Vikings',
        logoUrl: 'assets/logos/teams/min.png',
        primaryColor: Color(0xFF4F2683),
      ),
      Team(
        id: 'ne',
        name: 'New England Patriots',
        logoUrl: 'assets/logos/teams/ne.png',
        primaryColor: Color(0xFF002244),
      ),
      Team(
        id: 'no',
        name: 'New Orleans Saints',
        logoUrl: 'assets/logos/teams/no.png',
        primaryColor: Color(0xFFD3BC8D),
      ),
      Team(
        id: 'nyg',
        name: 'New York Giants',
        logoUrl: 'assets/logos/teams/nyg.png',
        primaryColor: Color(0xFF0B2265),
      ),
      Team(
        id: 'nyj',
        name: 'New York Jets',
        logoUrl: 'assets/logos/teams/nyj.png',
        primaryColor: Color(0xFF125740),
      ),
      Team(
        id: 'phi',
        name: 'Philadelphia Eagles',
        logoUrl: 'assets/logos/teams/phi.png',
        primaryColor: Color(0xFF004C54),
      ),
      Team(
        id: 'pit',
        name: 'Pittsburgh Steelers',
        logoUrl: 'assets/logos/teams/pit.png',
        primaryColor: Color(0xFFFFB612),
      ),
      Team(
        id: 'sea',
        name: 'Seattle Seahawks',
        logoUrl: 'assets/logos/teams/sea.png',
        primaryColor: Color(0xFF002244),
      ),
      Team(
        id: 'sf',
        name: 'San Francisco 49ers',
        logoUrl: 'assets/logos/teams/sf.png',
        primaryColor: Color(0xFFAA0000),
      ),
      Team(
        id: 'tb',
        name: 'Tampa Bay Buccaneers',
        logoUrl: 'assets/logos/teams/tb.png',
        primaryColor: Color(0xFFD50A0A),
      ),
      Team(
        id: 'ten',
        name: 'Tennessee Titans',
        logoUrl: 'assets/logos/teams/ten.png',
        primaryColor: Color(0xFF0C2340),
      ),
      Team(
        id: 'was',
        name: 'Washington Commanders',
        logoUrl: 'assets/logos/teams/was.png',
        primaryColor: Color(0xFF5A1414),
      ),
    ];
  }
}
