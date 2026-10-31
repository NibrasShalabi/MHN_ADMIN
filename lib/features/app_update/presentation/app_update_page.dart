import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/admin_constants.dart';
import '../../../core/constants/admin_strings.dart';
import '../../../core/error/admin_error.dart';
import '../../../core/theme/admin_text_styles.dart';
import '../../../core/widgets/admin_button.dart';
import '../../../core/widgets/admin_card.dart';
import '../../../core/widgets/admin_field.dart';
import '../../../core/widgets/admin_text_input.dart';
import '../data/app_update_repository.dart';

/// Edits config/app — what every launch of the customer app compares its
/// own build against.
class AppUpdatePage extends StatefulWidget {
  const AppUpdatePage({super.key});

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  final _repository = GetIt.instance<AppUpdateRepository>();
  final _latestBuild = TextEditingController();
  final _minBuild = TextEditingController();
  final _latestName = TextEditingController();
  final _notes = TextEditingController();
  final _storeUrl = TextEditingController();
  late final Future<void> _loaded = _repository.get().then((c) {
    _latestBuild.text = '${c.latestBuild}';
    _minBuild.text = '${c.minBuild}';
    _latestName.text = c.latestName;
    _notes.text = c.notes;
    _storeUrl.text = c.storeUrl;
  });
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_latestBuild, _minBuild, _latestName, _notes, _storeUrl]) {
      c.dispose();
    }
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  Future<void> _save() async {
    final latest = _int(_latestBuild), min = _int(_minBuild);
    final messenger = ScaffoldMessenger.of(context);
    if (min > latest) {
      messenger.showSnackBar(const SnackBar(content: Text(AdminStrings.updateMinAboveLatest)));
      return;
    }
    setState(() => _saving = true);
    try {
      await _repository.save(AppUpdateConfig(
        latestBuild: latest,
        minBuild: min,
        latestName: _latestName.text.trim(),
        notes: _notes.text.trim(),
        storeUrl: _storeUrl.text.trim(),
      ));
      messenger.showSnackBar(const SnackBar(content: Text(AdminStrings.saved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(AdminError.message(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loaded,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text(AdminError.message(snap.error!)));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminCard(
              title: AdminStrings.navAppUpdate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AdminStrings.updateHowItWorks, style: AdminTextStyles.caption),
                  const SizedBox(height: AdminConstants.spacingMd),
                  AdminField(
                    label: AdminStrings.updateLatestBuild,
                    hint: AdminStrings.updateLatestBuildHint,
                    child: AdminTextInput(controller: _latestBuild, keyboardType: TextInputType.number),
                  ),
                  AdminField(
                    label: AdminStrings.updateLatestName,
                    child: AdminTextInput(controller: _latestName, hint: '1.0.1'),
                  ),
                  AdminField(
                    label: AdminStrings.updateMinBuild,
                    hint: AdminStrings.updateMinBuildHint,
                    child: AdminTextInput(controller: _minBuild, keyboardType: TextInputType.number),
                  ),
                  AdminField(
                    label: AdminStrings.updateNotes,
                    child: AdminTextInput(controller: _notes, maxLines: 4),
                  ),
                  AdminField(
                    label: AdminStrings.updateStoreUrl,
                    child: AdminTextInput(controller: _storeUrl, hint: 'https://play.google.com/store/apps/details?id=…'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spacingLg),
            AdminButton(label: AdminStrings.save, onPressed: _saving ? null : _save),
          ],
        );
      },
    );
  }
}
