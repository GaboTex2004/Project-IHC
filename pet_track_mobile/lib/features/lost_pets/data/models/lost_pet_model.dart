class LostPetModel {
  final int? id;
  final String name;
  final String? photo;
  final String characteristics;
  final String lastLocation;
  final String dateLost; // Formato YYYY-MM-DD para Django DateField
  final String contactInfo;
  final DateTime? createdAt;

  LostPetModel({
    this.id,
    required this.name,
    this.photo,
    required this.characteristics,
    required this.lastLocation,
    required this.dateLost,
    required this.contactInfo,
    this.createdAt,
  });

  /// Crea una instancia a partir del JSON devuelto por Django REST Framework
  factory LostPetModel.fromJson(Map<String, dynamic> json) {
    return LostPetModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      photo: json['photo'] as String?,
      characteristics: json['characteristics'] as String? ?? '',
      lastLocation: json['last_location'] as String? ?? '',
      dateLost: json['date_lost'] as String? ?? '',
      contactInfo: json['contact_info'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Serializa a JSON (para peticiones estándar application/json)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (photo != null) 'photo': photo,
      'characteristics': characteristics,
      'last_location': lastLocation,
      'date_lost': dateLost,
      'contact_info': contactInfo,
    };
  }

  /// Convierte los campos de texto a un `Map<String, String>` para MultipartRequest
  Map<String, String> toFormDataFields() {
    return {
      'name': name,
      'characteristics': characteristics,
      'last_location': lastLocation,
      'date_lost': dateLost,
      'contact_info': contactInfo,
    };
  }

  LostPetModel copyWith({
    int? id,
    String? name,
    String? photo,
    String? characteristics,
    String? lastLocation,
    String? dateLost,
    String? contactInfo,
    DateTime? createdAt,
  }) {
    return LostPetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      characteristics: characteristics ?? this.characteristics,
      lastLocation: lastLocation ?? this.lastLocation,
      dateLost: dateLost ?? this.dateLost,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'LostPetModel(id: $id, name: $name, location: $lastLocation, date: $dateLost)';
  }
}
