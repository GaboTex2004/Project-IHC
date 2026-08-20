# pets/urls.py
from django.urls import path
from .views import HealthCheckView, SendNotificationView

urlpatterns = [
    path('health/', HealthCheckView.as_view(), name='health-check'),
    path('notifications/send/', SendNotificationView.as_view(), name='send-notification'),
]
