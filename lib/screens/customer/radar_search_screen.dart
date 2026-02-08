import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RadarSearchScreen extends StatefulWidget {
  const RadarSearchScreen({super.key});

  @override
  State<RadarSearchScreen> createState() => _RadarSearchScreenState();
}

class _RadarSearchScreenState extends State<RadarSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/quotes');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel(); // Cancel timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Searching for Professionals'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer?.cancel();
            context.go('/home');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              painter: RipplePainter(controller: _controller),
              child: const SizedBox(
                width: 200,
                height: 200,
                child: Icon(Icons.home, size: 50, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () {
                _timer?.cancel();
                context.go('/home');
              },
              child: const Text('Cancel Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Animation<double> controller;

  RipplePainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..color = Colors.blue.withOpacity(1 - controller.value);

    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 2) * (controller.value + i) / 3;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}