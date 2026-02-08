import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/theme/app_theme.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  bool _isImmediate = true;
  final TextEditingController _descController = TextEditingController();

  Future<void> _showDiscardDialog() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Request?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_descController.text.isNotEmpty) {
          _showDiscardDialog();
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Request'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_descController.text.isNotEmpty) {
                _showDiscardDialog();
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe your issue...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Add Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(3, (index) {
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreyColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.camera, color: Colors.grey),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Immediate'),
                          selected: _isImmediate,
                          onSelected: (selected) => setState(() => _isImmediate = selected),
                        ),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Text('Schedule'),
                          selected: !_isImmediate,
                          onSelected: (selected) => setState(() => _isImmediate = !selected),
                        ),
                      ],
                    ),
                    if (!_isImmediate) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            final day = DateTime.now().add(Duration(days: index));
                            return Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGreyColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1]),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request Posted!'), backgroundColor: Colors.green),
                    );
                    context.push('/search');
                  },
                  child: const Text('Post Request'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
