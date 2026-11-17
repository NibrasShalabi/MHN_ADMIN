/// Raised with an Arabic message, which AdminError shows as-is.
class MediaException implements Exception {
  final String message;

  const MediaException(this.message);

  @override
  String toString() => message;
}
