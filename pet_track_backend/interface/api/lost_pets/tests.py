from io import BytesIO
from tempfile import TemporaryDirectory

from django.contrib.auth.models import User
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings
from PIL import Image
from rest_framework.test import APIClient

from infrastructure.db.lost_pet_model import LostPetReportModel


class ReportTypeCreationTests(TestCase):
    def setUp(self):
        self.media_directory = TemporaryDirectory()
        self.addCleanup(self.media_directory.cleanup)
        media_settings = override_settings(MEDIA_ROOT=self.media_directory.name)
        media_settings.enable()
        self.addCleanup(media_settings.disable)

        user = User.objects.create_user('report_type_test_user', password='TestOnly2026!')
        self.client = APIClient()
        self.client.force_authenticate(user=user)

    @staticmethod
    def photo():
        buffer = BytesIO()
        Image.new('RGB', (8, 8), 'orange').save(buffer, format='JPEG')
        return SimpleUploadedFile('pet.jpg', buffer.getvalue(), content_type='image/jpeg')

    def test_all_report_types_are_persisted_and_new_lost_is_active(self):
        for report_type in ('LOST', 'FOUND', 'HOMELESS'):
            with self.subTest(report_type=report_type):
                response = self.client.post('/api/reports/create/', {
                    'name': '' if report_type == 'HOMELESS' else 'Max',
                    'photo': self.photo(),
                    'characteristics': 'Collar rojo',
                    'last_location': 'Parque',
                    'date_lost': '2026-09-15',
                    'contact_info': '70000000',
                    'report_type': report_type,
                }, format='multipart')
                self.assertEqual(response.status_code, 201, response.data)
                self.assertEqual(response.data['report_type'], report_type)
                self.assertEqual(response.data['status'], 'ACTIVE')

                saved = LostPetReportModel.objects.get(id=response.data['id'])
                self.assertEqual(saved.report_type, report_type)
                self.assertEqual(saved.status, 'ACTIVE')
