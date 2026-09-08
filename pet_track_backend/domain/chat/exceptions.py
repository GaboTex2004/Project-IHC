class ChatException(Exception):
    pass


class ConversationNotFoundException(ChatException):
    pass


class ConversationAccessDeniedException(ChatException):
    pass


class SelfConversationException(ChatException):
    pass


class ResolvedReportConversationException(ChatException):
    pass
