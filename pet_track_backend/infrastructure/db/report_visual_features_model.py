
from django.db import models

from .lost_pet_model import LostPetReportModel


class ReportVisualFeaturesModel(models.Model):
    class AnalysisStatus(models.TextChoices):
        PENDING = 'PENDING', 'Pendiente'
        PROCESSING = 'PROCESSING', 'Procesando'
        COMPLETED = 'COMPLETED', 'Completado'
        FAILED = 'FAILED', 'Fallido'

    report = models.OneToOneField(
        LostPetReportModel,
        on_delete=models.CASCADE,
        related_name='visual_features',
    )

    species = models.CharField(max_length=50, blank=True, default='')
    primary_color = models.CharField(max_length=50, blank=True, default='')
    secondary_color = models.CharField(max_length=50, blank=True, default='')
    markings = models.TextField(blank=True, default='')
    coat_type = models.CharField(max_length=50, blank=True, default='')
    ear_type = models.CharField(max_length=50, blank=True, default='')
    size = models.CharField(max_length=30, blank=True, default='')
    distinctive_features = models.TextField(blank=True, default='')

    analysis_status = models.CharField(
        max_length=15,
        choices=AnalysisStatus.choices,
        default=AnalysisStatus.PENDING,
    )

    photo_hash = models.CharField(max_length=64, blank=True, default='')
    model_version = models.CharField(max_length=100, blank=True, default='')
    analyzed_at = models.DateTimeField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'infrastructure_report_visual_features'

    def __str__(self):
        return f'Características visuales del reporte {self.report_id}'