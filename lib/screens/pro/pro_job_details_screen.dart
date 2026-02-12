import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/data/fake_data.dart';
import 'package:service_connect/theme/app_colors.dart';

class ProJobDetailsScreen extends StatefulWidget {
  final String jobId;
  const ProJobDetailsScreen({required this.jobId, super.key});

  @override
  State<ProJobDetailsScreen> createState() => _ProJobDetailsScreenState();
}

class _ProJobDetailsScreenState extends State<ProJobDetailsScreen> {
  final _priceController = TextEditingController();
  double _duration = 1.0;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = FakeData.jobs.firstWhere((job) => job.id == widget.jobId);
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.map, size: 36, color: AppColors.lightSubtitle),
                      const SizedBox(height: 8),
                      Text('Map Preview', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                // Distance badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.mapPin, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${job.distance} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(job.title, style: theme.textTheme.headlineSmall),
                            const Spacer(),
                            if (job.isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (job.location.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(LucideIcons.mapPin, size: 14, color: AppColors.lightSubtitle),
                              const SizedBox(width: 6),
                              Text(job.location, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Price Input
                  Text('Your Price', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      hintText: 'Enter your quote',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Duration Picker
                  Text('Estimated Duration', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
                    ),
                    child: SizedBox(
                      height: 120,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (i) =>
                            setState(() => _duration = (i + 2) / 2.0),
                        children: List.generate(
                          10,
                          (i) => Center(
                            child: Text(
                              '${(i + 2) / 2.0} hours',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Send Proposal
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_priceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a price'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quote Sent! ✓'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop();
                },
                child: const Text('Send Proposal', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}