from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from application.chat.services import (
    GetMessagesService,
    GetOrCreateConversationService,
    ListConversationsService,
    SendMessageService,
)
from domain.chat.exceptions import (
    ConversationAccessDeniedException,
    ConversationNotFoundException,
    ResolvedReportConversationException,
    SelfConversationException,
)
from domain.lost_pets.exceptions import ReportNotFoundException
from infrastructure.db.chat_repository import DjangoChatRepository
from infrastructure.db.lost_pet_repository import DjangoLostPetReportRepository
from interface.api.chat.serializers import (
    ConversationResponseSerializer,
    CreateConversationInputSerializer,
    MessageResponseSerializer,
    SendMessageInputSerializer,
)


class ConversationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        service = ListConversationsService(DjangoChatRepository())
        result = service.execute(request.user.id)
        serializer = ConversationResponseSerializer(result, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = CreateConversationInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        service = GetOrCreateConversationService(
            chat_repository=DjangoChatRepository(),
            report_repository=DjangoLostPetReportRepository(),
        )
        try:
            result = service.execute(
                report_id=serializer.validated_data['report_id'],
                interested_user_id=request.user.id,
            )
        except ReportNotFoundException as error:
            return Response({'error': str(error)}, status=status.HTTP_404_NOT_FOUND)
        except (SelfConversationException, ResolvedReportConversationException) as error:
            return Response({'error': str(error)}, status=status.HTTP_400_BAD_REQUEST)

        response_serializer = ConversationResponseSerializer(result)
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class ConversationMessagesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, conversation_id):
        service = GetMessagesService(DjangoChatRepository())
        try:
            result = service.execute(conversation_id, request.user.id)
        except ConversationNotFoundException as error:
            return Response({'error': str(error)}, status=status.HTTP_404_NOT_FOUND)
        except ConversationAccessDeniedException as error:
            return Response({'error': str(error)}, status=status.HTTP_403_FORBIDDEN)

        serializer = MessageResponseSerializer(result, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, conversation_id):
        serializer = SendMessageInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        service = SendMessageService(DjangoChatRepository())
        try:
            result = service.execute(
                conversation_id=conversation_id,
                sender_id=request.user.id,
                content=serializer.validated_data['content'],
            )
        except ConversationNotFoundException as error:
            return Response({'error': str(error)}, status=status.HTTP_404_NOT_FOUND)
        except ConversationAccessDeniedException as error:
            return Response({'error': str(error)}, status=status.HTTP_403_FORBIDDEN)

        response_serializer = MessageResponseSerializer(result)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)
