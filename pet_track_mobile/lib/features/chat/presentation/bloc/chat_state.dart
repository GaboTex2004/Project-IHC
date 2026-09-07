import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;
  const ConversationsLoaded(this.conversations);
  @override
  List<Object> get props => [conversations];
}

class ConversationOpened extends ChatState {
  final Conversation conversation;
  const ConversationOpened(this.conversation);
  @override
  List<Object> get props => [conversation];
}

class MessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool sending;
  final String? error;
  const MessagesLoaded(this.messages, {this.sending = false, this.error});
  @override
  List<Object?> get props => [messages, sending, error];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object> get props => [message];
}
