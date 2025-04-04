import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      customerName: data['customerName'] ?? '',
      status: data['status'] ?? 'Pending',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
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

  String getLocalizedStatus(AppLocalizations locale) {
    switch (status.toLowerCase()) {
      case 'completed':
        return locale.statusCompleted;
      case 'cancelled':
        return locale.statusCancelled;
      default:
        return locale.statusPending;
    }
  }

  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'orange';
    }
  }
}
