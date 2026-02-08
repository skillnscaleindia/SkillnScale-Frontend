import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RadarSearchScreen extends StatefulWidget {
  const RadarSearchScreen({super.key});

  @override
  State<RadarSearchScreen> createState() => _RadarSearchScreenState();
}

class _RadarSearchScreenState extends State<RadarSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/quotes');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Searching for Professionals'),
      ),
      body: Center(
        child: CustomPaint(
          painter: RipplePainter(controller: _controller),
          child: const SizedBox(
            width: 200,
            height: 200,
          ),
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
