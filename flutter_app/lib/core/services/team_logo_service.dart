/// Service to map team IDs to creative logo asset paths.
/// The creative logos avoid copyright issues by using original guerrilla-style designs.
class TeamLogoService {
  static final TeamLogoService _instance = TeamLogoService._internal();
  factory TeamLogoService() => _instance;
  TeamLogoService._internal();

  /// Maps team IDs to their corresponding creative logo filenames
  static const Map<String, String> _teamIdToLogoMap = {
    // AFC East
    'buf': 'guerrilla_bills.png',
    'mia': 'guerrilla_dolphins.png',
    'ne': 'guerrilla_patriots.png',
    'nyj': 'guerrilla_jets.png',
    // AFC North
    'bal': 'guerrilla_ravens.png',
    'cin': 'guerrilla_bengals.png',
    'cle': 'guerrilla_browns.png',
    'pit': 'guerrilla_steelers.png',
    // AFC South
    'hou': 'guerrilla_texans.png',
    'ind': 'guerrilla_colts.png',
    'jax': 'guerrilla_jaguars.png',
    'ten': 'guerrilla_titans.png',
    // AFC West
    'den': 'guerrilla_broncos.png',
    'kc': 'guerrilla_chiefs.png',
    'lac': 'guerrilla_chargers.png',
    'lv': 'guerrilla_raiders.png',
    // NFC East
    'dal': 'guerrilla_cowboys.png',
    'nyg': 'guerrilla_giants.png',
    'phi': 'guerrilla_eagles.png',
    'was': 'guerrilla_commanders.png',
    // NFC North
    'chi': 'guerrilla_bears.png',
    'det': 'guerrilla_lions.png',
    'gb': 'guerrilla_packers.png',
    'min': 'guerrilla_vikings.png',
    // NFC South
    'atl': 'guerrilla_falcons.png',
    'car': 'guerrilla_panters.png', // Note: file is named 'panters' not 'panthers'
    'no': 'guerrilla_saints.png',
    'tb': 'guerrilla_buccaneers.png',
    // NFC West
    'ari': 'guerrilla_cardinals.png',
    'la': 'guerrilla_rams.png',
    'lar': 'guerrilla_rams.png',
    'sf': 'guerrilla_49ers.png',
    'sea': 'guerrilla_seahawks.png',
  };

  /// Returns the asset path for a team's creative logo.
  /// Falls back to a default path if the team ID is not found.
  static String getLogoPath(String teamId) {
    final logoFile = _teamIdToLogoMap[teamId.toLowerCase()];
    if (logoFile != null) {
      return 'assets/creative_logos/$logoFile';
    }
    // Fallback to old logo path if not found in creative logos
    return 'assets/logos/teams/${teamId.toLowerCase()}.png';
  }
}
