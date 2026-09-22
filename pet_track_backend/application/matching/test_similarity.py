
from types import SimpleNamespace
from django.test import SimpleTestCase

from application.matching.similarity import calculate_similarity


class SimilarityTests(SimpleTestCase):

    def make_features(self, **overrides):
        data = {
            'species': 'perro',
            'primary_color': 'marrón',
            'secondary_color': 'blanco',
            'markings': 'mancha en el pecho',
            'coat_type': 'corto',
            'ear_type': 'caídas',
            'size': 'mediano',
            'distinctive_features': 'cola corta',
        }
        data.update(overrides)
        return SimpleNamespace(**data)

    def test_identical_features(self):
        lost = self.make_features()
        found = self.make_features()

        self.assertEqual(
            calculate_similarity(lost, found),
            100,
        )

    def test_different_species(self):
        lost = self.make_features(species='perro')
        found = self.make_features(species='gato')

        self.assertEqual(
            calculate_similarity(lost, found),
            0,
        )

    def test_normalizes_accents_and_capitalization(self):
        lost = self.make_features(primary_color='MARRÓN')
        found = self.make_features(primary_color='marron')

        self.assertEqual(
            calculate_similarity(lost, found),
            100,
        )

    def test_different_primary_color(self):
        lost = self.make_features(primary_color='marrón')
        found = self.make_features(primary_color='negro')

        self.assertEqual(
            calculate_similarity(lost, found),
            70,
        )

    def test_missing_optional_features(self):
        lost = self.make_features(
            secondary_color='',
            markings='',
            coat_type='',
            ear_type='',
            size='',
            distinctive_features='',
        )
        found = self.make_features()

        self.assertEqual(
            calculate_similarity(lost, found),
            30,
        )

    def test_missing_species(self):
        lost = self.make_features(species='')
        found = self.make_features()

        self.assertEqual(
            calculate_similarity(lost, found),
            0,
        )

    def test_no_comparable_characteristics(self):
        lost = self.make_features(
            primary_color='',
            secondary_color='',
            markings='',
            coat_type='',
            ear_type='',
            size='',
            distinctive_features='',
        )
        found = self.make_features()

        self.assertEqual(
            calculate_similarity(lost, found),
            0,
        )