import 'package:firebase_core/firebase_core.dart';

import '../constants/admin_strings.dart';

/// One Arabic message for any failure, instead of raw exception text.
abstract final class AdminError {
  static String message(Object e) => switch (e) {
        FirebaseException(code: final c) => switch (c) {
            'unavailable' || 'network-request-failed' || 'deadline-exceeded' => AdminStrings.errorNetwork,
            'permission-denied' || 'unauthenticated' => AdminStrings.errorPermission,
            'not-found' => AdminStrings.errorNotFound,
            'already-exists' => AdminStrings.errorExists,
            'resource-exhausted' => AdminStrings.errorBusy,
            _ => AdminStrings.somethingWentWrong,
          },
        // Messages the app raises itself are already Arabic.
        Exception() when _isArabic('$e') => '$e'.replaceFirst('Exception: ', ''),
        _ => AdminStrings.somethingWentWrong,
      };

  static bool _isArabic(String s) => RegExp(r'[؀-ۿ]').hasMatch(s);
}
