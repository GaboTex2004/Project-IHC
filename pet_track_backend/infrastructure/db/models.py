from django.db import models


class UserProfile(models.Model):
    user = models.OneToOneField('auth.User', on_delete=models.CASCADE, related_name='profile')
    phone = models.CharField(max_length=20, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'infrastructure_user_profile'

    def __str__(self):
        return self.user.username

# Registrar los modelos definidos en módulos separados para que
# Django los descubra durante la inicialización de la aplicación.
from .lost_pet_model import LostPetReportModel
from .chat_models import ConversationModel, MessageModel
from .sighting_model import SightingModel
from .report_visual_features_model import ReportVisualFeaturesModel