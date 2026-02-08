import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class Service {
  final String name;
  final IconData icon;

  Service({required this.name, required this.icon});
}

class FakeData {
  static final List<Service> services = [
    Service(name: 'Electrician', icon: LucideIcons.plug),
    Service(name: 'Plumber', icon: LucideIcons.wrench),
    Service(name: 'Salon', icon: LucideIcons.scissors),
  ];

  static final bool hasActiveJob = true;
}
