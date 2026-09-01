import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';
import '../constants/admin_strings.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

class AdminColumn {
  final String label;

  /// Relative width. Sums across all columns define the split, so a table
  /// stays proportional at any window size instead of guessing pixels.
  final int flex;

  const AdminColumn(this.label, {this.flex = 1});
}

/// The dashboard's list table.
///
/// Hand-built rather than DataTable: the built-in one fixes row heights,
/// fights RTL, and can't put arbitrary widgets (status chips, thumbnails,
/// action buttons) in a cell without wrapping every one of them.
class AdminDataTable extends StatelessWidget {
  final List<AdminColumn> columns;
  final int rowCount;
  final List<Widget> Function(int index) cellsBuilder;
  final void Function(int index)? onRowTap;
  final String emptyMessage;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.cellsBuilder,
    this.onRowTap,
    this.emptyMessage = AdminStrings.noData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderRow(columns: columns),
        const Divider(color: AdminColors.border, height: 1),
        if (rowCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AdminConstants.spacingXl),
            child: Center(
              child: Text(emptyMessage, style: AdminTextStyles.caption),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCount,
            separatorBuilder: (_, __) =>
            const Divider(color: AdminColors.border, height: 1),
            itemBuilder: (context, index) => _Row(
              columns: columns,
              cells: cellsBuilder(index),
              onTap: onRowTap == null ? null : () => onRowTap!(index),
            ),
          ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<AdminColumn> columns;

  const _HeaderRow({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.surfaceRaised,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.spacingLg,
        vertical: AdminConstants.spacingMd,
      ),
      child: Row(
        children: columns
            .map(
              (column) => Expanded(
            flex: column.flex,
            child: Text(column.label, style: AdminTextStyles.tableHeader),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _Row extends StatefulWidget {
  final List<AdminColumn> columns;
  final List<Widget> cells;
  final VoidCallback? onTap;

  const _Row({required this.columns, required this.cells, this.onTap});

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          // Hover feedback matters more here than on mobile: a wide row is
          // hard to track across the screen without it.
          color: _isHovered ? AdminColors.surfaceRaised : Colors.transparent,
          constraints: const BoxConstraints(minHeight: AdminConstants.tableRowHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.spacingLg,
            vertical: AdminConstants.spacingSm,
          ),
          child: Row(
            children: List.generate(widget.columns.length, (index) {
              return Expanded(
                flex: widget.columns[index].flex,
                child: index < widget.cells.length
                    ? widget.cells[index]
                    : const SizedBox.shrink(),
              );
            }),
          ),
        ),
      ),
    );
  }
}