import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  Future<void> _launch(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: const Text("Are you sure? You might be charged a cancellation fee."),
        actions: [
          TextButton(child: const Text("No, Keep it"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Cancelled")));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Your Professional')),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(initialCenter: LatLng(12.9716, 77.5946), initialZoom: 14.0),
            children: [
              TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      leading: CircleAvatar(child: Icon(LucideIcons.user)),
                      title: Text('Rajesh Kumar'),
                      subtitle: Text('KA 01 AB 1234 • 4.8 ★'),
                      trailing: Icon(LucideIcons.bike),
                    ),
                    const Divider(),
                    const Text('Arriving in 4 mins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Start Code: 4589', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(icon: const Icon(LucideIcons.phone, color: Colors.green), onPressed: () => _launch(Uri(scheme: 'tel', path: '1234567890'))),
                        IconButton(icon: const Icon(LucideIcons.messageSquare, color: Colors.blue), onPressed: () => _launch(Uri(scheme: 'sms', path: '1234567890'))),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showCancelDialog(context),
                      child: const Text("Cancel Booking", style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}