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

    Widget buildPaymentTile({
      required PaymentMethod value,
      required String title,
      required String assetLogo,
    }) {
      return RadioListTile<PaymentMethod>(
        value: value,
        groupValue: selected,
        onChanged: (v) => onChanged(v!),
        title: Row(
          children: [
            Image.asset(
              assetLogo,
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
        activeColor: const Color(0xFF124170),
      );
    }

    return Column(
      children: [
        buildPaymentTile(
          value: PaymentMethod.paylater,
          title: 'PayLater',
          assetLogo: 'assets/images/Paylater.png',
        ),
        buildPaymentTile(
          value: PaymentMethod.dana,
          title: 'DANA',
          assetLogo: 'assets/images/Dana.png',
        ),
        buildPaymentTile(
          value: PaymentMethod.cod,
          title: 'Bayar di Tempat (COD)',
          assetLogo: 'assets/images/COD.png',
        ),
        buildPaymentTile(
          value: PaymentMethod.ovo,
          title: 'OVO',
          assetLogo: 'assets/images/OVO.png',
        ),
      ],
    );
  }
}
