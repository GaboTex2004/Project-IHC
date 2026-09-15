from decimal import Decimal
from io import BytesIO
from uuid import uuid4
from django.core.files.uploadedfile import SimpleUploadedFile
from django.utils import timezone
from PIL import Image, ImageOps
from rest_framework import serializers


class CreateSightingInputSerializer(serializers.Serializer):
    report_id = serializers.IntegerField(min_value=1)
    latitude = serializers.DecimalField(
        max_digits=9, decimal_places=6,
        min_value=Decimal('-90'), max_value=Decimal('90'),
    )
    longitude = serializers.DecimalField(
        max_digits=9, decimal_places=6,
        min_value=Decimal('-180'), max_value=Decimal('180'),
    )
    location_description = serializers.CharField(max_length=255, trim_whitespace=True)
    sighting_datetime = serializers.DateTimeField()
    description = serializers.CharField(max_length=2000, trim_whitespace=True)
    photo = serializers.ImageField(required=False, allow_empty_file=False)

    def validate_sighting_datetime(self, value):
        if value > timezone.now():
            raise serializers.ValidationError('La fecha del avistamiento no puede ser futura')
        return value

    def validate_photo(self, value):
        # El almacenamiento de medios del proyecto sirve archivos por URL.
        # Quitar EXIF evita revelar GPS incrustado en fotografías originales.
        try:
            value.seek(0)
            with Image.open(value) as original:
                image = ImageOps.exif_transpose(original).convert('RGB')
                output = BytesIO()
                image.save(output, format='JPEG', quality=85)
        except (OSError, ValueError):
            raise serializers.ValidationError('No se pudo procesar la fotografía')
        return SimpleUploadedFile(
            f'sighting-{uuid4().hex}.jpg', output.getvalue(),
            content_type='image/jpeg',
        )


class SightingResponseSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    report_id = serializers.IntegerField()
    reporter_id = serializers.IntegerField()
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6)
    location_description = serializers.CharField()
    sighting_datetime = serializers.DateTimeField()
    description = serializers.CharField()
    photo = serializers.CharField()
    created_at = serializers.DateTimeField()
