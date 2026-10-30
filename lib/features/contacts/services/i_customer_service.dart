import 'package:latlong2/latlong.dart';

/// Contract cho dịch vụ quản lý khách hàng.
/// Bất kỳ triển khai nào (Firestore, SQL, API) đều phải tuân thủ hợp đồng này.
abstract class ICustomerService {
  /// Thêm một khách hàng mới vào hệ thống
  Future<void> addCustomer({
    required String name,
    required String phone,
    required String address,
    required LatLng location,
    List<String>? imageUrls,
  });

  /// Lấy danh sách tất cả khách hàng
  Future<List<Map<String, dynamic>>> getCustomers();

  /// Cập nhật thông tin khách hàng
  Future<void> updateCustomer(String id, Map<String, dynamic> data);

  /// Xóa khách hàng
  Future<void> deleteCustomer(String id);
}
