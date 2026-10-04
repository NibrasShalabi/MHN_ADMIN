import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';

/// Firebase implementation لـ AuthRepository في الـ Admin
///
/// الفرق عن Client App:
/// - بعد login، نتحقق من الـ admin custom claim
/// - لو ما في claim → نرجع false (مو admin)
/// - الـ claim يُضاف من Firebase Console أو Cloud Function
class FirebaseAdminAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAdminAuthRepository(this._auth);

  /// تسجيل الدخول مع التحقق من الـ admin claim
  /// Returns false لو:
  /// 1. بيانات غلط
  /// 2. المستخدم مو admin
  @override
  Future<bool> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // تحقق من الـ admin custom claim
      final idTokenResult = await credential.user!.getIdTokenResult(true);
      final isAdmin = idTokenResult.claims?['admin'] == true;

      if (!isAdmin) {
        // مو admin — سجّل خروج فوراً
        await _auth.signOut();
        return false;
      }

      return true;
    } on FirebaseAuthException {
      return false;
    }
  }
}