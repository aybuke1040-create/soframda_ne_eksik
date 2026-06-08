class ModerationIssue {
  final String fieldLabel;
  final String matchedTerm;

  const ModerationIssue({
    required this.fieldLabel,
    required this.matchedTerm,
  });
}

const String kCommunityTermsVersion = '2026-04-ugc-safety';

const List<String> kObjectionableTerms = [
  'salak',
  'aptal',
  'geri zekali',
  'gerizekali',
  'orospu',
  'pic',
  'pi\u00e7',
  'ibne',
  'siktir',
  'amk',
  'serefsiz',
  '\u015ferefsiz',
  'hakaret',
];

String _normalizeForModeration(String input) {
  return input
      .toLowerCase()
      .replaceAll('\u0131', 'i')
      .replaceAll('\u00e7', 'c')
      .replaceAll('\u011f', 'g')
      .replaceAll('\u00f6', 'o')
      .replaceAll('\u015f', 's')
      .replaceAll('\u00fc', 'u');
}

final List<RegExp> _objectionablePatterns = kObjectionableTerms
    .map(_normalizeForModeration)
    .map(_buildModerationPattern)
    .toList(growable: false);

RegExp _buildModerationPattern(String normalizedTerm) {
  final escaped = RegExp.escape(normalizedTerm).replaceAll(r'\ ', r'\s+');
  return RegExp('(^|[^a-z0-9])$escaped([^a-z0-9]|\$)');
}

ModerationIssue? findObjectionableContent(Map<String, String> fields) {
  for (final entry in fields.entries) {
    final normalizedValue = _normalizeForModeration(entry.value);
    if (normalizedValue.trim().isEmpty) {
      continue;
    }

    for (var i = 0; i < kObjectionableTerms.length; i++) {
      if (_objectionablePatterns[i].hasMatch(normalizedValue)) {
        return ModerationIssue(
          fieldLabel: entry.key,
          matchedTerm: kObjectionableTerms[i],
        );
      }
    }
  }

  return null;
}
