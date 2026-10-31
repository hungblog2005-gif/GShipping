import 'package:latlong2/latlong.dart';

/// Contract cho dịch vụ quản lý ca làm việc.
abstract class IShiftService {
  /// Lấy danh sách tất cả ca làm việc (Một lần)
  Future<List<Map<String, dynamic>>> getShifts();

  /// Lắng nghe danh sách ca làm việc (Real-time)
  Stream<List<Map<String, dynamic>>> getShiftsStream();

  /// Đăng ký một ca làm việc mới
  Future<void> addShift({
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    required LatLng locationCoord,
    List<String>? customerIds,
    String status = 'pending',
  });

  /// Cập nhật trạng thái ca làm việc (ví dụ: xác nhận, hoàn thành)
  Future<void> updateShiftStatus(String id, String status);

  /// Xóa ca làm việc
  Future<void> deleteShift(String id);
}
