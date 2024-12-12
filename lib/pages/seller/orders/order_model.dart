class Order {
  final String id;
  final String buyerId;
  final String ownerId;
  final String productId;
  final String productName;
  final int quantity;
  String status; // Removed final to allow updates
  final double totalPrice;

  Order({
    required this.id,
    required this.buyerId,
    required this.ownerId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.totalPrice,
  });

  factory Order.fromMap(Map<String, dynamic> data, String documentId) {
    return Order(
      id: documentId,
      buyerId: data['buyerId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      status: data['status'] ?? 'Pending',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': id,
      'buyerId': buyerId,
      'ownerId': ownerId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'status': status,
      'totalPrice': totalPrice,
    };
  }
}
