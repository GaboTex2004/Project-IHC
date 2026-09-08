import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection/injection.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatelessWidget {
  final Conversation conversation;
  const ChatPage({super.key, required this.conversation});
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.user.id : -1;
    return BlocProvider(
      create: (_) => sl<ChatBloc>()..add(LoadMessages(conversation.id)),
      child: _ChatView(conversation: conversation, userId: userId),
    );
  }
}

class _ChatView extends StatefulWidget {
  final Conversation conversation;
  final int userId;
  const _ChatView({required this.conversation, required this.userId});
  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  Timer? _timer;
  int _messageCount = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final bloc = context.read<ChatBloc>();
      final state = bloc.state;
      if (state is MessagesLoaded && !state.sending) {
        bloc.add(LoadMessages(widget.conversation.id, silent: true));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessage(widget.conversation.id, text));
    }
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && _scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.conversation.otherUserName),
          Text(
            widget.conversation.reportName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
    body: BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is MessagesLoaded) {
          if (state.messages.length > _messageCount) {
            _messageCount = state.messages.length;
            _controller.clear();
            _scrollDown();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        }
      },
      builder: (context, state) => Column(
        children: [
          Expanded(child: _messages(context, state)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLength: 1000,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state is MessagesLoaded && !state.sending
                        ? _send
                        : null,
                    icon: state is MessagesLoaded && state.sending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _messages(BuildContext context, ChatState state) {
    if (state is ChatLoading || state is ChatInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ChatError) {
      return Center(
        child: TextButton.icon(
          onPressed: () => context.read<ChatBloc>().add(
            LoadMessages(widget.conversation.id),
          ),
          icon: const Icon(Icons.refresh),
          label: Text(state.message),
        ),
      );
    }
    final messages = (state as MessagesLoaded).messages;
    if (messages.isEmpty) {
      return const Center(child: Text('Inicia la conversación.'));
    }
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ChatBloc>().add(LoadMessages(widget.conversation.id)),
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(14),
        itemCount: messages.length,
        itemBuilder: (_, index) {
          final message = messages[index];
          final mine = message.senderId == widget.userId;
          return Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 310),
              decoration: BoxDecoration(
                color: mine ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: mine ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
