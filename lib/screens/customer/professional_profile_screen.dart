
import 'package:flutter/material.dart';
import 'package:service_connect/data/fake_data.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  final String proId;

  const ProfessionalProfileScreen({super.key, required this.proId});

  @override
  Widget build(BuildContext context) {
    // For now, we'll use fake data. Later, you might fetch this from a backend.
    final professional = FakeData.professionals.firstWhere((pro) => pro.id == proId);

    return Scaffold(
      appBar: AppBar(
        title: Text(professional.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(professional.imageUrl),
                onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                professional.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${professional.yearsOfExperience} years of experience',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              professional.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Feedback',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // This is a placeholder for feedback. You would build a list of feedback widgets here.
            const Text('No feedback available yet.'),
          ],
        ),
      ),
    );
  }
}
