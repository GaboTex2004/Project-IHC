from dataclasses import dataclass


@dataclass
class CreateReportDTO:
    name: str | None
    photo: object
    characteristics: str
    last_location: str
    date_lost: str
    contact_info: str
    report_type: str


@dataclass
class ReportResponseDTO:
    id: int
    user_id: int
    name: str | None
    photo: str
    characteristics: str
    last_location: str
    date_lost: str
    contact_info: str
    report_type: str
    status: str
    created_at: str
