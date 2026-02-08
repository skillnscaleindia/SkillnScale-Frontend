import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/theme/app_theme.dart';

class ProProfileScreen extends StatefulWidget {
  const ProProfileScreen({super.key});

  @override
  State<ProProfileScreen> createState() => _ProProfileScreenState();
}

class _ProProfileScreenState extends State<ProProfileScreen> {
  bool _isAcceptingJobs = true;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                children: [
                  Text('Total Earnings', style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('\$1,250', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Jobs Done', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('24', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('Rating', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('4.8', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Accepting New Jobs'),
              value: _isAcceptingJobs,
              onChanged: (value) {
                setState(() {
                  _isAcceptingJobs = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}