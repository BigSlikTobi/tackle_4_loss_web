import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/services/team_logo_service.dart';

void main() {
  group('TeamLogoService Tests', () {
    test('Standard team codes return correct creative logo path', () {
      expect(TeamLogoService.getLogoPath('buf'),
          'assets/creative_logos/guerrilla_bills.png');
      expect(TeamLogoService.getLogoPath('mia'),
          'assets/creative_logos/guerrilla_dolphins.png');
      expect(TeamLogoService.getLogoPath('kc'),
          'assets/creative_logos/guerrilla_chiefs.png');
      expect(TeamLogoService.getLogoPath('la'),
          'assets/creative_logos/guerrilla_rams.png');
      expect(TeamLogoService.getLogoPath('lar'),
          'assets/creative_logos/guerrilla_rams.png');
    });

    test('Case insensitivity works', () {
      expect(TeamLogoService.getLogoPath('BUF'),
          'assets/creative_logos/guerrilla_bills.png');
      expect(TeamLogoService.getLogoPath('Mia'),
          'assets/creative_logos/guerrilla_dolphins.png');
    });

    test('Legacy team codes map to correct current team logos', () {
      // Oakland -> Raiders
      expect(TeamLogoService.getLogoPath('oak'),
          'assets/creative_logos/guerrilla_raiders.png');
      // San Diego -> Chargers
      expect(TeamLogoService.getLogoPath('sd'),
          'assets/creative_logos/guerrilla_chargers.png');
      // St. Louis -> Rams
      expect(TeamLogoService.getLogoPath('stl'),
          'assets/creative_logos/guerrilla_rams.png');
      // LA -> Rams (as per previous logic)
      expect(TeamLogoService.getLogoPath('la'),
          'assets/creative_logos/guerrilla_rams.png');
    });

    test('Unknown code returns default placeholder', () {
      expect(TeamLogoService.getLogoPath('unknown_team'),
          'assets/creative_logos/guerrilla_nfl.png');
    });
  });
}
