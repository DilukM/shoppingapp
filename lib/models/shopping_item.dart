class ShoppingItem {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String? imageBase64;

  ShoppingItem({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imageBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageBase64': imageBase64,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      imageBase64: map['imageBase64'],
    );
  }
}

class CartItem {
  final int? id;
  final int productId;
  final String name;
  final double price;
  int quantity;
  final String? imageBase64;

  CartItem({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageBase64': imageBase64,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id']?.toInt(),
      productId: map['productId']?.toInt() ?? 0,
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 1,
      imageBase64: map['imageBase64'],
    );
  }
}
