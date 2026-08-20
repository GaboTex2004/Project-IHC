from typing import List
from application.lost_pets.interfaces import LostPetReportRepository
from application.lost_pets.dtos import CreateReportDTO, ReportResponseDTO
from domain.lost_pets.exceptions import ReportNotFoundException, UnauthorizedReportAccessException


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
        )

        return ReportResponseDTO(
            id=report.id,
            user_id=report.user_id,
            name=report.name,
            photo=report.photo,
            characteristics=report.characteristics,
            last_location=report.last_location,
            date_lost=report.date_lost,
            contact_info=report.contact_info,
            created_at=report.created_at,
        )


class ListReportsService:
    def __init__(self, report_repository: LostPetReportRepository):
        self.report_repository = report_repository

    def execute(self, user_id: int = None) -> List[ReportResponseDTO]:
        if user_id:
            reports = self.report_repository.find_by_user(user_id)
        else:
            reports = self.report_repository.find_all()

        return [
            ReportResponseDTO(
                id=r.id,
                user_id=r.user_id,
                name=r.name,
                photo=r.photo,
                characteristics=r.characteristics,
                last_location=r.last_location,
                date_lost=r.date_lost,
                contact_info=r.contact_info,
                created_at=r.created_at,
            )
            for r in reports
        ]


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
