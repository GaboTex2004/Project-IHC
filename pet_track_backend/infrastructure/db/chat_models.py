from django.conf import settings
from django.db import models
from django.db.models import F, Q
from infrastructure.db.lost_pet_model import LostPetReportModel


class ConversationModel(models.Model):
    report = models.ForeignKey(
        LostPetReportModel,
        on_delete=models.CASCADE,
        related_name='conversations',
    )
    report_owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='owned_report_conversations',
    )
    interested_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='interested_report_conversations',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'infrastructure_conversation'
        ordering = ['-updated_at']
        constraints = [
            models.UniqueConstraint(
                fields=['report', 'interested_user'],
                name='unique_report_interested_conversation',
            ),
            models.CheckConstraint(
                condition=~Q(report_owner=F('interested_user')),
                name='conversation_participants_are_different',
            ),
        ]


class MessageModel(models.Model):
    conversation = models.ForeignKey(
        ConversationModel,
        on_delete=models.CASCADE,
        related_name='messages',
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='report_messages',
    )
    content = models.CharField(max_length=1000)
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        db_table = 'infrastructure_message'
        ordering = ['created_at']
