import hashlib
from application.matching.image_processing import prepare_report_image
from infrastructure.db.visual_features_repository import DjangoVisualFeaturesRepository

from infrastructure.db.lost_pet_repository import DjangoLostPetReportRepository
from infrastructure.ai.pet_visual_analyzer import (
    ANALYSIS_MODEL_VERSION,
    PetVisualAnalyzer,
)

class AnalysisValidationError(Exception):
    """La solicitud de análisis no cumple los requisitos."""


class AnalysisReportNotFoundError(Exception):
    """El reporte solicitado no existe."""


class AnalysisPermissionError(Exception):
    """El usuario no tiene permiso para analizar este reporte."""


class ValidateReportForAnalysisService:
    def __init__(self, report_repository=None):
        self.report_repository = (
            report_repository or DjangoLostPetReportRepository()
        )

    def execute(self, *, user_id: int, report_id: int):
        report = self.report_repository.find_by_id(report_id)

        if report is None:
            raise AnalysisReportNotFoundError(
                'El reporte no existe.'
            )

        if report.user_id != user_id:
            raise AnalysisPermissionError(
                'No tienes permiso para analizar este reporte.'
            )

        if report.status != 'ACTIVE':
            raise AnalysisValidationError(
                'Solo se pueden analizar reportes activos.'
            )

        if report.report_type not in ('LOST', 'FOUND', 'HOMELESS'):
            raise AnalysisValidationError(
                'Este tipo de reporte no admite análisis por ahora.'
            )

        if not report.photo:
            raise AnalysisValidationError(
                'El reporte no tiene una fotografía.'
            )

        return report

class PrepareReportAnalysisService:
    def __init__(
        self,
        validation_service=None,
        report_repository=None,
        features_repository=None,
        image_processor=None,
    ):
        self.validation_service = (
            validation_service
            if validation_service is not None
            else ValidateReportForAnalysisService()
        )
        self.report_repository = (
            report_repository
            if report_repository is not None
            else DjangoLostPetReportRepository()
        )
        self.features_repository = (
            features_repository
            if features_repository is not None
            else DjangoVisualFeaturesRepository()
        )
        self.image_processor = (
            image_processor
            if image_processor is not None
            else prepare_report_image
        )

    def execute(self, *, user_id: int, report_id: int):
        # Primero comprobamos que el usuario tenga permiso.
        report = self.validation_service.execute(
            user_id=user_id,
            report_id=report_id,
        )

        # Solo después consultamos el modelo con su fotografía.
        report_model = self.report_repository.find_model_by_id(report.id)

        if report_model is None:
            raise AnalysisReportNotFoundError(
                'El reporte ya no existe.'
            )

        if report_model.user_id != user_id:
            raise AnalysisPermissionError(
                'No tienes permiso para analizar este reporte.'
            )

        if report_model.status != 'ACTIVE':
            raise AnalysisValidationError(
                'Solo se pueden analizar reportes activos.'
            )

        if report_model.report_type not in ('LOST', 'FOUND', 'HOMELESS'):
            raise AnalysisValidationError(
                'Este tipo de reporte no admite análisis por ahora.'
            )

        if not report_model.photo:
            raise AnalysisValidationError(
                'El reporte no tiene una fotografía.'
            )

        # Solo después de estas comprobaciones abrimos la imagen.
        image_bytes = self.image_processor(report_model)

        photo_hash = hashlib.sha256(image_bytes).hexdigest()

        # Consultar el análisis existente sin crear registros todavía.
        existing_features = self.features_repository.find_by_report_id(
            report.id
        )
        can_reuse_analysis = (
            existing_features is not None
            and existing_features.analysis_status == 'COMPLETED'
            and existing_features.photo_hash == photo_hash
            and existing_features.model_version == ANALYSIS_MODEL_VERSION
        )

        return {
            'report_id': report.id,
            'image_bytes': image_bytes,
            'photo_hash': photo_hash,
            'existing_features': existing_features,
            'model_version': ANALYSIS_MODEL_VERSION,
            'can_reuse_analysis': can_reuse_analysis,
        }

    

class AnalyzeReportVisualFeaturesService:
    def __init__(
        self,
        preparation_service=None,
        analyzer=None,
        features_repository=None,
    ):
        self.preparation_service = (
            preparation_service
            if preparation_service is not None
            else PrepareReportAnalysisService()
        )
        self.analyzer = (
            analyzer
            if analyzer is not None
            else PetVisualAnalyzer()
        )
        self.features_repository = (
            features_repository
            if features_repository is not None
            else DjangoVisualFeaturesRepository()
        )

    def execute(self, *, user_id: int, report_id: int):
        prepared = self.preparation_service.execute(
            user_id=user_id,
            report_id=report_id,
        )

        if prepared['can_reuse_analysis']:
            return {
                'report_id': prepared['report_id'],
                'features': prepared['existing_features'],
                'photo_hash': prepared['photo_hash'],
                'model_version': prepared['model_version'],
                'reused': True,
            }

        features = self.analyzer.analyze(
            prepared['image_bytes']
        )

        saved_features = self.features_repository.save_completed(
            user_id=user_id,
            report_id=prepared['report_id'],
            features=features,
            photo_hash=prepared['photo_hash'],
            model_version=prepared['model_version'],
        )

        return {
            'report_id': prepared['report_id'],
            'features': saved_features,
            'photo_hash': prepared['photo_hash'],
            'model_version': prepared['model_version'],
            'reused': False,
        }
