from typing import List, Optional
from django.contrib.auth.models import User
from django.db.models import Q
from application.chat.interfaces import ChatRepository
from domain.chat.entities import Conversation, Message
from infrastructure.db.chat_models import ConversationModel, MessageModel
from infrastructure.db.lost_pet_model import LostPetReportModel


class DjangoChatRepository(ChatRepository):
    def get_or_create_conversation(
        self, report_id: int, report_owner_id: int, interested_user_id: int
    ) -> Conversation:
        conversation, _ = ConversationModel.objects.get_or_create(
            report_id=report_id,
            interested_user_id=interested_user_id,
            defaults={'report_owner_id': report_owner_id},
        )
        return self._to_conversation(conversation, interested_user_id)

    def list_conversations(self, user_id: int) -> List[Conversation]:
        conversations = ConversationModel.objects.filter(
            Q(report_owner_id=user_id) | Q(interested_user_id=user_id)
        ).select_related('report', 'report_owner', 'interested_user')
        return [self._to_conversation(item, user_id) for item in conversations]

    def find_conversation(
        self, conversation_id: int, viewer_id: int
    ) -> Optional[Conversation]:
        try:
            conversation = ConversationModel.objects.select_related(
                'report', 'report_owner', 'interested_user'
            ).get(id=conversation_id)
        except ConversationModel.DoesNotExist:
            return None
        return self._to_conversation(conversation, viewer_id)

    def list_messages(self, conversation_id: int) -> List[Message]:
        messages = MessageModel.objects.filter(
            conversation_id=conversation_id
        ).select_related('sender')
        return [self._to_message(message) for message in messages]

    def create_message(
        self, conversation_id: int, sender_id: int, content: str
    ) -> Message:
        message = MessageModel.objects.create(
            conversation_id=conversation_id,
            sender_id=sender_id,
            content=content,
        )
        conversation = message.conversation
        conversation.save(update_fields=['updated_at'])
        return self._to_message(message)

    def _to_conversation(
        self, model: ConversationModel, viewer_id: int
    ) -> Conversation:
        other_user = (
            model.interested_user
            if viewer_id == model.report_owner_id
            else model.report_owner
        )
        last_message = model.messages.order_by('-created_at').first()
        return Conversation(
            id=model.id,
            report_id=model.report_id,
            report_name=model.report.name,
            report_photo=model.report.photo.url if model.report.photo else '',
            report_owner_id=model.report_owner_id,
            interested_user_id=model.interested_user_id,
            other_user_id=other_user.id,
            other_user_name=self._user_name(other_user),
            last_message=last_message.content if last_message else None,
            updated_at=str(last_message.created_at if last_message else model.updated_at),
        )

    def _to_message(self, model: MessageModel) -> Message:
        return Message(
            id=model.id,
            conversation_id=model.conversation_id,
            sender_id=model.sender_id,
            sender_name=self._user_name(model.sender),
            content=model.content,
            created_at=str(model.created_at),
        )

    @staticmethod
    def _user_name(user: User) -> str:
        return user.get_full_name().strip() or user.username
