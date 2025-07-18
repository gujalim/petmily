class Pet {
  final String id;
  final String name;
  final String species; // dog, cat, etc.
  final String breed;
  final DateTime birthDate;
  final String? imageUrl;
  final String? imageBase64; // 로컬 저장용 Base64 이미지
  final double weight;
  final String gender; // male, female
  final String? microchipId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    this.imageUrl,
    this.imageBase64,
    required this.weight,
    required this.gender,
    this.microchipId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      birthDate: DateTime.parse(json['birthDate']),
      imageUrl: json['imageUrl'],
      imageBase64: json['imageBase64'],
      weight: json['weight'].toDouble(),
      gender: json['gender'],
      microchipId: json['microchipId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birthDate': birthDate.toIso8601String(),
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'weight': weight,
      'gender': gender,
      'microchipId': microchipId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    String? imageUrl,
    String? imageBase64,
    double? weight,
    String? gender,
    String? microchipId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBase64: imageBase64 ?? this.imageBase64,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      microchipId: microchipId ?? this.microchipId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
} 