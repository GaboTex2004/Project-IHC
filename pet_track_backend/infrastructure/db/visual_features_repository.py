import hashlib
from infrastructure.db.report_visual_features_model import (
    ReportVisualFeaturesModel,
)
from application.matching.image_processing import (
    prepare_report_image,
)
from infrastructure.db.lost_pet_model import LostPetReportModel
from django.db import transaction
from django.utils import timezone

class StaleReportAnalysisError(Exception):
    pass

class DjangoVisualFeaturesRepository:

    def find_by_report_id(self, report_id: int):
        return ReportVisualFeaturesModel.objects.filter(
            report_id=report_id
        ).first()
    def find_active_found_reports(self):
        return (
            ReportVisualFeaturesModel.objects
            .select_related('report')
            .filter(
                report__report_type__in=('FOUND', 'HOMELESS'),
                report__status='ACTIVE',
                analysis_status='COMPLETED',
            )
            .order_by('-report__created_at')
        )
    def get_or_create(self, report_id: int):
        features, created = (
            ReportVisualFeaturesModel.objects.get_or_create(
                report_id=report_id
            )
        )
        return features, created

    
    
    def save_completed(
        self,
        *,
        user_id: int,
        report_id: int,
        features,
        photo_hash: str,
        model_version: str,
    ):
        with transaction.atomic():
            report = (
                LostPetReportModel.objects
                .select_for_update()
                .filter(id=report_id)
                .first()
            )

            if report is None or report.status != 'ACTIVE':
                raise StaleReportAnalysisError(
                    'El reporte ya no está disponible para el análisis.'
                )
            if report.user_id != user_id:
                raise StaleReportAnalysisError(
                    'El reporte ya no pertenece al usuario que solicitó el análisis.'
                )
            if report.report_type not in ('LOST', 'FOUND', 'HOMELESS'):
                raise StaleReportAnalysisError(
                    'El tipo de reporte ya no admite análisis.'
                )

            if not report.photo:
                raise StaleReportAnalysisError(
                    'La fotografía del reporte fue eliminada.'
                )

            current_image_bytes = prepare_report_image(report)
            current_photo_hash = hashlib.sha256(
                current_image_bytes
            ).hexdigest()

            if current_photo_hash != photo_hash:
                raise StaleReportAnalysisError(
                    'La fotografía cambió durante el análisis.'
                )

            visual_features, _ = self.get_or_create(report_id)

            feature_data = features.model_dump()

            for field, value in feature_data.items():
                setattr(visual_features, field, value)

            visual_features.photo_hash = photo_hash
            visual_features.model_version = model_version
            visual_features.analysis_status = 'COMPLETED'
            visual_features.analyzed_at = timezone.now()

            visual_features.save()

            return visual_features
