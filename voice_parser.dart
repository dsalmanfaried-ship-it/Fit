class ParsedSet {
  final int reps;
  final double weight;
  const ParsedSet(this.reps, this.weight);
}

class VoiceParser {
  static String normalizeDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var result = input;
    for (var i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], '$i');
    }
    return result.replaceAll('٫', '.').replaceAll('،', ',');
  }

  /// Accepts examples such as "12 reps 40 kg", "12 عدة وزن 40 كيلو".
  static ParsedSet? parse(String speech) {
    final text = normalizeDigits(speech.toLowerCase());
    final numbers = RegExp(r'\d+(?:[.,]\d+)?')
        .allMatches(text)
        .map((m) => m.group(0)!.replaceAll(',', '.'))
        .toList();
    if (numbers.length < 2) return null;
    final reps = double.tryParse(numbers[0])?.round();
    final weight = double.tryParse(numbers[1]);
    if (reps == null || weight == null || reps < 1 || weight < 0) return null;
    return ParsedSet(reps, weight);
  }
}
