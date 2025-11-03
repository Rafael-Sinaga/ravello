class PaymentMethodModel {
  final String name;
  final String icon;
  final bool isSelected;

  PaymentMethodModel({
    required this.name,
    required this.icon,
    this.isSelected = false,
  });
}
