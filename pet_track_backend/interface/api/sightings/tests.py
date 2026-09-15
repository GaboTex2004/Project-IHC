from datetime import date
from io import BytesIO
from tempfile import TemporaryDirectory
from django.contrib.auth.models import User
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings
from django.utils import timezone
from PIL import Image
from rest_framework.test import APIClient
from infrastructure.db.lost_pet_model import LostPetReportModel
from infrastructure.db.sighting_model import SightingModel


class SightingApiTests(TestCase):
    def setUp(self):
        self.owner = User.objects.create_user('sighting_owner', password='SightingTest2026!')
        self.reporter = User.objects.create_user('sighting_reporter', password='SightingTest2026!')
        self.third = User.objects.create_user('sighting_third', password='SightingTest2026!')
        self.report = self.make_report('LOST')
        self.client = APIClient()
        self.payload = {
            'report_id': self.report.id,
            'latitude': '-17.783333',
            'longitude': '-63.183333',
            'location_description': 'Cerca del parque',
            'sighting_datetime': timezone.now().isoformat(),
            'description': 'Vi una mascota con el mismo collar',
        }

    def make_report(self, report_type):
        return LostPetReportModel.objects.create(
            user=self.owner, name='Luna', photo='lost_pets/test.jpg',
            characteristics='Collar naranja', last_location='Parque',
            date_lost=date.today(), contact_info='70000000',
            report_type=report_type,
        )

    def auth(self, user):
        response = self.client.post('/api/auth/login/', {
            'username': user.username, 'password': 'SightingTest2026!',
        }, format='json')
        self.assertEqual(response.status_code, 200)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")

    def test_create_privacy_and_owner_list(self):
        self.auth(self.reporter)
        result = self.client.post('/api/sightings/', self.payload, format='json')
        self.assertEqual(result.status_code, 201)
        sighting_id = result.data['id']
        self.assertEqual(result.data['reporter_id'], self.reporter.id)
        self.assertEqual(str(SightingModel.objects.get(id=sighting_id).latitude), '-17.783333')
        self.assertEqual(self.client.get(f'/api/sightings/{sighting_id}/').status_code, 200)
        self.assertEqual(self.client.get(f'/api/reports/{self.report.id}/sightings/').status_code, 403)

        self.auth(self.third)
        self.assertEqual(self.client.get(f'/api/sightings/{sighting_id}/').status_code, 403)
        self.assertEqual(self.client.get(f'/api/reports/{self.report.id}/sightings/').status_code, 403)
        self.auth(self.owner)
        listing = self.client.get(f'/api/reports/{self.report.id}/sightings/')
        self.assertEqual(listing.status_code, 200)
        self.assertEqual(listing.data[0]['id'], sighting_id)
        self.assertEqual(self.client.get(f'/api/sightings/{sighting_id}/').status_code, 200)

    def test_business_rules_and_coordinate_validation(self):
        self.auth(self.owner)
        self.assertEqual(self.client.post('/api/sightings/', self.payload, format='json').status_code, 400)
        self.auth(self.reporter)
        for report_type in ('FOUND', 'HOMELESS'):
            other = self.make_report(report_type)
            self.assertEqual(self.client.post('/api/sightings/', {
                **self.payload, 'report_id': other.id,
            }, format='json').status_code, 400)
        self.report.status = 'RESOLVED'
        self.report.save(update_fields=['status'])
        self.assertEqual(self.client.post('/api/sightings/', self.payload, format='json').status_code, 400)
        self.report.status = 'ACTIVE'
        self.report.save(update_fields=['status'])
        for field, value in [('latitude', '90.000001'), ('latitude', '-90.000001'),
                             ('longitude', '180.000001'), ('longitude', '-180.000001')]:
            self.assertEqual(self.client.post('/api/sightings/', {
                **self.payload, field: value,
            }, format='json').status_code, 400)
        self.assertEqual(self.client.post('/api/sightings/', {
            **self.payload, 'report_id': 999999,
        }, format='json').status_code, 404)
        self.assertEqual(SightingModel.objects.count(), 0)

    def test_jwt_required_for_all_sighting_endpoints(self):
        self.assertEqual(self.client.post('/api/sightings/', self.payload, format='json').status_code, 401)
        self.assertEqual(self.client.get(f'/api/reports/{self.report.id}/sightings/').status_code, 401)
        self.assertEqual(self.client.get('/api/sightings/999999/').status_code, 401)

    def test_optional_photo_upload_removes_original_exif(self):
        temporary_media = TemporaryDirectory()
        self.addCleanup(temporary_media.cleanup)
        media_override = override_settings(MEDIA_ROOT=temporary_media.name)
        media_override.enable()
        self.addCleanup(media_override.disable)

        image = Image.new('RGB', (8, 8), 'orange')
        original_exif = Image.Exif()
        original_exif[315] = 'original metadata'
        bytes_io = BytesIO()
        image.save(bytes_io, format='JPEG', exif=original_exif)
        photo = SimpleUploadedFile('proof.jpg', bytes_io.getvalue(), content_type='image/jpeg')
        self.auth(self.reporter)
        response = self.client.post('/api/sightings/', {**self.payload, 'photo': photo}, format='multipart')
        self.assertEqual(response.status_code, 201)
        saved = SightingModel.objects.get(id=response.data['id'])
        with Image.open(saved.photo.path) as stored_photo:
            self.assertNotIn(315, stored_photo.getexif())
