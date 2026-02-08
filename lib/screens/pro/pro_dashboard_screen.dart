import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/data/fake_data.dart';
import 'package:service_connect/theme/app_theme.dart';

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
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Press back again to exit')),
          );
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
              onChanged: (value) {
                setState(() => _isOnline = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_isOnline ? 'You are Online' : 'You are Offline')),
                );
              },
            ),
          ],
        ),
        body: FakeData.jobs.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_off_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No jobs available right now', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: FakeData.jobs.length,
                itemBuilder: (context, index) {
                  final job = FakeData.jobs[index];
                  return JobCard(job: job);
                },
              ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({required this.job, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/pro/job-details/${job.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                job.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.error)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${job.distance} km away'),
                  if (job.isUrgent)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Chip(
                        label: Text('URGENT', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.red,
                        labelStyle: TextStyle(color: Colors.white),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}