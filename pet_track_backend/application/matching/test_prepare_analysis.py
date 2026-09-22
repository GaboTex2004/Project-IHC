import hashlib
from types import SimpleNamespace
from unittest import TestCase
from unittest.mock import Mock

from application.matching.services import (
    AnalysisPermissionError,
    AnalysisValidationError,
    ANALYSIS_MODEL_VERSION,
    PrepareReportAnalysisService,
    ValidateReportForAnalysisService,
)


class ValidateReportForAnalysisServiceTests(TestCase):

    def setUp(self):
        self.repository = Mock()
        self.service = ValidateReportForAnalysisService(self.repository)

    def report(self, report_type='LOST', status='ACTIVE', user_id=5):
        return SimpleNamespace(
            id=10,
            user_id=user_id,
            status=status,
            report_type=report_type,
            photo='foto.jpg',
        )

    def test_acepta_lost_found_y_homeless_activos(self):
        for report_type in ('LOST', 'FOUND', 'HOMELESS'):
            with self.subTest(report_type=report_type):
                report = self.report(report_type=report_type)
                self.repository.find_by_id.return_value = report

                self.assertIs(
                    self.service.execute(user_id=5, report_id=10),
                    report,
                )

    def test_rechaza_reporte_inactivo(self):
        self.repository.find_by_id.return_value = self.report(
            status='RESOLVED'
        )

        with self.assertRaises(AnalysisValidationError):
            self.service.execute(user_id=5, report_id=10)

    def test_rechaza_reporte_ajeno(self):
        self.repository.find_by_id.return_value = self.report(user_id=99)

        with self.assertRaises(AnalysisPermissionError):
            self.service.execute(user_id=5, report_id=10)


class PrepareReportAnalysisServiceTests(TestCase):

    def setUp(self):
        self.validation = Mock()
        self.reports = Mock()
        self.features = Mock()
        self.image_processor = Mock()

        self.report = SimpleNamespace(id=10)
        self.report_model = SimpleNamespace(
            id=10,
            user_id=5,
            status='ACTIVE',
            report_type='LOST',
            photo='foto_de_prueba.jpg',
        )

        self.validation.execute.return_value = self.report
        self.reports.find_model_by_id.return_value = self.report_model
        self.image_processor.return_value = b'jpeg_de_prueba'
        self.features.find_by_report_id.return_value = None

        self.service = PrepareReportAnalysisService(
            validation_service=self.validation,
            report_repository=self.reports,
            features_repository=self.features,
            image_processor=self.image_processor,
        )

    def test_sin_permiso_no_accede_a_la_fotografia(self):
        self.validation.execute.side_effect = AnalysisPermissionError(
            'No tienes permiso.'
        )

        with self.assertRaises(AnalysisPermissionError):
            self.service.execute(user_id=5, report_id=10)

        self.reports.find_model_by_id.assert_not_called()
        self.image_processor.assert_not_called()
        self.features.find_by_report_id.assert_not_called()

    def test_prepara_reporte_valido(self):
        result = self.service.execute(user_id=5, report_id=10)

        self.validation.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )
        self.reports.find_model_by_id.assert_called_once_with(10)
        self.image_processor.assert_called_once_with(
            self.report_model
        )
        self.features.find_by_report_id.assert_called_once_with(10)

        self.assertEqual(result['report_id'], 10)
        self.assertEqual(result['image_bytes'], b'jpeg_de_prueba')
        self.assertIsNone(result['existing_features'])

    def test_propietario_cambia_antes_de_abrir_imagen(self):
        self.report_model.user_id = 99

        with self.assertRaises(AnalysisPermissionError):
            self.service.execute(user_id=5, report_id=10)

        self.image_processor.assert_not_called()
        self.features.find_by_report_id.assert_not_called()

    def test_reporte_se_resuelve_antes_de_abrir_imagen(self):
        self.report_model.status = 'RESOLVED'

        with self.assertRaises(AnalysisValidationError):
            self.service.execute(user_id=5, report_id=10)

        self.image_processor.assert_not_called()
        self.features.find_by_report_id.assert_not_called()

    def test_prepara_reporte_homeless(self):
        self.report_model.report_type = 'HOMELESS'

        result = self.service.execute(user_id=5, report_id=10)

        self.assertEqual(result['report_id'], 10)
        self.image_processor.assert_called_once_with(self.report_model)
        self.features.find_by_report_id.assert_called_once_with(10)

    def test_fotografia_se_elimina_antes_de_abrir_imagen(self):
        self.report_model.photo = ''

        with self.assertRaises(AnalysisValidationError):
            self.service.execute(user_id=5, report_id=10)

        self.image_processor.assert_not_called()
        self.features.find_by_report_id.assert_not_called()

    def test_calcula_hash_de_imagen_preparada(self):
        result = self.service.execute(user_id=5, report_id=10)

        expected_hash = hashlib.sha256(
            b'jpeg_de_prueba'
        ).hexdigest()

        self.assertEqual(result['photo_hash'], expected_hash)
        self.assertEqual(len(result['photo_hash']), 64)

    def test_reutiliza_analisis_completado_y_actual(self):
        import hashlib

        photo_hash = hashlib.sha256(b'jpeg_de_prueba').hexdigest()

        self.features.find_by_report_id.return_value = SimpleNamespace(
            analysis_status='COMPLETED',
            photo_hash=photo_hash,
            model_version=ANALYSIS_MODEL_VERSION,
        )

        result = self.service.execute(user_id=5, report_id=10)

        self.assertTrue(result['can_reuse_analysis'])

    def test_no_reutiliza_analisis_pendiente(self):
        self.features.find_by_report_id.return_value = SimpleNamespace(
            analysis_status='PENDING',
            photo_hash='',
            model_version='',
        )

        result = self.service.execute(user_id=5, report_id=10)

        self.assertFalse(result['can_reuse_analysis'])

    def test_no_reutiliza_si_cambio_la_fotografia(self):
        self.features.find_by_report_id.return_value = SimpleNamespace(
            analysis_status='COMPLETED',
            photo_hash='hash_anterior',
            model_version=ANALYSIS_MODEL_VERSION,
        )

        result = self.service.execute(user_id=5, report_id=10)

        self.assertFalse(result['can_reuse_analysis'])

    def test_no_reutiliza_si_cambio_el_modelo(self):
        import hashlib

        photo_hash = hashlib.sha256(b'jpeg_de_prueba').hexdigest()

        self.features.find_by_report_id.return_value = SimpleNamespace(
            analysis_status='COMPLETED',
            photo_hash=photo_hash,
            model_version='modelo_anterior',
        )

        result = self.service.execute(user_id=5, report_id=10)

        self.assertFalse(result['can_reuse_analysis'])
