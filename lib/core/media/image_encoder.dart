import 'dart:async';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../constants/admin_strings.dart';
import 'media_exception.dart';

/// Size and quality per kind of image. [thumbSide] adds a small copy for
/// cards and lists.
class ImageSpec {
  final int maxSide;
  final double quality;
  final int? thumbSide;
  final double thumbQuality;

  const ImageSpec(this.maxSide, this.quality, {this.thumbSide, this.thumbQuality = 0.70});

  static const product = ImageSpec(1600, 0.80, thumbSide: 400);
  static const banner = ImageSpec(1600, 0.80);
  static const logo = ImageSpec(512, 0.85);
  static const category = ImageSpec(512, 0.85);
  static const cover = ImageSpec(1200, 0.80);

  /// Near-lossless: a QR has to scan.
  static const qr = ImageSpec(1024, 0.95);
}

/// Resizes and re-encodes in the browser (canvas → WebP): fast, no package.
/// Chrome, Edge and Firefox write WebP; Safari doesn't, so the admin is
/// used from one of those.
abstract final class ImageEncoder {
  static Future<Uint8List> webp(Uint8List bytes, int maxSide, double quality) async {
    final bitmap = await web.window.createImageBitmap(web.Blob(<JSAny>[bytes.toJS].toJS)).toDart;
    final scale = min(1.0, maxSide / max(bitmap.width, bitmap.height));
    final w = (bitmap.width * scale).round(), h = (bitmap.height * scale).round();

    final canvas = web.HTMLCanvasElement()
      ..width = w
      ..height = h;
    canvas.context2D
      ..imageSmoothingQuality = 'high'
      ..drawImage(bitmap, 0, 0, w.toDouble(), h.toDouble());
    bitmap.close();

    final done = Completer<web.Blob?>();
    canvas.toBlob(((web.Blob? b) => done.complete(b)).toJS, 'image/webp', quality.toJS);
    final blob = await done.future;
    // A browser that can't write WebP hands back PNG instead.
    if (blob == null || blob.type != 'image/webp') throw const MediaException(AdminStrings.mediaBrowserUnsupported);
    return (await blob.arrayBuffer().toDart).toDart.asUint8List();
  }
}
