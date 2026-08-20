# pets/views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db import connection
from config.notifications import send_push_notification, send_push_notification_to_topic


class HealthCheckView(APIView):
    schema = None

    def get(self, request):
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


class SendNotificationView(APIView):
    schema = None

    def post(self, request):
        token = request.data.get("token")
        title = request.data.get("title", "Pet Track")
        body = request.data.get("body", "")
        data = request.data.get("data", {})
        topic = request.data.get("topic")

        if not token and not topic:
            return Response(
                {"error": "Se requiere 'token' o 'topic'"},
                status=400
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
                status=500
            )
