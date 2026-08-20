from dataclasses import dataclass


@dataclass
class CreateReportDTO:
    name: str
    photo: object
    characteristics: str
    last_location: str
    date_lost: str
    contact_info: str


@dataclass
class ReportResponseDTO:
    id: int
    user_id: int
    name: str
    photo: str
    characteristics: str
    last_location: str
    date_lost: str
    contact_info: str
    created_at: str
