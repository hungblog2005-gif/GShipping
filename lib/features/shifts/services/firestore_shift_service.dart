import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'i_shift_service.dart';

class FirestoreShiftService implements IShiftService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'shifts';

  @override
  Future<List<Map<String, dynamic>>> getShifts() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .orderBy('startTime', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      throw Exception('Firestore Error (getShifts): $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getShiftsStream() {
    return _db
        .collection(_collection)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  @override
  Future<void> addShift({
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    required LatLng locationCoord,
    String status = 'pending',
  }) async {
    try {
      await _db.collection(_collection).add({
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'location': location,
        'latitude': locationCoord.latitude,
        'longitude': locationCoord.longitude,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Firestore Error (addShift): $e');
    }
  }

  @override
  Future<void> updateShiftStatus(String id, String status) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Firestore Error (updateShiftStatus): $e');
    }
  }

  @override
  Future<void> deleteShift(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Firestore Error (deleteShift): $e');
    }
  }
}
