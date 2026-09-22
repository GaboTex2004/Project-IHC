
from django.conf import settings
from google import genai


class GeminiConfigurationError(Exception):
    pass


class GeminiClient:
    def __init__(self, api_key=None, client_factory=None):
        self.api_key = (
            api_key
            if api_key is not None
            else settings.GEMINI_API_KEY
        )
        self.client_factory = (
            client_factory
            if client_factory is not None
            else genai.Client
        )

    def create_client(self):
        if not self.api_key:
            raise GeminiConfigurationError(
                'La clave de Gemini no está configurada.'
            )

        return self.client_factory(api_key=self.api_key)