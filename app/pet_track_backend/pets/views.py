# pets/views.py
from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db import connection
from .models import LostPetReport
from .serializers import LostPetReportSerializer
from config.notifications import send_push_notification, send_push_notification_to_topic


class LostPetReportViewSet(viewsets.ModelViewSet):
    # Traemos todos los reportes, ordenados por el más reciente primero
    queryset = LostPetReport.objects.all().order_by('-created_at')
    serializer_class = LostPetReportSerializer


@api_view(['GET'])
def health_check(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {str(e)}"

    return Response({
        "status": "ok",
        "database": db_status
    })


@api_view(['POST'])
def send_notification(request):
    token = request.data.get("token")
    title = request.data.get("title", "Pet Track")
    body = request.data.get("body", "")
    data = request.data.get("data", {})
    topic = request.data.get("topic")

    if not token and not topic:
        return Response(
            {"error": "Se requiere 'token' o 'topic'"},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        if topic:
            result = send_push_notification_to_topic(topic, title, body, data)
        else:
            result = send_push_notification(token, title, body, data)

        return Response({
            "status": "ok",
            "message_id": result
        })
    except Exception as e:
        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )