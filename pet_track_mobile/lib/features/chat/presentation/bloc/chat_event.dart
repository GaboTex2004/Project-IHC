import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object> get props => [];
}

class LoadConversations extends ChatEvent {
  const LoadConversations();
}

class OpenConversation extends ChatEvent {
  final int reportId;
  const OpenConversation(this.reportId);
  @override
  List<Object> get props => [reportId];
}

class LoadMessages extends ChatEvent {
  final int conversationId;
  final bool silent;
  const LoadMessages(this.conversationId, {this.silent = false});
  @override
  List<Object> get props => [conversationId, silent];
}

class SendMessage extends ChatEvent {
  final int conversationId;
  final String content;
  const SendMessage(this.conversationId, this.content);
  @override
  List<Object> get props => [conversationId, content];
}
