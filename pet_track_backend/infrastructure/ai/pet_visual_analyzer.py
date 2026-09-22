from google.genai import errors
from google.genai import types
from pydantic import ValidationError

from application.matching.visual_features_schema import PetVisualFeatures
from infrastructure.ai.gemini_client import GeminiClient


GEMINI_MODEL = 'gemini-3.6-flash'
ANALYSIS_MODEL_VERSION = f'{GEMINI_MODEL}-pet-visual-v1'

ANALYSIS_PROMPT = """
Analiza únicamente la fotografía de esta mascota.

Describe solo las características físicas que puedas observar.
No inventes información ni deduzcas datos que no sean visibles.

Reglas:
- species: especie del animal, por ejemplo, perro o gato.
- primary_color: color principal del pelaje.
- secondary_color: segundo color visible, si existe.
- markings: manchas, patrones o distribución de colores.
- coat_type: tipo de pelaje visible.
- ear_type: forma visible de las orejas.
- size: tamaño aparente, solo si puede estimarse.
- distinctive_features: rasgos físicos distintivos visibles.

Si un campo opcional no puede determinarse, utiliza una cadena vacía.
No incluyas nombres, ubicaciones, propietarios ni datos de contacto.
Responde únicamente con los campos del esquema solicitado.
"""


class GeminiAnalysisError(Exception):
    pass


class PetVisualAnalyzer:
    def __init__(self, gemini_client=None):
        self.gemini_client = (
            gemini_client
            if gemini_client is not None
            else GeminiClient()
        )

    def analyze(self, image_bytes: bytes) -> PetVisualFeatures:
        if not image_bytes:
            raise GeminiAnalysisError(
                'No se recibió una fotografía para analizar.'
            )

        client = self.gemini_client.create_client()

        try:
            response = client.models.generate_content(
                model=GEMINI_MODEL,
                contents=[
                    ANALYSIS_PROMPT,
                    types.Part.from_bytes(
                        data=image_bytes,
                        mime_type='image/jpeg',
                    ),
                ],
                config=types.GenerateContentConfig(
                    response_mime_type='application/json',
                    response_schema={
                        'type': 'OBJECT',
                        'properties': {
                            'species': {'type': 'STRING'},
                            'primary_color': {'type': 'STRING'},
                            'secondary_color': {'type': 'STRING'},
                            'markings': {'type': 'STRING'},
                            'coat_type': {'type': 'STRING'},
                            'ear_type': {'type': 'STRING'},
                            'size': {'type': 'STRING'},
                            'distinctive_features': {'type': 'STRING'},
                        },
                        'required': [
                            'species',
                            'primary_color',
                        ],
                    },
                    temperature=0,
                ),
            )

            if not response.text:
                raise GeminiAnalysisError(
                    'Gemini no devolvió características visuales.'
                )

            return PetVisualFeatures.model_validate_json(
                response.text
            )

        except (ValidationError, ValueError) as exc:
            raise GeminiAnalysisError(
                'La respuesta de Gemini no tiene un formato válido.'
            ) from exc
        except errors.APIError as exc:
            import logging

            logger = logging.getLogger(__name__)
            logger.exception(
                'Error de la API de Gemini. Código HTTP: %s',
                getattr(exc, 'code', 'desconocido'),
            )

            raise GeminiAnalysisError(
                'No se pudo completar el análisis con Gemini.'
            ) from exc