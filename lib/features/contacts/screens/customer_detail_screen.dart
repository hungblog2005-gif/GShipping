import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/firestore_customer_service.dart';
import '../../shifts/screens/customer_map_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final FirestoreCustomerService _customerService = FirestoreCustomerService();
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.fullName);
    _phoneController = TextEditingController(text: widget.customer.phoneNumber);
    _addressController = TextEditingController(text: widget.customer.address);
    _noteController = TextEditingController(text: widget.customer.note);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateCustomer() async {
    try {
      await _customerService.updateCustomer(
        widget.customer.id,
        {
          'fullName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
          'note': _noteController.text,
        },
      );
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin khách hàng thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật: $e')),
      );
    }
  }

  void _viewOnMap() {
    // Vì Customer model hiện tại không lưu tọa độ trực tiếp (chỉ có trong Firestore),
    // ta cần lấy lại dữ liệu từ service để có latitude/longitude.
    // Để đơn giản và nhanh, ta truyền khách hàng này vào CustomerMapScreen.
    // Tuy nhiên, CustomerMapScreen mong đợi List<Map<String, dynamic>>.

    // Lấy dữ liệu từ Firestore để có tọa độ
    _customerService.getCustomers().then((allCustomers) {
      final customerData = allCustomers.firstWhere((c) => c['id'] == widget.customer.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerMapScreen(customers: [customerData]),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết khách hàng'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  widget.customer.fullName.isNotEmpty ? widget.customer.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoField('Họ và Tên', _nameController),
            const SizedBox(height: 16),
            _buildInfoField('Số điện thoại', _phoneController),
            const SizedBox(height: 16),
            _buildInfoField('Địa chỉ', _addressController),
            const SizedBox(height: 16),
            _buildInfoField('Ghi chú', _noteController),
            const SizedBox(height: 32),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateCustomer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu thay đổi'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _viewOnMap,
                  icon: const Icon(Icons.map),
                  label: const Text('Xem địa chỉ trên bản đồ'),
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

  Widget _buildInfoField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _isEditing
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  controller.text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
      ],
    );
  }
}
