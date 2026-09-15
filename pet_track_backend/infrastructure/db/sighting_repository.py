from django.db import transaction
from domain.lost_pets.exceptions import ReportNotFoundException
from domain.sightings.entities import Sighting
from domain.sightings.exceptions import SightingNotAllowedException
from infrastructure.db.lost_pet_model import LostPetReportModel
from infrastructure.db.sighting_model import SightingModel
from application.sightings.interfaces import SightingRepository


class DjangoSightingRepository(SightingRepository):
    @transaction.atomic
    def create(self, report_id, reporter_id, latitude, longitude,
               location_description, sighting_datetime, description, photo):
        # Revalida bajo bloqueo: el propietario puede resolver el reporte
        # mientras otro usuario completa las pantallas del formulario.
        try:
            report = LostPetReportModel.objects.select_for_update().get(id=report_id)
        except LostPetReportModel.DoesNotExist:
            raise ReportNotFoundException(f'Reporte {report_id} no encontrado')
        if report.user_id == reporter_id or report.report_type != 'LOST' or report.status != 'ACTIVE':
            raise SightingNotAllowedException('Este reporte ya no admite avistamientos')
        model = SightingModel.objects.create(
            report=report,
            reporter_id=reporter_id,
            latitude=latitude,
            longitude=longitude,
            location_description=location_description,
            sighting_datetime=sighting_datetime,
            description=description,
            photo=photo,
        )
        return self._to_entity(model)

    def find_by_id(self, sighting_id):
        model = SightingModel.objects.select_related('report').filter(id=sighting_id).first()
        return self._to_entity(model) if model else None

    def find_by_report(self, report_id):
        models = SightingModel.objects.select_related('report').filter(report_id=report_id)
        return [self._to_entity(model) for model in models]

    @staticmethod
    def _to_entity(model):
        return Sighting(
            id=model.id,
            report_id=model.report_id,
            report_owner_id=model.report.user_id,
            reporter_id=model.reporter_id,
            latitude=model.latitude,
            longitude=model.longitude,
            location_description=model.location_description,
            sighting_datetime=model.sighting_datetime,
            description=model.description,
            photo=model.photo.url if model.photo else '',
            created_at=model.created_at,
        )
