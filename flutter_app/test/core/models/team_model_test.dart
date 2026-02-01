import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/models/team_model.dart';

void main() {
  group('Team Model', () {
    group('constructor', () {
      test('creates team with all required fields', () {
        const team = Team(
          id: 'KC',
          name: 'Kansas City Chiefs',
          logoUrl: 'assets/logos/teams/kc.svg',
          primaryColor: Color(0xFFE31837),
          secondaryColor: Color(0xFFFFB81C),
        );

        expect(team.id, 'KC');
        expect(team.name, 'Kansas City Chiefs');
        expect(team.logoUrl, 'assets/logos/teams/kc.svg');
        expect(team.primaryColor, const Color(0xFFE31837));
        expect(team.secondaryColor, const Color(0xFFFFB81C));
      });

      test('works with different NFL teams', () {
        final teams = [
          const Team(
            id: 'SF',
            name: 'San Francisco 49ers',
            logoUrl: 'assets/logos/teams/sf.svg',
            primaryColor: Color(0xFFAA0000),
            secondaryColor: Color(0xFFB3995D),
          ),
          const Team(
            id: 'DAL',
            name: 'Dallas Cowboys',
            logoUrl: 'assets/logos/teams/dal.svg',
            primaryColor: Color(0xFF002244),
            secondaryColor: Color(0xFF869397),
          ),
          const Team(
            id: 'PHI',
            name: 'Philadelphia Eagles',
            logoUrl: 'assets/logos/teams/phi.svg',
            primaryColor: Color(0xFF004C54),
            secondaryColor: Color(0xFFA5ACAF),
          ),
        ];

        expect(teams.length, 3);
        expect(teams.map((t) => t.id).toList(), ['SF', 'DAL', 'PHI']);
      });
    });

    group('const constructor', () {
      test('allows const instantiation', () {
        const team = Team(
          id: 'BUF',
          name: 'Buffalo Bills',
          logoUrl: 'assets/logos/teams/buf.svg',
          primaryColor: Color(0xFF00338D),
          secondaryColor: Color(0xFFC60C30),
        );

        expect(team.id, 'BUF');
      });
    });
  });
}
