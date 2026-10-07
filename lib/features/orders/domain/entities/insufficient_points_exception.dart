/// Confirming a loyalty order would take the customer's balance below zero.
class InsufficientPointsException implements Exception {
  final int required;
  final int balance;

  const InsufficientPointsException({required this.required, required this.balance});
}
