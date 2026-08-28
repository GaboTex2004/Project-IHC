from django.db import models


class LostPetReportModel(models.Model):
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE, related_name='lost_pet_reports')
    name = models.CharField(max_length=100)
    photo = models.ImageField(upload_to='lost_pets/')
    characteristics = models.TextField()
    last_location = models.CharField(max_length=255)
    date_lost = models.DateField()
    contact_info = models.CharField(max_length=150)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'infrastructure_lost_pet_report'
        ordering = ['-created_at']

    def __str__(self):
        return f"Mascota Perdida: {self.name}"
