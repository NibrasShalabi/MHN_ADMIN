import 'entities/category.dart';

/// Builds store categories from pasted text, one per line:
///
///     أطفال : أثاث، أحذية، ألبسة
///     * نسائي : أحذية، فساتين سهرة
///
/// The name comes before the colon, the filters after it, separated by
/// commas (، or ,). A leading `*` marks the category female-only.
abstract final class CategoryImport {
  static List<Category> parse(String text) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final result = <Category>[];
    for (final (i, raw) in text.split('\n').indexed) {
      var line = raw.trim();
      if (line.isEmpty) continue;
      final femaleOnly = line.startsWith('*');
      if (femaleOnly) line = line.substring(1).trim();
      final colon = line.indexOf(RegExp('[:：]'));
      final name = (colon < 0 ? line : line.substring(0, colon)).trim();
      if (name.isEmpty) continue;
      final filters = colon < 0
          ? const <String>[]
          : line.substring(colon + 1).split(RegExp('[،,]')).map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
      result.add(Category(
        id: 'C-${stamp}_$i',
        name: name,
        scope: CategoryScope.store,
        femaleOnly: femaleOnly,
        filters: [for (final (j, f) in filters.indexed) ProductFilter(id: 'F-${stamp}_${i}_$j', name: f)],
      ));
    }
    return result;
  }
}
