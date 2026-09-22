
from types import SimpleNamespace
from unittest import TestCase
from unittest.mock import Mock

from application.matching.services import (
    AnalysisPermissionError,
    AnalysisReportNotFoundError,
    AnalysisValidationError,
    ValidateReportForAnalysisService,
)


class ValidateReportForAnalysisServiceTests(TestCase):

    def setUp(self):
        self.repository = Mock()
        self.service = ValidateReportForAnalysisService(
            report_repository=self.repository
        )

        self.report = SimpleNamespace(
            id=10,
            user_id=5,
            report_type='LOST',
            status='ACTIVE',
            photo='https://example.com/mascota.jpg',
        )

        self.repository.find_by_id.return_value = self.report

    def test_reporte_inexistente(self):
        self.repository.find_by_id.return_value = None

        with self.assertRaises(AnalysisReportNotFoundError):
            self.service.execute(user_id=5, report_id=10)

    def test_reporte_de_otro_usuario(self):
        self.report.user_id = 99

        with self.assertRaises(AnalysisPermissionError):
            self.service.execute(user_id=5, report_id=10)

    def test_reporte_resuelto(self):
        self.report.status = 'RESOLVED'

        with self.assertRaises(AnalysisValidationError):
            self.service.execute(user_id=5, report_id=10)

    def test_reporte_homeless(self):
        self.report.report_type = 'HOMELESS'

        with self.assertRaises(AnalysisValidationError):
            self.service.execute(user_id=5, report_id=10)

    def test_reporte_sin_fotografia(self):
        self.report.photo = ''

        with self.assertRaises(AnalysisValidationError):
            self.service.execute(user_id=5, report_id=10)

    def test_reporte_lost_valido(self):
        result = self.service.execute(user_id=5, report_id=10)

        self.assertIs(result, self.report)
        self.repository.find_by_id.assert_called_once_with(10)

    def test_reporte_found_valido(self):
        self.report.report_type = 'FOUND'

        result = self.service.execute(user_id=5, report_id=10)

        self.assertIs(result, self.report)