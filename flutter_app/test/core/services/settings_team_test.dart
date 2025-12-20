import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/core/models/team_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService Team Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('setFavoriteTeam updates selectedTeam and notifies listeners', () async {
      final service = SettingsService();
      var notified = false;
      service.addListener(() => notified = true);

      const testTeam = Team(
        id: 'kc',
        name: 'Kansas City Chiefs',
        logoUrl: 'assets/logos/teams/kc.png',
        primaryColor: Colors.red,
      );

      await service.setFavoriteTeam(testTeam);

      expect(service.selectedTeam?.id, 'kc');
      expect(notified, isTrue);
    });
  });
}
