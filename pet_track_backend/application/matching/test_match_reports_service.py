import hashlib

from infrastructure.ai.pet_visual_analyzer import ANALYSIS_MODEL_VERSION
from application.matching.match_reports_service import (
    MatchReportsService,
    MatchReportNotFoundError,
    MatchPermissionError,
    has_current_analysis,
)
from types import SimpleNamespace
from unittest.mock import Mock, patch

from django.contrib.auth.models import User
from django.test import TestCase

from infrastructure.db.lost_pet_model import LostPetReportModel
from application.matching.match_reports_service import MatchReportsService


class MatchReportsServiceTests(TestCase):

    def setUp(self):
        self.owner = User.objects.create_user(
            username='owner',
            password='testpassword',
        )

        self.other_user = User.objects.create_user(
            username='other',
            password='testpassword',
        )

        self.lost_report = LostPetReportModel.objects.create(
            user=self.owner,
            name='Rocky',
            photo='lost_pets/rocky.jpg',
            characteristics='Perro marrón',
            last_location='Zona central',
            date_lost='2026-09-20',
            contact_info='Contacto de prueba',
            report_type='LOST',
            status='ACTIVE',
        )

        self.repository = Mock()
        self.service = MatchReportsService(
            features_repository=self.repository
        )
        self.analysis_patcher = patch(
            'application.matching.match_reports_service.has_current_analysis',
            side_effect=lambda report, features: (
                features is not None
                and features.analysis_status == 'COMPLETED'
            ),
        )
        self.analysis_patcher.start()
        self.addCleanup(self.analysis_patcher.stop)

    def make_features(self, report=None, **overrides):
        data = {
            'species': 'perro',
            'primary_color': 'marrón',
            'secondary_color': 'blanco',
            'markings': 'mancha en el pecho',
            'coat_type': 'corto',
            'ear_type': 'caídas',
            'size': 'mediano',
            'distinctive_features': 'cola corta',
            'analysis_status': 'COMPLETED',
            'report': report,
        }
        data.update(overrides)
        return SimpleNamespace(**data)

    def test_returns_matching_found_report(self):
        found_report = SimpleNamespace(
            id=20,
            user_id=self.other_user.id,
            name='Perro encontrado',
            report_type='FOUND',
        )

        self.repository.find_by_report_id.return_value = (
            self.make_features()
        )
        self.repository.find_active_found_reports.return_value = [
            self.make_features(report=found_report)
        ]

        result = self.service.execute(
            user_id=self.owner.id,
            report_id=self.lost_report.id,
        )

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['report_id'], 20)
        self.assertEqual(result[0]['score'], 100)

    def test_returns_matching_homeless_report(self):
        homeless_report = SimpleNamespace(
            id=23,
            user_id=self.other_user.id,
            name=None,
            report_type='HOMELESS',
        )

        self.repository.find_by_report_id.return_value = self.make_features()
        self.repository.find_active_found_reports.return_value = [
            self.make_features(report=homeless_report)
        ]

        result = self.service.execute(
            user_id=self.owner.id,
            report_id=self.lost_report.id,
        )

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['report_id'], 23)
        self.assertEqual(result[0]['report_type'], 'HOMELESS')
        self.assertEqual(result[0]['score'], 100)

    def test_returns_no_matches_without_valid_candidates(self):
        self.repository.find_by_report_id.return_value = self.make_features()
        self.repository.find_active_found_reports.return_value = []

        result = self.service.execute(
            user_id=self.owner.id,
            report_id=self.lost_report.id,
        )

        self.assertEqual(result, [])

    def test_rejects_another_users_lost_report(self):
        with self.assertRaises(MatchPermissionError):
            self.service.execute(
                user_id=self.other_user.id,
                report_id=self.lost_report.id,
            )

    def test_requires_completed_analysis(self):
        self.repository.find_by_report_id.return_value = None

        with self.assertRaises(ValueError):
            self.service.execute(
                user_id=self.owner.id,
                report_id=self.lost_report.id,
            )

    def test_excludes_same_users_reports(self):
        found_report = SimpleNamespace(
            id=21,
            user_id=self.owner.id,
            name='Otro reporte',
            report_type='FOUND',
        )

        self.repository.find_by_report_id.return_value = (
            self.make_features()
        )
        self.repository.find_active_found_reports.return_value = [
            self.make_features(report=found_report)
        ]

        result = self.service.execute(
            user_id=self.owner.id,
            report_id=self.lost_report.id,
        )

        self.assertEqual(result, [])

    def test_excludes_different_species(self):
        found_report = SimpleNamespace(
            id=22,
            user_id=self.other_user.id,
            name='Gato encontrado',
            report_type='FOUND',
        )

        self.repository.find_by_report_id.return_value = (
            self.make_features()
        )
        self.repository.find_active_found_reports.return_value = [
            self.make_features(
                report=found_report,
                species='gato',
            )
        ]

        result = self.service.execute(
            user_id=self.owner.id,
            report_id=self.lost_report.id,
        )

        self.assertEqual(result, [])

    
    def test_excludes_found_report_with_outdated_analysis(self):
        found_report = SimpleNamespace(
            id=30,
            user_id=self.other_user.id,
            name='Mascota encontrada',
            report_type='FOUND',
        )

        lost_features = self.make_features()
        found_features = self.make_features(
            report=found_report
        )

        self.repository.find_by_report_id.return_value = (
            lost_features
        )

        self.repository.find_active_found_reports.return_value = [
            found_features
        ]

        # El análisis de la mascota perdida sigue vigente,
        # pero el de la mascota encontrada está desactualizado.
        with patch(
            'application.matching.match_reports_service.has_current_analysis',
            side_effect=[True, False],
        ):
            result = self.service.execute(
                user_id=self.owner.id,
                report_id=self.lost_report.id,
            )

        self.assertEqual(result, [])

    def test_rejects_nonexistent_report(self):
        with self.assertRaises(MatchReportNotFoundError):
            self.service.execute(
                user_id=self.owner.id,
                report_id=999999,
            )


