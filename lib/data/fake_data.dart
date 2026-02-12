
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
  final String category;
  final String location;

  Job({
    required this.id,
    required this.title,
    required this.distance,
    required this.isUrgent,
    required this.imageUrl,
    this.category = '',
    this.location = '',
  });
}

class Quote {
  final String id;
  final String proId;
  final String proName;
  final double rating;
  final double price;
  final String time;
  final String proImageUrl;
  final int jobsDone;
  final bool isVerified;

  Quote({
    required this.id,
    required this.proId,
    required this.proName,
    required this.rating,
    required this.price,
    required this.time,
    required this.proImageUrl,
    this.jobsDone = 0,
    this.isVerified = false,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSystemMessage;

  ChatMessage({required this.text, this.isUser = false, this.isSystemMessage = false});
}

class Professional {
  final String id;
  final String name;
  final String imageUrl;
  final int yearsOfExperience;
  final String description;

  Professional({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.yearsOfExperience,
    required this.description,
  });
}

class PromoBanner {
  final String title;
  final String subtitle;
  final String discount;
  final List<Color> gradientColors;
  final IconData icon;

  PromoBanner({
    required this.title,
    required this.subtitle,
    required this.discount,
    required this.gradientColors,
    required this.icon,
  });
}

class FakeData {
  static final List<Professional> professionals = [
    Professional(
      id: 'pro1',
      name: 'Rajesh Kumar',
      imageUrl: 'https://picsum.photos/seed/pro1/200',
      yearsOfExperience: 8,
      description: 'Expert plumber with years of experience in residential and commercial plumbing.',
    ),
    Professional(
      id: 'pro2',
      name: 'Suresh Singh',
      imageUrl: 'https://picsum.photos/seed/pro2/200',
      yearsOfExperience: 12,
      description: 'Certified electrician specializing in home wiring and appliance installations.',
    ),
    Professional(
      id: 'pro3',
      name: 'Anjali Sharma',
      imageUrl: 'https://picsum.photos/seed/pro3/200',
      yearsOfExperience: 5,
      description: 'Skilled carpenter offering custom furniture and home renovation services.',
    ),
  ];

  static final List<Service> services = [
    Service(name: 'Electrician', icon: LucideIcons.plug),
    Service(name: 'Plumber', icon: LucideIcons.wrench),
    Service(name: 'Salon', icon: LucideIcons.scissors),
    Service(name: 'AC Repair', icon: LucideIcons.thermometer),
    Service(name: 'Carpenter', icon: LucideIcons.hammer),
    Service(name: 'Painting', icon: LucideIcons.paintbrush),
    Service(name: 'Cleaning', icon: LucideIcons.sparkles),
    Service(name: 'Pest Control', icon: LucideIcons.bug),
  ];

  static final bool hasActiveJob = true;

  static final List<Job> jobs = [
    Job(id: '1', title: 'Leaking Tap', distance: 2.5, isUrgent: true, imageUrl: 'https://picsum.photos/seed/job1/200', category: 'Plumbing', location: 'Koramangala, Bengaluru'),
    Job(id: '2', title: 'AC Repair', distance: 5.0, isUrgent: false, imageUrl: 'https://picsum.photos/seed/job2/200', category: 'AC Repair', location: 'HSR Layout, Bengaluru'),
    Job(id: '3', title: 'Switchboard Replacement', distance: 1.2, isUrgent: true, imageUrl: 'https://picsum.photos/seed/job3/200', category: 'Electrical', location: 'Indiranagar, Bengaluru'),
    Job(id: '4', title: 'Full House Painting', distance: 10.0, isUrgent: false, imageUrl: 'https://picsum.photos/seed/job4/200', category: 'Painting', location: 'Whitefield, Bengaluru'),
    Job(id: '5', title: 'Kitchen Cleaning', distance: 3.0, isUrgent: false, imageUrl: 'https://picsum.photos/seed/job5/200', category: 'Cleaning', location: 'JP Nagar, Bengaluru'),
  ];

  static final List<Quote> quotes = [
    Quote(id: '1', proId: 'pro1', proName: 'Rajesh Kumar', rating: 4.5, price: 50, time: '30 mins', proImageUrl: 'https://picsum.photos/seed/pro1/100', jobsDone: 234, isVerified: true),
    Quote(id: '2', proId: 'pro2', proName: 'Suresh Singh', rating: 4.8, price: 55, time: '45 mins', proImageUrl: 'https://picsum.photos/seed/pro2/100', jobsDone: 567, isVerified: true),
    Quote(id: '3', proId: 'pro3', proName: 'Anjali Sharma', rating: 4.9, price: 60, time: '1 hour', proImageUrl: 'https://picsum.photos/seed/pro3/100', jobsDone: 89, isVerified: false),
  ];

  static final List<ChatMessage> chatMessages = [
    ChatMessage(text: 'Hello! I can fix your leaking tap for \$50.', isUser: false),
    ChatMessage(text: 'Can you do it for \$40?', isUser: true),
    ChatMessage(text: 'Offer Updated: ~~\$50~~ -> \$45', isSystemMessage: true),
    ChatMessage(text: 'Okay, I can do \$45. It is the best I can offer.', isUser: false),
  ];

  static final List<PromoBanner> promoBanners = [
    PromoBanner(
      title: "Valentine's Week Special!",
      subtitle: 'on Salon & Beauty Services',
      discount: '25% OFF',
      gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
      icon: LucideIcons.heart,
    ),
    PromoBanner(
      title: 'Summer AC Service',
      subtitle: 'Deep cleaning & gas refill',
      discount: '₹200 OFF',
      gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      icon: LucideIcons.snowflake,
    ),
  ];
}
