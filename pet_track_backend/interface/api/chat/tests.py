from datetime import date
from django.contrib.auth.models import User
from django.test import TestCase
from rest_framework.test import APIClient
from infrastructure.db.chat_models import ConversationModel
from infrastructure.db.lost_pet_model import LostPetReportModel


class ChatApiIntegrationTests(TestCase):
    def setUp(self):
        self.password = 'PetTrack-test-2026!'
        self.owner = User.objects.create_user('chat_owner', password=self.password)
        self.interested = User.objects.create_user('chat_interested', password=self.password)
        self.outsider = User.objects.create_user('chat_outsider', password=self.password)
        self.report = LostPetReportModel.objects.create(
            user=self.owner,
            name='Luna',
            photo='lost_pets/test.jpg',
            characteristics='Collar naranja',
            last_location='Parque',
            date_lost=date.today(),
            contact_info='70000000',
        )
        self.client = APIClient()

    def token(self, user):
        response = self.client.post(
            '/api/auth/login/',
            {'username': user.username, 'password': self.password},
            format='json',
        )
        self.assertEqual(response.status_code, 200)
        return response.data['access']

    def authenticate(self, user):
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token(user)}')

    def test_complete_participant_security_and_message_flow(self):
        self.authenticate(self.interested)
        first = self.client.post('/api/conversations/', {'report_id': self.report.id}, format='json')
        second = self.client.post('/api/conversations/', {'report_id': self.report.id}, format='json')
        self.assertEqual(first.status_code, 200)
        self.assertEqual(second.status_code, 200)
        self.assertEqual(first.data['id'], second.data['id'])
        self.assertEqual(ConversationModel.objects.count(), 1)
        conversation_id = first.data['id']

        sent = self.client.post(f'/api/conversations/{conversation_id}/messages/', {'content': '  Hola, creo que la vi  '}, format='json')
        self.assertEqual(sent.status_code, 201)
        self.assertEqual(sent.data['content'], 'Hola, creo que la vi')
        self.assertEqual(self.client.post(f'/api/conversations/{conversation_id}/messages/', {'content': '   '}, format='json').status_code, 400)

        self.authenticate(self.owner)
        self.assertEqual(self.client.post('/api/conversations/', {'report_id': self.report.id}, format='json').status_code, 400)
        owner_list = self.client.get('/api/conversations/')
        self.assertEqual(owner_list.status_code, 200)
        self.assertEqual(owner_list.data[0]['id'], conversation_id)
        read = self.client.get(f'/api/conversations/{conversation_id}/messages/')
        self.assertEqual(read.status_code, 200)
        self.assertEqual(read.data[0]['content'], 'Hola, creo que la vi')
        self.assertEqual(self.client.post(f'/api/conversations/{conversation_id}/messages/', {'content': 'Gracias'}, format='json').status_code, 201)

        self.authenticate(self.interested)
        self.assertEqual(self.client.get('/api/conversations/').data[0]['id'], conversation_id)

        self.authenticate(self.outsider)
        self.assertEqual(self.client.get('/api/conversations/').data, [])
        self.assertEqual(self.client.get(f'/api/conversations/{conversation_id}/messages/').status_code, 403)
        self.assertEqual(self.client.post(f'/api/conversations/{conversation_id}/messages/', {'content': 'intrusión'}, format='json').status_code, 403)
        self.assertEqual(self.client.get('/api/conversations/999999/messages/').status_code, 404)

        self.client.credentials()
        self.assertEqual(self.client.get('/api/conversations/').status_code, 401)

    def test_resolved_report_blocks_new_chat_but_keeps_existing_chat(self):
        self.authenticate(self.interested)
        created = self.client.post('/api/conversations/', {'report_id': self.report.id}, format='json')
        conversation_id = created.data['id']
        self.report.status = LostPetReportModel.ReportStatus.RESOLVED
        self.report.save(update_fields=['status'])
        self.assertEqual(self.client.post('/api/conversations/', {'report_id': self.report.id}, format='json').status_code, 400)
        self.assertEqual(self.client.get(f'/api/conversations/{conversation_id}/messages/').status_code, 200)

        other = User.objects.create_user('chat_other', password=self.password)
        self.authenticate(other)
        self.assertEqual(self.client.post('/api/conversations/', {'report_id': self.report.id}, format='json').status_code, 400)
