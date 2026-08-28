from typing import Optional, List
from application.lost_pets.interfaces import LostPetReportRepository
from domain.lost_pets.entities import LostPetReport
from infrastructure.db.lost_pet_model import LostPetReportModel


class DjangoLostPetReportRepository(LostPetReportRepository):
    def find_all(self) -> List[LostPetReport]:
        reports = LostPetReportModel.objects.all()
        return [self._to_entity(r) for r in reports]

    def find_by_id(self, report_id: int) -> Optional[LostPetReport]:
        try:
            report = LostPetReportModel.objects.get(id=report_id)
            return self._to_entity(report)
        except LostPetReportModel.DoesNotExist:
            return None

    def find_by_user(self, user_id: int) -> List[LostPetReport]:
        reports = LostPetReportModel.objects.filter(user_id=user_id)
        return [self._to_entity(r) for r in reports]

    def create(self, user_id: int, name: str, photo: str, characteristics: str,
               last_location: str, date_lost: str, contact_info: str) -> LostPetReport:
        from django.contrib.auth.models import User
        user = User.objects.get(id=user_id)

        report = LostPetReportModel.objects.create(
            user=user,
            name=name,
            photo=photo,
            characteristics=characteristics,
            last_location=last_location,
            date_lost=date_lost,
            contact_info=contact_info,
        )
        return self._to_entity(report)

    def delete(self, report_id: int) -> bool:
        deleted, _ = LostPetReportModel.objects.filter(id=report_id).delete()
        return deleted > 0

    def _to_entity(self, model: LostPetReportModel) -> LostPetReport:
        return LostPetReport(
            id=model.id,
            user_id=model.user_id,
            name=model.name,
            photo=model.photo.url if model.photo else '',
            characteristics=model.characteristics,
            last_location=model.last_location,
            date_lost=str(model.date_lost),
            contact_info=model.contact_info,
            created_at=str(model.created_at),
        )
