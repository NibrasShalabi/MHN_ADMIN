import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../constants/admin_strings.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// One entry in the dashboard sidebar.
class AdminNavItem {
  final String id;
  final String label;
  final IconData icon;

  const AdminNavItem({required this.id, required this.label, required this.icon});
}

/// Dashboard frame: fixed sidebar on wide screens, drawer on narrow ones.
///
/// The sidebar is pinned rather than collapsible on desktop — an admin
/// moves between orders, products and support constantly, and hiding that
/// behind a toggle adds a click to every one of those moves.
class AdminShell extends StatelessWidget {
  final List<AdminNavItem> items;
  final String selectedId;
  final ValueChanged<String> onSelect;

  final String title;
  final List<Widget> actions;
  final Widget child;

  const AdminShell({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).width < AdminConstants.compactBreakpoint;

    final sidebar = _Sidebar(
      items: items,
      selectedId: selectedId,
      onSelect: (id) {
        if (isCompact) Navigator.of(context).maybePop();
        onSelect(id);
      },
    );

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      endDrawer: isCompact ? Drawer(child: sidebar) : null,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _TopBar(title: title, actions: actions, showMenu: isCompact),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AdminConstants.maxContentWidth,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // RTL: the sidebar belongs on the right, which is where `Row`
          // puts its last child.
          if (!isCompact) sidebar,
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<AdminNavItem> items;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _Sidebar({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AdminConstants.sidebarWidth,
      color: AdminColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AdminConstants.spacingLg),
              child: Text(AdminStrings.brandShort, style: AdminTextStyles.pageTitle),
            ),
            const Divider(color: AdminColors.border, height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingSm),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _NavTile(
                    item: item,
                    isSelected: item.id == selectedId,
                    onTap: () => onSelect(item.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final AdminNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AdminColors.gold : AdminColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.surface : null,
          border: BorderDirectional(
            // Marker on the inner edge — in RTL that's the left side of
            // the sidebar, facing the content.
            end: BorderSide(
              color: isSelected ? AdminColors.gold : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.spacingLg,
          vertical: AdminConstants.spacingMd,
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: color),
            const SizedBox(width: AdminConstants.spacingMd),
            Expanded(
              child: Text(
                item.label,
                style: AdminTextStyles.body.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final bool showMenu;

  const _TopBar({required this.title, required this.actions, required this.showMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AdminConstants.topBarHeight,
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(
          bottom: BorderSide(color: AdminColors.border, width: AdminConstants.borderThin),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AdminConstants.spacingLg),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AdminTextStyles.pageTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...actions,
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AdminColors.gold),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
    );
  }
}