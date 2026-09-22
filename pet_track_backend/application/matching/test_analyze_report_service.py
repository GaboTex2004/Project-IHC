
from types import SimpleNamespace
from unittest import TestCase
from unittest.mock import Mock

from application.matching.services import (
    AnalyzeReportVisualFeaturesService,
)


class AnalyzeReportVisualFeaturesServiceTests(TestCase):

    def setUp(self):
        self.preparation = Mock()
        self.analyzer = Mock()
        self.features_repository = Mock()

        self.existing_features = SimpleNamespace(
            species='Perro',
            primary_color='Marrón',
        )

        self.preparation.execute.return_value = {
            'report_id': 10,
            'image_bytes': b'jpeg_de_prueba',
            'photo_hash': 'hash_de_prueba',
            'model_version': 'modelo_de_prueba',
            'existing_features': self.existing_features,
            'can_reuse_analysis': True,
        }

        self.service = AnalyzeReportVisualFeaturesService(
            preparation_service=self.preparation,
            analyzer=self.analyzer,
            features_repository=self.features_repository,
        )

    def test_reutiliza_analisis_sin_llamar_a_gemini(self):
        result = self.service.execute(
            user_id=5,
            report_id=10,
        )
        self.features_repository.save_completed.assert_not_called()
        self.preparation.execute.assert_called_once_with(
            user_id=5,
            report_id=10,
        )
        self.analyzer.analyze.assert_not_called()

        self.assertTrue(result['reused'])
        self.assertIs(
            result['features'],
            self.existing_features,
        )
        self.assertEqual(result['report_id'], 10)

    
    def test_analiza_fotografia_si_no_puede_reutilizar(self):
        self.preparation.execute.return_value[
            'can_reuse_analysis'
        ] = False

        new_features = SimpleNamespace(
            species='Gato',
            primary_color='Negro',
        )

        self.analyzer.analyze.return_value = new_features

        saved_features = SimpleNamespace(
            id=20,
            species='Gato',
            primary_color='Negro',
        )

        self.features_repository.save_completed.return_value = saved_features

        result = self.service.execute(
            user_id=5,
            report_id=10,
        )

        self.analyzer.analyze.assert_called_once_with(
            b'jpeg_de_prueba'
        )

        self.features_repository.save_completed.assert_called_once_with(
            user_id=5,
            report_id=10,
            features=new_features,
            photo_hash='hash_de_prueba',
            model_version='modelo_de_prueba',
        )

        self.assertFalse(result['reused'])
        self.assertIs(result['features'], saved_features)

        self.assertEqual(
            result['photo_hash'],
            'hash_de_prueba',
        )

        self.assertEqual(
            result['model_version'],
            'modelo_de_prueba',
        )

    def test_propaga_error_si_falla_el_guardado(self):
        self.preparation.execute.return_value[
            'can_reuse_analysis'
        ] = False

        new_features = SimpleNamespace(
            species='Gato',
            primary_color='Negro',
        )

        self.analyzer.analyze.return_value = new_features

        self.features_repository.save_completed.side_effect = RuntimeError(
            'No se pudo guardar el análisis'
        )

        with self.assertRaises(RuntimeError):
            self.service.execute(
                user_id=5,
                report_id=10,
            )

        self.analyzer.analyze.assert_called_once_with(
            b'jpeg_de_prueba'
        )

        self.features_repository.save_completed.assert_called_once()