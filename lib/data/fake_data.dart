
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class Service {
  final String name;
  final IconData icon;

  Service({required this.name, required this.icon});
}

class Job {
  final String id;
  final String title;
  final double distance;
  final bool isUrgent;
  final String imageUrl;

  Job({
    required this.id,
    required this.title,
    required this.distance,
    required this.isUrgent,
    required this.imageUrl,
  });
}

class Quote {
  final String id;
  final String proName;
  final double rating;
  final double price;
  final String time;
  final String proImageUrl;

  Quote({
    required this.id,
    required this.proName,
    required this.rating,
    required this.price,
    required this.time,
    required this.proImageUrl,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSystemMessage;

  ChatMessage({required this.text, this.isUser = false, this.isSystemMessage = false});
}

class FakeData {
  static final List<Service> services = [
    Service(name: 'Electrician', icon: LucideIcons.plug),
    Service(name: 'Plumber', icon: LucideIcons.wrench),
    Service(name: 'Salon', icon: LucideIcons.scissors),
  ];

  static final bool hasActiveJob = true;

  static final List<Job> jobs = [
    Job(id: '1', title: 'Leaking Tap', distance: 2.5, isUrgent: true, imageUrl: 'https://picsum.photos/seed/job1/200'),
    Job(id: '2', title: 'AC Repair', distance: 5.0, isUrgent: false, imageUrl: 'https://picsum.photos/seed/job2/200'),
    Job(id: '3', title: 'Switchboard Replacement', distance: 1.2, isUrgent: true, imageUrl: 'https://picsum.photos/seed/job3/200'),
    Job(id: '4', title: 'Full House Painting', distance: 10.0, isUrgent: false, imageUrl: 'https://picsum.photos/seed/job4/200'),
    Job(id: '5', title: 'Kitchen Cleaning', distance: 3.0, isUrgent: false, imageUrl: 'https://picsum.photos/seed/job5/200'),
  ];

  static final List<Quote> quotes = [
    Quote(id: '1', proName: 'Rajesh Kumar', rating: 4.5, price: 50, time: '30 mins', proImageUrl: 'https://picsum.photos/seed/pro1/100'),
    Quote(id: '2', proName: 'Suresh Singh', rating: 4.8, price: 55, time: '45 mins', proImageUrl: 'https://picsum.photos/seed/pro2/100'),
    Quote(id: '3', proName: 'Anjali Sharma', rating: 4.9, price: 60, time: '1 hour', proImageUrl: 'https://picsum.photos/seed/pro3/100'),
  ];

  static final List<ChatMessage> chatMessages = [
    ChatMessage(text: 'Hello! I can fix your leaking tap for \$50.', isUser: false),
    ChatMessage(text: 'Can you do it for \$40?', isUser: true),
    ChatMessage(text: 'Offer Updated: ~~\$50~~ -> \$45', isSystemMessage: true),
    ChatMessage(text: 'Okay, I can do \$45. It is the best I can offer.', isUser: false),
  ];
}
