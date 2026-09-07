from abc import ABC, abstractmethod
from typing import Optional, List
from domain.lost_pets.entities import LostPetReport


class LostPetReportRepository(ABC):
    @abstractmethod
    def find_all(self) -> List[LostPetReport]:
        pass

    @abstractmethod
    def find_public(self, exclude_user_id: int = None) -> List[LostPetReport]:
        pass

    @abstractmethod
    def find_by_id(self, report_id: int) -> Optional[LostPetReport]:
        pass

    @abstractmethod
    def find_by_user(self, user_id: int) -> List[LostPetReport]:
        pass

    @abstractmethod
    def create(self, user_id: int, name: Optional[str], photo: str,
               characteristics: str, last_location: str, date_lost: str,
               contact_info: str, report_type: str) -> LostPetReport:
        pass

    @abstractmethod
    def update_status(self, report_id: int, report_status: str) -> Optional[LostPetReport]:
        pass

    @abstractmethod
    def delete(self, report_id: int) -> bool:
        pass
