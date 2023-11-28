class CartItem {
  String name;
  String image;
  String price;
  int count;
  List<String> extras;
  bool isVeg;
  CartItem(
      this.name, this.image, this.price, this.count, this.extras, this.isVeg);
}