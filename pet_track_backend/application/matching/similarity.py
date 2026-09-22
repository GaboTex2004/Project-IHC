
import unicodedata


def normalize(value):
    """Normaliza textos para comparar características."""
    value = str(value or '').strip().lower()

    return ''.join(
        character
        for character in unicodedata.normalize('NFKD', value)
        if not unicodedata.combining(character)
    )


def calculate_similarity(lost_features, found_features):
    """
    Compara características visuales.

    Devuelve un porcentaje orientativo entre 0 y 100.
    No representa la probabilidad de que sea la misma mascota.
    """

    lost_species = normalize(lost_features.species)
    found_species = normalize(found_features.species)

    # No comparar animales de especies diferentes o desconocidas.
    if not lost_species or not found_species:
        return 0

    if lost_species != found_species:
        return 0

    weights = {
        'primary_color': 30,
        'secondary_color': 15,
        'markings': 20,
        'coat_type': 10,
        'ear_type': 10,
        'size': 5,
        'distinctive_features': 10,
    }

    earned_points = 0
    available_points = 0

    for field, weight in weights.items():
        lost_value = normalize(getattr(lost_features, field, ''))
        found_value = normalize(getattr(found_features, field, ''))

        # Los campos desconocidos no cuentan como coincidencias.
        if not lost_value or not found_value:
            continue

        available_points += weight

        if lost_value == found_value:
            earned_points += weight

    if available_points == 0:
        return 0

    # Calculamos la similitud sobre los campos comparables.
    similarity = earned_points / available_points

    # Penalizamos la falta de información.
    coverage = available_points / sum(weights.values())

    return round(similarity * coverage * 100)