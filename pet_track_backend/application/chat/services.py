from typing import List
from application.chat.interfaces import ChatRepository
from application.lost_pets.interfaces import LostPetReportRepository
from domain.chat.entities import Conversation, Message
from domain.chat.exceptions import (
    ConversationAccessDeniedException,
    ConversationNotFoundException,
    ResolvedReportConversationException,
    SelfConversationException,
)
from domain.lost_pets.exceptions import ReportNotFoundException


class GetOrCreateConversationService:
    def __init__(self, chat_repository: ChatRepository,
                 report_repository: LostPetReportRepository):
        self.chat_repository = chat_repository
        self.report_repository = report_repository

    def execute(self, report_id: int, interested_user_id: int) -> Conversation:
        report = self.report_repository.find_by_id(report_id)
        if report is None:
            raise ReportNotFoundException(f"Reporte {report_id} no encontrado")
        if report.user_id == interested_user_id:
            raise SelfConversationException(
                "No puedes iniciar una conversación contigo mismo"
            )
        if report.status != 'ACTIVE':
            raise ResolvedReportConversationException(
                "No se pueden iniciar conversaciones nuevas en reportes resueltos"
            )
        return self.chat_repository.get_or_create_conversation(
            report_id=report.id,
            report_owner_id=report.user_id,
            interested_user_id=interested_user_id,
        )


class ListConversationsService:
    def __init__(self, chat_repository: ChatRepository):
        self.chat_repository = chat_repository

    def execute(self, user_id: int) -> List[Conversation]:
        return self.chat_repository.list_conversations(user_id)


class GetMessagesService:
    def __init__(self, chat_repository: ChatRepository):
        self.chat_repository = chat_repository

    def execute(self, conversation_id: int, user_id: int) -> List[Message]:
        conversation = self.chat_repository.find_conversation(conversation_id, user_id)
        if conversation is None:
            raise ConversationNotFoundException(
                f"Conversación {conversation_id} no encontrada"
            )
        if not conversation.has_participant(user_id):
            raise ConversationAccessDeniedException(
                "No tienes acceso a esta conversación"
            )
        return self.chat_repository.list_messages(conversation_id)


class SendMessageService:
    def __init__(self, chat_repository: ChatRepository):
        self.chat_repository = chat_repository

    def execute(self, conversation_id: int, sender_id: int, content: str) -> Message:
        conversation = self.chat_repository.find_conversation(conversation_id, sender_id)
        if conversation is None:
            raise ConversationNotFoundException(
                f"Conversación {conversation_id} no encontrada"
            )
        if not conversation.has_participant(sender_id):
            raise ConversationAccessDeniedException(
                "No tienes acceso a esta conversación"
            )
        return self.chat_repository.create_message(
            conversation_id=conversation_id,
            sender_id=sender_id,
            content=content,
        )
