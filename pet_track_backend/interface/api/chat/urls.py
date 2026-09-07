from django.urls import path
from interface.api.chat.views import ConversationMessagesView, ConversationsView


urlpatterns = [
    path('', ConversationsView.as_view(), name='conversations'),
    path(
        '<int:conversation_id>/messages/',
        ConversationMessagesView.as_view(),
        name='conversation-messages',
    ),
]
