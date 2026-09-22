
from io import BytesIO

from PIL import Image, ImageOps, UnidentifiedImageError


MAX_IMAGE_BYTES = 10 * 1024 * 1024
MAX_IMAGE_PIXELS = 20_000_000
OUTPUT_MAX_DIMENSION = 1600


class InvalidReportImageError(Exception):
    """La fotografía no puede procesarse de forma segura."""


def prepare_report_image(report_model) -> bytes:
    """
    Lee la fotografía almacenada y devuelve un JPEG
    normalizado sin los metadatos originales.

    No modifica el archivo original.
    """
    if not report_model.photo:
        raise InvalidReportImageError(
            'El reporte no tiene fotografía.'
        )

    try:
        with report_model.photo.open('rb') as photo_file:
            image_bytes = photo_file.read(MAX_IMAGE_BYTES + 1)

        if len(image_bytes) > MAX_IMAGE_BYTES:
            raise InvalidReportImageError(
                'La fotografía supera el límite de 10 MB.'
            )

        with Image.open(BytesIO(image_bytes)) as image:
            width, height = image.size

            if width * height > MAX_IMAGE_PIXELS:
                raise InvalidReportImageError(
                    'La resolución de la fotografía es demasiado alta.'
                )

            # Respeta la orientación indicada por EXIF.
            image = ImageOps.exif_transpose(image)

            # Convierte a RGB para producir un JPEG estándar.
            image = image.convert('RGB')
            image.thumbnail(
                (OUTPUT_MAX_DIMENSION, OUTPUT_MAX_DIMENSION)
            )

            output = BytesIO()
            image.save(
                output,
                format='JPEG',
                quality=85,
            )

            return output.getvalue()

    except (UnidentifiedImageError, OSError, ValueError) as exc:
        raise InvalidReportImageError(
            'No se pudo procesar la fotografía.'
        ) from exc