
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase

from infrastructure.db.lost_pet_model import LostPetReportModel
from infrastructure.db.report_visual_features_model import (
    ReportVisualFeaturesModel,
)
from infrastructure.db.visual_features_repository import (
    DjangoVisualFeaturesRepository,
)
import tempfile
from pathlib import Path
from django.test import override_settings
from application.matching.visual_features_schema import PetVisualFeatures
import hashlib
from io import BytesIO

from PIL import Image

from application.matching.image_processing import prepare_report_image
from infrastructure.db.visual_features_repository import (
    StaleReportAnalysisError,
)

class DjangoVisualFeaturesRepositoryTests(TestCase):

    @classmethod
    def setUpClass(cls):
        cls._temporary_media = tempfile.TemporaryDirectory()
        cls._media_settings = override_settings(
            MEDIA_ROOT=Path(cls._temporary_media.name)
        )
        cls._media_settings.enable()

        try:
            super().setUpClass()
        except Exception:
            cls._media_settings.disable()
            cls._temporary_media.cleanup()
            raise

    @classmethod
    def tearDownClass(cls):
        try:
            super().tearDownClass()
        finally:
            cls._media_settings.disable()
            cls._temporary_media.cleanup()

    @staticmethod
    def create_test_image(color='brown'):
        image = Image.new('RGB', (100, 100), color=color)
        output = BytesIO()
        image.save(output, format='JPEG')
        return output.getvalue()
    def setUp(self):
        self.user = get_user_model().objects.create_user(
            username='usuario_prueba',
            password='clave_de_prueba',
        )

        self.report = LostPetReportModel.objects.create(
            user=self.user,
            name='Mascota de prueba',
            photo=SimpleUploadedFile(
                'prueba.jpg',
                self.create_test_image(),
                content_type='image/jpeg',
            ),
            characteristics='Descripción de prueba',
            last_location='Ubicación de prueba',
            date_lost='2026-09-21',
            contact_info='Contacto de prueba',
            report_type=LostPetReportModel.ReportType.LOST,
        )

        self.repository = DjangoVisualFeaturesRepository()

    def test_buscar_registro_inexistente(self):
        result = self.repository.find_by_report_id(self.report.id)

        self.assertIsNone(result)

    def test_crear_registro_pendiente(self):
        features, created = self.repository.get_or_create(
            self.report.id
        )

        self.assertTrue(created)
        self.assertEqual(features.report_id, self.report.id)
        self.assertEqual(
            features.analysis_status,
            ReportVisualFeaturesModel.AnalysisStatus.PENDING,
        )

    def test_candidatos_incluyen_found_y_homeless_completados_activos(self):
        candidate_user = get_user_model().objects.create_user(
            username='candidate_user',
            password='clave_de_prueba',
        )
        included_ids = []
        for report_type in ('FOUND', 'HOMELESS'):
            report = LostPetReportModel.objects.create(
                user=candidate_user,
                name='Candidato',
                photo='lost_pets/candidato.jpg',
                characteristics='Descripción',
                last_location='Ubicación',
                date_lost='2026-09-21',
                contact_info='Contacto',
                report_type=report_type,
                status='ACTIVE',
            )
            ReportVisualFeaturesModel.objects.create(
                report=report,
                analysis_status='COMPLETED',
            )
            included_ids.append(report.id)

        excluded_report = LostPetReportModel.objects.create(
            user=candidate_user,
            name='Sin análisis',
            photo='lost_pets/sin-analisis.jpg',
            characteristics='Descripción',
            last_location='Ubicación',
            date_lost='2026-09-21',
            contact_info='Contacto',
            report_type='FOUND',
            status='ACTIVE',
        )
        ReportVisualFeaturesModel.objects.create(
            report=excluded_report,
            analysis_status='PENDING',
        )

        result_ids = {
            features.report_id
            for features in self.repository.find_active_found_reports()
        }

        self.assertEqual(result_ids, set(included_ids))

    def test_reutilizar_registro_existente(self):
        first, first_created = self.repository.get_or_create(
            self.report.id
        )

        second, second_created = self.repository.get_or_create(
            self.report.id
        )

        self.assertTrue(first_created)
        self.assertFalse(second_created)
        self.assertEqual(first.id, second.id)

        self.assertEqual(
            ReportVisualFeaturesModel.objects.filter(
                report_id=self.report.id
            ).count(),
            1,
        )

    def test_buscar_registro_existente(self):
        created_features, _ = self.repository.get_or_create(
            self.report.id
        )

        found_features = self.repository.find_by_report_id(
            self.report.id
        )

        self.assertEqual(
            found_features.id,
            created_features.id,
        )

    def test_guarda_analisis_completado(self):
        features = PetVisualFeatures(
            species='Perro',
            primary_color='Marrón',
            secondary_color='Blanco',
            markings='Mancha blanca en el pecho',
            coat_type='Corto',
            ear_type='Caídas',
            size='Mediano',
            distinctive_features='Oreja izquierda más oscura',
        )
        image_bytes = prepare_report_image(self.report)
        photo_hash = hashlib.sha256(image_bytes).hexdigest()
        saved = self.repository.save_completed(
            user_id=self.user.id,
            report_id=self.report.id,
            features=features,
            photo_hash=photo_hash,
            model_version='modelo-de-prueba-v1',
        )

        saved.refresh_from_db()

        self.assertEqual(saved.species, 'Perro')
        self.assertEqual(saved.primary_color, 'Marrón')
        self.assertEqual(saved.secondary_color, 'Blanco')
        self.assertEqual(saved.analysis_status, 'COMPLETED')
        self.assertEqual(saved.photo_hash, photo_hash)
        self.assertEqual(saved.model_version, 'modelo-de-prueba-v1')
        self.assertIsNotNone(saved.analyzed_at)

    def test_no_guarda_si_la_fotografia_cambio(self):
        original_bytes = prepare_report_image(self.report)
        original_hash = hashlib.sha256(original_bytes).hexdigest()

        self.report.photo.save(
            'fotografia_nueva.jpg',
            SimpleUploadedFile(
                'fotografia_nueva.jpg',
                self.create_test_image(color='black'),
                content_type='image/jpeg',
            ),
            save=True,
        )

        features = PetVisualFeatures(
            species='Perro',
            primary_color='Marrón',
        )

        with self.assertRaises(StaleReportAnalysisError):
            self.repository.save_completed(
                user_id=self.user.id,
                report_id=self.report.id,
                features=features,
                photo_hash=original_hash,
                model_version='modelo-de-prueba-v1',
            )

        self.assertFalse(
            ReportVisualFeaturesModel.objects.filter(
                report_id=self.report.id
            ).exists()
        )

    
    def test_no_guarda_si_el_usuario_no_es_propietario(self):
        features = PetVisualFeatures(
            species='Perro',
            primary_color='Marrón',
        )

        image_bytes = prepare_report_image(self.report)
        photo_hash = hashlib.sha256(image_bytes).hexdigest()

        with self.assertRaises(StaleReportAnalysisError):
            self.repository.save_completed(
                user_id=self.user.id + 1000,
                report_id=self.report.id,
                features=features,
                photo_hash=photo_hash,
                model_version='modelo-de-prueba-v1',
            )

        self.assertFalse(
            ReportVisualFeaturesModel.objects.filter(
                report_id=self.report.id
            ).exists()
        )

        def test_no_guarda_si_el_usuario_no_es_propietario(self):
            features = PetVisualFeatures(
                species='Perro',
                primary_color='Marrón',
            )

            image_bytes = prepare_report_image(self.report)
            photo_hash = hashlib.sha256(image_bytes).hexdigest()

            with self.assertRaises(StaleReportAnalysisError):
                self.repository.save_completed(
                    user_id=self.user.id + 1000,
                    report_id=self.report.id,
                    features=features,
                    photo_hash=photo_hash,
                    model_version='modelo-de-prueba-v1',
                )

            self.assertFalse(
                ReportVisualFeaturesModel.objects.filter(
                    report_id=self.report.id
                ).exists()
            )
