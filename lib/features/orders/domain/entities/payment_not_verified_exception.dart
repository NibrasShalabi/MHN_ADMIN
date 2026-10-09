/// An order paid in money can't be confirmed before its payment is verified.
class PaymentNotVerifiedException implements Exception {
  const PaymentNotVerifiedException();
}
