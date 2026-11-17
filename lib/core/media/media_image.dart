import 'dart:typed_data';

/// An image in a form: one already in the bucket, or one just picked.
sealed class MediaImage {
  const MediaImage();
}

/// Saved earlier. [path] is the bucket path (products/abc/1712_0.webp) —
/// or, for data entered before the bucket existed, a full http URL.
final class StoredImage extends MediaImage {
  final String path;

  const StoredImage(this.path);
}

/// Picked in this form, uploaded on save.
final class PickedImage extends MediaImage {
  final Uint8List bytes;

  const PickedImage(this.bytes);
}
