import 'package:flutter/material.dart';
import 'package:service_connect/theme/app_theme.dart';

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
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: [Tab(text: 'Active'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(BookingStatus.active),
            _buildList(BookingStatus.completed),
            _buildList(BookingStatus.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BookingStatus status) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 3,
      itemBuilder: (context, index) => HistoryCard(status: status),
    );
  }
}

enum BookingStatus { active, completed, cancelled }

class HistoryCard extends StatelessWidget {
  final BookingStatus status;
  const HistoryCard({required this.status, super.key});

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Job Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Service: AC Repair", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Date: 24th July, 2024"),
            const Text("Total: \$55.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        title: const Text('AC Repair', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('24th July, 2024'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('\$55', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildStatusChip(status),
          ],
        ),
        onTap: () => _showDetails(context),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color = status == BookingStatus.active ? Colors.blue : (status == BookingStatus.completed ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.name.toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}