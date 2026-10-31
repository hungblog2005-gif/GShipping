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

  late final Future<List<Map<String, dynamic>>> _shiftCustomersFuture;
  final TextEditingController _phoneSearchController = TextEditingController();
  List<Map<String, dynamic>> _searchedCustomers = [];
  Set<String> _selectedCustomerIds = {};
  late String _currentStatus;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.shift.status;
    _shiftCustomersFuture = widget.shift.customerIds.isEmpty
        ? Future.value([])
        : _customerService.getCustomers();
  }

  Future<void> _markShiftCompleted() async {
    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _shiftService.updateShiftStatus(widget.shift.id, 'completed');
      if (!mounted) return;
      setState(() {
        _currentStatus = 'completed';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ca làm thành hoàn thành')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật trạng thái ca làm: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ca làm này không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold)),
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
    await _searchCustomerByPhone('');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Tìm & Chọn khách hàng',
                style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _phoneSearchController,
                      decoration: InputDecoration(
                        labelText: 'Nhập SĐT khách hàng',
                        prefixIcon: const Icon(Icons.phone, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        _searchCustomerByPhone(value, onUpdate: setStateDialog);
                      },
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: _searchedCustomers.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('Không tìm thấy khách hàng nào', style: TextStyle(color: Color(0xFF64748B))),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchedCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = _searchedCustomers[index];
                                final id = customer['id'];
                                final isSelected = _selectedCustomerIds.contains(id);

                                return CheckboxListTile(
                                  title: Text(
                                    customer['fullName'],
                                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(customer['phoneNumber'], style: const TextStyle(color: Color(0xFF64748B))),
                                  value: isSelected,
                                  activeColor: const Color(0xFF2563EB),
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedCustomerIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn ít nhất một khách hàng')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _showMapWithSelectedCustomers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
      case 'confirmed': return const Color(0xFF15803D); // Success Green
      case 'pending': return const Color(0xFFB45309); // Warning Amber
      case 'completed': return const Color(0xFF64748B); // Slate
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Chi tiết ca làm',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFB91C1C)),
            onPressed: _handleDelete,
            tooltip: 'Xóa ca làm',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(_currentStatus), width: 1),
                ),
                child: Text(
                  _getStatusText(_currentStatus),
                  style: TextStyle(
                    color: _getStatusColor(_currentStatus),
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
            const SizedBox(height: 24),
            _buildShiftCustomers(),
            const SizedBox(height: 40),
            if (_currentStatus != 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUpdatingStatus ? null : _markShiftCompleted,
                  icon: _isUpdatingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_isUpdatingStatus ? 'Đang cập nhật...' : 'Hoàn thành ca làm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (_currentStatus != 'completed') const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCustomerSelectionDialog,
                icon: const Icon(Icons.map),
                label: const Text('Tìm khách hàng & Xem bản đồ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCustomers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khách hàng đã đăng ký',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _shiftCustomersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
            }
            if (snapshot.hasError) {
              return Text(
                'Lỗi tải danh sách khách hàng: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFB91C1C)),
              );
            }

            final customersById = {
              for (final customer in snapshot.data ?? [])
                customer['id']?.toString() ?? '': customer,
            };
            if (widget.shift.customerIds.isEmpty) {
              return const Text('Ca làm này chưa có khách hàng.', style: TextStyle(color: Color(0xFF64748B)));
            }

            return Column(
              children: widget.shift.customerIds.map((id) {
                final customer = customersById[id];
                final name = customer?['fullName']?.toString();
                final phone = customer?['phoneNumber']?.toString() ?? '';
                final address = customer?['address']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEFF6FF),
                      child: Icon(Icons.person, color: Color(0xFF2563EB)),
                    ),
                    title: Text(
                      name ?? 'Khách hàng không còn trong danh sách đã lưu',
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                    ),
                    subtitle: name == null
                        ? null
                        : Text(
                            [phone, address].where((value) => value.isNotEmpty).join('\n'),
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
