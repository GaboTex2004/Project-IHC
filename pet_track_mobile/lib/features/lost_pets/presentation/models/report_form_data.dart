import 'dart:typed_data';

enum ReportType { namedPet, homeless }

extension ReportTypeLabel on ReportType {
  String get label => switch (this) {
        ReportType.namedPet => 'Con nombre',
        ReportType.homeless => 'Sin hogar',
      };

  String get apiValue => switch (this) {
        ReportType.namedPet => 'FOUND',
        ReportType.homeless => 'HOMELESS',
      };
}

enum PetSpecies { dog, cat, other }

extension PetSpeciesLabel on PetSpecies {
  String get label => switch (this) {
        PetSpecies.dog => 'Perro',
        PetSpecies.cat => 'Gato',
        PetSpecies.other => 'Otro',
      };
}

enum PetSize { small, medium, large }

extension PetSizeLabel on PetSize {
  String get label => switch (this) {
        PetSize.small => 'Pequeño',
        PetSize.medium => 'Mediano',
        PetSize.large => 'Grande',
      };
}

enum PetAgeRange { unknown, puppy, young, adult, senior }

extension PetAgeRangeLabel on PetAgeRange {
  String get label => switch (this) {
        PetAgeRange.unknown => 'No identificada',
        PetAgeRange.puppy => 'Cachorro (0-6 meses)',
        PetAgeRange.young => 'Joven (6 meses - 2 años)',
        PetAgeRange.adult => 'Adulto (2-7 años)',
        PetAgeRange.senior => 'Adulto mayor (7+ años)',
      };
}

enum PetGender { unknown, male, female }

extension PetGenderLabel on PetGender {
  String get label => switch (this) {
        PetGender.unknown => 'No identificado',
        PetGender.male => 'Macho',
        PetGender.female => 'Hembra',
      };
}

enum IdentificationType { tag, microchip, bandana, other }

extension IdentificationTypeLabel on IdentificationType {
  String get label => switch (this) {
        IdentificationType.tag => 'Collar con placa',
        IdentificationType.microchip => 'Microchip',
        IdentificationType.bandana => 'Bandana',
        IdentificationType.other => 'Otro',
      };
}

class ReportPhoto {
  final Uint8List bytes;
  final String name;

  const ReportPhoto({required this.bytes, required this.name});
}

class ReportFormData {
  final ReportType reportType;
  final String name;
  final PetSpecies species;
  final String breed;
  final String color;
  final PetSize size;
  final PetAgeRange ageRange;
  final PetGender gender;
  final bool hasIdentification;
  final IdentificationType? identificationType;
  final String identificationNumber;
  final String characteristics;
  final String lastLocation;
  final DateTime date;
  final String contactInfo;
  final List<ReportPhoto> photos;

  const ReportFormData({
    required this.reportType,
    required this.name,
    required this.species,
    required this.breed,
    required this.color,
    required this.size,
    required this.ageRange,
    required this.gender,
    required this.hasIdentification,
    required this.identificationType,
    required this.identificationNumber,
    required this.characteristics,
    required this.lastLocation,
    required this.date,
    required this.contactInfo,
    required this.photos,
  });

  String get displayName => reportType == ReportType.homeless ? 'Sin nombre' : name;

  String get descriptionLine {
    final values = <String>[species.label];
    if (breed.trim().isNotEmpty) values.add(breed.trim());
    if (reportType == ReportType.homeless) values.add(size.label);
    return values.join(' · ');
  }
}
