from django.db import models

class LostPetReport(models.Model):
    name = models.CharField(max_length=100)
    # Django subirá esto a Cloudinary automáticamente
    photo = models.ImageField(upload_to='lost_pets/') 
    characteristics = models.TextField()
    last_location = models.CharField(max_length=255)
    date_lost = models.DateField()
    contact_info = models.CharField(max_length=150)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Mascota Perdida: {self.name}"