import 'package:cloud_firestore/cloud_firestore.dart';

class Shift {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String status; // 'pending', 'confirmed', 'completed'

  Shift({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.status,
  });

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] ?? '',
      startTime: _parseDateTime(map['startTime']),
      endTime: _parseDateTime(map['endTime']),
      location: map['location'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
