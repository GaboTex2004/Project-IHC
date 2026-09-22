from google.genai import errors
from types import SimpleNamespace
from unittest import TestCase
from unittest.mock import Mock

from infrastructure.ai.pet_visual_analyzer import (
    GeminiAnalysisError,
    PetVisualAnalyzer,
)


class PetVisualAnalyzerTests(TestCase):

    def setUp(self):
        self.client = Mock()
        self.gemini_client = Mock()
        self.gemini_client.create_client.return_value = self.client

        self.analyzer = PetVisualAnalyzer(
            gemini_client=self.gemini_client
        )

    def test_acepta_respuesta_valida(self):
        self.client.models.generate_content.return_value = (
            SimpleNamespace(
                text=(
                    '{"species":"Perro",'
                    '"primary_color":"Marrón",'
                    '"secondary_color":"Blanco"}'
                )
            )
        )

        result = self.analyzer.analyze(b'jpeg_de_prueba')

        self.assertEqual(result.species, 'Perro')
        self.assertEqual(result.primary_color, 'Marrón')
        self.assertEqual(result.secondary_color, 'Blanco')

        self.client.models.generate_content.assert_called_once()

    def test_rechaza_imagen_vacia(self):
        with self.assertRaises(GeminiAnalysisError):
            self.analyzer.analyze(b'')

        self.gemini_client.create_client.assert_not_called()

    def test_rechaza_respuesta_vacia(self):
        self.client.models.generate_content.return_value = (
            SimpleNamespace(text='')
        )

        with self.assertRaises(GeminiAnalysisError):
            self.analyzer.analyze(b'jpeg_de_prueba')

    def test_rechaza_json_invalido(self):
        self.client.models.generate_content.return_value = (
            SimpleNamespace(text='esto no es JSON')
        )

        with self.assertRaises(GeminiAnalysisError):
            self.analyzer.analyze(b'jpeg_de_prueba')

    def test_rechaza_caracteristicas_incompletas(self):
        self.client.models.generate_content.return_value = (
            SimpleNamespace(
                text='{"species":"Perro"}'
            )
        )

        with self.assertRaises(GeminiAnalysisError):
            self.analyzer.analyze(b'jpeg_de_prueba')

    def test_controla_error_de_api(self):
        self.client.models.generate_content.side_effect = (
            errors.APIError(
                code=503,
                response_json={
                    'error': {
                        'message': 'Servicio temporalmente no disponible'
                    }
                },
            )
        )

        with self.assertRaisesRegex(
            GeminiAnalysisError,
            'No se pudo completar el análisis con Gemini.',
        ):
            self.analyzer.analyze(b'jpeg_de_prueba')