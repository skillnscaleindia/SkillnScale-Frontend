import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_connect/data/fake_data.dart';
import 'package:service_connect/theme/app_theme.dart';

class ProJobDetailsScreen extends StatefulWidget {
  final String jobId;

  const ProJobDetailsScreen({required this.jobId, super.key});

  @override
  State<ProJobDetailsScreen> createState() => _ProJobDetailsScreenState();
}

class _ProJobDetailsScreenState extends State<ProJobDetailsScreen> {
  double _duration = 1.0;

  @override
  Widget build(BuildContext context) {
    final job = FakeData.jobs.firstWhere((job) => job.id == widget.jobId);

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            color: AppTheme.lightGreyColor,
            child: const Center(child: Text('Map Snippet')), // Placeholder for map
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter your price',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Start Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Basic date/time picker for now
                  ElevatedButton(
                    onPressed: () => _selectDateTime(context),
                    child: const Text('Select Start Time'),
                  ),
                  const SizedBox(height: 24),
                  const Text('Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 150,
                    child: CupertinoPicker(
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _duration = (index + 2) / 2.0;
                        });
                      },
                      children: List.generate(5, (index) {
                        final duration = (index + 2) / 2.0;
                        return Center(child: Text('$duration hours'));
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quote Sent')),
                  );
                  context.pop();
                },
                child: const Text('Send Proposal'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        // Handle date and time selection
      }
    }
  }
}
