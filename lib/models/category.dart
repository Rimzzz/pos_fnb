import 'dart:convert';

List<Category> categoryFromMap(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromMap(x)));

String categoryToMap(List<Category> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Category {
  Category({
    required this.id,
    required this.categoryName,
    required this.picture,
  });

  final String id;
  final String categoryName;
  final String picture;

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        categoryName: json["category_name"],
        picture: json["picture"],
      );

  factory Category.fromMapLocalDb(Map<String, dynamic> json) => Category(
        id: json["id_category"],
        categoryName: json["category_name"],
        picture: json["picture"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "category_name": categoryName,
        "picture": picture,
      };

  Map<String, dynamic> toMapLocalDb() => {
        "id": id,
        "id_category": id,
        "category_name": categoryName,
        "picture": picture,
      };

  Category copyWith({
    String? id,
    String? categoryName,
    String? picture,
  }) {
    return Category(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      picture: picture ?? this.picture,
    );
  }
}
