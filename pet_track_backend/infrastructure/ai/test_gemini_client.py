
from unittest import TestCase
from unittest.mock import Mock

from infrastructure.ai.gemini_client import (
    GeminiClient,
    GeminiConfigurationError,
)


class GeminiClientTests(TestCase):

    def test_rechaza_clave_vacia(self):
        client_factory = Mock()

        gemini = GeminiClient(
            api_key='',
            client_factory=client_factory,
        )

        with self.assertRaises(GeminiConfigurationError):
            gemini.create_client()

        client_factory.assert_not_called()

    def test_crea_cliente_con_clave_configurada(self):
        client_factory = Mock()
        fake_client = object()
        client_factory.return_value = fake_client

        gemini = GeminiClient(
            api_key='clave_ficticia',
            client_factory=client_factory,
        )

        result = gemini.create_client()

        client_factory.assert_called_once_with(
            api_key='clave_ficticia'
        )
        self.assertIs(result, fake_client)