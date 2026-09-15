from decimal import Decimal
from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from infrastructure.db.lost_pet_model import LostPetReportModel


class SightingModel(models.Model):
    report = models.ForeignKey(
        LostPetReportModel, on_delete=models.CASCADE, related_name='sightings',
    )
    reporter = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='reported_sightings',
    )
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6,
        validators=[MinValueValidator(Decimal('-90')), MaxValueValidator(Decimal('90'))],
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6,
        validators=[MinValueValidator(Decimal('-180')), MaxValueValidator(Decimal('180'))],
    )
    location_description = models.CharField(max_length=255)
    sighting_datetime = models.DateTimeField()
    description = models.TextField(max_length=2000)
    photo = models.ImageField(upload_to='sightings/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'infrastructure_sighting'
        ordering = ['-sighting_datetime']
        constraints = [
            models.CheckConstraint(
                condition=models.Q(latitude__gte=-90, latitude__lte=90),
                name='sighting_latitude_range',
            ),
            models.CheckConstraint(
                condition=models.Q(longitude__gte=-180, longitude__lte=180),
                name='sighting_longitude_range',
            ),
        ]
