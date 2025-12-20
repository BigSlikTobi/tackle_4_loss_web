class LocalizationUtils {
  LocalizationUtils._();

  /// Parses the simple markdown format with language markers:
  /// _English_
  /// ...
  /// _German_
  /// ...
  static String extractLocalizedMarkdownDescription(String raw, String langCode) {
    // defined markers
    const String markerEn = '_English_';
    const String markerDe = '_German_';

    // indexes
    final int idxEn = raw.indexOf(markerEn);
    final int idxDe = raw.indexOf(markerDe);

    // If file is plain text (no markers), return as is
    if (idxEn == -1 && idxDe == -1) return raw;

    String content = '';

    if (langCode == 'de' && idxDe != -1) {
      // German requested and found. 
      // It assumes German is the last section or followed by another marker (not yet implemented)
      content = raw.substring(idxDe + markerDe.length).trim();
    } else if (idxEn != -1) {
      // Fallback to English.
      // Ends at German marker if present, else end of string.
      final int end = (idxDe != -1 && idxDe > idxEn) ? idxDe : raw.length;
      content = raw.substring(idxEn + markerEn.length, end).trim();
    } else {
      // Fallback if structure is weird: return whole
      content = raw;
    }
    
    return content;
  }
}
