String sanitizeDisplayText(String input) {
  if (input.isEmpty) {
    return input;
  }

  final buffer = StringBuffer();
  final units = input.codeUnits;
  var index = 0;

  while (index < units.length) {
    final unit = units[index];

    if (_isHighSurrogate(unit)) {
      if (index + 1 < units.length && _isLowSurrogate(units[index + 1])) {
        buffer.writeCharCode(unit);
        buffer.writeCharCode(units[index + 1]);
        index += 2;
        continue;
      }
      index += 1;
      continue;
    }

    if (_isLowSurrogate(unit) || unit == 0) {
      index += 1;
      continue;
    }

    buffer.writeCharCode(unit);
    index += 1;
  }

  return _sanitizeDialoguePrefix(_sanitizeLinks(buffer.toString())).trim();
}

bool _isHighSurrogate(int value) => value >= 0xD800 && value <= 0xDBFF;

bool _isLowSurrogate(int value) => value >= 0xDC00 && value <= 0xDFFF;

String _sanitizeLinks(String input) {
  if (input.isEmpty) {
    return input;
  }

  var output = input;

  output = output.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\((https?:\/\/|www\.)[^)]+\)', caseSensitive: false),
    (match) => match.group(1) ?? '',
  );

  output = output.replaceAll(
    RegExp(r'(?:(?:https?:\/\/)|(?:www\.))\S+', caseSensitive: false),
    '',
  );

  output = output.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  output = output.replaceAll(RegExp(r'\n[ \t]+'), '\n');
  output = output.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return output;
}

String _sanitizeDialoguePrefix(String input) {
  if (input.isEmpty) {
    return input;
  }

  return input.replaceFirst(
    RegExp(
      r'^\s*(?:[-*]\s*)?(?:\*\*)?[\p{L}\p{N}_][\p{L}\p{N}_\s.\-]{0,32}(?:\*\*)?\s*[:：]\s*',
      unicode: true,
    ),
    '',
  );
}
