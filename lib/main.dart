import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/admin_strings.dart';
import 'core/injector/injector.dart';
import 'core/theme/admin_colors.dart';
import 'core/theme/admin_text_styles.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const LoginPage(),
    );
  }
}