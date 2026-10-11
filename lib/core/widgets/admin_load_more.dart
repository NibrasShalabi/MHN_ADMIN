import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../constants/admin_strings.dart';
import 'admin_button.dart';

/// "Load more" under a paged list; hidden once everything is loaded.
class AdminLoadMore extends StatelessWidget {
  final bool hasMore;
  final bool loading;
  final VoidCallback onPressed;

  const AdminLoadMore({super.key, required this.hasMore, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AdminConstants.spacingMd),
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : AdminButton(
                label: AdminStrings.loadMore,
                icon: Icons.expand_more,
                kind: AdminButtonKind.secondary,
                onPressed: onPressed,
              ),
      ),
    );
  }
}
