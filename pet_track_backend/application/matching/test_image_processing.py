
from io import BytesIO
from types import SimpleNamespace
from unittest import TestCase
from unittest.mock import Mock

from PIL import Image

from application.matching.image_processing import (
    InvalidReportImageError,
    MAX_IMAGE_BYTES,
    OUTPUT_MAX_DIMENSION,
    prepare_report_image,
)


class PrepareReportImageTests(TestCase):

    def make_report(self, content):
        photo = Mock()
        photo.__bool__ = Mock(return_value=True)
        photo.open.return_value.__enter__ = Mock(
            return_value=BytesIO(content)
        )
        photo.open.return_value.__exit__ = Mock(
            return_value=False
        )
        return SimpleNamespace(photo=photo)

    def make_image(self, size=(100, 100), exif=None):
        output = BytesIO()
        image = Image.new('RGB', size, 'red')

        if exif is None:
            image.save(output, format='JPEG')
        else:
            image.save(output, format='JPEG', exif=exif)

        return output.getvalue()

    def test_imagen_valida_produce_jpeg(self):
        report = self.make_report(self.make_image())

        result = prepare_report_image(report)

        with Image.open(BytesIO(result)) as image:
            self.assertEqual(image.format, 'JPEG')
            self.assertEqual(image.mode, 'RGB')

    def test_no_conserva_metadatos_exif(self):
        exif = Image.Exif()
        exif[270] = 'Informacion privada de prueba'

        report = self.make_report(self.make_image(exif=exif))

        result = prepare_report_image(report)

        with Image.open(BytesIO(result)) as image:
            self.assertEqual(len(image.getexif()), 0)

    def test_reduce_imagen_grande(self):
        report = self.make_report(
            self.make_image(size=(2000, 1000))
        )

        result = prepare_report_image(report)

        with Image.open(BytesIO(result)) as image:
            self.assertLessEqual(
                max(image.size),
                OUTPUT_MAX_DIMENSION,
            )

    def test_rechaza_archivo_corrupto(self):
        report = self.make_report(b'Esto no es una imagen')

        with self.assertRaises(InvalidReportImageError):
            prepare_report_image(report)

    def test_rechaza_archivo_demasiado_grande(self):
        report = self.make_report(
            b'x' * (MAX_IMAGE_BYTES + 1)
        )

        with self.assertRaises(InvalidReportImageError):
            prepare_report_image(report)

    def test_rechaza_reporte_sin_fotografia(self):
        report = SimpleNamespace(photo=None)

        with self.assertRaises(InvalidReportImageError):
            prepare_report_image(report)

    
    def test_rechaza_resolucion_excesiva(self):
        report = self.make_report(
            self.make_image(size=(5000, 5000))
        )

        with self.assertRaises(InvalidReportImageError):
            prepare_report_image(report)

    def test_respeta_orientacion_exif(self):
        exif = Image.Exif()
        exif[274] = 6  # Rotación de 90 grados

        report = self.make_report(
            self.make_image(size=(100, 200), exif=exif)
        )

        result = prepare_report_image(report)

        with Image.open(BytesIO(result)) as image:
            self.assertEqual(image.size, (200, 100))
            self.assertEqual(len(image.getexif()), 0)