// lib/widgets/payment_method_selector.dart
import 'package:flutter/material.dart';

enum PaymentMethod { paylater, dana, cod, ovo }

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF124170);

    return Column(
      children: [
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.paylater,
          groupValue: selected,
          onChanged: (v) => onChanged(v!),
          title: const Text('PayLater'),
          secondary: const Icon(Icons.account_balance_wallet_outlined),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.dana,
          groupValue: selected,
          onChanged: (v) => onChanged(v!),
          title: const Text('Dana'),
          secondary: const Icon(Icons.account_balance_wallet),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.cod,
          groupValue: selected,
          onChanged: (v) => onChanged(v!),
          title: const Text('Bayar di tempat'),
          secondary: const Icon(Icons.money_outlined),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.ovo,
          groupValue: selected,
          onChanged: (v) => onChanged(v!),
          title: const Text('OVO'),
          secondary: const Icon(Icons.payment_outlined),
        ),
      ],
    );
  }
}
