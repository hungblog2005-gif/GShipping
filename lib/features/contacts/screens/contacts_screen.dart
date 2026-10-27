import 'package:flutter/material.dart';

// Model cho khách hàng
class Customer {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String? note;

  Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.note,
  });
}

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // Dữ liệu mẫu khách hàng
  final List<Customer> _customers = [
    Customer(
      id: '1',
      fullName: 'Nguyễn Văn A',
      phoneNumber: '0901 234 567',
      address: '123 Đường Lê Lợi, Quận 1, TP.HCM',
      note: 'Khách quen, thích giao buổi sáng',
    ),
    Customer(
      id: '2',
      fullName: 'Trần Thị B',
      phoneNumber: '0912 345 678',
      address: '456 Đường Nguyễn Huệ, Quận 1, TP.HCM',
    ),
    Customer(
      id: '3',
      fullName: 'Lê Văn C',
      phoneNumber: '0988 765 432',
      address: '789 Đường Cách Mạng Tháng 8, Quận 3, TP.HCM',
      note: 'Gọi điện trước khi đến 15p',
    ),
    Customer(
      id: '4',
      fullName: 'Phạm Minh D',
      phoneNumber: '0977 111 222',
      address: '101 Đường Võ Văn Kiệt, Quận 5, TP.HCM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khách hàng'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Logic thêm khách hàng mới
            },
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ô tìm kiếm khách hàng
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm tên, SĐT hoặc địa chỉ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Danh sách khách hàng
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return CustomerCard(customer: customer);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerCard extends StatelessWidget {
  final Customer customer;
  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            customer.fullName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          customer.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(customer.phoneNumber, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.address,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (customer.note != null) ...[
              const SizedBox(height: 4),
              Text(
                'Note: ${customer.note}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () {
            // Logic gọi điện thoại
          },
        ),
      ),
    );
  }
}
