import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model cho ca làm việc
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
}

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  // Dữ liệu mẫu
  final List<Shift> _shifts = [
    Shift(
      id: '1',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 12)),
      location: 'Quận 1, TP. Hồ Chí Minh',
      status: 'confirmed',
    ),
    Shift(
      id: '2',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 13)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 17)),
      location: 'Quận 7, TP. Hồ Chí Minh',
      status: 'pending',
    ),
    Shift(
      id: '3',
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      endTime: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      location: 'Thủ Đức, TP. Hồ Chí Minh',
      status: 'completed',
    ),
  ];

  Color _getStatusColor(String status) {
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

  String _getStatusText(String status) {
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

  @override
  Widget build(BuildContext context) {
    // Chia ca làm thành 2 nhóm: Tương lai và Quá khứ
    final upcomingShifts = _shifts.where((s) => s.startTime.isAfter(DateTime.now())).toList();
    final completedShifts = _shifts.where((s) => s.startTime.isBefore(DateTime.now())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ca làm việc'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tóm tắt ca làm
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
                  ...upcomingShifts.map((shift) => ShiftCard(shift: shift, statusColor: _getStatusColor(shift.status), statusText: _getStatusText(shift.status))),
                ],
                const SizedBox(height: 24),
                if (completedShifts.isNotEmpty) ...[
                  const SectionHeader(title: 'Lịch sử ca làm'),
                  ...completedShifts.map((shift) => ShiftCard(shift: shift, statusColor: _getStatusColor(shift.status), statusText: _getStatusText(shift.status))),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // logic đăng ký ca làm
        },
        label: const Text('Đăng ký ca mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ngày tháng (Vùng highlight bên trái)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    dateFormat.format(shift.startTime),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timeFormat.format(shift.startTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin chi tiết
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.location,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${timeFormat.format(shift.startTime)} - ${timeFormat.format(shift.endTime)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Trạng thái (Chip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
