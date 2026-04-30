import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/team_standing.dart';

/// Service for fetching standings data from the Supabase edge function.
class StandingsDataService {
  late final SupabaseClient _supabase;
  static const String _functionName = 'standings';

  /// Default constructor - initializes Supabase client
  StandingsDataService() : _supabase = Supabase.instance.client;

  /// Testing constructor - allows subclasses without Supabase initialization
  @protected
  StandingsDataService.testing() : _supabase = _DummySupabaseClient();

  /// Fetches standings grouped by conference and division.
  /// Returns a list of ConferenceStandings (AFC, NFC).
  Future<List<ConferenceStandings>> fetchStandings({int? season}) async {
    try {
      final body = season != null ? {'season': season} : null;
      final response = await _supabase.functions.invoke(
        _functionName,
        body: body,
      );

      if (response.status != 200) {
        throw Exception('Failed to fetch standings: ${response.status}');
      }

      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList
          .map((json) =>
              ConferenceStandings.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StandingsDataService.fetchStandings error: $e');
      rethrow;
    }
  }
}

/// Dummy SupabaseClient for testing constructors - never actually used
/// since mock classes override all methods that use the client.
class _DummySupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
