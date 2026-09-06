enum PetStatus { homeless, adopted, lost }

extension PetStatusLabel on PetStatus {
  String get label => switch (this) {
        PetStatus.homeless => 'SIN HOGAR',
        PetStatus.adopted => 'ADOPTADO',
        PetStatus.lost => 'PERDIDO',
      };
}
