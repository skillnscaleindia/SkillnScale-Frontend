import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/services/data_service.dart';
import 'package:service_connect/services/chat_service.dart';
import 'package:service_connect/l10n/app_localizations.dart';

class MatchedProfessionalsScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String categoryName;

  const MatchedProfessionalsScreen({
    required this.requestId,
    this.categoryName = 'Service',
    super.key,
  });

  @override
  ConsumerState<MatchedProfessionalsScreen> createState() =>
      _MatchedProfessionalsScreenState();
}

class _MatchedProfessionalsScreenState
    extends ConsumerState<MatchedProfessionalsScreen> {
  List<Map<String, dynamic>> _professionals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final dataService = ref.read(dataServiceProvider);
      final matches = await dataService.getMatchedProfessionals(widget.requestId);
      if (mounted) {
        setState(() {
          _professionals = matches;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _startChat(Map<String, dynamic> pro) async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final room = await chatService.createChatRoom(
        requestId: widget.requestId,
        professionalId: pro['id'] as String,
      );
      if (mounted) {
        context.push('/chat/${room['id']}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchedPros),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.sparkles, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  l10n.aiMatch,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _professionals.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _professionals.length,
                      itemBuilder: (context, index) =>
                          _buildProCard(_professionals[index], index, theme),
                    ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(LucideIcons.searchX, size: 36, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            'No professionals found',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your request or check back later',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProCard(Map<String, dynamic> pro, int index, ThemeData theme) {
    final rating = (pro['rating'] as num?)?.toDouble() ?? 0.0;
    final matchScore = (pro['match_score'] as num?)?.toDouble() ?? 0.0;
    final matchReason = pro['match_reason'] as String? ?? '';
    final name = pro['full_name'] as String? ?? 'Professional';
    final bio = pro['bio'] as String? ?? '';
    final jobsDone = pro['jobs_completed'] as int? ?? 0;
    final reviewsCount = pro['reviews_count'] as int? ?? 0;
    final isBestMatch = index == 0;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBestMatch
              ? AppColors.accent.withOpacity(0.4)
              : theme.colorScheme.outline.withOpacity(0.12),
          width: isBestMatch ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Best Match Badge
          if (isBestMatch)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.crown, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '🏆 ${l10n.bestMatch}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar + Name + Score
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            matchReason,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Match Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(matchScore).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${matchScore.toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _getScoreColor(matchScore),
                            ),
                          ),
                          Text(
                            'match',
                            style: TextStyle(
                              fontSize: 9,
                              color: _getScoreColor(matchScore),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    bio,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Stats Row
                Row(
                  children: [
                    _buildStat(
                      icon: Icons.star_rounded,
                      value: rating > 0 ? rating.toStringAsFixed(1) : 'New',
                      label: rating > 0 ? '($reviewsCount)' : '',
                      color: const Color(0xFFFFB800),
                      theme: theme,
                    ),
                    const SizedBox(width: 20),
                    _buildStat(
                      icon: LucideIcons.briefcase,
                      value: '$jobsDone',
                      label: l10n.jobsDone,
                      color: AppColors.accent,
                      theme: theme,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Chat Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _startChat(pro),
                    icon: const Icon(LucideIcons.messageCircle, size: 16),
                    label: Text(l10n.chatNow),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 3),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
