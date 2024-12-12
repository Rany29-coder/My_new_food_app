class Product {
  final String id;
  final String name;
  final double price;
  final double originalPrice; // Original price
  final DateTime expiryDate;
  final String details;
  final String imageUrl;
  final double weight; // Weight
  final double rating; // Rating

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.expiryDate,
    required this.details,
    required this.imageUrl,
    required this.weight,
    required this.rating,
  });

factory Product.fromMap(Map<String, dynamic> map, String id) {
  return Product(
    id: id,
    name: map['productName'] ?? 'Unknown', // Provide a default value
    price: map['price'] != null ? double.parse(map['price'].toString()) : 0.0,
    originalPrice: map['originalPrice'] != null ? double.parse(map['originalPrice'].toString()) : 0.0,
    expiryDate: map['expiryDate'] != null
        ? DateTime.parse(map['expiryDate'])
        : DateTime.now(), // Provide a default date
    details: map['details'] ?? 'No details available', // Provide default text
    imageUrl: map['imageUrl'] ?? '', // Default to an empty string
    weight: map['weight'] != null ? double.parse(map['weight'].toString()) : 0.0,
    rating: map['rating'] != null ? double.parse(map['rating'].toString()) : 0.0,
  );
}


  Map<String, dynamic> toMap() {
    return {
      'productName': name,
      'price': price,
      'originalPrice': originalPrice,
      'expiryDate': expiryDate.toIso8601String(),
      'details': details,
      'imageUrl': imageUrl,
      'weight': weight,
      'rating': rating,
    };
  }
}
