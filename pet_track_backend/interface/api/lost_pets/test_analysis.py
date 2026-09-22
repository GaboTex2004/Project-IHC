
from types import SimpleNamespace
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import SimpleTestCase
from django.urls import reverse

from rest_framework.test import APIClient

from application.matching.services import (
    AnalysisPermissionError,
    AnalysisReportNotFoundError,
    AnalysisValidationError,
)
from application.matching.image_processing import InvalidReportImageError
from infrastructure.db.visual_features_repository import (
    StaleReportAnalysisError,
)
from infrastructure.ai.pet_visual_analyzer import GeminiAnalysisError
from infrastructure.ai.gemini_client import GeminiConfigurationError

class AnalyzeReportEndpointTests(SimpleTestCase):

    def setUp(self):
        self.client = APIClient()
        self.url = reverse(
            'analyze-report',
            kwargs={'report_id': 10},
        )

    def test_sin_autenticacion(self):
        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 401)

    @patch(
        'interface.api.lost_pets.analysis_views.'
        'AnalyzeReportView.get_analysis_service'
    )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_reporte_valido(
        self,
        service_class,
        get_analysis_service,
    ):
        user = get_user_model()(
            id=5,
            username='usuario_prueba',
        )
        self.client.force_authenticate(user=user)

        service_class.return_value.execute.return_value = (
            SimpleNamespace(id=10)
        )

        get_analysis_service.return_value.execute.return_value = {
            'report_id': 10,
            'features': SimpleNamespace(
                species='Perro',
                primary_color='Marrón',
                secondary_color='',
                markings='',
                coat_type='',
                ear_type='',
                size='',
                distinctive_features='',
            ),
            'reused': False,
        }

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['report_id'], 10)
        self.assertEqual(response.data['status'], 'COMPLETED')

        service_class.return_value.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )

        get_analysis_service.return_value.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )

    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_reporte_de_otro_usuario(self, service_class):
        user = get_user_model()(id=5, username='usuario_prueba')
        self.client.force_authenticate(user=user)

        service_class.return_value.execute.side_effect = (
            AnalysisPermissionError()
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 403)

    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_reporte_inexistente(self, service_class):
        user = get_user_model()(id=5, username='usuario_prueba')
        self.client.force_authenticate(user=user)

        service_class.return_value.execute.side_effect = (
            AnalysisReportNotFoundError()
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 404)

    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_reporte_no_valido(self, service_class):
        user = get_user_model()(id=5, username='usuario_prueba')
        self.client.force_authenticate(user=user)

        service_class.return_value.execute.side_effect = (
            AnalysisValidationError('Solo reportes activos.')
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 400)

    
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'AnalyzeReportView.get_analysis_service'
    )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_devuelve_analisis_completado(
        self,
        validation_class,
        get_analysis_service,
    ):
        user = get_user_model()(
            id=5,
            username='usuario_prueba',
        )
        self.client.force_authenticate(user=user)

        validation_class.return_value.execute.return_value = (
            SimpleNamespace(id=10)
        )

        saved_features = SimpleNamespace(
            species='Perro',
            primary_color='Marrón',
            secondary_color='Blanco',
            markings='Mancha blanca en el pecho',
            coat_type='Corto',
            ear_type='Caídas',
            size='Mediano',
            distinctive_features='',
        )

        analysis_service = get_analysis_service.return_value
        analysis_service.execute.return_value = {
            'report_id': 10,
            'features': saved_features,
            'photo_hash': 'hash_de_prueba',
            'model_version': 'modelo_de_prueba',
            'reused': False,
        }

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['report_id'], 10)
        self.assertEqual(response.data['status'], 'COMPLETED')
        self.assertFalse(response.data['reused'])
        self.assertEqual(
            response.data['features']['species'],
            'Perro',
        )
        self.assertEqual(
            response.data['features']['primary_color'],
            'Marrón',
        )

        analysis_service.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'AnalyzeReportView.get_analysis_service'
    )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_fotografia_invalida(
        self,
        validation_class,
        get_analysis_service,
    ):
        user = get_user_model()(
            id=5,
            username='usuario_prueba',
        )
        self.client.force_authenticate(user=user)

        validation_class.return_value.execute.return_value = (
            SimpleNamespace(id=10)
        )

        analysis_service = get_analysis_service.return_value
        analysis_service.execute.side_effect = InvalidReportImageError(
            'Imagen inválida.'
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 400)
        self.assertEqual(
            response.data['error'],
            'La fotografía no se puede procesar.',
        )

        analysis_service.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'AnalyzeReportView.get_analysis_service'
    )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_reporte_cambia_durante_analisis(
        self,
        validation_class,
        get_analysis_service,
    ):
        user = get_user_model()(
            id=5,
            username='usuario_prueba',
        )
        self.client.force_authenticate(user=user)

        validation_class.return_value.execute.return_value = (
            SimpleNamespace(id=10)
        )

        analysis_service = get_analysis_service.return_value
        analysis_service.execute.side_effect = StaleReportAnalysisError(
            'La fotografía cambió.'
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 409)
        self.assertEqual(
            response.data['error'],
            'El reporte cambió durante el análisis. Inténtalo nuevamente.',
        )

        analysis_service.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )

    @patch(
        'interface.api.lost_pets.analysis_views.'
        'AnalyzeReportView.get_analysis_service'
    )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_error_de_gemini(
        self,
        validation_class,
        get_analysis_service,
    ):
        user = get_user_model()(
            id=5,
            username='usuario_prueba',
        )
        self.client.force_authenticate(user=user)

        validation_class.return_value.execute.return_value = (
            SimpleNamespace(id=10)
        )

        analysis_service = get_analysis_service.return_value
        analysis_service.execute.side_effect = GeminiAnalysisError(
            'Error interno del proveedor.'
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 503)
        self.assertEqual(
            response.data['error'],
            'El servicio de análisis no está disponible en este momento.',
        )

        analysis_service.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'AnalyzeReportView.get_analysis_service'
    )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_gemini_sin_configurar(
        self,
        validation_class,
        get_analysis_service,
    ):
        user = get_user_model()(
            id=5,
            username='usuario_prueba',
        )
        self.client.force_authenticate(user=user)

        validation_class.return_value.execute.return_value = (
            SimpleNamespace(id=10)
        )

        analysis_service = get_analysis_service.return_value
        analysis_service.execute.side_effect = GeminiConfigurationError(
            'Clave de Gemini no configurada.'
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 503)
        self.assertEqual(
            response.data['error'],
            'El servicio de análisis no está disponible en este momento.',
        )

        analysis_service.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'AnalyzeReportView.get_analysis_service'
    )
    @patch(
        'interface.api.lost_pets.analysis_views.'
        'ValidateReportForAnalysisService'
    )
    def test_reporte_eliminado_durante_analisis(
        self,
        validation_class,
        get_analysis_service,
    ):
        user = get_user_model()(
            id=5,
            username='usuario_prueba',
        )
        self.client.force_authenticate(user=user)

        # La primera validación es exitosa.
        validation_class.return_value.execute.return_value = (
            SimpleNamespace(id=10)
        )

        # La segunda validación detecta que el reporte ya no existe.
        analysis_service = get_analysis_service.return_value
        analysis_service.execute.side_effect = AnalysisReportNotFoundError(
            'El reporte ya no existe.'
        )

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 404)
        self.assertEqual(
            response.data['error'],
            'El reporte no existe.',
        )

        analysis_service.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )