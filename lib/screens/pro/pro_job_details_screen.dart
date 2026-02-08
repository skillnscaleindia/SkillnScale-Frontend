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
  final _priceController = TextEditingController();
  double _duration = 1.0;

  @override
  Widget build(BuildContext context) {
    final job = FakeData.jobs.firstWhere((job) => job.id == widget.jobId);
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Column(
        children: [
          Container(height: 200, color: AppTheme.lightGreyColor, child: const Center(child: Text('Map Snippet'))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '\$ ')),
                  const SizedBox(height: 24),
                  const Text('Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 120,
                    child: CupertinoPicker(
                      itemExtent: 40,
                      onSelectedItemChanged: (i) => setState(() => _duration = (i + 2) / 2.0),
                      children: List.generate(10, (i) => Center(child: Text('${(i + 2) / 2.0} hours'))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_priceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a price'), backgroundColor: Colors.red));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote Sent!'), backgroundColor: Colors.green));
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
}