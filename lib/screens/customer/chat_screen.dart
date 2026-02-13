import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:service_connect/theme/app_colors.dart';
import 'package:service_connect/services/chat_service.dart';
import 'package:service_connect/services/auth_service.dart';
import 'package:service_connect/services/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_connect/l10n/app_localizations.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatScreen({required this.roomId, super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _priceController = TextEditingController();
  
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _currentlyPlayingUrl;
  PlayerState _playerState = PlayerState.stopped;

  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _roomInfo;
  bool _loading = true;
  Timer? _pollTimer;
  String? _currentUserId;
  bool _showPriceInput = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(authServiceProvider).userId;
    _loadMessages();
    // Poll for new messages every 3 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _loadMessages());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _priceController.dispose();
    _pollTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final messages = await chatService.getMessages(widget.roomId);
      if (mounted) {
        final prevLen = _messages.length;
        setState(() {
          _messages = messages;
          _loading = false;
        });
        // Auto-scroll on new messages
        if (messages.length > prevLen) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.sendMessage(roomId: widget.roomId, content: text);
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  Future<void> _proposePrice() async {
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) return;
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) return;
    _priceController.clear();
    setState(() => _showPriceInput = false);

    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.proposePrice(roomId: widget.roomId, price: price);
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to propose: $e')),
        );
      }
    }
  }

  Future<void> _acceptPrice() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final booking = await chatService.acceptPrice(widget.roomId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Booking confirmed!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.push('/payment', extra: booking);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: $e')),
        );
      }
    }
  }

  // Check if last message is a price proposal from the OTHER user
  bool get _canAcceptPrice {
    if (_messages.isEmpty) return false;
    final last = _messages.last;
    return last['message_type'] == 'price_proposal' &&
        last['sender_id'] != _currentUserId;
  }

  double? get _lastProposedPrice {
    if (!_canAcceptPrice) return null;
    return (_messages.last['proposed_price'] as num?)?.toDouble();
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      _uploadAndSendAudio(path);
    }
  }

  Future<void> _uploadAndSendAudio(String path) async {
    try {
      final file = XFile(path);
      final url = await ref.read(uploadServiceProvider).uploadFile(file);
      await ref.read(chatServiceProvider).sendMessage(
        roomId: widget.roomId, 
        content: 'Voice Message',
        messageType: 'voice',
        mediaUrl: url,
        duration: 0, // Calculate if possible
      );
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send voice: $e')));
      }
    }
  }

  Future<void> _playAudio(String url) async {
    if (_currentlyPlayingUrl == url && _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource('http://localhost:8000$url'));
      setState(() => _currentlyPlayingUrl = url);
    }
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.user, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.priceNegotiation,
                  style: theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.messageSquare,
                                  size: 48, color: AppColors.lightSubtitle),
                              const SizedBox(height: 12),
                              Text(
                                'Start the conversation!',
                                style: theme.textTheme.bodyMedium!
                                    .copyWith(color: AppColors.lightSubtitle),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            if (msg['message_type'] == 'system') {
                              return _buildSystemMessage(
                                  msg['content'] ?? '', theme);
                            }
                            if (msg['message_type'] == 'price_proposal') {
                              return _buildPriceProposal(msg, theme);
                            }
                            if (msg['message_type'] == 'voice') {
                              return _buildVoiceMessage(msg, theme);
                            }
                            return _buildChatBubble(msg, theme);
                          },
                        ),
                ),

                // Accept Price bar
                if (_canAcceptPrice)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color:
                              theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _acceptPrice,
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: Text(
                          '${l10n.acceptPrice} ₹${_lastProposedPrice?.toStringAsFixed(0) ?? ''}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Price Input
                if (_showPriceInput)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.05),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.accent.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('₹',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              border: InputBorder.none,
                              hintStyle: theme.textTheme.bodyMedium!
                                  .copyWith(color: AppColors.lightSubtitle),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _showPriceInput = false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _proposePrice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                          ),
                          child: Text(l10n.proposePrice),
                        ),
                      ],
                    ),
                  ),

                // Message Input
                Container(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 8,
                    top: 8,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.indianRupee, size: 20, color: AppColors.accent),
                        onPressed: () => setState(() => _showPriceInput = !_showPriceInput),
                      ),
                      Expanded(
                        child: _isRecording 
                          ? Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text('Recording... Release to send', style: TextStyle(color: Colors.red)),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: l10n.typeMessage,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  hintStyle: theme.textTheme.bodyMedium!.copyWith(color: AppColors.lightSubtitle),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onLongPress: _startRecording,
                        onLongPressEnd: (_) => _stopRecording(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: _isRecording 
                                ? const LinearGradient(colors: [Colors.red, Colors.redAccent]) 
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            _isRecording ? LucideIcons.mic : (_controller.text.isEmpty ? LucideIcons.mic : LucideIcons.send),
                            size: 18, color: Colors.white,
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

  Widget _buildChatBubble(Map<String, dynamic> msg, ThemeData theme) {
    final isMe = msg['sender_id'] == _currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.accent : theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg['content'] ?? '',
          style: theme.textTheme.bodyMedium!.copyWith(
            color: isMe ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceProposal(Map<String, dynamic> msg, ThemeData theme) {
    final isMe = msg['sender_id'] == _currentUserId;
    final price = (msg['proposed_price'] as num?)?.toDouble() ?? 0;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.08),
                    AppColors.success.withOpacity(0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(18),
          border: isMe
              ? null
              : Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.indianRupee,
                  size: 14,
                  color: isMe ? Colors.white70 : AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Price Proposal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white70 : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '₹${price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessage(String text, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodySmall!.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceMessage(Map<String, dynamic> msg, ThemeData theme) {
    final isMe = msg['sender_id'] == _currentUserId;
    final url = msg['media_url'] as String?;
    final isPlaying = _currentlyPlayingUrl == url && _playerState == PlayerState.playing;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.accent : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: isMe ? null : Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: url != null ? () => _playAudio(url) : null,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isMe ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Voice Message',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
