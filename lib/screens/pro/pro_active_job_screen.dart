import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slide_to_act/slide_to_act.dart';

class ProActiveJobScreen extends StatefulWidget {
  const ProActiveJobScreen({super.key});

  @override
  State<ProActiveJobScreen> createState() => _ProActiveJobScreenState();
}

class _ProActiveJobScreenState extends State<ProActiveJobScreen> {
  final GlobalKey<SlideActionState> _slideKey = GlobalKey();
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _seconds = 0;
  bool _jobStarted = false;

  void _startJob() {
    if (_codeController.text != '4589') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Start Code'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _jobStarted = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Job'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (!_jobStarted) ...[
              const Text("Ask customer for the Start Code", style: TextStyle(fontSize: 18)),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Start Code',
                  hintText: 'e.g. 4589',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 5),
              ),
              ElevatedButton(
                onPressed: _startJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Verify & Start', style: TextStyle(fontSize: 18)),
              ),
            ] else ...[
              Column(
                children: [
                  const Text("Job in Progress", style: TextStyle(fontSize: 20, color: Colors.green)),
                  const SizedBox(height: 20),
                  Text(
                    _formatDuration(Duration(seconds: _seconds)),
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SlideAction(
                key: _slideKey,
                onSubmit: () {
                  _timer?.cancel();
                  context.go('/home'); // Or to a summary screen
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job Completed!")));
                  return null;
                },
                text: 'Slide to Finish Job',
                innerColor: Colors.red,
                outerColor: Colors.red.shade100,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}