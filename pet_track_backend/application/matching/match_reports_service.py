import hashlib

from application.matching.image_processing import prepare_report_image
from infrastructure.ai.pet_visual_analyzer import ANALYSIS_MODEL_VERSION
from application.matching.similarity import calculate_similarity
from infrastructure.db.lost_pet_model import LostPetReportModel
from infrastructure.db.visual_features_repository import (
    DjangoVisualFeaturesRepository,
)

def has_current_analysis(report, features):
    if (
        features is None
        or features.analysis_status != 'COMPLETED'
        or features.model_version != ANALYSIS_MODEL_VERSION
        or not features.photo_hash
        or not report.photo
    ):
        return False

    image_bytes = prepare_report_image(report)

    return (
        hashlib.sha256(image_bytes).hexdigest()
        == features.photo_hash
    )
class MatchReportNotFoundError(Exception):
    pass


class MatchPermissionError(Exception):
    pass

class MatchReportsService:
    def __init__(self, features_repository=None):
        self.features_repository = (
            features_repository
            if features_repository is not None
            else DjangoVisualFeaturesRepository()
        )

    def execute(self, *, user_id: int, report_id: int):
        # El usuario solo puede buscar coincidencias de su propia mascota.
        lost_report = LostPetReportModel.objects.filter(
            id=report_id,
        ).first()

        if lost_report is None:
            raise MatchReportNotFoundError(
                'El reporte no existe.'
            )

        if lost_report.user_id != user_id:
            raise MatchPermissionError(
                'No tienes permiso para consultar este reporte.'
            )

        if (
            lost_report.report_type != 'LOST'
            or lost_report.status != 'ACTIVE'
        ):
            raise ValueError(
                'El reporte debe ser de una mascota perdida y estar activo.'
            )

        lost_features = self.features_repository.find_by_report_id(
            report_id
        )

        if not has_current_analysis(lost_report, lost_features):
            raise ValueError(
                'Primero debes analizar la fotografía de tu mascota.'
            )

        matches = []

        for found_features in (
            self.features_repository.find_active_found_reports()
        ):
            found_report = found_features.report
            if not has_current_analysis(found_report, found_features):
                continue
            # No mostrar reportes del mismo usuario como coincidencias.
            if found_report.user_id == user_id:
                continue

            score = calculate_similarity(
                lost_features,
                found_features,
            )

            if score <= 0:
                continue

            matches.append({
                'report_id': found_report.id,
                'name': found_report.name,
                'score': score,
                'report_type': found_report.report_type,
            })

        matches.sort(
            key=lambda item: (-item['score'], item['report_id'])
        )

        return matches