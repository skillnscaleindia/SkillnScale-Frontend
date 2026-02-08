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
  final _codeController = TextEditingController();
  Timer? _timer;
  int _seconds = 0;
  bool _started = false;

  void _start() {
    if (_codeController.text != '4589') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Code'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _seconds++));
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
      appBar: AppBar(title: const Text('Active Job'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (!_started) ...[
              const Text("Ask customer for code (4589)", style: TextStyle(fontSize: 18)),
              TextField(controller: _codeController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, letterSpacing: 5)),
              ElevatedButton(onPressed: _start, child: const Text('Verify & Start')),
            ] else ...[
              Text('${Duration(seconds: _seconds).inMinutes}:${(Duration(seconds: _seconds).inSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
              SlideAction(
                onSubmit: () {
                  _timer?.cancel();
                  context.go('/home');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job Completed!")));
                  return null;
                },
                text: 'Slide to Finish',
              ),
            ],
          ],
        ),
      ),
    );
  }
}