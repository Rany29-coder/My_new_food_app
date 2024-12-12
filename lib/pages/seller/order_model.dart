class Order {
  final String id;
  final String customerName;
  final String status;
  final double totalAmount;

  Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.totalAmount,
  });

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      id: data['id'],
      customerName: data['customerName'],
      status: data['status'],
      totalAmount: data['totalAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'status': status,
      'totalAmount': totalAmount,
    };
  }
}
