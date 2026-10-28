import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shift_model.dart';
import '../services/firestore_shift_service.dart';
import '../../contacts/services/firestore_customer_service.dart';
import 'customer_map_screen.dart';

class ShiftDetailScreen extends StatefulWidget {
  final Shift shift;

  const ShiftDetailScreen({
    super.key,
    required this.shift,
  });

  @override
  State<ShiftDetailScreen> createState() => _ShiftDetailScreenState();
}

class _ShiftDetailScreenState extends State<ShiftDetailScreen> {
  final FirestoreShiftService _shiftService = FirestoreShiftService();
  final FirestoreCustomerService _customerService = FirestoreCustomerService();

  final TextEditingController _phoneSearchController = TextEditingController();
  List<Map<String, dynamic>> _searchedCustomers = [];
  Set<String> _selectedCustomerIds = {};

  Future<void> _handleDelete() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ca làm này không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await _shiftService.deleteShift(widget.shift.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa ca làm thành công')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa ca làm: $e')),
          );
        }
      }
    }
  }

  Future<void> _searchCustomerByPhone(String phone, {StateSetter? onUpdate}) async {
    try {
      final data = await _customerService.getCustomers();
      setState(() {
        if (phone.isEmpty) {
          _searchedCustomers = data;
        } else {
          _searchedCustomers = data.where((c) => c['phoneNumber'].toString().contains(phone)).toList();
        }
      });
      if (onUpdate != null) {
        onUpdate(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
    }
  }

  void _showCustomerSelectionDialog() async {
    // Load toàn bộ khách hàng trước khi hiển thị dialog
    await _searchCustomerByPhone('');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tìm & Chọn khách hàng'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _phoneSearchController,
                      decoration: const InputDecoration(
                        labelText: 'Nhập SĐT khách hàng',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _searchCustomerByPhone(value, onUpdate: setStateDialog);
                      },
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: _searchedCustomers.isEmpty
                          ? const Center(child: Text('Không tìm thấy khách hàng nào'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchedCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = _searchedCustomers[index];
                                final id = customer['id'];
                                final isSelected = _selectedCustomerIds.contains(id);

                                return CheckboxListTile(
                                  title: Text(customer['fullName']),
                                  subtitle: Text(customer['phoneNumber']),
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedCustomerIds.add(id);
                                      } else {
                                        _selectedCustomerIds.remove(id);
                                      }
                                    });
                                    setStateDialog(() {});
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedCustomerIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất một khách hàng')));
                      return;
                    }
                    Navigator.pop(context);
                    _showMapWithSelectedCustomers();
                  },
                  child: const Text('Xem bản đồ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMapWithSelectedCustomers() async {
    List<Map<String, dynamic>> selectedData = [];
    final allCustomers = await _customerService.getCustomers();

    for (var id in _selectedCustomerIds) {
      final customer = allCustomers.firstWhere((c) => c['id'] == id);
      selectedData.add(customer);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerMapScreen(customers: selectedData),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed': return 'Đã xác nhận';
      case 'pending': return 'Đang chờ';
      case 'completed': return 'Hoàn thành';
      default: return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'completed': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ca làm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _handleDelete,
            tooltip: 'Xóa ca làm',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(shift.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(shift.status)),
                ),
                child: Text(
                  _getStatusText(shift.status),
                  style: TextStyle(
                    color: _getStatusColor(shift.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailItem(Icons.calendar_today, 'Ngày làm việc', dateFormat.format(shift.startTime)),
            const SizedBox(height: 16),
            _buildDetailItem(Icons.access_time, 'Thời gian', '${timeFormat.format(shift.startTime)} - ${timeFormat.format(shift.endTime)}'),
            const SizedBox(height: 16),
            _buildDetailItem(Icons.location_on, 'Địa điểm', shift.location),
            const SizedBox(height: 16),
            _buildDetailItem(Icons.fingerprint, 'Mã ca làm', shift.id),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCustomerSelectionDialog,
                icon: const Icon(Icons.map),
                label: const Text('Tìm khách hàng & Xem bản đồ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
