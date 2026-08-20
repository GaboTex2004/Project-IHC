from django.apps import AppConfig


class InfrastructureDbConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'infrastructure.db'
    verbose_name = 'Infrastructure - Database'
