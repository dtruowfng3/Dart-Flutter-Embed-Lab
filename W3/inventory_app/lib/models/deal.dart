//deal.dart
class Deal {
  final int? id;
  final String productId;
  final String type; // 'import' or 'export'
  final int quantity;
  final DateTime timestamp;

  Deal({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static Deal fromMap(Map<String, dynamic> map) {
    return Deal(
      id: map['id'],
      productId: map['product_id'],
      type: map['type'],
      quantity: map['quantity'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
