
from unittest import TestCase

from pydantic import ValidationError

from application.matching.visual_features_schema import (
    PetVisualFeatures,
)


class PetVisualFeaturesTests(TestCase):

    def test_acepta_caracteristicas_validas(self):
        features = PetVisualFeatures(
            species='Perro',
            primary_color='Marrón',
            secondary_color='Blanco',
            markings='Mancha blanca en el pecho',
            coat_type='Corto',
            ear_type='Caídas',
            size='Mediano',
            distinctive_features='Una oreja más oscura',
        )

        self.assertEqual(features.species, 'Perro')
        self.assertEqual(features.primary_color, 'Marrón')

    def test_rechaza_especie_vacia(self):
        with self.assertRaises(ValidationError):
            PetVisualFeatures(
                species='',
                primary_color='Negro',
            )

    def test_rechaza_color_principal_vacio(self):
        with self.assertRaises(ValidationError):
            PetVisualFeatures(
                species='Gato',
                primary_color='',
            )

    def test_rechaza_campos_desconocidos(self):
        with self.assertRaises(ValidationError):
            PetVisualFeatures(
                species='Perro',
                primary_color='Blanco',
                edad_inventada=5,
            )

    def test_rechaza_texto_demasiado_largo(self):
        with self.assertRaises(ValidationError):
            PetVisualFeatures(
                species='Perro',
                primary_color='Negro',
                markings='A' * 501,
            )

    def test_acepta_campos_opcionales_omitidos(self):
        features = PetVisualFeatures(
            species='Gato',
            primary_color='Gris',
        )

        self.assertEqual(features.secondary_color, '')
        self.assertEqual(features.markings, '')
        self.assertEqual(features.distinctive_features, '')