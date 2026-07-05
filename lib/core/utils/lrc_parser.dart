class LrcLine {
  final Duration timestamp;
  final String text;

  LrcLine({required this.timestamp, required this.text});
}

class LrcParser {
  static List<LrcLine> parse(String rawLrc) {
    if (rawLrc.isEmpty) return [];

    final lines = rawLrc.split('\n');
    final List<LrcLine> lrcLines = [];

    // Pattern matches: [mm:ss.xx] or [mm:ss:xx] or [mm:ss]
    final regex = RegExp(r'\[(\d+):(\d+)(?:\.(\d+))?\](.*)');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final hundredthsStr = match.group(3) ?? '0';
        int milliseconds = 0;
        if (hundredthsStr.length == 2) {
          milliseconds = int.parse(hundredthsStr) * 10;
        } else if (hundredthsStr.length == 3) {
          milliseconds = int.parse(hundredthsStr);
        } else {
          milliseconds = int.parse(hundredthsStr);
        }

        final text = match.group(4)?.trim() ?? '';
        final timestamp = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        lrcLines.add(LrcLine(timestamp: timestamp, text: text));
      }
    }

    if (lrcLines.isEmpty && rawLrc.trim().isNotEmpty) {
      final plainLines = rawLrc.split('\n');
      for (var i = 0; i < plainLines.length; i++) {
        final text = plainLines[i].trim();
        if (text.isNotEmpty) {
          lrcLines.add(LrcLine(
            timestamp: Duration.zero,
            text: text,
          ));
        }
      }
    }

    lrcLines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lrcLines;
  }
}
