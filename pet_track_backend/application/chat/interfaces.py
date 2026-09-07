from abc import ABC, abstractmethod
from typing import List, Optional
from domain.chat.entities import Conversation, Message


class ChatRepository(ABC):
    @abstractmethod
    def get_or_create_conversation(
        self, report_id: int, report_owner_id: int, interested_user_id: int
    ) -> Conversation:
        pass

    @abstractmethod
    def list_conversations(self, user_id: int) -> List[Conversation]:
        pass

    @abstractmethod
    def find_conversation(self, conversation_id: int, viewer_id: int) -> Optional[Conversation]:
        pass

    @abstractmethod
    def list_messages(self, conversation_id: int) -> List[Message]:
        pass

    @abstractmethod
    def create_message(self, conversation_id: int, sender_id: int, content: str) -> Message:
        pass
