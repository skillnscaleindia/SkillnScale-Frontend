import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear state here if using Riverpod
              context.go('/');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}