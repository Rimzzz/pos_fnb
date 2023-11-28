import 'dart:convert';

List<Product> productFromMap(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromMap(x)));

String productToMap(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Product {
  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.picture,
    required this.sku,
    required this.categoryId,
    required this.categoryName,
    required this.isActive,
  });

  final String productId;
  final String productName;
  final String price;
  final String picture;
  final String sku;
  final String categoryId;
  final String categoryName;
  final String isActive;

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        productId: json["product_id"],
        productName: json["product_name"],
        price: json["price"],
        picture: json["picture"],
        sku: json["sku"] ?? '',
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        isActive: json["is_active"],
      );

  Map<String, dynamic> toMap() => {
        "product_id": productId,
        "product_name": productName,
        "price": price,
        "picture": picture,
        "sku": sku,
        "category_id": categoryId,
        "category_name": categoryName,
        "is_active": isActive,
      };

      Map<String, dynamic> toMapLocalDb() => {
        "id":productId,
        "product_id": productId,
        "product_name": productName,
        "price": price,
        "picture": picture,
        "sku": sku,
        "category_id": categoryId,
        "category_name": categoryName,
        "is_active": isActive,
      };

  @override
  String toString() {
    return 'Product(productId: $productId, productName: $productName, price: $price, picture: $picture, sku: $sku, categoryId: $categoryId, categoryName: $categoryName, isActive: $isActive)';
  }
}
