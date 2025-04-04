import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final DateTime expiryDate;
  final String details;
  final String imageUrl;
  final double weight;
  final double rating;

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

  /// Factory with localization context
  factory Product.fromMap(Map<String, dynamic> map, String id, BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Product(
      id: id,
      name: map['productName'] ?? locale.unknownProduct,
      price: map['price'] != null ? double.tryParse(map['price'].toString()) ?? 0.0 : 0.0,
      originalPrice: map['originalPrice'] != null ? double.tryParse(map['originalPrice'].toString()) ?? 0.0 : 0.0,
      expiryDate: map['expiryDate'] != null
          ? DateTime.tryParse(map['expiryDate']) ?? DateTime.now()
          : DateTime.now(),
      details: map['details'] ?? locale.noDetailsAvailable,
      imageUrl: map['imageUrl'] ?? '',
      weight: map['weight'] != null ? double.tryParse(map['weight'].toString()) ?? 0.0 : 0.0,
      rating: map['rating'] != null ? double.tryParse(map['rating'].toString()) ?? 0.0 : 0.0,
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
