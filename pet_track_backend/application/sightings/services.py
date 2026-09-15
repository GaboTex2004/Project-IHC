from domain.lost_pets.exceptions import ReportNotFoundException
from domain.sightings.exceptions import (
    SightingAccessDeniedException,
    SightingNotAllowedException,
    SightingNotFoundException,
)


class CreateSightingService:
    def __init__(self, report_repository, sighting_repository):
        self.report_repository = report_repository
        self.sighting_repository = sighting_repository

    def execute(self, report_id, reporter_id, latitude, longitude,
                location_description, sighting_datetime, description, photo):
        report = self.report_repository.find_by_id(report_id)
        if report is None:
            raise ReportNotFoundException(f'Reporte {report_id} no encontrado')
        if report.user_id == reporter_id:
            raise SightingNotAllowedException('No puedes reportar un avistamiento en tu propio reporte')
        if report.report_type != 'LOST' or report.status != 'ACTIVE':
            raise SightingNotAllowedException('Solo se admiten avistamientos en reportes perdidos activos')
        return self.sighting_repository.create(
            report_id, reporter_id, latitude, longitude,
            location_description, sighting_datetime, description, photo,
        )


class GetSightingService:
    def __init__(self, sighting_repository):
        self.sighting_repository = sighting_repository

    def execute(self, sighting_id, user_id):
        sighting = self.sighting_repository.find_by_id(sighting_id)
        if sighting is None:
            raise SightingNotFoundException(f'Avistamiento {sighting_id} no encontrado')
        if user_id not in (sighting.reporter_id, sighting.report_owner_id):
            raise SightingAccessDeniedException('No tienes permiso para consultar este avistamiento')
        return sighting


class ListReportSightingsService:
    def __init__(self, report_repository, sighting_repository):
        self.report_repository = report_repository
        self.sighting_repository = sighting_repository

    def execute(self, report_id, user_id):
        report = self.report_repository.find_by_id(report_id)
        if report is None:
            raise ReportNotFoundException(f'Reporte {report_id} no encontrado')
        if report.user_id != user_id:
            raise SightingAccessDeniedException('Solo el propietario puede listar los avistamientos del reporte')
        return self.sighting_repository.find_by_report(report_id)
