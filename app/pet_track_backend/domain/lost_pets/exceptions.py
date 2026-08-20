class LostPetException(Exception):
    pass


class ReportNotFoundException(LostPetException):
    pass


class UnauthorizedReportAccessException(LostPetException):
    pass
