import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/data/fake_data.dart';
import 'package:service_connect/theme/app_theme.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            CircleAvatar(child: Icon(LucideIcons.user)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Location', style: TextStyle(fontSize: 12)),
                Text('Bengaluru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Services', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: FakeData.services.map((service) {
                return InkWell(
                  onTap: () => context.push('/request'),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.lightGreyColor,
                        child: Icon(service.icon, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(service.name),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (FakeData.hasActiveJob)
              InkWell( // WRAPPED IN INKWELL
                onTap: () => context.push('/tracking'), // ADDED NAVIGATION
                child: Card(
                  color: AppTheme.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.userCheck, color: Colors.white),
                        const SizedBox(width: 16),
                        const Text(
                          'Pro Arriving in 5 mins',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
