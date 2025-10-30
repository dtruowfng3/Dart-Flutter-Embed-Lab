//product.dart
class Product {
  final String id;
  final String name;
  int quantity;

  Product({required this.id, required this.name, required this.quantity});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'quantity': quantity};
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(id: map['id'], name: map['name'], quantity: map['quantity']);
  }
}
