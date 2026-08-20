# pets/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import LostPetReportViewSet, health_check, send_notification

# El router crea automáticamente las URLs para nuestro ViewSet
router = DefaultRouter()
router.register(r'lost-pets', LostPetReportViewSet, basename='lost-pets')

urlpatterns = [
    path('', include(router.urls)),
    path('health/', health_check, name='health-check'),
    path('notifications/send/', send_notification, name='send-notification'),
]