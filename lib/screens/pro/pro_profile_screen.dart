import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/theme/app_theme.dart';

class ProProfileScreen extends StatelessWidget {
  const ProProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out?'),
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
            },
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
                gradient: const LinearGradient(colors: [AppTheme.primaryColor, Colors.blueAccent]),
              ),
              child: const Column(children: [Text('Earnings', style: TextStyle(color: Colors.white)), Text('\$1,250', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold))]),
            ),
            const SizedBox(height: 24),
            SwitchListTile(title: const Text('Accepting Jobs'), value: true, onChanged: (v) {}),
          ],
        ),
      ),
    );
  }
}