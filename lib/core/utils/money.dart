import 'package:intl/intl.dart';

/// The store prices everything in US dollars: "$1,250" or "$9.99".
abstract final class Money {
  static final NumberFormat _format = NumberFormat('#,##0.##', 'en');

  static String format(num amount) => '\$${_format.format(amount)}';
}
