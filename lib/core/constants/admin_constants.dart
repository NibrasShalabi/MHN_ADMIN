/// Layout tokens for the dashboard.
class AdminConstants {
  AdminConstants._();

  static const String appName = 'MHN Shopping — لوحة التحكم';

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 16;

  static const double borderThin = 1;

  // Shell
  static const double sidebarWidth = 248;
  static const double topBarHeight = 60;

  /// Below this the sidebar collapses into a drawer. Set where a sidebar
  /// plus a usable table stop fitting side by side, not at a device size.
  static const double compactBreakpoint = 1000;

  /// Content stops widening past this — full-width text rows on a large
  /// monitor are hard to scan.
  static const double maxContentWidth = 1320;

  // Forms
  static const double fieldHeight = 42;
  static const double sidePanelWidth = 460;

  // Tables
  static const double tableRowHeight = 56;
}