import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Feed'),
        actions: [
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: FakeData.jobs.length,
        itemBuilder: (context, index) {
          final job = FakeData.jobs[index];
          return JobCard(job: job);
        },
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
                    const Chip(
                      label: Text('URGENT'),
                      backgroundColor: Colors.red,
                      labelStyle: TextStyle(color: Colors.white),
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
