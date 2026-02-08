import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/data/fake_data.dart';
import 'package:service_connect/theme/app_theme.dart';

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes'),
      ),
      body: ListView.builder(
        itemCount: FakeData.quotes.length,
        itemBuilder: (context, index) {
          final quote = FakeData.quotes[index];
          return QuoteCard(quote: quote);
        },
      ),
    );
  }
}

class QuoteCard extends StatelessWidget {
  final Quote quote;

  const QuoteCard({required this.quote, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(quote.proImageUrl),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quote.proName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < quote.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: [
                _buildGridItem(Icons.attach_money, '\$${quote.price}'),
                _buildGridItem(Icons.timer, quote.time),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(onPressed: () => context.push('/chat/${quote.id}'), child: const Text('Chat')),
                ElevatedButton(onPressed: () => context.push('/payment'), child: const Text('Accept')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
