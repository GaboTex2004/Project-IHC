# pets/serializers.py
from rest_framework import serializers
from .models import LostPetReport

class LostPetReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = LostPetReport
        fields = '__all__'  # Esto le dice que incluya todos los campos de tu modelo
        
        # Opcional: Si quieres que la fecha de creación sea solo de lectura
        read_only_fields = ['created_at']