class CurrentAnalysisTests(TestCase):

    def setUp(self):
        self.report = SimpleNamespace(photo='mascota.jpg')

        self.image_bytes = b'fotografia-original'

        self.features = SimpleNamespace(
            analysis_status='COMPLETED',
            model_version=ANALYSIS_MODEL_VERSION,
            photo_hash=hashlib.sha256(
                self.image_bytes
            ).hexdigest(),
        )

    @patch(
        'application.matching.match_reports_service.prepare_report_image'
    )
    def test_accepts_current_analysis(self, mock_prepare):
        mock_prepare.return_value = self.image_bytes

        result = has_current_analysis(
            self.report,
            self.features,
        )

        self.assertTrue(result)

    @patch(
        'application.matching.match_reports_service.prepare_report_image'
    )
    def test_rejects_changed_photo(self, mock_prepare):
        mock_prepare.return_value = b'fotografia-modificada'

        result = has_current_analysis(
            self.report,
            self.features,
        )

        self.assertFalse(result)

    @patch(
        'application.matching.match_reports_service.prepare_report_image'
    )
    def test_rejects_old_model_version(self, mock_prepare):
        self.features.model_version = 'modelo-antiguo'

        result = has_current_analysis(
            self.report,
            self.features,
        )

        self.assertFalse(result)
        mock_prepare.assert_not_called()

    @patch(
        'application.matching.match_reports_service.prepare_report_image'
    )
    def test_rejects_incomplete_analysis(self, mock_prepare):
        self.features.analysis_status = 'FAILED'

        result = has_current_analysis(
            self.report,
            self.features,
        )

        self.assertFalse(result)
        mock_prepare.assert_not_called()

    def test_rejects_missing_features(self):
        result = has_current_analysis(
            self.report,
            None,
        )

        self.assertFalse(result)
