from django.db import models


class LostPetReportModel(models.Model):
    class ReportType(models.TextChoices):
        LOST = 'LOST', 'Perdido'
        FOUND = 'FOUND', 'Encontrado'
        HOMELESS = 'HOMELESS', 'Sin hogar'

    class ReportStatus(models.TextChoices):
        ACTIVE = 'ACTIVE', 'Activo'
        RESOLVED = 'RESOLVED', 'Resuelto'

    user = models.ForeignKey('auth.User', on_delete=models.CASCADE, related_name='lost_pet_reports')
    name = models.CharField(max_length=100, blank=True, null=True)
    photo = models.ImageField(upload_to='lost_pets/')
    characteristics = models.TextField()
    last_location = models.CharField(max_length=255)
    date_lost = models.DateField()
    contact_info = models.CharField(max_length=150)
    report_type = models.CharField(
        max_length=10,
        choices=ReportType.choices,
        default=ReportType.LOST,
    )
    status = models.CharField(
        max_length=10,
        choices=ReportStatus.choices,
        default=ReportStatus.ACTIVE,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'infrastructure_lost_pet_report'
        ordering = ['-created_at']

    def __str__(self):
        return f"Reporte {self.report_type}: {self.name or 'Sin nombre'}"
