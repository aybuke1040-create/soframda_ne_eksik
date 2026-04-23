import 'dart:convert';

bool _looksLikeMojibake(String value) {
  for (final codeUnit in value.codeUnits) {
    if (codeUnit == 0x00c3 ||
        codeUnit == 0x00c4 ||
        codeUnit == 0x00c5 ||
        codeUnit == 0x00e2) {
      return true;
    }
  }
  return false;
}

String normalizeNotificationText(String value) {
  if (value.isEmpty || !_looksLikeMojibake(value)) {
    return value;
  }

  try {
    return utf8.decode(latin1.encode(value), allowMalformed: true);
  } catch (_) {
    return value;
  }
}
