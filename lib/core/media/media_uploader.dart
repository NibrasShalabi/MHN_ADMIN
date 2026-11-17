import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constants/admin_strings.dart';
import 'media_config.dart';
import 'media_exception.dart';

/// Writes and deletes files by path. The one piece that knows the storage
/// provider — moving to Firebase Storage means another implementation of
/// this, registered in the injector. See docs/media.md.
abstract interface class MediaUploader {
  Future<void> put(String path, Uint8List bytes, String contentType);
  Future<void> delete(String path);
}

/// R2 through the Worker in media_worker/, signed in with the admin's
/// Firebase ID token (the Worker checks the admin claim).
class WorkerMediaUploader implements MediaUploader {
  final FirebaseAuth _auth;
  final http.Client _http;

  WorkerMediaUploader(this._auth, [http.Client? client]) : _http = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${MediaConfig.uploadUrl}/$path');

  Future<Map<String, String>> _headers([String? contentType]) async {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) throw const MediaException(AdminStrings.errorPermission);
    return {'Authorization': 'Bearer $token', 'Content-Type': ?contentType};
  }

  @override
  Future<void> put(String path, Uint8List bytes, String contentType) async =>
      _check(await _http.put(_uri(path), headers: await _headers(contentType), body: bytes));

  @override
  Future<void> delete(String path) async => _check(await _http.delete(_uri(path), headers: await _headers()));

  void _check(http.Response r) {
    if (r.statusCode < 300) return;
    throw MediaException(switch (r.statusCode) {
      401 || 403 => AdminStrings.errorPermission,
      413 => AdminStrings.mediaTooLarge,
      _ => AdminStrings.mediaUploadFailed,
    });
  }
}
