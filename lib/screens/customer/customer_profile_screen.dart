import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 60,
            child: Icon(LucideIcons.user, size: 60),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(LucideIcons.calendarCheck),
            title: const Text('My Bookings'),
            onTap: () => context.push('/history'),
          ),
          const ListTile(
            leading: Icon(LucideIcons.creditCard),
            title: Text('Payment Methods'),
          ),
          const ListTile(
            leading: Icon(LucideIcons.lifeBuoy),
            title: Text('Support / Help'),
          ),
          ListTile(
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            leading: const Icon(LucideIcons.logOut, color: Colors.red),
            onTap: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}
