import 'package:cloud_firestore/cloud_firestore.dart';

/// Where images are read from and written to. Firestore stores paths only,
/// so moving to a custom domain or another provider is one edit of
/// config/media — no document changes, no app release. See docs/media.md.
abstract final class MediaConfig {
  /// Public reads. Today the bucket's r2.dev URL; later e.g. `https://img.example.com`.
  static String baseUrl = 'https://pub-2d134d4fdf6440c1b779696af1a07dfd.r2.dev';

  /// Writes: the Worker in media_worker/.
  static String uploadUrl = 'https://mhn-media.nibras-shalabi0.workers.dev';

  /// One read at startup; the defaults above stand if it fails.
  static Future<void> load(FirebaseFirestore db) async {
    try {
      final d = (await db.collection('config').doc('media').get()).data();
      baseUrl = d?['baseUrl'] as String? ?? baseUrl;
      uploadUrl = d?['uploadUrl'] as String? ?? uploadUrl;
    } catch (_) {}
  }

  static bool _external(String path) => path.startsWith('http');

  static String url(String path) => _external(path) ? path : '$baseUrl/$path';

  /// The small copy saved next to an image that has one (products).
  static String thumbOf(String path) => path.replaceFirst(RegExp(r'\.webp$'), '_thumb.webp');
}
