import '../../../../core/constants/admin_strings.dart';

enum OrderTab { pending, ongoing }

extension OrderTabX on OrderTab {
  String get label => switch (this) {
    OrderTab.pending => AdminStrings.ordersPendingTab,
    OrderTab.ongoing => AdminStrings.ordersOngoingTab,
  };
}

enum SortOrder { newest, oldest }

extension SortOrderX on SortOrder {
  String get label => switch (this) {
    SortOrder.newest => AdminStrings.sortNewestFirst,
    SortOrder.oldest => AdminStrings.sortOldestFirst,
  };
}