import 'dart:math';

/// Name search without a search service: every product stores the prefixes
/// of its words ("كريم" → ك، كر، كري، كريم), and a query is one
/// `array-contains` on them — it costs what it returns, whatever the catalog
/// size. Only word beginnings match: "كري" finds "كريم", "ريم" doesn't.
abstract final class SearchKeys {
  /// Longer prefixes add little and grow every document.
  static const int _maxPrefix = 15;

  /// Spelling variants typed interchangeably (أ/ا، ة/ه، ى/ي، tashkeel).
  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[ً-ْـ]'), '')
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');

  static List<String> _words(String s) =>
      normalize(s).split(RegExp(r'[^\p{L}\p{N}]+', unicode: true)).where((w) => w.isNotEmpty).toList();

  /// Written on every product save.
  static List<String> of(String name) => {
        for (final w in _words(name))
          for (var i = 1; i <= min(w.length, _maxPrefix); i++) w.substring(0, i),
      }.toList();

  /// The one key the server matches — the query's longest word, the most
  /// selective. Null when there is nothing to search.
  static String? keyOf(String query) {
    final words = _words(query)..sort((a, b) => b.length - a.length);
    if (words.isEmpty) return null;
    return words.first.substring(0, min(words.first.length, _maxPrefix));
  }

  /// The query's other words, checked on what the server returned.
  static bool matches(String name, String query) {
    final words = _words(name);
    return _words(query).every((q) => words.any((w) => w.startsWith(q)));
  }
}
