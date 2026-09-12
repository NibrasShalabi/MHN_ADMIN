abstract class AuthRepository {
  /// Returns true on success. Never throws for wrong credentials — a
  /// failed login is a normal outcome, not an error.
  Future<bool> login(String email, String password);
}