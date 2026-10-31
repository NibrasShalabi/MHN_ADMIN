import 'package:cloud_firestore/cloud_firestore.dart';

/// What the app checks on every launch (config/app). Builds are the
/// `+N` in pubspec's `version: 1.2.0+N` — they only go up.
class AppUpdateConfig {
  /// The newest build in the store; older builds are offered the update.
  final int latestBuild;

  /// Builds below this can't be used until updated — for a breaking change
  /// or a serious bug. Keep it at or below [latestBuild].
  final int minBuild;

  /// Shown to the customer, e.g. "1.2.0".
  final String latestName;
  final String notes;

  /// Where the update button goes — the Play Store page, or a direct APK link.
  final String storeUrl;

  const AppUpdateConfig({
    this.latestBuild = 0,
    this.minBuild = 0,
    this.latestName = '',
    this.notes = '',
    this.storeUrl = '',
  });

  factory AppUpdateConfig.fromMap(Map<String, dynamic> m) => AppUpdateConfig(
        latestBuild: (m['latestBuild'] as num? ?? 0).toInt(),
        minBuild: (m['minBuild'] as num? ?? 0).toInt(),
        latestName: m['latestName'] as String? ?? '',
        notes: m['notes'] as String? ?? '',
        storeUrl: m['storeUrl'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'latestBuild': latestBuild,
        'minBuild': minBuild,
        'latestName': latestName,
        'notes': notes,
        'storeUrl': storeUrl,
      };
}

class AppUpdateRepository {
  final FirebaseFirestore _db;

  AppUpdateRepository(this._db);

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('config').doc('app');

  Future<AppUpdateConfig> get() async => AppUpdateConfig.fromMap((await _doc.get()).data() ?? const {});

  Future<void> save(AppUpdateConfig config) => _doc.set(config.toMap());
}
