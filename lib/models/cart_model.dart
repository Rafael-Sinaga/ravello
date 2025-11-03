class CartItem {
  final String title;
  final String price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.title,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });
}
