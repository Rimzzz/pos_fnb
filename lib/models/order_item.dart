import 'product.dart';

class OrderItem {
  final Product product;
  int quantity;
  OrderItem({
    required this.product,
    required this.quantity,
  });

  @override
  String toString() => 'OrderItem(product: $product, quantity: $quantity)';
}
