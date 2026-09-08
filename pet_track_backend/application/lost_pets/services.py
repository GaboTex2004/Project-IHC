from typing import List
from application.lost_pets.interfaces import LostPetReportRepository
from application.lost_pets.dtos import CreateReportDTO, ReportResponseDTO
from domain.lost_pets.exceptions import ReportNotFoundException, UnauthorizedReportAccessException


def _to_response_dto(report) -> ReportResponseDTO:
    return ReportResponseDTO(
        id=report.id,
        user_id=report.user_id,
        name=report.name,
        photo=report.photo,
        characteristics=report.characteristics,
        last_location=report.last_location,
        date_lost=report.date_lost,
        contact_info=report.contact_info,
        report_type=report.report_type,
        status=report.status,
        created_at=report.created_at,
    )


class CreateReportService:
    def __init__(self, report_repository: LostPetReportRepository):
        self.report_repository = report_repository

    def execute(self, user_id: int, dto: CreateReportDTO) -> ReportResponseDTO:
        report = self.report_repository.create(
            user_id=user_id,
            name=dto.name,
            photo=dto.photo,
            characteristics=dto.characteristics,
            last_location=dto.last_location,
            date_lost=dto.date_lost,
            contact_info=dto.contact_info,
            report_type=dto.report_type,
        )
        return _to_response_dto(report)


class ListReportsService:
    def __init__(self, report_repository: LostPetReportRepository):
        self.report_repository = report_repository

    def execute(self, exclude_user_id: int = None) -> List[ReportResponseDTO]:
        reports = self.report_repository.find_public(exclude_user_id)
        return [_to_response_dto(report) for report in reports]


class ListMyReportsService:
    def __init__(self, report_repository: LostPetReportRepository):
        self.report_repository = report_repository

    def execute(self, user_id: int) -> List[ReportResponseDTO]:
        reports = self.report_repository.find_by_user(user_id)
        return [_to_response_dto(report) for report in reports]


class GetReportDetailService:
    def __init__(self, report_repository: LostPetReportRepository):
        self.report_repository = report_repository

    def execute(self, report_id: int) -> ReportResponseDTO:
        report = self.report_repository.find_by_id(report_id)
        if report is None:
            raise ReportNotFoundException(f"Reporte {report_id} no encontrado")

        return _to_response_dto(report)


class UpdateReportStatusService:
    def __init__(self, report_repository: LostPetReportRepository):
        self.report_repository = report_repository

    def execute(self, user_id: int, report_id: int, report_status: str) -> ReportResponseDTO:
        report = self.report_repository.find_by_id(report_id)
        if report is None:
            raise ReportNotFoundException(f"Reporte {report_id} no encontrado")
        if not report.belongs_to(user_id):
            raise UnauthorizedReportAccessException(
                "No tienes permiso para modificar este reporte"
            )

        updated_report = self.report_repository.update_status(report_id, report_status)
        if updated_report is None:
            raise ReportNotFoundException(f"Reporte {report_id} no encontrado")
        return _to_response_dto(updated_report)


class DeleteReportService:
    def __init__(self, report_repository: LostPetReportRepository):
        self.report_repository = report_repository

    def execute(self, user_id: int, report_id: int) -> bool:
        report = self.report_repository.find_by_id(report_id)
        if report is None:
            raise ReportNotFoundException(f"Reporte {report_id} no encontrado")

        if not report.belongs_to(user_id):
            raise UnauthorizedReportAccessException("No tienes permiso para eliminar este reporte")

        return self.report_repository.delete(report_id)
