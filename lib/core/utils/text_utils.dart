import 'dart:convert';

String normalizeNotificationText(String value) {
  if (value.isEmpty) {
    return value;
  }

  var normalized = value;

  const replacements = {
    'Ä°': 'İ',
    'Ä±': 'ı',
    'ÄŸ': 'ğ',
    'Äž': 'Ğ',
    'ÅŸ': 'ş',
    'Åž': 'Ş',
    'Ã¼': 'ü',
    'Ãœ': 'Ü',
    'Ã¶': 'ö',
    'Ã–': 'Ö',
    'Ã§': 'ç',
    'Ã‡': 'Ç',
    'â‚º': '₺',
    'â€¢': '•',
  };

  replacements.forEach((broken, fixed) {
    normalized = normalized.replaceAll(broken, fixed);
  });

  if (normalized.contains('Ãƒ') ||
      normalized.contains('Ã…') ||
      normalized.contains('Ã„')) {
    try {
      normalized = utf8.decode(latin1.encode(normalized));
    } catch (_) {
      return normalized;
    }
  }

  return normalized;
}
