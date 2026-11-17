import 'dart:typed_data';

import 'image_encoder.dart';
import 'media_config.dart';
import 'media_image.dart';
import 'media_uploader.dart';

/// What the repositories call: picked images in, bucket paths out.
class MediaService {
  final MediaUploader _uploader;

  MediaService(this._uploader);

  /// Uploads the picked images under [folder] and returns every path in the
  /// form's order — stored ones are kept as they are. Each upload gets a new
  /// name, so a replaced image never shows stale from a cache.
  Future<List<String>> save(String folder, List<MediaImage> images, ImageSpec spec) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return [
      for (final (i, image) in images.indexed)
        switch (image) {
          StoredImage(:final path) => path,
          PickedImage(:final bytes) => await _upload('$folder/${stamp}_$i.webp', bytes, spec),
        },
    ];
  }

  Future<String> _upload(String path, Uint8List bytes, ImageSpec spec) async {
    await _uploader.put(path, await ImageEncoder.webp(bytes, spec.maxSide, spec.quality), 'image/webp');
    if (spec.thumbSide case final side?) {
      await _uploader.put(MediaConfig.thumbOf(path), await ImageEncoder.webp(bytes, side, spec.thumbQuality), 'image/webp');
    }
    return path;
  }

  /// Deletes what [before] held and [after] doesn't, thumbs included. Run
  /// after the document is saved; a failure only leaves an unused file.
  Future<void> removeUnused(Iterable<String?> before, [Iterable<String?> after = const []]) async {
    final keep = after.toSet();
    final gone = before.whereType<String>().where((p) => !keep.contains(p) && !p.startsWith('http'));
    await Future.wait([
      for (final p in gone) ...[_quiet(_uploader.delete(p)), _quiet(_uploader.delete(MediaConfig.thumbOf(p)))],
    ]);
  }

  static Future<void> _quiet(Future<void> f) async {
    try {
      await f;
    } catch (_) {}
  }
}
