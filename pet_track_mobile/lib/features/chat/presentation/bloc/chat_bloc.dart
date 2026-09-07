import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/get_or_create_conversation_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

EventTransformer<E> _sequential<E>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase getConversations;
  final GetOrCreateConversationUseCase getOrCreateConversation;
  final GetMessagesUseCase getMessages;
  final SendMessageUseCase sendMessage;
  bool _loadingMessages = false;

  ChatBloc({
    required this.getConversations,
    required this.getOrCreateConversation,
    required this.getMessages,
    required this.sendMessage,
  }) : super(const ChatInitial()) {
    on<ChatEvent>((event, emit) async {
      if (event is LoadConversations) {
        await _loadConversations(event, emit);
      } else if (event is OpenConversation) {
        await _openConversation(event, emit);
      } else if (event is LoadMessages) {
        await _loadMessages(event, emit);
      } else if (event is SendMessage) {
        await _sendMessage(event, emit);
      }
    }, transformer: _sequential());
  }

  Future<void> _loadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await getConversations();
    result.fold(
      (f) => emit(ChatError(f.message)),
      (items) => emit(ConversationsLoaded(items)),
    );
  }

  Future<void> _openConversation(
    OpenConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await getOrCreateConversation(event.reportId);
    result.fold(
      (f) => emit(ChatError(f.message)),
      (item) => emit(ConversationOpened(item)),
    );
  }

  Future<void> _loadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (_loadingMessages) return;
    _loadingMessages = true;
    if (!event.silent) emit(const ChatLoading());
    final result = await getMessages(event.conversationId);
    _loadingMessages = false;
    result.fold((f) {
      if (event.silent && state is MessagesLoaded) {
        emit(
          MessagesLoaded((state as MessagesLoaded).messages, error: f.message),
        );
      } else {
        emit(ChatError(f.message));
      }
    }, (items) => emit(MessagesLoaded(items)));
  }

  Future<void> _sendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final List<ChatMessage> previous = state is MessagesLoaded
        ? (state as MessagesLoaded).messages
        : const <ChatMessage>[];
    emit(MessagesLoaded(previous, sending: true));
    final result = await sendMessage(
      event.conversationId,
      event.content.trim(),
    );
    result.fold(
      (f) => emit(MessagesLoaded(previous, error: f.message)),
      (message) => emit(MessagesLoaded([...previous, message])),
    );
  }
}
