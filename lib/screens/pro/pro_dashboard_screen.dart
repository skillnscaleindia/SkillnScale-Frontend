import 'package:flutter/material.dart';

class ProDashboardScreen extends StatelessWidget {
  const ProDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome, Professional!'),
      ),
    );
  }
}
