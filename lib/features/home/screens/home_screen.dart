import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final Geocoding _geocoding = Geocoding();
  LatLng _currentPin = const LatLng(10.762622, 106.660172);
  bool _isPinned = false;

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng bật dịch vụ định vị GPS')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền vị trí bị từ chối vĩnh viễn')),
        );
      }
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPin = currentLocation;
      _isPinned = true;
    });

    _mapController.move(currentLocation, 15.0);
  }

  void _pinTrackerPosition() {
    final center = _mapController.camera.center;
    setState(() {
      _currentPin = center;
      _isPinned = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã ghim vị trí tại điểm ngắm!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _searchAddress(String address) async {
    if (address.trim().isEmpty) return;

    // Tối ưu cho tiếng Việt: Thêm "Việt Nam" để thu hẹp phạm vi tìm kiếm
    final searchQuery = "${address.trim()}, Việt Nam";

    try {
      final locations = await _geocoding.locationFromAddress(searchQuery);
      if (!mounted) return;

      if (locations.isNotEmpty) {
        final firstLocation = locations.first;
        final targetLatLng = LatLng(
          firstLocation.latitude,
          firstLocation.longitude,
        );

        setState(() {
          _currentPin = targetLatLng;
          _isPinned = true;
        });

        _mapController.move(targetLatLng, 15.0);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã tìm thấy vị trí cho: $address')));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy địa chỉ này tại Việt Nam. Vui lòng thử lại!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Lớp Bản đồ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _currentPin, initialZoom: 13.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gshipping.app',
              ),
              if (_isPinned)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPin,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Thanh tìm kiếm địa chỉ (Đặt sau FlutterMap để nằm trên)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm địa chỉ...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onSubmitted: (value) {
                  _searchAddress(value);
                },
              ),
            ),
          ),

          // 2. Lớp Tracker - Sử dụng const để tối ưu performance
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [TrackerDot(), SizedBox(height: 4), TrackerLabel()],
              ),
            ),
          ),

          // 3. Bộ nút điều khiển
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'btn_location',
                  onPressed: _determinePosition,
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'btn_pin',
                  onPressed: _pinTrackerPosition,
                  mini: true,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: _isPinned ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrackerDot extends StatelessWidget {
  const TrackerDot({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 2),
        color: Colors.blue.withValues(alpha: 0.2),
      ),
    );
  }
}

class TrackerLabel extends StatelessWidget {
  const TrackerLabel({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text(
      "Chọn vị trí",
      style: TextStyle(
        fontSize: 12,
        color: Colors.blue,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.white70,
      ),
    );
  }
}
