import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../services/firestore_shift_service.dart';
import '../../contacts/services/firestore_customer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shift_detail_screen.dart';
import 'customer_map_screen.dart';
import '../models/shift_model.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  final FirestoreShiftService _shiftService = FirestoreShiftService();
  final FirestoreCustomerService _customerService = FirestoreCustomerService();
  String _selectedFilter = 'all'; // 'all', 'today', 'tomorrow', 'this_week'

  // State cho tìm kiếm khách hàng
  final TextEditingController _phoneSearchController = TextEditingController();
  // Sử dụng Map<String, dynamic> để tránh lỗi import model nếu chưa khớp
  List<Map<String, dynamic>> _searchedCustomers = [];
  Set<String> _selectedCustomerIds = {};

  // Tính toán màu sắc trạng thái dựa trên thời gian thực
  Color _getStatusColor(String status, Shift shift) {
    final now = DateTime.now();
    if (now.isAfter(shift.startTime) && now.isBefore(shift.endTime)) {
      return Colors.blue; // Đang thực hiện
    } else if (now.isAfter(shift.endTime)) {
      return Colors.blueGrey; // Đã hoàn thành
    }

    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  // Tính toán text trạng thái dựa trên thời gian thực
  String _getStatusText(String status, Shift shift) {
    final now = DateTime.now();
    if (now.isAfter(shift.startTime) && now.isBefore(shift.endTime)) {
      return 'Đang thực hiện';
    } else if (now.isAfter(shift.endTime)) {
      return 'Hoàn thành';
    }

    switch (status) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'pending':
        return 'Đang chờ';
      case 'completed':
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

  // Hàm tìm kiếm khách hàng theo SĐT
  Future<void> _searchCustomerByPhone(String phone) async {
    if (phone.isEmpty) {
      setState(() {
        _searchedCustomers = [];
      });
      return;
    }

    try {
      final data = await _customerService.getCustomers();
      setState(() {
        _searchedCustomers = data.where((c) => c['phoneNumber'].toString().contains(phone)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
    }
  }

  // Hàm hiển thị chọn khách hàng
  void _showCustomerSelectionDialog() {
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
                        _searchCustomerByPhone(value);
                        setState(() {}); // Update UI để hiện danh sách tìm kiếm
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

  // Hàm điều hướng sang màn hình bản đồ
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

  List<Shift> _filterShiftsByTime(List<Shift> shifts) {
    if (_selectedFilter == 'all') return shifts;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return shifts.where((shift) {
      final shiftDate = DateTime(shift.startTime.year, shift.startTime.month, shift.startTime.day);

      switch (_selectedFilter) {
        case 'today':
          return shiftDate.isAtSameMomentAs(today);
        case 'tomorrow':
          return shiftDate.isAtSameMomentAs(tomorrow);
        case 'this_week':
          return shift.startTime.isAfter(today) &&
                 shift.startTime.isBefore(today.add(const Duration(days: 7)));
        default:
          return true;
      }
    }).toList();
  }

  void _showAddShiftDialog() {
    final TextEditingController locationController = TextEditingController();
    DateTime selectedStart = DateTime.now().add(const Duration(days: 1));
    DateTime selectedEnd = DateTime.now().add(const Duration(days: 1, hours: 4));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Đăng ký ca làm mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Địa điểm',
                        hintText: 'Nhập địa chỉ ca làm...',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('dd/MM HH:mm').format(selectedStart)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedStart,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedStart),
                                );
                                if (time != null) {
                                  setStateDialog(() {
                                    selectedStart = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('dd/MM HH:mm').format(selectedEnd)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedEnd,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedEnd),
                                );
                                if (time != null) {
                                  setStateDialog(() {
                                    selectedEnd = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (locationController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập địa điểm')));
                      return;
                    }
                    try {
                      await _shiftService.addShift(
                        startTime: selectedStart,
                        endTime: selectedEnd,
                        location: locationController.text,
                        locationCoord: const LatLng(10.762622, 106.660172),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký ca làm thành công!')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tạo ca: $e')));
                    }
                  },
                  child: const Text('Tạo ca'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ca làm việc'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _showCustomerSelectionDialog,
            tooltip: 'Tìm khách hàng và xem bản đồ',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Tất cả'),
                  const SizedBox(width: 8),
                  _buildFilterChip('today', 'Hôm nay'),
                  const SizedBox(width: 8),
                  _buildFilterChip('tomorrow', 'Ngày mai'),
                  const SizedBox(width: 8),
                  _buildFilterChip('this_week', 'Tuần này'),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _shiftService.getShiftsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Expanded(child: Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}')));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Expanded(child: Center(child: Text('Chưa có ca làm việc nào')));
              }

              final allShifts = snapshot.data!.map((map) => Shift.fromMap(map)).toList();
              final filteredShifts = _filterHiftsByTime(allShifts); // Note: fixed typo from _filterShiftsByTime below

              final upcomingShifts = filteredShifts.where((s) => s.startTime.isAfter(DateTime.now())).toList();
              final completedShifts = filteredShifts.where((s) => s.startTime.isBefore(DateTime.now())).toList();

              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('Ca sắp tới', upcomingShifts.length.toString()),
                          _buildSummaryItem('Hoàn thành', completedShifts.length.toString()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (upcomingShifts.isNotEmpty) ...[
                            const SectionHeader(title: 'Ca sắp tới'),
                            ...upcomingShifts.map((shift) => ShiftCard(
                              shift: shift,
                              statusColor: _getStatusColor(shift.status, shift),
                              statusText: _getStatusText(shift.status, shift),
                            )),
                          ],
                          if (upcomingShifts.isEmpty && completedShifts.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Không có ca nào trong khoảng thời gian này'))),
                          const SizedBox(height: 24),
                          if (completedShifts.isNotEmpty) ...[
                            const SectionHeader(title: 'Lịch sử ca làm'),
                            ...completedShifts.map((shift) => ShiftCard(
                              shift: shift,
                              statusColor: _getStatusColor(shift.status, shift),
                              statusText: _getStatusText(shift.status, shift),
                            )),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddShiftDialog,
        label: const Text('Đăng ký ca mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Fix the typo in the function call above
  List<Shift> _filterHiftsByTime(List<Shift> shifts) => _filterShiftsByTime(shifts);

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() { _selectedFilter = filter; });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final Color statusColor;
  final String statusText;
  const ShiftCard({super.key, required this.shift, required this.statusColor, required this.statusText});
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftDetailScreen(shift: shift))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text(dateFormat.format(shift.startTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(timeFormat.format(shift.startTime), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shift.location, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${timeFormat.format(shift.startTime)} - ${timeFormat.format(shift.endTime)}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
