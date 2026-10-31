import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/constants/admin_strings.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../data/repository/products_repository.dart';
import '../../domain/entities/product.dart';

/// Picks one store product by searching its name on the server — the
/// pickers used to load every product to fill a dropdown.
class ProductPicker extends StatefulWidget {
  /// Shown as picked on open (an existing banner's product).
  final String? initialId;

  /// Limits the results to one section; null = all of them.
  final String? section;

  final ValueChanged<Product?> onChanged;

  const ProductPicker({super.key, this.initialId, this.section, required this.onChanged});

  @override
  State<ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<ProductPicker> {
  static const Duration _debounce = Duration(milliseconds: 400);

  final _repository = GetIt.instance<ProductsRepository>();
  final _controller = TextEditingController();
  Timer? _timer;
  Product? _selected;
  List<Product> _results = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialId case final id?) {
      _repository.getProduct(id).then((p) {
        if (mounted) setState(() => _selected = p);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Waits for typing to pause, so a word is one query, not one per letter.
  void _onTyped(String query) {
    _timer?.cancel();
    _timer = Timer(_debounce, () async {
      setState(() => _loading = true);
      final results = await _repository.search(query, section: widget.section).catchError((_) => <Product>[]);
      if (!mounted || query != _controller.text) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    });
  }

  void _pick(Product? product) {
    setState(() => _selected = product);
    widget.onChanged(product);
  }

  @override
  Widget build(BuildContext context) {
    if (_selected case final p?) {
      return Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AdminColors.gold, size: 20),
          const SizedBox(width: AdminConstants.spacingSm),
          Expanded(child: Text('${p.name} — ${Money.format(p.price)}', style: AdminTextStyles.body)),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AdminColors.textSecondary),
            onPressed: () => _pick(null),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminTextInput(controller: _controller, hint: AdminStrings.searchProducts, onChanged: _onTyped),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AdminConstants.spacingSm),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_controller.text.trim().isNotEmpty && _results.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AdminConstants.spacingSm),
            child: Text(AdminStrings.noProducts, style: AdminTextStyles.caption),
          )
        else
          for (final p in _results)
            ListTile(
              dense: true,
              title: Text(p.name, style: AdminTextStyles.body),
              trailing: Text(Money.format(p.price), style: AdminTextStyles.caption),
              onTap: () => _pick(p),
            ),
      ],
    );
  }
}
