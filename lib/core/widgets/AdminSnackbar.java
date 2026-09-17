//import 'package:flutter/material.dart';
//import '../theme/admin_colors.dart';
//import '../theme/admin_text_styles.dart';
//import '../constants/admin_constants.dart';
//
//class AdminSnackbar {
//  static void error(BuildContext context, String message) => _show(context, message, AdminColors.danger);
//  static void success(BuildContext context, String message) => _show(context, message, AdminColors.success);
//  static void info(BuildContext context, String message) => _show(context, message, AdminColors.primary);
//
//  static void _show(BuildContext context, String message, Color color) {
//    ScaffoldMessenger.of(context).showSnackBar(
//            SnackBar(
//                    content: Text(message, style: AdminTextStyles.caption.copyWith(color: AdminColors.textPrimary)),
//    backgroundColor: color,
//            behavior: SnackBarBehavior.floating,
//            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminConstants.radiusSm)),
//    duration: const Duration(seconds: 3),
//      ),
//    );
//  }
//}