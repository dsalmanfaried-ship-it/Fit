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
    return result
      .replaceAll('٫', '.').replaceAll('،', ',')
      .replaceAll('كيلو', 'kg').replaceAll('كجم', 'kg')
      .replaceAll('عدة', 'reps').replaceAll('عدات', 'reps')
      .replaceAll('وزن', 'weight').replaceAll('عملت', '');
  }

  /// Examples: "عملت ١٢ عدة بوزن ٤٠ كيلو", "12 reps at 40 kg".
  static ParsedSet? parse(String speech) {
    final text = normalizeDigits(speech.toLowerCase());
    final nums = RegExp(r'\d+(?:[.,]\d+)?').allMatches(text)
      .map((m) => m.group(0)!.replaceAll(',', '.')).toList();
    if (nums.length < 2) return null;
    final reps = double.tryParse(nums[0])?.round();
    final weight = double.tryParse(nums[1]);
    if (reps == null || weight == null || reps < 1 || weight < 0) return null;
    return ParsedSet(reps, weight);
  }
}
