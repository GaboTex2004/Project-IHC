# pets/views.py
from rest_framework import viewsets
from .models import LostPetReport
from .serializers import LostPetReportSerializer

class LostPetReportViewSet(viewsets.ModelViewSet):
    # Traemos todos los reportes, ordenados por el más reciente primero
    queryset = LostPetReport.objects.all().order_by('-created_at')
    serializer_class = LostPetReportSerializer