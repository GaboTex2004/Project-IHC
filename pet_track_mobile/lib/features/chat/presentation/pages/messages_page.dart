import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/pet_track_bottom_navigation.dart';
import '../../../../injection/injection.dart';
import '../../../../theme/app_colors.dart';
import '../../../lost_pets/presentation/pages/create_report_page.dart';
import '../../../lost_pets/presentation/widgets/pet_track_header.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ChatBloc>()..add(const LoadConversations()),
    child: const _MessagesView(),
  );
}

class _MessagesView extends StatelessWidget {
  const _MessagesView();
  void _select(BuildContext context, PetTrackDestination destination) {
    switch (destination) {
      case PetTrackDestination.profile:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      case PetTrackDestination.createReport:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateReportPage()));
      case PetTrackDestination.home:
        Navigator.of(context).popUntil((route) => route.isFirst);
      case PetTrackDestination.messages:
        return;
      case PetTrackDestination.settings:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta función estará disponible próximamente.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: const PetTrackHeader(title: 'Mensajes'),
    bottomNavigationBar: PetTrackBottomNavigation(
      selectedDestination: PetTrackDestination.messages,
      onDestinationSelected: (value) => _select(context, value),
    ),
    body: BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading || state is ChatInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ChatError) {
          return _Status(
            message: state.message,
            retry: () =>
                context.read<ChatBloc>().add(const LoadConversations()),
          );
        }
        final conversations = (state as ConversationsLoaded).conversations;
        if (conversations.isEmpty) {
          return _Status(
            message: 'Aún no tienes conversaciones.',
            retry: () =>
                context.read<ChatBloc>().add(const LoadConversations()),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              context.read<ChatBloc>().add(const LoadConversations()),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) =>
                _ConversationTile(conversation: conversations[index]),
          ),
        );
      },
    ),
  );
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.surfaceMuted,
        backgroundImage: conversation.reportPhoto.isNotEmpty
            ? NetworkImage(conversation.reportPhoto)
            : null,
        child: conversation.reportPhoto.isEmpty ? const Icon(Icons.pets) : null,
      ),
      title: Text(
        conversation.reportName,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${conversation.otherUserName}\n${conversation.lastMessage ?? 'Sin mensajes todavía'}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _time(conversation.updatedAt),
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatPage(conversation: conversation)),
      ),
    ),
  );
  String _time(DateTime value) =>
      '${value.toLocal().hour.toString().padLeft(2, '0')}:${value.toLocal().minute.toString().padLeft(2, '0')}';
}

class _Status extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const _Status({required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.forum_outlined, size: 60),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    ),
  );
}
