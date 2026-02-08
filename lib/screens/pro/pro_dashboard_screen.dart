import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/data/fake_data.dart';

class ProDashboardScreen extends StatefulWidget {
  const ProDashboardScreen({super.key});

  @override
  State<ProDashboardScreen> createState() => _ProDashboardScreenState();
}

class _ProDashboardScreenState extends State<ProDashboardScreen> {
  bool _isOnline = false;
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Press back again to exit')));
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Job Feed'),
          automaticallyImplyLeading: false,
          actions: [
            Switch(
              value: _isOnline,
              onChanged: (val) => setState(() => _isOnline = val),
            ),
          ],
        ),
        body: FakeData.jobs.isEmpty
            ? const Center(child: Text('No jobs available right now'))
            : ListView.builder(
                itemCount: FakeData.jobs.length,
                itemBuilder: (context, index) {
                  final job = FakeData.jobs[index];
                  return ListTile(
                    leading: Image.network(job.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(job.title),
                    subtitle: Text('${job.distance} km away'),
                    trailing: job.isUrgent ? const Chip(label: Text('URGENT', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red) : null,
                    onTap: () => context.push('/pro/job-details/${job.id}'),
                  );
                },
              ),
      ),
    );
  }
}