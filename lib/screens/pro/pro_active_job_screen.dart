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
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Job'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Enter Start Code',
                hintText: '4589',
              ),
              keyboardType: TextInputType.number,
            ),
            Text(
              _formatDuration(Duration(seconds: _seconds)),
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            SlideAction(
              key: _slideKey,
              onSubmit: () {
                context.go('/review');
              },
              text: 'Slide to Finish Job',
            ),
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
