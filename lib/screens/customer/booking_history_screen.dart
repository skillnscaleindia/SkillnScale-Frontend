import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(BookingStatus.active),
            _buildBookingList(BookingStatus.completed),
            _buildBookingList(BookingStatus.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BookingStatus status) {
    return ListView.builder(
      itemCount: 5, // Replace with actual data
      itemBuilder: (context, index) {
        return HistoryCard(status: status);
      },
    );
  }
}

enum BookingStatus { active, completed, cancelled }

class HistoryCard extends StatelessWidget {
  final BookingStatus status;

  const HistoryCard({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: const Text('AC Repair'), // Replace with actual data
        subtitle: const Text('24th July, 2024'), // Replace with actual data
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$55', style: const TextStyle(fontWeight: FontWeight.bold)), // Replace with actual data
            Chip(
              label: Text(status.name.toUpperCase()),
              backgroundColor: _getStatusColor(status),
              labelStyle: const TextStyle(color: Colors.white),
            )
          ],
        ),
        onTap: () { // Show JobDetails bottom sheet
        },
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.active:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}
