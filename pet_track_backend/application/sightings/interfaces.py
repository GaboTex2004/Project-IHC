from abc import ABC, abstractmethod


class SightingRepository(ABC):
    @abstractmethod
    def create(self, report_id, reporter_id, latitude, longitude,
               location_description, sighting_datetime, description, photo):
        pass

    @abstractmethod
    def find_by_id(self, sighting_id):
        pass

    @abstractmethod
    def find_by_report(self, report_id):
        pass
