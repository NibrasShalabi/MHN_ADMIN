import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/admin_strings.dart';
import 'core/injector/injector.dart';
import 'core/theme/admin_colors.dart';
import 'core/theme/admin_text_styles.dart';
import 'features/dashboard/presentation/pages/admin_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Arabic date formatting data — loaded once, before anything renders.
  await initializeDateFormatting('ar');
  setupInjector();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AdminStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AdminColors.canvas,
        fontFamily: 'Tajawal',
        colorScheme: const ColorScheme.dark(
          primary: AdminColors.primary,
          secondary: AdminColors.gold,
          surface: AdminColors.surface,
          error: AdminColors.danger,
        ),
        dividerColor: AdminColors.border,
        textTheme: const TextTheme(bodyMedium: AdminTextStyles.body),
      ),
      // Arabic-only, same as the app: RTL is forced through `builder`
      // rather than a Locale, because MaterialApp inserts its own
      // Directionality that would override anything wrapped outside it.
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      // TODO(routing): move to go_router once there are deep links worth
      // addressing. Until then the shell owns section switching, and a
      // router would add indirection without buying anything.
      home: const AdminHomePage(),
    );
  }
}