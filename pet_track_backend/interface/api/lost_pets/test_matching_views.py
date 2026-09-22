
from unittest.mock import patch

from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework.test import APITestCase
from application.matching.match_reports_service import (
    MatchPermissionError,
    MatchReportNotFoundError,
)

class ReportMatchesViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            username='matching_user',
            password='testpassword',
        )

        self.url = reverse(
            'report-matches',
            kwargs={'report_id': 1},
        )

    def test_requires_authentication(self):
        response = self.client.get(self.url)

        self.assertIn(response.status_code, [401, 403])

    @patch(
        'interface.api.lost_pets.matching_views.MatchReportsService.execute'
    )
    def test_returns_matches(self, mock_execute):
        self.client.force_authenticate(user=self.user)

        mock_execute.return_value = [
            {
                'report_id': 20,
                'name': 'Mascota encontrada',
                'score': 85,
                'report_type': 'FOUND',
            }
        ]

        response = self.client.get(self.url)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['report_id'], 1)
        self.assertEqual(response.data['total_matches'], 1)
        self.assertEqual(len(response.data['matches']), 1)

        mock_execute.assert_called_once_with(
            user_id=self.user.id,
            report_id=1,
        )

    @patch(
        'interface.api.lost_pets.matching_views.MatchReportsService.execute'
    )
    def test_returns_empty_results(self, mock_execute):
        self.client.force_authenticate(user=self.user)

        mock_execute.return_value = []

        response = self.client.get(self.url)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['total_matches'], 0)
        self.assertEqual(response.data['matches'], [])

    @patch(
        'interface.api.lost_pets.matching_views.MatchReportsService.execute'
    )
    def test_returns_validation_error(self, mock_execute):
        self.client.force_authenticate(user=self.user)

        mock_execute.side_effect = ValueError(
            'Primero debes analizar la fotografía de tu mascota.'
        )

        response = self.client.get(self.url)

        self.assertEqual(response.status_code, 400)
        self.assertIn('error', response.data)

    
    @patch(
        'interface.api.lost_pets.matching_views.MatchReportsService.execute'
    )
    def test_returns_403_for_another_users_report(self, mock_execute):
        self.client.force_authenticate(user=self.user)

        mock_execute.side_effect = MatchPermissionError(
            'No tienes permiso para consultar este reporte.'
        )

        response = self.client.get(self.url)

        self.assertEqual(response.status_code, 403)
        self.assertIn('error', response.data)

        mock_execute.assert_called_once_with(
            user_id=self.user.id,
            report_id=1,
        )

    @patch(
        'interface.api.lost_pets.matching_views.MatchReportsService.execute'
    )
    def test_returns_404_for_nonexistent_report(self, mock_execute):
        self.client.force_authenticate(user=self.user)

        mock_execute.side_effect = MatchReportNotFoundError(
            'El reporte no existe.'
        )

        response = self.client.get(self.url)

        self.assertEqual(response.status_code, 404)
        self.assertIn('error', response.data)

        mock_execute.assert_called_once_with(
            user_id=self.user.id,
            report_id=1,
        )