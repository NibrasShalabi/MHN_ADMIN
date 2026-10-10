import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_card.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/fitness_repository.dart';

/// The specialist's WhatsApp number, used by the supplements page and the
/// "ask the specialist" button on consult-only products.
class SpecialistWhatsappCard extends StatefulWidget {
  const SpecialistWhatsappCard({super.key});

  @override
  State<SpecialistWhatsappCard> createState() => _SpecialistWhatsappCardState();
}

class _SpecialistWhatsappCardState extends State<SpecialistWhatsappCard> {
  final _repo = GetIt.instance<FitnessRepository>();
  final _number = TextEditingController();
  String _saved = '';
  bool _loading = true;
  bool _saving = false;

  static final _valid = RegExp(r'^\+?[0-9]{9,15}$');

  @override
  void initState() {
    super.initState();
    _repo.getSpecialistWhatsapp().then((n) {
      if (!mounted) return;
      setState(() {
        _number.text = _saved = n;
        _loading = false;
      });
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  String get _value => _number.text.trim();
  bool get _isValid => _valid.hasMatch(_value);

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repo.setSpecialistWhatsapp(_value);
      _saved = _value;
      _toast(AdminStrings.saved);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: AdminStrings.specialistWhatsapp,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AdminStrings.specialistWhatsappHint, style: AdminTextStyles.caption),
                const SizedBox(height: AdminConstants.spacingMd),
                AdminTextInput(
                  controller: _number,
                  hint: '963912345678',
                  keyboardType: TextInputType.phone,
                  errorText: _value.isNotEmpty && !_isValid ? AdminStrings.specialistWhatsappInvalid : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AdminConstants.spacingMd),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AdminButton(
                    label: AdminStrings.save,
                    onPressed: _saving || !_isValid || _value == _saved ? null : _save,
                  ),
                ),
              ],
            ),
    );
  }
}
