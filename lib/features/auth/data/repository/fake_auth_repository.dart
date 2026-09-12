import 'auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  // TODO(logic-phase): replace with real authentication (Firebase Auth
  // or equivalent) once the backend exists. One hardcoded credential is
  // a placeholder gate, not a security boundary — anyone reading the
  // source sees it.
  static const _email = 'admin@mhn.com';
  static const _password = 'admin123';

  @override
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return email.trim().toLowerCase() == _email && password == _password;
  }
}