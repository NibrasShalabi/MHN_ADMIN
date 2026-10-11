/// Short-lived memory cache shared by the admin repositories.
///
/// The dashboard, analytics and the list pages all read the same
/// collections; within [ttl] they share one read. Any write clears the
/// whole cache, so a change is never hidden behind a stale copy.
abstract final class AdminCache {
  static const Duration ttl = Duration(minutes: 2);
  static final Map<String, (DateTime, Future<Object?>)> _entries = {};

  static Future<T> get<T>(String key, Future<T> Function() load) {
    final hit = _entries[key];
    if (hit != null && DateTime.now().difference(hit.$1) < ttl) return hit.$2.then((v) => v as T);
    final future = load();
    _entries[key] = (DateTime.now(), future);
    // A failed read is retried next time; the caller still gets the error.
    future.then((_) {}, onError: (Object _) => _entries.remove(key));
    return future;
  }

  static void clear() => _entries.clear();
}
