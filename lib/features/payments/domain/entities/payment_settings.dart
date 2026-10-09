import 'package:equatable/equatable.dart';

/// Where customers send money — `config/payment_addresses`, shown at checkout.
enum PaymentChannel {
  trc20('USDT — TRC20 (Tron)'),
  bep20('USDT — BEP20 (BNB Smart Chain)'),
  erc20('USDT — ERC20 (Ethereum)'),
  shamCash('شام كاش');

  final String label;
  const PaymentChannel(this.label);

  /// Field name in Firestore — kept as the client already reads it.
  String get key => this == shamCash ? 'sham_cash' : name;

  /// Catches the usual paste mistakes before customers send money to them.
  bool isValidAddress(String value) => switch (this) {
        PaymentChannel.trc20 => RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$').hasMatch(value),
        PaymentChannel.bep20 || PaymentChannel.erc20 => RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(value),
        PaymentChannel.shamCash => value.length >= 6,
      };
}

class PaymentSettings extends Equatable {
  final Map<PaymentChannel, String> addresses;
  final Set<PaymentChannel> disabled;

  const PaymentSettings({this.addresses = const {}, this.disabled = const {}});

  factory PaymentSettings.fromMap(Map<String, dynamic> d) => PaymentSettings(
        addresses: {
          for (final c in PaymentChannel.values)
            if ((d[c.key] as String?)?.trim() case final v? when v.isNotEmpty) c: v,
        },
        disabled: {
          for (final c in PaymentChannel.values)
            if ((d['disabled'] as List? ?? const []).contains(c.key)) c,
        },
      );

  Map<String, dynamic> toMap() => {
        for (final c in PaymentChannel.values) c.key: addresses[c] ?? '',
        'disabled': [for (final c in disabled) c.key],
      };

  @override
  List<Object?> get props => [addresses, disabled];
}
