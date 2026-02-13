import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/services/data_service.dart';
import 'package:service_connect/theme/app_colors.dart';

class TrackProfessionalScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const TrackProfessionalScreen({required this.bookingId, super.key});

  @override
  ConsumerState<TrackProfessionalScreen> createState() => _TrackProfessionalScreenState();
}

class _TrackProfessionalScreenState extends ConsumerState<TrackProfessionalScreen> {
  final MapController _mapController = MapController();
  LatLng? _proLocation;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchLocation());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    final data = await ref.read(dataServiceProvider).getBookingLocation(widget.bookingId);
    if (data['latitude'] != null && data['longitude'] != null) {
      if (mounted) {
        setState(() {
          _proLocation = LatLng(data['latitude'], data['longitude']);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Professional')),
      body: _proLocation == null
          ? Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Location not available yet'),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _proLocation!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.serviceconnect.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _proLocation!,
                      width: 60,
                      height: 60,
                      child: const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 40),
                    ),
                  ],
                ),
              ],
            ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_proLocation != null) {
            _mapController.move(_proLocation!, 15);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
