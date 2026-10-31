import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  bool _isUpdatingImages = false;
  final ImagePicker _imagePicker = ImagePicker();
  late List<String> _imageUrls;

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
    _imageUrls = List<String>.from(widget.customer.imageUrls ?? []);
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

  Future<String> _uploadImage(XFile image) async {
    const cloudName = 'dbbliokko';
    const uploadPreset = 'gshipping_preset';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    )
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Không thể tải ảnh lên Cloudinary: $responseBody');
    }

    final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
    final secureUrl = responseData['secure_url'];
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw Exception('Cloudinary không trả về đường dẫn ảnh hợp lệ.');
    }
    return secureUrl;
  }

  Future<void> _addImages() async {
    final selectedImages = await _imagePicker.pickMultiImage();
    if (selectedImages.isEmpty || !mounted) return;

    setState(() => _isUpdatingImages = true);
    try {
      final uploadedUrls = <String>[];
      for (final image in selectedImages) {
        uploadedUrls.add(await _uploadImage(image));
      }

      final updatedUrls = [..._imageUrls, ...uploadedUrls];
      await _customerService.updateCustomer(
        widget.customer.id,
        {'imageUrls': updatedUrls},
      );
      if (!mounted) return;
      setState(() => _imageUrls = updatedUrls);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm ảnh khách hàng')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thêm ảnh: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingImages = false);
    }
  }

  Future<void> _replaceImage(int index) async {
    final selectedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage == null || !mounted) return;

    setState(() => _isUpdatingImages = true);
    try {
      final replacementUrl = await _uploadImage(selectedImage);
      final updatedUrls = List<String>.from(_imageUrls)..[index] = replacementUrl;
      await _customerService.updateCustomer(
        widget.customer.id,
        {'imageUrls': updatedUrls},
      );
      if (!mounted) return;
      setState(() => _imageUrls = updatedUrls);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh khách hàng')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật ảnh: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingImages = false);
    }
  }

  Future<void> _deleteImage(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ảnh'),
        content: const Text('Bạn có chắc chắn muốn xóa ảnh này khỏi hồ sơ khách hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Color(0xFFB91C1C))),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    setState(() => _isUpdatingImages = true);
    try {
      final updatedUrls = List<String>.from(_imageUrls)..removeAt(index);
      await _customerService.updateCustomer(
        widget.customer.id,
        {'imageUrls': updatedUrls},
      );
      if (!mounted) return;
      setState(() => _imageUrls = updatedUrls);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa ảnh khỏi hồ sơ khách hàng')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xóa ảnh: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingImages = false);
    }
  }

  void _viewOnMap() {
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Chi tiết khách hàng',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: const Color(0xFF2563EB)),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  _buildImageGallery(),
                  const SizedBox(height: 16),
                  Text(
                    widget.customer.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoField('Họ và Tên', _nameController),
            const SizedBox(height: 20),
            _buildInfoField('Số điện thoại', _phoneController),
            const SizedBox(height: 20),
            _buildInfoField('Địa chỉ', _addressController),
            const SizedBox(height: 20),
            _buildInfoField('Ghi chú', _noteController),
            const SizedBox(height: 40),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        if (_imageUrls.isEmpty)
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF2563EB),
            child: Text(
              widget.customer.fullName.isNotEmpty ? widget.customer.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrls[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.broken_image, color: Color(0xFFCBD5E1)),
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Row(
                              children: [
                                _buildImageAction(
                                  icon: Icons.edit,
                                  tooltip: 'Thay ảnh',
                                  onPressed: _isUpdatingImages ? null : () => _replaceImage(index),
                                ),
                                const SizedBox(width: 4),
                                _buildImageAction(
                                  icon: Icons.delete,
                                  tooltip: 'Xóa ảnh',
                                  onPressed: _isUpdatingImages ? null : () => _deleteImage(index),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (_isEditing)
          TextButton.icon(
            onPressed: _isUpdatingImages ? null : _addImages,
            icon: _isUpdatingImages
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_isUpdatingImages ? 'Đang cập nhật ảnh...' : 'Thêm ảnh'),
          ),
      ],
    );
  }

  Widget _buildImageAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _isEditing
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
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
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
      ],
    );
  }
}
