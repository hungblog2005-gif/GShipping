import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String? note;
  final List<String>? imageUrls;

  Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.note,
    this.imageUrls,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      note: map['note'],
      imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null,
    );
  }
}
