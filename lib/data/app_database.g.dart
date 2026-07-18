// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PetsTable extends Pets with TableInfo<$PetsTable, Pet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🐾'),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _allergiesMeta = const VerificationMeta(
    'allergies',
  );
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
    'allergies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _characteristicsMeta = const VerificationMeta(
    'characteristics',
  );
  @override
  late final GeneratedColumn<String> characteristics = GeneratedColumn<String>(
    'characteristics',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hasPedigreeMeta = const VerificationMeta(
    'hasPedigree',
  );
  @override
  late final GeneratedColumn<bool> hasPedigree = GeneratedColumn<bool>(
    'has_pedigree',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_pedigree" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pedigreeNumberMeta = const VerificationMeta(
    'pedigreeNumber',
  );
  @override
  late final GeneratedColumn<String> pedigreeNumber = GeneratedColumn<String>(
    'pedigree_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _microchipMeta = const VerificationMeta(
    'microchip',
  );
  @override
  late final GeneratedColumn<String> microchip = GeneratedColumn<String>(
    'microchip',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reproductiveStatusMeta =
      const VerificationMeta('reproductiveStatus');
  @override
  late final GeneratedColumn<String> reproductiveStatus =
      GeneratedColumn<String>(
        'reproductive_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _bodyConditionScoreMeta =
      const VerificationMeta('bodyConditionScore');
  @override
  late final GeneratedColumn<double> bodyConditionScore =
      GeneratedColumn<double>(
        'body_condition_score',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _clinicReferenceMeta = const VerificationMeta(
    'clinicReference',
  );
  @override
  late final GeneratedColumn<String> clinicReference = GeneratedColumn<String>(
    'clinic_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _veterinarianReferenceMeta =
      const VerificationMeta('veterinarianReference');
  @override
  late final GeneratedColumn<String> veterinarianReference =
      GeneratedColumn<String>(
        'veterinarian_reference',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _documentNotesMeta = const VerificationMeta(
    'documentNotes',
  );
  @override
  late final GeneratedColumn<String> documentNotes = GeneratedColumn<String>(
    'document_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _photoDataMeta = const VerificationMeta(
    'photoData',
  );
  @override
  late final GeneratedColumn<String> photoData = GeneratedColumn<String>(
    'photo_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    species,
    breed,
    emoji,
    weight,
    allergies,
    birthDate,
    sex,
    color,
    characteristics,
    hasPedigree,
    pedigreeNumber,
    microchip,
    size,
    reproductiveStatus,
    bodyConditionScore,
    clinicReference,
    veterinarianReference,
    documentNotes,
    photoData,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    } else if (isInserting) {
      context.missing(_breedMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('allergies')) {
      context.handle(
        _allergiesMeta,
        allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('characteristics')) {
      context.handle(
        _characteristicsMeta,
        characteristics.isAcceptableOrUnknown(
          data['characteristics']!,
          _characteristicsMeta,
        ),
      );
    }
    if (data.containsKey('has_pedigree')) {
      context.handle(
        _hasPedigreeMeta,
        hasPedigree.isAcceptableOrUnknown(
          data['has_pedigree']!,
          _hasPedigreeMeta,
        ),
      );
    }
    if (data.containsKey('pedigree_number')) {
      context.handle(
        _pedigreeNumberMeta,
        pedigreeNumber.isAcceptableOrUnknown(
          data['pedigree_number']!,
          _pedigreeNumberMeta,
        ),
      );
    }
    if (data.containsKey('microchip')) {
      context.handle(
        _microchipMeta,
        microchip.isAcceptableOrUnknown(data['microchip']!, _microchipMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('reproductive_status')) {
      context.handle(
        _reproductiveStatusMeta,
        reproductiveStatus.isAcceptableOrUnknown(
          data['reproductive_status']!,
          _reproductiveStatusMeta,
        ),
      );
    }
    if (data.containsKey('body_condition_score')) {
      context.handle(
        _bodyConditionScoreMeta,
        bodyConditionScore.isAcceptableOrUnknown(
          data['body_condition_score']!,
          _bodyConditionScoreMeta,
        ),
      );
    }
    if (data.containsKey('clinic_reference')) {
      context.handle(
        _clinicReferenceMeta,
        clinicReference.isAcceptableOrUnknown(
          data['clinic_reference']!,
          _clinicReferenceMeta,
        ),
      );
    }
    if (data.containsKey('veterinarian_reference')) {
      context.handle(
        _veterinarianReferenceMeta,
        veterinarianReference.isAcceptableOrUnknown(
          data['veterinarian_reference']!,
          _veterinarianReferenceMeta,
        ),
      );
    }
    if (data.containsKey('document_notes')) {
      context.handle(
        _documentNotesMeta,
        documentNotes.isAcceptableOrUnknown(
          data['document_notes']!,
          _documentNotesMeta,
        ),
      );
    }
    if (data.containsKey('photo_data')) {
      context.handle(
        _photoDataMeta,
        photoData.isAcceptableOrUnknown(data['photo_data']!, _photoDataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      allergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      characteristics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}characteristics'],
      )!,
      hasPedigree: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_pedigree'],
      )!,
      pedigreeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pedigree_number'],
      ),
      microchip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}microchip'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      )!,
      reproductiveStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reproductive_status'],
      )!,
      bodyConditionScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_condition_score'],
      ),
      clinicReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_reference'],
      )!,
      veterinarianReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}veterinarian_reference'],
      )!,
      documentNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_notes'],
      )!,
      photoData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_data'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PetsTable createAlias(String alias) {
    return $PetsTable(attachedDatabase, alias);
  }
}

class Pet extends DataClass implements Insertable<Pet> {
  final int id;
  final String name;
  final String species;
  final String breed;
  final String emoji;
  final double weight;
  final String allergies;
  final DateTime? birthDate;
  final String sex;
  final String color;
  final String characteristics;
  final bool hasPedigree;
  final String? pedigreeNumber;
  final String? microchip;
  final String size;
  final String reproductiveStatus;
  final double? bodyConditionScore;
  final String clinicReference;
  final String veterinarianReference;
  final String documentNotes;
  final String? photoData;
  final DateTime createdAt;
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.emoji,
    required this.weight,
    required this.allergies,
    this.birthDate,
    required this.sex,
    required this.color,
    required this.characteristics,
    required this.hasPedigree,
    this.pedigreeNumber,
    this.microchip,
    required this.size,
    required this.reproductiveStatus,
    this.bodyConditionScore,
    required this.clinicReference,
    required this.veterinarianReference,
    required this.documentNotes,
    this.photoData,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['species'] = Variable<String>(species);
    map['breed'] = Variable<String>(breed);
    map['emoji'] = Variable<String>(emoji);
    map['weight'] = Variable<double>(weight);
    map['allergies'] = Variable<String>(allergies);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['sex'] = Variable<String>(sex);
    map['color'] = Variable<String>(color);
    map['characteristics'] = Variable<String>(characteristics);
    map['has_pedigree'] = Variable<bool>(hasPedigree);
    if (!nullToAbsent || pedigreeNumber != null) {
      map['pedigree_number'] = Variable<String>(pedigreeNumber);
    }
    if (!nullToAbsent || microchip != null) {
      map['microchip'] = Variable<String>(microchip);
    }
    map['size'] = Variable<String>(size);
    map['reproductive_status'] = Variable<String>(reproductiveStatus);
    if (!nullToAbsent || bodyConditionScore != null) {
      map['body_condition_score'] = Variable<double>(bodyConditionScore);
    }
    map['clinic_reference'] = Variable<String>(clinicReference);
    map['veterinarian_reference'] = Variable<String>(veterinarianReference);
    map['document_notes'] = Variable<String>(documentNotes);
    if (!nullToAbsent || photoData != null) {
      map['photo_data'] = Variable<String>(photoData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PetsCompanion toCompanion(bool nullToAbsent) {
    return PetsCompanion(
      id: Value(id),
      name: Value(name),
      species: Value(species),
      breed: Value(breed),
      emoji: Value(emoji),
      weight: Value(weight),
      allergies: Value(allergies),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      sex: Value(sex),
      color: Value(color),
      characteristics: Value(characteristics),
      hasPedigree: Value(hasPedigree),
      pedigreeNumber: pedigreeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pedigreeNumber),
      microchip: microchip == null && nullToAbsent
          ? const Value.absent()
          : Value(microchip),
      size: Value(size),
      reproductiveStatus: Value(reproductiveStatus),
      bodyConditionScore: bodyConditionScore == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyConditionScore),
      clinicReference: Value(clinicReference),
      veterinarianReference: Value(veterinarianReference),
      documentNotes: Value(documentNotes),
      photoData: photoData == null && nullToAbsent
          ? const Value.absent()
          : Value(photoData),
      createdAt: Value(createdAt),
    );
  }

  factory Pet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String>(json['breed']),
      emoji: serializer.fromJson<String>(json['emoji']),
      weight: serializer.fromJson<double>(json['weight']),
      allergies: serializer.fromJson<String>(json['allergies']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      sex: serializer.fromJson<String>(json['sex']),
      color: serializer.fromJson<String>(json['color']),
      characteristics: serializer.fromJson<String>(json['characteristics']),
      hasPedigree: serializer.fromJson<bool>(json['hasPedigree']),
      pedigreeNumber: serializer.fromJson<String?>(json['pedigreeNumber']),
      microchip: serializer.fromJson<String?>(json['microchip']),
      size: serializer.fromJson<String>(json['size']),
      reproductiveStatus: serializer.fromJson<String>(
        json['reproductiveStatus'],
      ),
      bodyConditionScore: serializer.fromJson<double?>(
        json['bodyConditionScore'],
      ),
      clinicReference: serializer.fromJson<String>(json['clinicReference']),
      veterinarianReference: serializer.fromJson<String>(
        json['veterinarianReference'],
      ),
      documentNotes: serializer.fromJson<String>(json['documentNotes']),
      photoData: serializer.fromJson<String?>(json['photoData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String>(breed),
      'emoji': serializer.toJson<String>(emoji),
      'weight': serializer.toJson<double>(weight),
      'allergies': serializer.toJson<String>(allergies),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'sex': serializer.toJson<String>(sex),
      'color': serializer.toJson<String>(color),
      'characteristics': serializer.toJson<String>(characteristics),
      'hasPedigree': serializer.toJson<bool>(hasPedigree),
      'pedigreeNumber': serializer.toJson<String?>(pedigreeNumber),
      'microchip': serializer.toJson<String?>(microchip),
      'size': serializer.toJson<String>(size),
      'reproductiveStatus': serializer.toJson<String>(reproductiveStatus),
      'bodyConditionScore': serializer.toJson<double?>(bodyConditionScore),
      'clinicReference': serializer.toJson<String>(clinicReference),
      'veterinarianReference': serializer.toJson<String>(veterinarianReference),
      'documentNotes': serializer.toJson<String>(documentNotes),
      'photoData': serializer.toJson<String?>(photoData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? species,
    String? breed,
    String? emoji,
    double? weight,
    String? allergies,
    Value<DateTime?> birthDate = const Value.absent(),
    String? sex,
    String? color,
    String? characteristics,
    bool? hasPedigree,
    Value<String?> pedigreeNumber = const Value.absent(),
    Value<String?> microchip = const Value.absent(),
    String? size,
    String? reproductiveStatus,
    Value<double?> bodyConditionScore = const Value.absent(),
    String? clinicReference,
    String? veterinarianReference,
    String? documentNotes,
    Value<String?> photoData = const Value.absent(),
    DateTime? createdAt,
  }) => Pet(
    id: id ?? this.id,
    name: name ?? this.name,
    species: species ?? this.species,
    breed: breed ?? this.breed,
    emoji: emoji ?? this.emoji,
    weight: weight ?? this.weight,
    allergies: allergies ?? this.allergies,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    sex: sex ?? this.sex,
    color: color ?? this.color,
    characteristics: characteristics ?? this.characteristics,
    hasPedigree: hasPedigree ?? this.hasPedigree,
    pedigreeNumber: pedigreeNumber.present
        ? pedigreeNumber.value
        : this.pedigreeNumber,
    microchip: microchip.present ? microchip.value : this.microchip,
    size: size ?? this.size,
    reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
    bodyConditionScore: bodyConditionScore.present
        ? bodyConditionScore.value
        : this.bodyConditionScore,
    clinicReference: clinicReference ?? this.clinicReference,
    veterinarianReference: veterinarianReference ?? this.veterinarianReference,
    documentNotes: documentNotes ?? this.documentNotes,
    photoData: photoData.present ? photoData.value : this.photoData,
    createdAt: createdAt ?? this.createdAt,
  );
  Pet copyWithCompanion(PetsCompanion data) {
    return Pet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      weight: data.weight.present ? data.weight.value : this.weight,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      sex: data.sex.present ? data.sex.value : this.sex,
      color: data.color.present ? data.color.value : this.color,
      characteristics: data.characteristics.present
          ? data.characteristics.value
          : this.characteristics,
      hasPedigree: data.hasPedigree.present
          ? data.hasPedigree.value
          : this.hasPedigree,
      pedigreeNumber: data.pedigreeNumber.present
          ? data.pedigreeNumber.value
          : this.pedigreeNumber,
      microchip: data.microchip.present ? data.microchip.value : this.microchip,
      size: data.size.present ? data.size.value : this.size,
      reproductiveStatus: data.reproductiveStatus.present
          ? data.reproductiveStatus.value
          : this.reproductiveStatus,
      bodyConditionScore: data.bodyConditionScore.present
          ? data.bodyConditionScore.value
          : this.bodyConditionScore,
      clinicReference: data.clinicReference.present
          ? data.clinicReference.value
          : this.clinicReference,
      veterinarianReference: data.veterinarianReference.present
          ? data.veterinarianReference.value
          : this.veterinarianReference,
      documentNotes: data.documentNotes.present
          ? data.documentNotes.value
          : this.documentNotes,
      photoData: data.photoData.present ? data.photoData.value : this.photoData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('emoji: $emoji, ')
          ..write('weight: $weight, ')
          ..write('allergies: $allergies, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('color: $color, ')
          ..write('characteristics: $characteristics, ')
          ..write('hasPedigree: $hasPedigree, ')
          ..write('pedigreeNumber: $pedigreeNumber, ')
          ..write('microchip: $microchip, ')
          ..write('size: $size, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('bodyConditionScore: $bodyConditionScore, ')
          ..write('clinicReference: $clinicReference, ')
          ..write('veterinarianReference: $veterinarianReference, ')
          ..write('documentNotes: $documentNotes, ')
          ..write('photoData: $photoData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    species,
    breed,
    emoji,
    weight,
    allergies,
    birthDate,
    sex,
    color,
    characteristics,
    hasPedigree,
    pedigreeNumber,
    microchip,
    size,
    reproductiveStatus,
    bodyConditionScore,
    clinicReference,
    veterinarianReference,
    documentNotes,
    photoData,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pet &&
          other.id == this.id &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.emoji == this.emoji &&
          other.weight == this.weight &&
          other.allergies == this.allergies &&
          other.birthDate == this.birthDate &&
          other.sex == this.sex &&
          other.color == this.color &&
          other.characteristics == this.characteristics &&
          other.hasPedigree == this.hasPedigree &&
          other.pedigreeNumber == this.pedigreeNumber &&
          other.microchip == this.microchip &&
          other.size == this.size &&
          other.reproductiveStatus == this.reproductiveStatus &&
          other.bodyConditionScore == this.bodyConditionScore &&
          other.clinicReference == this.clinicReference &&
          other.veterinarianReference == this.veterinarianReference &&
          other.documentNotes == this.documentNotes &&
          other.photoData == this.photoData &&
          other.createdAt == this.createdAt);
}

class PetsCompanion extends UpdateCompanion<Pet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> species;
  final Value<String> breed;
  final Value<String> emoji;
  final Value<double> weight;
  final Value<String> allergies;
  final Value<DateTime?> birthDate;
  final Value<String> sex;
  final Value<String> color;
  final Value<String> characteristics;
  final Value<bool> hasPedigree;
  final Value<String?> pedigreeNumber;
  final Value<String?> microchip;
  final Value<String> size;
  final Value<String> reproductiveStatus;
  final Value<double?> bodyConditionScore;
  final Value<String> clinicReference;
  final Value<String> veterinarianReference;
  final Value<String> documentNotes;
  final Value<String?> photoData;
  final Value<DateTime> createdAt;
  const PetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.emoji = const Value.absent(),
    this.weight = const Value.absent(),
    this.allergies = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    this.color = const Value.absent(),
    this.characteristics = const Value.absent(),
    this.hasPedigree = const Value.absent(),
    this.pedigreeNumber = const Value.absent(),
    this.microchip = const Value.absent(),
    this.size = const Value.absent(),
    this.reproductiveStatus = const Value.absent(),
    this.bodyConditionScore = const Value.absent(),
    this.clinicReference = const Value.absent(),
    this.veterinarianReference = const Value.absent(),
    this.documentNotes = const Value.absent(),
    this.photoData = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String species,
    required String breed,
    this.emoji = const Value.absent(),
    this.weight = const Value.absent(),
    this.allergies = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    this.color = const Value.absent(),
    this.characteristics = const Value.absent(),
    this.hasPedigree = const Value.absent(),
    this.pedigreeNumber = const Value.absent(),
    this.microchip = const Value.absent(),
    this.size = const Value.absent(),
    this.reproductiveStatus = const Value.absent(),
    this.bodyConditionScore = const Value.absent(),
    this.clinicReference = const Value.absent(),
    this.veterinarianReference = const Value.absent(),
    this.documentNotes = const Value.absent(),
    this.photoData = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       species = Value(species),
       breed = Value(breed);
  static Insertable<Pet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? emoji,
    Expression<double>? weight,
    Expression<String>? allergies,
    Expression<DateTime>? birthDate,
    Expression<String>? sex,
    Expression<String>? color,
    Expression<String>? characteristics,
    Expression<bool>? hasPedigree,
    Expression<String>? pedigreeNumber,
    Expression<String>? microchip,
    Expression<String>? size,
    Expression<String>? reproductiveStatus,
    Expression<double>? bodyConditionScore,
    Expression<String>? clinicReference,
    Expression<String>? veterinarianReference,
    Expression<String>? documentNotes,
    Expression<String>? photoData,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (emoji != null) 'emoji': emoji,
      if (weight != null) 'weight': weight,
      if (allergies != null) 'allergies': allergies,
      if (birthDate != null) 'birth_date': birthDate,
      if (sex != null) 'sex': sex,
      if (color != null) 'color': color,
      if (characteristics != null) 'characteristics': characteristics,
      if (hasPedigree != null) 'has_pedigree': hasPedigree,
      if (pedigreeNumber != null) 'pedigree_number': pedigreeNumber,
      if (microchip != null) 'microchip': microchip,
      if (size != null) 'size': size,
      if (reproductiveStatus != null) 'reproductive_status': reproductiveStatus,
      if (bodyConditionScore != null)
        'body_condition_score': bodyConditionScore,
      if (clinicReference != null) 'clinic_reference': clinicReference,
      if (veterinarianReference != null)
        'veterinarian_reference': veterinarianReference,
      if (documentNotes != null) 'document_notes': documentNotes,
      if (photoData != null) 'photo_data': photoData,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? species,
    Value<String>? breed,
    Value<String>? emoji,
    Value<double>? weight,
    Value<String>? allergies,
    Value<DateTime?>? birthDate,
    Value<String>? sex,
    Value<String>? color,
    Value<String>? characteristics,
    Value<bool>? hasPedigree,
    Value<String?>? pedigreeNumber,
    Value<String?>? microchip,
    Value<String>? size,
    Value<String>? reproductiveStatus,
    Value<double?>? bodyConditionScore,
    Value<String>? clinicReference,
    Value<String>? veterinarianReference,
    Value<String>? documentNotes,
    Value<String?>? photoData,
    Value<DateTime>? createdAt,
  }) {
    return PetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      emoji: emoji ?? this.emoji,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      color: color ?? this.color,
      characteristics: characteristics ?? this.characteristics,
      hasPedigree: hasPedigree ?? this.hasPedigree,
      pedigreeNumber: pedigreeNumber ?? this.pedigreeNumber,
      microchip: microchip ?? this.microchip,
      size: size ?? this.size,
      reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      clinicReference: clinicReference ?? this.clinicReference,
      veterinarianReference:
          veterinarianReference ?? this.veterinarianReference,
      documentNotes: documentNotes ?? this.documentNotes,
      photoData: photoData ?? this.photoData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (characteristics.present) {
      map['characteristics'] = Variable<String>(characteristics.value);
    }
    if (hasPedigree.present) {
      map['has_pedigree'] = Variable<bool>(hasPedigree.value);
    }
    if (pedigreeNumber.present) {
      map['pedigree_number'] = Variable<String>(pedigreeNumber.value);
    }
    if (microchip.present) {
      map['microchip'] = Variable<String>(microchip.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (reproductiveStatus.present) {
      map['reproductive_status'] = Variable<String>(reproductiveStatus.value);
    }
    if (bodyConditionScore.present) {
      map['body_condition_score'] = Variable<double>(bodyConditionScore.value);
    }
    if (clinicReference.present) {
      map['clinic_reference'] = Variable<String>(clinicReference.value);
    }
    if (veterinarianReference.present) {
      map['veterinarian_reference'] = Variable<String>(
        veterinarianReference.value,
      );
    }
    if (documentNotes.present) {
      map['document_notes'] = Variable<String>(documentNotes.value);
    }
    if (photoData.present) {
      map['photo_data'] = Variable<String>(photoData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('emoji: $emoji, ')
          ..write('weight: $weight, ')
          ..write('allergies: $allergies, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('color: $color, ')
          ..write('characteristics: $characteristics, ')
          ..write('hasPedigree: $hasPedigree, ')
          ..write('pedigreeNumber: $pedigreeNumber, ')
          ..write('microchip: $microchip, ')
          ..write('size: $size, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('bodyConditionScore: $bodyConditionScore, ')
          ..write('clinicReference: $clinicReference, ')
          ..write('veterinarianReference: $veterinarianReference, ')
          ..write('documentNotes: $documentNotes, ')
          ..write('photoData: $photoData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  static const VerificationMeta _petNameMeta = const VerificationMeta(
    'petName',
  );
  @override
  late final GeneratedColumn<String> petName = GeneratedColumn<String>(
    'pet_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('💊'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Rotina'),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _lastCompletedAtMeta = const VerificationMeta(
    'lastCompletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedAt =
      GeneratedColumn<DateTime>(
        'last_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    petId,
    petName,
    icon,
    category,
    dueAt,
    intervalDays,
    lastCompletedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('pet_name')) {
      context.handle(
        _petNameMeta,
        petName.isAcceptableOrUnknown(data['pet_name']!, _petNameMeta),
      );
    } else if (isInserting) {
      context.missing(_petNameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
        _lastCompletedAtMeta,
        lastCompletedAt.isAcceptableOrUnknown(
          data['last_completed_at']!,
          _lastCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      petName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      lastCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final String title;
  final int petId;
  final String petName;
  final String icon;
  final String category;
  final DateTime dueAt;
  final int intervalDays;
  final DateTime? lastCompletedAt;
  final DateTime createdAt;
  const Reminder({
    required this.id,
    required this.title,
    required this.petId,
    required this.petName,
    required this.icon,
    required this.category,
    required this.dueAt,
    required this.intervalDays,
    this.lastCompletedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['pet_id'] = Variable<int>(petId);
    map['pet_name'] = Variable<String>(petName);
    map['icon'] = Variable<String>(icon);
    map['category'] = Variable<String>(category);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['interval_days'] = Variable<int>(intervalDays);
    if (!nullToAbsent || lastCompletedAt != null) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      petId: Value(petId),
      petName: Value(petName),
      icon: Value(icon),
      category: Value(category),
      dueAt: Value(dueAt),
      intervalDays: Value(intervalDays),
      lastCompletedAt: lastCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      petId: serializer.fromJson<int>(json['petId']),
      petName: serializer.fromJson<String>(json['petName']),
      icon: serializer.fromJson<String>(json['icon']),
      category: serializer.fromJson<String>(json['category']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      lastCompletedAt: serializer.fromJson<DateTime?>(json['lastCompletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'petId': serializer.toJson<int>(petId),
      'petName': serializer.toJson<String>(petName),
      'icon': serializer.toJson<String>(icon),
      'category': serializer.toJson<String>(category),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'lastCompletedAt': serializer.toJson<DateTime?>(lastCompletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Reminder copyWith({
    int? id,
    String? title,
    int? petId,
    String? petName,
    String? icon,
    String? category,
    DateTime? dueAt,
    int? intervalDays,
    Value<DateTime?> lastCompletedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Reminder(
    id: id ?? this.id,
    title: title ?? this.title,
    petId: petId ?? this.petId,
    petName: petName ?? this.petName,
    icon: icon ?? this.icon,
    category: category ?? this.category,
    dueAt: dueAt ?? this.dueAt,
    intervalDays: intervalDays ?? this.intervalDays,
    lastCompletedAt: lastCompletedAt.present
        ? lastCompletedAt.value
        : this.lastCompletedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      petId: data.petId.present ? data.petId.value : this.petId,
      petName: data.petName.present ? data.petName.value : this.petName,
      icon: data.icon.present ? data.icon.value : this.icon,
      category: data.category.present ? data.category.value : this.category,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      lastCompletedAt: data.lastCompletedAt.present
          ? data.lastCompletedAt.value
          : this.lastCompletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('petId: $petId, ')
          ..write('petName: $petName, ')
          ..write('icon: $icon, ')
          ..write('category: $category, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    petId,
    petName,
    icon,
    category,
    dueAt,
    intervalDays,
    lastCompletedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.title == this.title &&
          other.petId == this.petId &&
          other.petName == this.petName &&
          other.icon == this.icon &&
          other.category == this.category &&
          other.dueAt == this.dueAt &&
          other.intervalDays == this.intervalDays &&
          other.lastCompletedAt == this.lastCompletedAt &&
          other.createdAt == this.createdAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> petId;
  final Value<String> petName;
  final Value<String> icon;
  final Value<String> category;
  final Value<DateTime> dueAt;
  final Value<int> intervalDays;
  final Value<DateTime?> lastCompletedAt;
  final Value<DateTime> createdAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.petId = const Value.absent(),
    this.petName = const Value.absent(),
    this.icon = const Value.absent(),
    this.category = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int petId,
    required String petName,
    this.icon = const Value.absent(),
    this.category = const Value.absent(),
    required DateTime dueAt,
    this.intervalDays = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       petId = Value(petId),
       petName = Value(petName),
       dueAt = Value(dueAt);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? petId,
    Expression<String>? petName,
    Expression<String>? icon,
    Expression<String>? category,
    Expression<DateTime>? dueAt,
    Expression<int>? intervalDays,
    Expression<DateTime>? lastCompletedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (petId != null) 'pet_id': petId,
      if (petName != null) 'pet_name': petName,
      if (icon != null) 'icon': icon,
      if (category != null) 'category': category,
      if (dueAt != null) 'due_at': dueAt,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (lastCompletedAt != null) 'last_completed_at': lastCompletedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? petId,
    Value<String>? petName,
    Value<String>? icon,
    Value<String>? category,
    Value<DateTime>? dueAt,
    Value<int>? intervalDays,
    Value<DateTime?>? lastCompletedAt,
    Value<DateTime>? createdAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      dueAt: dueAt ?? this.dueAt,
      intervalDays: intervalDays ?? this.intervalDays,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (petName.present) {
      map['pet_name'] = Variable<String>(petName.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (lastCompletedAt.present) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('petId: $petId, ')
          ..write('petName: $petName, ')
          ..write('icon: $icon, ')
          ..write('category: $category, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VaccinesTable extends Vaccines with TableInfo<$VaccinesTable, Vaccine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDoseAtMeta = const VerificationMeta(
    'nextDoseAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDoseAt = GeneratedColumn<DateTime>(
    'next_dose_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicNameMeta = const VerificationMeta(
    'clinicName',
  );
  @override
  late final GeneratedColumn<String> clinicName = GeneratedColumn<String>(
    'clinic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    name,
    appliedAt,
    nextDoseAt,
    clinicName,
    batchNumber,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vaccine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('next_dose_at')) {
      context.handle(
        _nextDoseAtMeta,
        nextDoseAt.isAcceptableOrUnknown(
          data['next_dose_at']!,
          _nextDoseAtMeta,
        ),
      );
    }
    if (data.containsKey('clinic_name')) {
      context.handle(
        _clinicNameMeta,
        clinicName.isAcceptableOrUnknown(data['clinic_name']!, _clinicNameMeta),
      );
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vaccine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vaccine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
      nextDoseAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_dose_at'],
      ),
      clinicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_name'],
      ),
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VaccinesTable createAlias(String alias) {
    return $VaccinesTable(attachedDatabase, alias);
  }
}

class Vaccine extends DataClass implements Insertable<Vaccine> {
  final int id;
  final int petId;
  final String name;
  final DateTime appliedAt;
  final DateTime? nextDoseAt;
  final String? clinicName;
  final String? batchNumber;
  final DateTime createdAt;
  const Vaccine({
    required this.id,
    required this.petId,
    required this.name,
    required this.appliedAt,
    this.nextDoseAt,
    this.clinicName,
    this.batchNumber,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['name'] = Variable<String>(name);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    if (!nullToAbsent || nextDoseAt != null) {
      map['next_dose_at'] = Variable<DateTime>(nextDoseAt);
    }
    if (!nullToAbsent || clinicName != null) {
      map['clinic_name'] = Variable<String>(clinicName);
    }
    if (!nullToAbsent || batchNumber != null) {
      map['batch_number'] = Variable<String>(batchNumber);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VaccinesCompanion toCompanion(bool nullToAbsent) {
    return VaccinesCompanion(
      id: Value(id),
      petId: Value(petId),
      name: Value(name),
      appliedAt: Value(appliedAt),
      nextDoseAt: nextDoseAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDoseAt),
      clinicName: clinicName == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicName),
      batchNumber: batchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(batchNumber),
      createdAt: Value(createdAt),
    );
  }

  factory Vaccine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vaccine(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      name: serializer.fromJson<String>(json['name']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      nextDoseAt: serializer.fromJson<DateTime?>(json['nextDoseAt']),
      clinicName: serializer.fromJson<String?>(json['clinicName']),
      batchNumber: serializer.fromJson<String?>(json['batchNumber']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'name': serializer.toJson<String>(name),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'nextDoseAt': serializer.toJson<DateTime?>(nextDoseAt),
      'clinicName': serializer.toJson<String?>(clinicName),
      'batchNumber': serializer.toJson<String?>(batchNumber),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vaccine copyWith({
    int? id,
    int? petId,
    String? name,
    DateTime? appliedAt,
    Value<DateTime?> nextDoseAt = const Value.absent(),
    Value<String?> clinicName = const Value.absent(),
    Value<String?> batchNumber = const Value.absent(),
    DateTime? createdAt,
  }) => Vaccine(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    name: name ?? this.name,
    appliedAt: appliedAt ?? this.appliedAt,
    nextDoseAt: nextDoseAt.present ? nextDoseAt.value : this.nextDoseAt,
    clinicName: clinicName.present ? clinicName.value : this.clinicName,
    batchNumber: batchNumber.present ? batchNumber.value : this.batchNumber,
    createdAt: createdAt ?? this.createdAt,
  );
  Vaccine copyWithCompanion(VaccinesCompanion data) {
    return Vaccine(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      name: data.name.present ? data.name.value : this.name,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      nextDoseAt: data.nextDoseAt.present
          ? data.nextDoseAt.value
          : this.nextDoseAt,
      clinicName: data.clinicName.present
          ? data.clinicName.value
          : this.clinicName,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vaccine(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('name: $name, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('nextDoseAt: $nextDoseAt, ')
          ..write('clinicName: $clinicName, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    petId,
    name,
    appliedAt,
    nextDoseAt,
    clinicName,
    batchNumber,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vaccine &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.name == this.name &&
          other.appliedAt == this.appliedAt &&
          other.nextDoseAt == this.nextDoseAt &&
          other.clinicName == this.clinicName &&
          other.batchNumber == this.batchNumber &&
          other.createdAt == this.createdAt);
}

class VaccinesCompanion extends UpdateCompanion<Vaccine> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> name;
  final Value<DateTime> appliedAt;
  final Value<DateTime?> nextDoseAt;
  final Value<String?> clinicName;
  final Value<String?> batchNumber;
  final Value<DateTime> createdAt;
  const VaccinesCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.name = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.nextDoseAt = const Value.absent(),
    this.clinicName = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VaccinesCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String name,
    required DateTime appliedAt,
    this.nextDoseAt = const Value.absent(),
    this.clinicName = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : petId = Value(petId),
       name = Value(name),
       appliedAt = Value(appliedAt);
  static Insertable<Vaccine> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? name,
    Expression<DateTime>? appliedAt,
    Expression<DateTime>? nextDoseAt,
    Expression<String>? clinicName,
    Expression<String>? batchNumber,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (name != null) 'name': name,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (nextDoseAt != null) 'next_dose_at': nextDoseAt,
      if (clinicName != null) 'clinic_name': clinicName,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VaccinesCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? name,
    Value<DateTime>? appliedAt,
    Value<DateTime?>? nextDoseAt,
    Value<String?>? clinicName,
    Value<String?>? batchNumber,
    Value<DateTime>? createdAt,
  }) {
    return VaccinesCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      appliedAt: appliedAt ?? this.appliedAt,
      nextDoseAt: nextDoseAt ?? this.nextDoseAt,
      clinicName: clinicName ?? this.clinicName,
      batchNumber: batchNumber ?? this.batchNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (nextDoseAt.present) {
      map['next_dose_at'] = Variable<DateTime>(nextDoseAt.value);
    }
    if (clinicName.present) {
      map['clinic_name'] = Variable<String>(clinicName.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinesCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('name: $name, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('nextDoseAt: $nextDoseAt, ')
          ..write('clinicName: $clinicName, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PreventiveRecordsTable extends PreventiveRecords
    with TableInfo<$PreventiveRecordsTable, PreventiveRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreventiveRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productMeta = const VerificationMeta(
    'product',
  );
  @override
  late final GeneratedColumn<String> product = GeneratedColumn<String>(
    'product',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 140,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    category,
    product,
    appliedAt,
    nextDueAt,
    provider,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preventive_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreventiveRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('product')) {
      context.handle(
        _productMeta,
        product.isAcceptableOrUnknown(data['product']!, _productMeta),
      );
    } else if (isInserting) {
      context.missing(_productMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreventiveRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreventiveRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      product: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PreventiveRecordsTable createAlias(String alias) {
    return $PreventiveRecordsTable(attachedDatabase, alias);
  }
}

class PreventiveRecord extends DataClass
    implements Insertable<PreventiveRecord> {
  final int id;
  final int petId;
  final String category;
  final String product;
  final DateTime appliedAt;
  final DateTime? nextDueAt;
  final String? provider;
  final String? notes;
  final DateTime createdAt;
  const PreventiveRecord({
    required this.id,
    required this.petId,
    required this.category,
    required this.product,
    required this.appliedAt,
    this.nextDueAt,
    this.provider,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['category'] = Variable<String>(category);
    map['product'] = Variable<String>(product);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    if (!nullToAbsent || nextDueAt != null) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PreventiveRecordsCompanion toCompanion(bool nullToAbsent) {
    return PreventiveRecordsCompanion(
      id: Value(id),
      petId: Value(petId),
      category: Value(category),
      product: Value(product),
      appliedAt: Value(appliedAt),
      nextDueAt: nextDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueAt),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PreventiveRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreventiveRecord(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      category: serializer.fromJson<String>(json['category']),
      product: serializer.fromJson<String>(json['product']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      nextDueAt: serializer.fromJson<DateTime?>(json['nextDueAt']),
      provider: serializer.fromJson<String?>(json['provider']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'category': serializer.toJson<String>(category),
      'product': serializer.toJson<String>(product),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'nextDueAt': serializer.toJson<DateTime?>(nextDueAt),
      'provider': serializer.toJson<String?>(provider),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PreventiveRecord copyWith({
    int? id,
    int? petId,
    String? category,
    String? product,
    DateTime? appliedAt,
    Value<DateTime?> nextDueAt = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => PreventiveRecord(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    category: category ?? this.category,
    product: product ?? this.product,
    appliedAt: appliedAt ?? this.appliedAt,
    nextDueAt: nextDueAt.present ? nextDueAt.value : this.nextDueAt,
    provider: provider.present ? provider.value : this.provider,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  PreventiveRecord copyWithCompanion(PreventiveRecordsCompanion data) {
    return PreventiveRecord(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      category: data.category.present ? data.category.value : this.category,
      product: data.product.present ? data.product.value : this.product,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      provider: data.provider.present ? data.provider.value : this.provider,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreventiveRecord(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('category: $category, ')
          ..write('product: $product, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('provider: $provider, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    petId,
    category,
    product,
    appliedAt,
    nextDueAt,
    provider,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreventiveRecord &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.category == this.category &&
          other.product == this.product &&
          other.appliedAt == this.appliedAt &&
          other.nextDueAt == this.nextDueAt &&
          other.provider == this.provider &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PreventiveRecordsCompanion extends UpdateCompanion<PreventiveRecord> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> category;
  final Value<String> product;
  final Value<DateTime> appliedAt;
  final Value<DateTime?> nextDueAt;
  final Value<String?> provider;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const PreventiveRecordsCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.category = const Value.absent(),
    this.product = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.provider = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PreventiveRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String category,
    required String product,
    required DateTime appliedAt,
    this.nextDueAt = const Value.absent(),
    this.provider = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : petId = Value(petId),
       category = Value(category),
       product = Value(product),
       appliedAt = Value(appliedAt);
  static Insertable<PreventiveRecord> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? category,
    Expression<String>? product,
    Expression<DateTime>? appliedAt,
    Expression<DateTime>? nextDueAt,
    Expression<String>? provider,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (category != null) 'category': category,
      if (product != null) 'product': product,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (provider != null) 'provider': provider,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PreventiveRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? category,
    Value<String>? product,
    Value<DateTime>? appliedAt,
    Value<DateTime?>? nextDueAt,
    Value<String?>? provider,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return PreventiveRecordsCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      category: category ?? this.category,
      product: product ?? this.product,
      appliedAt: appliedAt ?? this.appliedAt,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      provider: provider ?? this.provider,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (product.present) {
      map['product'] = Variable<String>(product.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreventiveRecordsCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('category: $category, ')
          ..write('product: $product, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('provider: $provider, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MedicationPlansTable extends MedicationPlans
    with TableInfo<$MedicationPlansTable, MedicationPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 140,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleMeta = const VerificationMeta(
    'schedule',
  );
  @override
  late final GeneratedColumn<String> schedule = GeneratedColumn<String>(
    'schedule',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastTakenAtMeta = const VerificationMeta(
    'lastTakenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastTakenAt = GeneratedColumn<DateTime>(
    'last_taken_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    name,
    dosage,
    schedule,
    startAt,
    endAt,
    active,
    lastTakenAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('schedule')) {
      context.handle(
        _scheduleMeta,
        schedule.isAcceptableOrUnknown(data['schedule']!, _scheduleMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('last_taken_at')) {
      context.handle(
        _lastTakenAtMeta,
        lastTakenAt.isAcceptableOrUnknown(
          data['last_taken_at']!,
          _lastTakenAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
      schedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      lastTakenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_taken_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicationPlansTable createAlias(String alias) {
    return $MedicationPlansTable(attachedDatabase, alias);
  }
}

class MedicationPlan extends DataClass implements Insertable<MedicationPlan> {
  final int id;
  final int petId;
  final String name;
  final String dosage;
  final String schedule;
  final DateTime startAt;
  final DateTime? endAt;
  final bool active;
  final DateTime? lastTakenAt;
  final String? notes;
  final DateTime createdAt;
  const MedicationPlan({
    required this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.startAt,
    this.endAt,
    required this.active,
    this.lastTakenAt,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    map['schedule'] = Variable<String>(schedule);
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || lastTakenAt != null) {
      map['last_taken_at'] = Variable<DateTime>(lastTakenAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationPlansCompanion toCompanion(bool nullToAbsent) {
    return MedicationPlansCompanion(
      id: Value(id),
      petId: Value(petId),
      name: Value(name),
      dosage: Value(dosage),
      schedule: Value(schedule),
      startAt: Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      active: Value(active),
      lastTakenAt: lastTakenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTakenAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationPlan(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      schedule: serializer.fromJson<String>(json['schedule']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      active: serializer.fromJson<bool>(json['active']),
      lastTakenAt: serializer.fromJson<DateTime?>(json['lastTakenAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'schedule': serializer.toJson<String>(schedule),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'active': serializer.toJson<bool>(active),
      'lastTakenAt': serializer.toJson<DateTime?>(lastTakenAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationPlan copyWith({
    int? id,
    int? petId,
    String? name,
    String? dosage,
    String? schedule,
    DateTime? startAt,
    Value<DateTime?> endAt = const Value.absent(),
    bool? active,
    Value<DateTime?> lastTakenAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => MedicationPlan(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
    schedule: schedule ?? this.schedule,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    active: active ?? this.active,
    lastTakenAt: lastTakenAt.present ? lastTakenAt.value : this.lastTakenAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicationPlan copyWithCompanion(MedicationPlansCompanion data) {
    return MedicationPlan(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      schedule: data.schedule.present ? data.schedule.value : this.schedule,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      active: data.active.present ? data.active.value : this.active,
      lastTakenAt: data.lastTakenAt.present
          ? data.lastTakenAt.value
          : this.lastTakenAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationPlan(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('schedule: $schedule, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('active: $active, ')
          ..write('lastTakenAt: $lastTakenAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    petId,
    name,
    dosage,
    schedule,
    startAt,
    endAt,
    active,
    lastTakenAt,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationPlan &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.schedule == this.schedule &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.active == this.active &&
          other.lastTakenAt == this.lastTakenAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MedicationPlansCompanion extends UpdateCompanion<MedicationPlan> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> name;
  final Value<String> dosage;
  final Value<String> schedule;
  final Value<DateTime> startAt;
  final Value<DateTime?> endAt;
  final Value<bool> active;
  final Value<DateTime?> lastTakenAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MedicationPlansCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.schedule = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.active = const Value.absent(),
    this.lastTakenAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicationPlansCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String name,
    required String dosage,
    required String schedule,
    required DateTime startAt,
    this.endAt = const Value.absent(),
    this.active = const Value.absent(),
    this.lastTakenAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : petId = Value(petId),
       name = Value(name),
       dosage = Value(dosage),
       schedule = Value(schedule),
       startAt = Value(startAt);
  static Insertable<MedicationPlan> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? schedule,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<bool>? active,
    Expression<DateTime>? lastTakenAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (schedule != null) 'schedule': schedule,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (active != null) 'active': active,
      if (lastTakenAt != null) 'last_taken_at': lastTakenAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicationPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? name,
    Value<String>? dosage,
    Value<String>? schedule,
    Value<DateTime>? startAt,
    Value<DateTime?>? endAt,
    Value<bool>? active,
    Value<DateTime?>? lastTakenAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return MedicationPlansCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      schedule: schedule ?? this.schedule,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      active: active ?? this.active,
      lastTakenAt: lastTakenAt ?? this.lastTakenAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (schedule.present) {
      map['schedule'] = Variable<String>(schedule.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (lastTakenAt.present) {
      map['last_taken_at'] = Variable<DateTime>(lastTakenAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationPlansCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('schedule: $schedule, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('active: $active, ')
          ..write('lastTakenAt: $lastTakenAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FamilyInvitationsTable extends FamilyInvitations
    with TableInfo<$FamilyInvitationsTable, FamilyInvitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyInvitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionsMeta = const VerificationMeta(
    'permissions',
  );
  @override
  late final GeneratedColumn<String> permissions = GeneratedColumn<String>(
    'permissions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('saude'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendente'),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    email,
    role,
    permissions,
    status,
    expiresAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_invitations';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyInvitation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('permissions')) {
      context.handle(
        _permissionsMeta,
        permissions.isAcceptableOrUnknown(
          data['permissions']!,
          _permissionsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyInvitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyInvitation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      permissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FamilyInvitationsTable createAlias(String alias) {
    return $FamilyInvitationsTable(attachedDatabase, alias);
  }
}

class FamilyInvitation extends DataClass
    implements Insertable<FamilyInvitation> {
  final int id;
  final int petId;
  final String email;
  final String role;
  final String permissions;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;
  const FamilyInvitation({
    required this.id,
    required this.petId,
    required this.email,
    required this.role,
    required this.permissions,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['permissions'] = Variable<String>(permissions);
    map['status'] = Variable<String>(status);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FamilyInvitationsCompanion toCompanion(bool nullToAbsent) {
    return FamilyInvitationsCompanion(
      id: Value(id),
      petId: Value(petId),
      email: Value(email),
      role: Value(role),
      permissions: Value(permissions),
      status: Value(status),
      expiresAt: Value(expiresAt),
      createdAt: Value(createdAt),
    );
  }

  factory FamilyInvitation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyInvitation(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      permissions: serializer.fromJson<String>(json['permissions']),
      status: serializer.fromJson<String>(json['status']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'permissions': serializer.toJson<String>(permissions),
      'status': serializer.toJson<String>(status),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FamilyInvitation copyWith({
    int? id,
    int? petId,
    String? email,
    String? role,
    String? permissions,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) => FamilyInvitation(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    email: email ?? this.email,
    role: role ?? this.role,
    permissions: permissions ?? this.permissions,
    status: status ?? this.status,
    expiresAt: expiresAt ?? this.expiresAt,
    createdAt: createdAt ?? this.createdAt,
  );
  FamilyInvitation copyWithCompanion(FamilyInvitationsCompanion data) {
    return FamilyInvitation(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      permissions: data.permissions.present
          ? data.permissions.value
          : this.permissions,
      status: data.status.present ? data.status.value : this.status,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyInvitation(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('permissions: $permissions, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    petId,
    email,
    role,
    permissions,
    status,
    expiresAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyInvitation &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.email == this.email &&
          other.role == this.role &&
          other.permissions == this.permissions &&
          other.status == this.status &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt);
}

class FamilyInvitationsCompanion extends UpdateCompanion<FamilyInvitation> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> email;
  final Value<String> role;
  final Value<String> permissions;
  final Value<String> status;
  final Value<DateTime> expiresAt;
  final Value<DateTime> createdAt;
  const FamilyInvitationsCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.permissions = const Value.absent(),
    this.status = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FamilyInvitationsCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String email,
    required String role,
    this.permissions = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime expiresAt,
    this.createdAt = const Value.absent(),
  }) : petId = Value(petId),
       email = Value(email),
       role = Value(role),
       expiresAt = Value(expiresAt);
  static Insertable<FamilyInvitation> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? permissions,
    Expression<String>? status,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (permissions != null) 'permissions': permissions,
      if (status != null) 'status': status,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FamilyInvitationsCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? email,
    Value<String>? role,
    Value<String>? permissions,
    Value<String>? status,
    Value<DateTime>? expiresAt,
    Value<DateTime>? createdAt,
  }) {
    return FamilyInvitationsCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(permissions.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyInvitationsCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('permissions: $permissions, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('agendado'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    partnerName,
    service,
    scheduledAt,
    status,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partnerNameMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final int id;
  final int petId;
  final String partnerName;
  final String service;
  final DateTime scheduledAt;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const Appointment({
    required this.id,
    required this.petId,
    required this.partnerName,
    required this.service,
    required this.scheduledAt,
    required this.status,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['partner_name'] = Variable<String>(partnerName);
    map['service'] = Variable<String>(service);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      petId: Value(petId),
      partnerName: Value(partnerName),
      service: Value(service),
      scheduledAt: Value(scheduledAt),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      service: serializer.fromJson<String>(json['service']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'partnerName': serializer.toJson<String>(partnerName),
      'service': serializer.toJson<String>(service),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Appointment copyWith({
    int? id,
    int? petId,
    String? partnerName,
    String? service,
    DateTime? scheduledAt,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Appointment(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    partnerName: partnerName ?? this.partnerName,
    service: service ?? this.service,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      service: data.service.present ? data.service.value : this.service,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('partnerName: $partnerName, ')
          ..write('service: $service, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    petId,
    partnerName,
    service,
    scheduledAt,
    status,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.partnerName == this.partnerName &&
          other.service == this.service &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> partnerName;
  final Value<String> service;
  final Value<DateTime> scheduledAt;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.service = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String partnerName,
    required String service,
    required DateTime scheduledAt,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : petId = Value(petId),
       partnerName = Value(partnerName),
       service = Value(service),
       scheduledAt = Value(scheduledAt);
  static Insertable<Appointment> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? partnerName,
    Expression<String>? service,
    Expression<DateTime>? scheduledAt,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (partnerName != null) 'partner_name': partnerName,
      if (service != null) 'service': service,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppointmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? partnerName,
    Value<String>? service,
    Value<DateTime>? scheduledAt,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      partnerName: partnerName ?? this.partnerName,
      service: service ?? this.service,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('partnerName: $partnerName, ')
          ..write('service: $service, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VeterinaryContactsTable extends VeterinaryContacts
    with TableInfo<$VeterinaryContactsTable, VeterinaryContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VeterinaryContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Veterinário'),
  );
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _whatsappMeta = const VerificationMeta(
    'whatsapp',
  );
  @override
  late final GeneratedColumn<String> whatsapp = GeneratedColumn<String>(
    'whatsapp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    specialty,
    phone,
    whatsapp,
    address,
    city,
    state,
    notes,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'veterinary_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<VeterinaryContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('whatsapp')) {
      context.handle(
        _whatsappMeta,
        whatsapp.isAcceptableOrUnknown(data['whatsapp']!, _whatsappMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VeterinaryContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VeterinaryContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      whatsapp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}whatsapp'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VeterinaryContactsTable createAlias(String alias) {
    return $VeterinaryContactsTable(attachedDatabase, alias);
  }
}

class VeterinaryContact extends DataClass
    implements Insertable<VeterinaryContact> {
  final int id;
  final String name;
  final String kind;
  final String specialty;
  final String phone;
  final String whatsapp;
  final String address;
  final String city;
  final String state;
  final String notes;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VeterinaryContact({
    required this.id,
    required this.name,
    required this.kind,
    required this.specialty,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.city,
    required this.state,
    required this.notes,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['specialty'] = Variable<String>(specialty);
    map['phone'] = Variable<String>(phone);
    map['whatsapp'] = Variable<String>(whatsapp);
    map['address'] = Variable<String>(address);
    map['city'] = Variable<String>(city);
    map['state'] = Variable<String>(state);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VeterinaryContactsCompanion toCompanion(bool nullToAbsent) {
    return VeterinaryContactsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      specialty: Value(specialty),
      phone: Value(phone),
      whatsapp: Value(whatsapp),
      address: Value(address),
      city: Value(city),
      state: Value(state),
      notes: Value(notes),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VeterinaryContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VeterinaryContact(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      specialty: serializer.fromJson<String>(json['specialty']),
      phone: serializer.fromJson<String>(json['phone']),
      whatsapp: serializer.fromJson<String>(json['whatsapp']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      state: serializer.fromJson<String>(json['state']),
      notes: serializer.fromJson<String>(json['notes']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'specialty': serializer.toJson<String>(specialty),
      'phone': serializer.toJson<String>(phone),
      'whatsapp': serializer.toJson<String>(whatsapp),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'state': serializer.toJson<String>(state),
      'notes': serializer.toJson<String>(notes),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VeterinaryContact copyWith({
    int? id,
    String? name,
    String? kind,
    String? specialty,
    String? phone,
    String? whatsapp,
    String? address,
    String? city,
    String? state,
    String? notes,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VeterinaryContact(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    specialty: specialty ?? this.specialty,
    phone: phone ?? this.phone,
    whatsapp: whatsapp ?? this.whatsapp,
    address: address ?? this.address,
    city: city ?? this.city,
    state: state ?? this.state,
    notes: notes ?? this.notes,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VeterinaryContact copyWithCompanion(VeterinaryContactsCompanion data) {
    return VeterinaryContact(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      phone: data.phone.present ? data.phone.value : this.phone,
      whatsapp: data.whatsapp.present ? data.whatsapp.value : this.whatsapp,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      notes: data.notes.present ? data.notes.value : this.notes,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VeterinaryContact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('specialty: $specialty, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    specialty,
    phone,
    whatsapp,
    address,
    city,
    state,
    notes,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VeterinaryContact &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.specialty == this.specialty &&
          other.phone == this.phone &&
          other.whatsapp == this.whatsapp &&
          other.address == this.address &&
          other.city == this.city &&
          other.state == this.state &&
          other.notes == this.notes &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VeterinaryContactsCompanion extends UpdateCompanion<VeterinaryContact> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> specialty;
  final Value<String> phone;
  final Value<String> whatsapp;
  final Value<String> address;
  final Value<String> city;
  final Value<String> state;
  final Value<String> notes;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const VeterinaryContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.notes = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VeterinaryContactsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.kind = const Value.absent(),
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.notes = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<VeterinaryContact> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? specialty,
    Expression<String>? phone,
    Expression<String>? whatsapp,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? notes,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (specialty != null) 'specialty': specialty,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (notes != null) 'notes': notes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VeterinaryContactsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? specialty,
    Value<String>? phone,
    Value<String>? whatsapp,
    Value<String>? address,
    Value<String>? city,
    Value<String>? state,
    Value<String>? notes,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return VeterinaryContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (whatsapp.present) {
      map['whatsapp'] = Variable<String>(whatsapp.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VeterinaryContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('specialty: $specialty, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, WeightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    weight,
    measuredAt,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class WeightEntry extends DataClass implements Insertable<WeightEntry> {
  final int id;
  final int petId;
  final double weight;
  final DateTime measuredAt;
  final String? note;
  final DateTime createdAt;
  const WeightEntry({
    required this.id,
    required this.petId,
    required this.weight,
    required this.measuredAt,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['weight'] = Variable<double>(weight);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(
      id: Value(id),
      petId: Value(petId),
      weight: Value(weight),
      measuredAt: Value(measuredAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory WeightEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEntry(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      weight: serializer.fromJson<double>(json['weight']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'weight': serializer.toJson<double>(weight),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WeightEntry copyWith({
    int? id,
    int? petId,
    double? weight,
    DateTime? measuredAt,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => WeightEntry(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    weight: weight ?? this.weight,
    measuredAt: measuredAt ?? this.measuredAt,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  WeightEntry copyWithCompanion(WeightEntriesCompanion data) {
    return WeightEntry(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      weight: data.weight.present ? data.weight.value : this.weight,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntry(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('weight: $weight, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, petId, weight, measuredAt, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEntry &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.weight == this.weight &&
          other.measuredAt == this.measuredAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class WeightEntriesCompanion extends UpdateCompanion<WeightEntry> {
  final Value<int> id;
  final Value<int> petId;
  final Value<double> weight;
  final Value<DateTime> measuredAt;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const WeightEntriesCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.weight = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required double weight,
    required DateTime measuredAt,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : petId = Value(petId),
       weight = Value(weight),
       measuredAt = Value(measuredAt);
  static Insertable<WeightEntry> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<double>? weight,
    Expression<DateTime>? measuredAt,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (weight != null) 'weight': weight,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WeightEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<double>? weight,
    Value<DateTime>? measuredAt,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return WeightEntriesCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      measuredAt: measuredAt ?? this.measuredAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('weight: $weight, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 180,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free_offline'),
  );
  static const VerificationMeta _familyValidUntilMeta = const VerificationMeta(
    'familyValidUntil',
  );
  @override
  late final GeneratedColumn<DateTime> familyValidUntil =
      GeneratedColumn<DateTime>(
        'family_valid_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    plan,
    familyValidUntil,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    }
    if (data.containsKey('family_valid_until')) {
      context.handle(
        _familyValidUntilMeta,
        familyValidUntil.isAcceptableOrUnknown(
          data['family_valid_until']!,
          _familyValidUntilMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      )!,
      familyValidUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}family_valid_until'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String name;
  final String email;
  final String plan;
  final DateTime? familyValidUntil;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    this.familyValidUntil,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['plan'] = Variable<String>(plan);
    if (!nullToAbsent || familyValidUntil != null) {
      map['family_valid_until'] = Variable<DateTime>(familyValidUntil);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      plan: Value(plan),
      familyValidUntil: familyValidUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(familyValidUntil),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      plan: serializer.fromJson<String>(json['plan']),
      familyValidUntil: serializer.fromJson<DateTime?>(
        json['familyValidUntil'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'plan': serializer.toJson<String>(plan),
      'familyValidUntil': serializer.toJson<DateTime?>(familyValidUntil),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? plan,
    Value<DateTime?> familyValidUntil = const Value.absent(),
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    plan: plan ?? this.plan,
    familyValidUntil: familyValidUntil.present
        ? familyValidUntil.value
        : this.familyValidUntil,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      plan: data.plan.present ? data.plan.value : this.plan,
      familyValidUntil: data.familyValidUntil.present
          ? data.familyValidUntil.value
          : this.familyValidUntil,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('plan: $plan, ')
          ..write('familyValidUntil: $familyValidUntil, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, plan, familyValidUntil, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.plan == this.plan &&
          other.familyValidUntil == this.familyValidUntil &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> plan;
  final Value<DateTime?> familyValidUntil;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.plan = const Value.absent(),
    this.familyValidUntil = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    this.plan = const Value.absent(),
    this.familyValidUntil = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       email = Value(email);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? plan,
    Expression<DateTime>? familyValidUntil,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (plan != null) 'plan': plan,
      if (familyValidUntil != null) 'family_valid_until': familyValidUntil,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? plan,
    Value<DateTime?>? familyValidUntil,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      familyValidUntil: familyValidUntil ?? this.familyValidUntil,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (familyValidUntil.present) {
      map['family_valid_until'] = Variable<DateTime>(familyValidUntil.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('plan: $plan, ')
          ..write('familyValidUntil: $familyValidUntil, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperation extends DataClass implements Insertable<SyncOperation> {
  final int id;
  final String entityType;
  final int? entityId;
  final String operation;
  final String payload;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const SyncOperation({
    required this.id,
    required this.entityType,
    this.entityId,
    required this.operation,
    required this.payload,
    required this.occurredAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperation(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<int?>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncOperation copyWith({
    int? id,
    String? entityType,
    Value<int?> entityId = const Value.absent(),
    String? operation,
    String? payload,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SyncOperation(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SyncOperation copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperation(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperation(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperation &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperation> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int?> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  const SyncOperationsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    this.entityId = const Value.absent(),
    required String operation,
    this.payload = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  }) : entityType = Value(entityType),
       operation = Value(operation);
  static Insertable<SyncOperation> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncOperationsCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<int?>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
  }) {
    return SyncOperationsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      occurredAt: occurredAt ?? this.occurredAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PetsTable pets = $PetsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $VaccinesTable vaccines = $VaccinesTable(this);
  late final $PreventiveRecordsTable preventiveRecords =
      $PreventiveRecordsTable(this);
  late final $MedicationPlansTable medicationPlans = $MedicationPlansTable(
    this,
  );
  late final $FamilyInvitationsTable familyInvitations =
      $FamilyInvitationsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $VeterinaryContactsTable veterinaryContacts =
      $VeterinaryContactsTable(this);
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pets,
    reminders,
    vaccines,
    preventiveRecords,
    medicationPlans,
    familyInvitations,
    appointments,
    veterinaryContacts,
    weightEntries,
    userProfiles,
    syncOperations,
  ];
}

typedef $$PetsTableCreateCompanionBuilder =
    PetsCompanion Function({
      Value<int> id,
      required String name,
      required String species,
      required String breed,
      Value<String> emoji,
      Value<double> weight,
      Value<String> allergies,
      Value<DateTime?> birthDate,
      Value<String> sex,
      Value<String> color,
      Value<String> characteristics,
      Value<bool> hasPedigree,
      Value<String?> pedigreeNumber,
      Value<String?> microchip,
      Value<String> size,
      Value<String> reproductiveStatus,
      Value<double?> bodyConditionScore,
      Value<String> clinicReference,
      Value<String> veterinarianReference,
      Value<String> documentNotes,
      Value<String?> photoData,
      Value<DateTime> createdAt,
    });
typedef $$PetsTableUpdateCompanionBuilder =
    PetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> species,
      Value<String> breed,
      Value<String> emoji,
      Value<double> weight,
      Value<String> allergies,
      Value<DateTime?> birthDate,
      Value<String> sex,
      Value<String> color,
      Value<String> characteristics,
      Value<bool> hasPedigree,
      Value<String?> pedigreeNumber,
      Value<String?> microchip,
      Value<String> size,
      Value<String> reproductiveStatus,
      Value<double?> bodyConditionScore,
      Value<String> clinicReference,
      Value<String> veterinarianReference,
      Value<String> documentNotes,
      Value<String?> photoData,
      Value<DateTime> createdAt,
    });

final class $$PetsTableReferences
    extends BaseReferences<_$AppDatabase, $PetsTable, Pet> {
  $$PetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'pets__id__reminders__pet_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VaccinesTable, List<Vaccine>> _vaccinesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vaccines,
    aliasName: 'pets__id__vaccines__pet_id',
  );

  $$VaccinesTableProcessedTableManager get vaccinesRefs {
    final manager = $$VaccinesTableTableManager(
      $_db,
      $_db.vaccines,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vaccinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PreventiveRecordsTable, List<PreventiveRecord>>
  _preventiveRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.preventiveRecords,
        aliasName: 'pets__id__preventive_records__pet_id',
      );

  $$PreventiveRecordsTableProcessedTableManager get preventiveRecordsRefs {
    final manager = $$PreventiveRecordsTableTableManager(
      $_db,
      $_db.preventiveRecords,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preventiveRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MedicationPlansTable, List<MedicationPlan>>
  _medicationPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicationPlans,
    aliasName: 'pets__id__medication_plans__pet_id',
  );

  $$MedicationPlansTableProcessedTableManager get medicationPlansRefs {
    final manager = $$MedicationPlansTableTableManager(
      $_db,
      $_db.medicationPlans,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationPlansRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FamilyInvitationsTable, List<FamilyInvitation>>
  _familyInvitationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.familyInvitations,
        aliasName: 'pets__id__family_invitations__pet_id',
      );

  $$FamilyInvitationsTableProcessedTableManager get familyInvitationsRefs {
    final manager = $$FamilyInvitationsTableTableManager(
      $_db,
      $_db.familyInvitations,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _familyInvitationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppointmentsTable, List<Appointment>>
  _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appointments,
    aliasName: 'pets__id__appointments__pet_id',
  );

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager(
      $_db,
      $_db.appointments,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WeightEntriesTable, List<WeightEntry>>
  _weightEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weightEntries,
    aliasName: 'pets__id__weight_entries__pet_id',
  );

  $$WeightEntriesTableProcessedTableManager get weightEntriesRefs {
    final manager = $$WeightEntriesTableTableManager(
      $_db,
      $_db.weightEntries,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weightEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PetsTableFilterComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characteristics => $composableBuilder(
    column: $table.characteristics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPedigree => $composableBuilder(
    column: $table.hasPedigree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pedigreeNumber => $composableBuilder(
    column: $table.pedigreeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get microchip => $composableBuilder(
    column: $table.microchip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reproductiveStatus => $composableBuilder(
    column: $table.reproductiveStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyConditionScore => $composableBuilder(
    column: $table.bodyConditionScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicReference => $composableBuilder(
    column: $table.clinicReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get veterinarianReference => $composableBuilder(
    column: $table.veterinarianReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentNotes => $composableBuilder(
    column: $table.documentNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoData => $composableBuilder(
    column: $table.photoData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vaccinesRefs(
    Expression<bool> Function($$VaccinesTableFilterComposer f) f,
  ) {
    final $$VaccinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vaccines,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaccinesTableFilterComposer(
            $db: $db,
            $table: $db.vaccines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> preventiveRecordsRefs(
    Expression<bool> Function($$PreventiveRecordsTableFilterComposer f) f,
  ) {
    final $$PreventiveRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preventiveRecords,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreventiveRecordsTableFilterComposer(
            $db: $db,
            $table: $db.preventiveRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicationPlansRefs(
    Expression<bool> Function($$MedicationPlansTableFilterComposer f) f,
  ) {
    final $$MedicationPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationPlans,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationPlansTableFilterComposer(
            $db: $db,
            $table: $db.medicationPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> familyInvitationsRefs(
    Expression<bool> Function($$FamilyInvitationsTableFilterComposer f) f,
  ) {
    final $$FamilyInvitationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.familyInvitations,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyInvitationsTableFilterComposer(
            $db: $db,
            $table: $db.familyInvitations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appointmentsRefs(
    Expression<bool> Function($$AppointmentsTableFilterComposer f) f,
  ) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableFilterComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> weightEntriesRefs(
    Expression<bool> Function($$WeightEntriesTableFilterComposer f) f,
  ) {
    final $$WeightEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weightEntries,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeightEntriesTableFilterComposer(
            $db: $db,
            $table: $db.weightEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PetsTableOrderingComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characteristics => $composableBuilder(
    column: $table.characteristics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPedigree => $composableBuilder(
    column: $table.hasPedigree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pedigreeNumber => $composableBuilder(
    column: $table.pedigreeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get microchip => $composableBuilder(
    column: $table.microchip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reproductiveStatus => $composableBuilder(
    column: $table.reproductiveStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyConditionScore => $composableBuilder(
    column: $table.bodyConditionScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicReference => $composableBuilder(
    column: $table.clinicReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get veterinarianReference => $composableBuilder(
    column: $table.veterinarianReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentNotes => $composableBuilder(
    column: $table.documentNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoData => $composableBuilder(
    column: $table.photoData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get characteristics => $composableBuilder(
    column: $table.characteristics,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasPedigree => $composableBuilder(
    column: $table.hasPedigree,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pedigreeNumber => $composableBuilder(
    column: $table.pedigreeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get microchip =>
      $composableBuilder(column: $table.microchip, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get reproductiveStatus => $composableBuilder(
    column: $table.reproductiveStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bodyConditionScore => $composableBuilder(
    column: $table.bodyConditionScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicReference => $composableBuilder(
    column: $table.clinicReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get veterinarianReference => $composableBuilder(
    column: $table.veterinarianReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentNotes => $composableBuilder(
    column: $table.documentNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoData =>
      $composableBuilder(column: $table.photoData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vaccinesRefs<T extends Object>(
    Expression<T> Function($$VaccinesTableAnnotationComposer a) f,
  ) {
    final $$VaccinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vaccines,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaccinesTableAnnotationComposer(
            $db: $db,
            $table: $db.vaccines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> preventiveRecordsRefs<T extends Object>(
    Expression<T> Function($$PreventiveRecordsTableAnnotationComposer a) f,
  ) {
    final $$PreventiveRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.preventiveRecords,
          getReferencedColumn: (t) => t.petId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreventiveRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.preventiveRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> medicationPlansRefs<T extends Object>(
    Expression<T> Function($$MedicationPlansTableAnnotationComposer a) f,
  ) {
    final $$MedicationPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationPlans,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> familyInvitationsRefs<T extends Object>(
    Expression<T> Function($$FamilyInvitationsTableAnnotationComposer a) f,
  ) {
    final $$FamilyInvitationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.familyInvitations,
          getReferencedColumn: (t) => t.petId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FamilyInvitationsTableAnnotationComposer(
                $db: $db,
                $table: $db.familyInvitations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> appointmentsRefs<T extends Object>(
    Expression<T> Function($$AppointmentsTableAnnotationComposer a) f,
  ) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> weightEntriesRefs<T extends Object>(
    Expression<T> Function($$WeightEntriesTableAnnotationComposer a) f,
  ) {
    final $$WeightEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weightEntries,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeightEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.weightEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PetsTable,
          Pet,
          $$PetsTableFilterComposer,
          $$PetsTableOrderingComposer,
          $$PetsTableAnnotationComposer,
          $$PetsTableCreateCompanionBuilder,
          $$PetsTableUpdateCompanionBuilder,
          (Pet, $$PetsTableReferences),
          Pet,
          PrefetchHooks Function({
            bool remindersRefs,
            bool vaccinesRefs,
            bool preventiveRecordsRefs,
            bool medicationPlansRefs,
            bool familyInvitationsRefs,
            bool appointmentsRefs,
            bool weightEntriesRefs,
          })
        > {
  $$PetsTableTableManager(_$AppDatabase db, $PetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String> breed = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String> allergies = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> characteristics = const Value.absent(),
                Value<bool> hasPedigree = const Value.absent(),
                Value<String?> pedigreeNumber = const Value.absent(),
                Value<String?> microchip = const Value.absent(),
                Value<String> size = const Value.absent(),
                Value<String> reproductiveStatus = const Value.absent(),
                Value<double?> bodyConditionScore = const Value.absent(),
                Value<String> clinicReference = const Value.absent(),
                Value<String> veterinarianReference = const Value.absent(),
                Value<String> documentNotes = const Value.absent(),
                Value<String?> photoData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PetsCompanion(
                id: id,
                name: name,
                species: species,
                breed: breed,
                emoji: emoji,
                weight: weight,
                allergies: allergies,
                birthDate: birthDate,
                sex: sex,
                color: color,
                characteristics: characteristics,
                hasPedigree: hasPedigree,
                pedigreeNumber: pedigreeNumber,
                microchip: microchip,
                size: size,
                reproductiveStatus: reproductiveStatus,
                bodyConditionScore: bodyConditionScore,
                clinicReference: clinicReference,
                veterinarianReference: veterinarianReference,
                documentNotes: documentNotes,
                photoData: photoData,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String species,
                required String breed,
                Value<String> emoji = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String> allergies = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> characteristics = const Value.absent(),
                Value<bool> hasPedigree = const Value.absent(),
                Value<String?> pedigreeNumber = const Value.absent(),
                Value<String?> microchip = const Value.absent(),
                Value<String> size = const Value.absent(),
                Value<String> reproductiveStatus = const Value.absent(),
                Value<double?> bodyConditionScore = const Value.absent(),
                Value<String> clinicReference = const Value.absent(),
                Value<String> veterinarianReference = const Value.absent(),
                Value<String> documentNotes = const Value.absent(),
                Value<String?> photoData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PetsCompanion.insert(
                id: id,
                name: name,
                species: species,
                breed: breed,
                emoji: emoji,
                weight: weight,
                allergies: allergies,
                birthDate: birthDate,
                sex: sex,
                color: color,
                characteristics: characteristics,
                hasPedigree: hasPedigree,
                pedigreeNumber: pedigreeNumber,
                microchip: microchip,
                size: size,
                reproductiveStatus: reproductiveStatus,
                bodyConditionScore: bodyConditionScore,
                clinicReference: clinicReference,
                veterinarianReference: veterinarianReference,
                documentNotes: documentNotes,
                photoData: photoData,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PetsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                remindersRefs = false,
                vaccinesRefs = false,
                preventiveRecordsRefs = false,
                medicationPlansRefs = false,
                familyInvitationsRefs = false,
                appointmentsRefs = false,
                weightEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (remindersRefs) db.reminders,
                    if (vaccinesRefs) db.vaccines,
                    if (preventiveRecordsRefs) db.preventiveRecords,
                    if (medicationPlansRefs) db.medicationPlans,
                    if (familyInvitationsRefs) db.familyInvitations,
                    if (appointmentsRefs) db.appointments,
                    if (weightEntriesRefs) db.weightEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (remindersRefs)
                        await $_getPrefetchedData<Pet, $PetsTable, Reminder>(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.petId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vaccinesRefs)
                        await $_getPrefetchedData<Pet, $PetsTable, Vaccine>(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._vaccinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PetsTableReferences(db, table, p0).vaccinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.petId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (preventiveRecordsRefs)
                        await $_getPrefetchedData<
                          Pet,
                          $PetsTable,
                          PreventiveRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._preventiveRecordsRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).preventiveRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.petId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicationPlansRefs)
                        await $_getPrefetchedData<
                          Pet,
                          $PetsTable,
                          MedicationPlan
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._medicationPlansRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).medicationPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.petId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (familyInvitationsRefs)
                        await $_getPrefetchedData<
                          Pet,
                          $PetsTable,
                          FamilyInvitation
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._familyInvitationsRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).familyInvitationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.petId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appointmentsRefs)
                        await $_getPrefetchedData<Pet, $PetsTable, Appointment>(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._appointmentsRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).appointmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.petId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (weightEntriesRefs)
                        await $_getPrefetchedData<Pet, $PetsTable, WeightEntry>(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._weightEntriesRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).weightEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.petId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PetsTable,
      Pet,
      $$PetsTableFilterComposer,
      $$PetsTableOrderingComposer,
      $$PetsTableAnnotationComposer,
      $$PetsTableCreateCompanionBuilder,
      $$PetsTableUpdateCompanionBuilder,
      (Pet, $$PetsTableReferences),
      Pet,
      PrefetchHooks Function({
        bool remindersRefs,
        bool vaccinesRefs,
        bool preventiveRecordsRefs,
        bool medicationPlansRefs,
        bool familyInvitationsRefs,
        bool appointmentsRefs,
        bool weightEntriesRefs,
      })
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required String title,
      required int petId,
      required String petName,
      Value<String> icon,
      Value<String> category,
      required DateTime dueAt,
      Value<int> intervalDays,
      Value<DateTime?> lastCompletedAt,
      Value<DateTime> createdAt,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> petId,
      Value<String> petName,
      Value<String> icon,
      Value<String> category,
      Value<DateTime> dueAt,
      Value<int> intervalDays,
      Value<DateTime?> lastCompletedAt,
      Value<DateTime> createdAt,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('reminders__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<int>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get petName => $composableBuilder(
    column: $table.petName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get petName => $composableBuilder(
    column: $table.petName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get petName =>
      $composableBuilder(column: $table.petName, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool petId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> petName = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                title: title,
                petId: petId,
                petName: petName,
                icon: icon,
                category: category,
                dueAt: dueAt,
                intervalDays: intervalDays,
                lastCompletedAt: lastCompletedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int petId,
                required String petName,
                Value<String> icon = const Value.absent(),
                Value<String> category = const Value.absent(),
                required DateTime dueAt,
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                title: title,
                petId: petId,
                petName: petName,
                icon: icon,
                category: category,
                dueAt: dueAt,
                intervalDays: intervalDays,
                lastCompletedAt: lastCompletedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.petId,
                                referencedTable: $$RemindersTableReferences
                                    ._petIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._petIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool petId})
    >;
typedef $$VaccinesTableCreateCompanionBuilder =
    VaccinesCompanion Function({
      Value<int> id,
      required int petId,
      required String name,
      required DateTime appliedAt,
      Value<DateTime?> nextDoseAt,
      Value<String?> clinicName,
      Value<String?> batchNumber,
      Value<DateTime> createdAt,
    });
typedef $$VaccinesTableUpdateCompanionBuilder =
    VaccinesCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<String> name,
      Value<DateTime> appliedAt,
      Value<DateTime?> nextDoseAt,
      Value<String?> clinicName,
      Value<String?> batchNumber,
      Value<DateTime> createdAt,
    });

final class $$VaccinesTableReferences
    extends BaseReferences<_$AppDatabase, $VaccinesTable, Vaccine> {
  $$VaccinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('vaccines__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<int>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VaccinesTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinesTable> {
  $$VaccinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDoseAt => $composableBuilder(
    column: $table.nextDoseAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VaccinesTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinesTable> {
  $$VaccinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDoseAt => $composableBuilder(
    column: $table.nextDoseAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VaccinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinesTable> {
  $$VaccinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDoseAt => $composableBuilder(
    column: $table.nextDoseAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VaccinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaccinesTable,
          Vaccine,
          $$VaccinesTableFilterComposer,
          $$VaccinesTableOrderingComposer,
          $$VaccinesTableAnnotationComposer,
          $$VaccinesTableCreateCompanionBuilder,
          $$VaccinesTableUpdateCompanionBuilder,
          (Vaccine, $$VaccinesTableReferences),
          Vaccine,
          PrefetchHooks Function({bool petId})
        > {
  $$VaccinesTableTableManager(_$AppDatabase db, $VaccinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<DateTime?> nextDoseAt = const Value.absent(),
                Value<String?> clinicName = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VaccinesCompanion(
                id: id,
                petId: petId,
                name: name,
                appliedAt: appliedAt,
                nextDoseAt: nextDoseAt,
                clinicName: clinicName,
                batchNumber: batchNumber,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String name,
                required DateTime appliedAt,
                Value<DateTime?> nextDoseAt = const Value.absent(),
                Value<String?> clinicName = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VaccinesCompanion.insert(
                id: id,
                petId: petId,
                name: name,
                appliedAt: appliedAt,
                nextDoseAt: nextDoseAt,
                clinicName: clinicName,
                batchNumber: batchNumber,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VaccinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.petId,
                                referencedTable: $$VaccinesTableReferences
                                    ._petIdTable(db),
                                referencedColumn: $$VaccinesTableReferences
                                    ._petIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VaccinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaccinesTable,
      Vaccine,
      $$VaccinesTableFilterComposer,
      $$VaccinesTableOrderingComposer,
      $$VaccinesTableAnnotationComposer,
      $$VaccinesTableCreateCompanionBuilder,
      $$VaccinesTableUpdateCompanionBuilder,
      (Vaccine, $$VaccinesTableReferences),
      Vaccine,
      PrefetchHooks Function({bool petId})
    >;
typedef $$PreventiveRecordsTableCreateCompanionBuilder =
    PreventiveRecordsCompanion Function({
      Value<int> id,
      required int petId,
      required String category,
      required String product,
      required DateTime appliedAt,
      Value<DateTime?> nextDueAt,
      Value<String?> provider,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$PreventiveRecordsTableUpdateCompanionBuilder =
    PreventiveRecordsCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<String> category,
      Value<String> product,
      Value<DateTime> appliedAt,
      Value<DateTime?> nextDueAt,
      Value<String?> provider,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$PreventiveRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PreventiveRecordsTable,
          PreventiveRecord
        > {
  $$PreventiveRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('preventive_records__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<int>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreventiveRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PreventiveRecordsTable> {
  $$PreventiveRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreventiveRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PreventiveRecordsTable> {
  $$PreventiveRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreventiveRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreventiveRecordsTable> {
  $$PreventiveRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get product =>
      $composableBuilder(column: $table.product, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreventiveRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreventiveRecordsTable,
          PreventiveRecord,
          $$PreventiveRecordsTableFilterComposer,
          $$PreventiveRecordsTableOrderingComposer,
          $$PreventiveRecordsTableAnnotationComposer,
          $$PreventiveRecordsTableCreateCompanionBuilder,
          $$PreventiveRecordsTableUpdateCompanionBuilder,
          (PreventiveRecord, $$PreventiveRecordsTableReferences),
          PreventiveRecord,
          PrefetchHooks Function({bool petId})
        > {
  $$PreventiveRecordsTableTableManager(
    _$AppDatabase db,
    $PreventiveRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreventiveRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreventiveRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreventiveRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> product = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PreventiveRecordsCompanion(
                id: id,
                petId: petId,
                category: category,
                product: product,
                appliedAt: appliedAt,
                nextDueAt: nextDueAt,
                provider: provider,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String category,
                required String product,
                required DateTime appliedAt,
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PreventiveRecordsCompanion.insert(
                id: id,
                petId: petId,
                category: category,
                product: product,
                appliedAt: appliedAt,
                nextDueAt: nextDueAt,
                provider: provider,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreventiveRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.petId,
                                referencedTable:
                                    $$PreventiveRecordsTableReferences
                                        ._petIdTable(db),
                                referencedColumn:
                                    $$PreventiveRecordsTableReferences
                                        ._petIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PreventiveRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreventiveRecordsTable,
      PreventiveRecord,
      $$PreventiveRecordsTableFilterComposer,
      $$PreventiveRecordsTableOrderingComposer,
      $$PreventiveRecordsTableAnnotationComposer,
      $$PreventiveRecordsTableCreateCompanionBuilder,
      $$PreventiveRecordsTableUpdateCompanionBuilder,
      (PreventiveRecord, $$PreventiveRecordsTableReferences),
      PreventiveRecord,
      PrefetchHooks Function({bool petId})
    >;
typedef $$MedicationPlansTableCreateCompanionBuilder =
    MedicationPlansCompanion Function({
      Value<int> id,
      required int petId,
      required String name,
      required String dosage,
      required String schedule,
      required DateTime startAt,
      Value<DateTime?> endAt,
      Value<bool> active,
      Value<DateTime?> lastTakenAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$MedicationPlansTableUpdateCompanionBuilder =
    MedicationPlansCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<String> name,
      Value<String> dosage,
      Value<String> schedule,
      Value<DateTime> startAt,
      Value<DateTime?> endAt,
      Value<bool> active,
      Value<DateTime?> lastTakenAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$MedicationPlansTableReferences
    extends
        BaseReferences<_$AppDatabase, $MedicationPlansTable, MedicationPlan> {
  $$MedicationPlansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('medication_plans__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<int>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationPlansTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationPlansTable> {
  $$MedicationPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTakenAt => $composableBuilder(
    column: $table.lastTakenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationPlansTable> {
  $$MedicationPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTakenAt => $composableBuilder(
    column: $table.lastTakenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationPlansTable> {
  $$MedicationPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get lastTakenAt => $composableBuilder(
    column: $table.lastTakenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationPlansTable,
          MedicationPlan,
          $$MedicationPlansTableFilterComposer,
          $$MedicationPlansTableOrderingComposer,
          $$MedicationPlansTableAnnotationComposer,
          $$MedicationPlansTableCreateCompanionBuilder,
          $$MedicationPlansTableUpdateCompanionBuilder,
          (MedicationPlan, $$MedicationPlansTableReferences),
          MedicationPlan,
          PrefetchHooks Function({bool petId})
        > {
  $$MedicationPlansTableTableManager(
    _$AppDatabase db,
    $MedicationPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<String> schedule = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastTakenAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicationPlansCompanion(
                id: id,
                petId: petId,
                name: name,
                dosage: dosage,
                schedule: schedule,
                startAt: startAt,
                endAt: endAt,
                active: active,
                lastTakenAt: lastTakenAt,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String name,
                required String dosage,
                required String schedule,
                required DateTime startAt,
                Value<DateTime?> endAt = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastTakenAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicationPlansCompanion.insert(
                id: id,
                petId: petId,
                name: name,
                dosage: dosage,
                schedule: schedule,
                startAt: startAt,
                endAt: endAt,
                active: active,
                lastTakenAt: lastTakenAt,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.petId,
                                referencedTable:
                                    $$MedicationPlansTableReferences
                                        ._petIdTable(db),
                                referencedColumn:
                                    $$MedicationPlansTableReferences
                                        ._petIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicationPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationPlansTable,
      MedicationPlan,
      $$MedicationPlansTableFilterComposer,
      $$MedicationPlansTableOrderingComposer,
      $$MedicationPlansTableAnnotationComposer,
      $$MedicationPlansTableCreateCompanionBuilder,
      $$MedicationPlansTableUpdateCompanionBuilder,
      (MedicationPlan, $$MedicationPlansTableReferences),
      MedicationPlan,
      PrefetchHooks Function({bool petId})
    >;
typedef $$FamilyInvitationsTableCreateCompanionBuilder =
    FamilyInvitationsCompanion Function({
      Value<int> id,
      required int petId,
      required String email,
      required String role,
      Value<String> permissions,
      Value<String> status,
      required DateTime expiresAt,
      Value<DateTime> createdAt,
    });
typedef $$FamilyInvitationsTableUpdateCompanionBuilder =
    FamilyInvitationsCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<String> email,
      Value<String> role,
      Value<String> permissions,
      Value<String> status,
      Value<DateTime> expiresAt,
      Value<DateTime> createdAt,
    });

final class $$FamilyInvitationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FamilyInvitationsTable,
          FamilyInvitation
        > {
  $$FamilyInvitationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('family_invitations__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<int>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FamilyInvitationsTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyInvitationsTable> {
  $$FamilyInvitationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FamilyInvitationsTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyInvitationsTable> {
  $$FamilyInvitationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FamilyInvitationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyInvitationsTable> {
  $$FamilyInvitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FamilyInvitationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyInvitationsTable,
          FamilyInvitation,
          $$FamilyInvitationsTableFilterComposer,
          $$FamilyInvitationsTableOrderingComposer,
          $$FamilyInvitationsTableAnnotationComposer,
          $$FamilyInvitationsTableCreateCompanionBuilder,
          $$FamilyInvitationsTableUpdateCompanionBuilder,
          (FamilyInvitation, $$FamilyInvitationsTableReferences),
          FamilyInvitation,
          PrefetchHooks Function({bool petId})
        > {
  $$FamilyInvitationsTableTableManager(
    _$AppDatabase db,
    $FamilyInvitationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyInvitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyInvitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyInvitationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> permissions = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FamilyInvitationsCompanion(
                id: id,
                petId: petId,
                email: email,
                role: role,
                permissions: permissions,
                status: status,
                expiresAt: expiresAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String email,
                required String role,
                Value<String> permissions = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime expiresAt,
                Value<DateTime> createdAt = const Value.absent(),
              }) => FamilyInvitationsCompanion.insert(
                id: id,
                petId: petId,
                email: email,
                role: role,
                permissions: permissions,
                status: status,
                expiresAt: expiresAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FamilyInvitationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.petId,
                                referencedTable:
                                    $$FamilyInvitationsTableReferences
                                        ._petIdTable(db),
                                referencedColumn:
                                    $$FamilyInvitationsTableReferences
                                        ._petIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FamilyInvitationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyInvitationsTable,
      FamilyInvitation,
      $$FamilyInvitationsTableFilterComposer,
      $$FamilyInvitationsTableOrderingComposer,
      $$FamilyInvitationsTableAnnotationComposer,
      $$FamilyInvitationsTableCreateCompanionBuilder,
      $$FamilyInvitationsTableUpdateCompanionBuilder,
      (FamilyInvitation, $$FamilyInvitationsTableReferences),
      FamilyInvitation,
      PrefetchHooks Function({bool petId})
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      required int petId,
      required String partnerName,
      required String service,
      required DateTime scheduledAt,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<String> partnerName,
      Value<String> service,
      Value<DateTime> scheduledAt,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$AppointmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment> {
  $$AppointmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('appointments__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<int>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          Appointment,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (Appointment, $$AppointmentsTableReferences),
          Appointment,
          PrefetchHooks Function({bool petId})
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> partnerName = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                petId: petId,
                partnerName: partnerName,
                service: service,
                scheduledAt: scheduledAt,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String partnerName,
                required String service,
                required DateTime scheduledAt,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                petId: petId,
                partnerName: partnerName,
                service: service,
                scheduledAt: scheduledAt,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppointmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.petId,
                                referencedTable: $$AppointmentsTableReferences
                                    ._petIdTable(db),
                                referencedColumn: $$AppointmentsTableReferences
                                    ._petIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      Appointment,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (Appointment, $$AppointmentsTableReferences),
      Appointment,
      PrefetchHooks Function({bool petId})
    >;
typedef $$VeterinaryContactsTableCreateCompanionBuilder =
    VeterinaryContactsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> kind,
      Value<String> specialty,
      Value<String> phone,
      Value<String> whatsapp,
      Value<String> address,
      Value<String> city,
      Value<String> state,
      Value<String> notes,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$VeterinaryContactsTableUpdateCompanionBuilder =
    VeterinaryContactsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> kind,
      Value<String> specialty,
      Value<String> phone,
      Value<String> whatsapp,
      Value<String> address,
      Value<String> city,
      Value<String> state,
      Value<String> notes,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$VeterinaryContactsTableFilterComposer
    extends Composer<_$AppDatabase, $VeterinaryContactsTable> {
  $$VeterinaryContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VeterinaryContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $VeterinaryContactsTable> {
  $$VeterinaryContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VeterinaryContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VeterinaryContactsTable> {
  $$VeterinaryContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get whatsapp =>
      $composableBuilder(column: $table.whatsapp, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VeterinaryContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VeterinaryContactsTable,
          VeterinaryContact,
          $$VeterinaryContactsTableFilterComposer,
          $$VeterinaryContactsTableOrderingComposer,
          $$VeterinaryContactsTableAnnotationComposer,
          $$VeterinaryContactsTableCreateCompanionBuilder,
          $$VeterinaryContactsTableUpdateCompanionBuilder,
          (
            VeterinaryContact,
            BaseReferences<
              _$AppDatabase,
              $VeterinaryContactsTable,
              VeterinaryContact
            >,
          ),
          VeterinaryContact,
          PrefetchHooks Function()
        > {
  $$VeterinaryContactsTableTableManager(
    _$AppDatabase db,
    $VeterinaryContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VeterinaryContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VeterinaryContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VeterinaryContactsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> specialty = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> whatsapp = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VeterinaryContactsCompanion(
                id: id,
                name: name,
                kind: kind,
                specialty: specialty,
                phone: phone,
                whatsapp: whatsapp,
                address: address,
                city: city,
                state: state,
                notes: notes,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> kind = const Value.absent(),
                Value<String> specialty = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> whatsapp = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VeterinaryContactsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                specialty: specialty,
                phone: phone,
                whatsapp: whatsapp,
                address: address,
                city: city,
                state: state,
                notes: notes,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VeterinaryContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VeterinaryContactsTable,
      VeterinaryContact,
      $$VeterinaryContactsTableFilterComposer,
      $$VeterinaryContactsTableOrderingComposer,
      $$VeterinaryContactsTableAnnotationComposer,
      $$VeterinaryContactsTableCreateCompanionBuilder,
      $$VeterinaryContactsTableUpdateCompanionBuilder,
      (
        VeterinaryContact,
        BaseReferences<
          _$AppDatabase,
          $VeterinaryContactsTable,
          VeterinaryContact
        >,
      ),
      VeterinaryContact,
      PrefetchHooks Function()
    >;
typedef $$WeightEntriesTableCreateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<int> id,
      required int petId,
      required double weight,
      required DateTime measuredAt,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$WeightEntriesTableUpdateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<double> weight,
      Value<DateTime> measuredAt,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$WeightEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntry> {
  $$WeightEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('weight_entries__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<int>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEntriesTable,
          WeightEntry,
          $$WeightEntriesTableFilterComposer,
          $$WeightEntriesTableOrderingComposer,
          $$WeightEntriesTableAnnotationComposer,
          $$WeightEntriesTableCreateCompanionBuilder,
          $$WeightEntriesTableUpdateCompanionBuilder,
          (WeightEntry, $$WeightEntriesTableReferences),
          WeightEntry,
          PrefetchHooks Function({bool petId})
        > {
  $$WeightEntriesTableTableManager(_$AppDatabase db, $WeightEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WeightEntriesCompanion(
                id: id,
                petId: petId,
                weight: weight,
                measuredAt: measuredAt,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required double weight,
                required DateTime measuredAt,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WeightEntriesCompanion.insert(
                id: id,
                petId: petId,
                weight: weight,
                measuredAt: measuredAt,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WeightEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.petId,
                                referencedTable: $$WeightEntriesTableReferences
                                    ._petIdTable(db),
                                referencedColumn: $$WeightEntriesTableReferences
                                    ._petIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntriesTable,
      WeightEntry,
      $$WeightEntriesTableFilterComposer,
      $$WeightEntriesTableOrderingComposer,
      $$WeightEntriesTableAnnotationComposer,
      $$WeightEntriesTableCreateCompanionBuilder,
      $$WeightEntriesTableUpdateCompanionBuilder,
      (WeightEntry, $$WeightEntriesTableReferences),
      WeightEntry,
      PrefetchHooks Function({bool petId})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String name,
      required String email,
      Value<String> plan,
      Value<DateTime?> familyValidUntil,
      Value<DateTime> updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<String> plan,
      Value<DateTime?> familyValidUntil,
      Value<DateTime> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get familyValidUntil => $composableBuilder(
    column: $table.familyValidUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get familyValidUntil => $composableBuilder(
    column: $table.familyValidUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<DateTime> get familyValidUntil => $composableBuilder(
    column: $table.familyValidUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> plan = const Value.absent(),
                Value<DateTime?> familyValidUntil = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                email: email,
                plan: plan,
                familyValidUntil: familyValidUntil,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                Value<String> plan = const Value.absent(),
                Value<DateTime?> familyValidUntil = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                email: email,
                plan: plan,
                familyValidUntil: familyValidUntil,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$SyncOperationsTableCreateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<int> id,
      required String entityType,
      Value<int?> entityId,
      required String operation,
      Value<String> payload,
      Value<DateTime> occurredAt,
      Value<DateTime?> syncedAt,
    });
typedef $$SyncOperationsTableUpdateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<int?> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> occurredAt,
      Value<DateTime?> syncedAt,
    });

class $$SyncOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOperationsTable,
          SyncOperation,
          $$SyncOperationsTableFilterComposer,
          $$SyncOperationsTableOrderingComposer,
          $$SyncOperationsTableAnnotationComposer,
          $$SyncOperationsTableCreateCompanionBuilder,
          $$SyncOperationsTableUpdateCompanionBuilder,
          (
            SyncOperation,
            BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperation>,
          ),
          SyncOperation,
          PrefetchHooks Function()
        > {
  $$SyncOperationsTableTableManager(
    _$AppDatabase db,
    $SyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncOperationsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                Value<int?> entityId = const Value.absent(),
                required String operation,
                Value<String> payload = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncOperationsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOperationsTable,
      SyncOperation,
      $$SyncOperationsTableFilterComposer,
      $$SyncOperationsTableOrderingComposer,
      $$SyncOperationsTableAnnotationComposer,
      $$SyncOperationsTableCreateCompanionBuilder,
      $$SyncOperationsTableUpdateCompanionBuilder,
      (
        SyncOperation,
        BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperation>,
      ),
      SyncOperation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PetsTableTableManager get pets => $$PetsTableTableManager(_db, _db.pets);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$VaccinesTableTableManager get vaccines =>
      $$VaccinesTableTableManager(_db, _db.vaccines);
  $$PreventiveRecordsTableTableManager get preventiveRecords =>
      $$PreventiveRecordsTableTableManager(_db, _db.preventiveRecords);
  $$MedicationPlansTableTableManager get medicationPlans =>
      $$MedicationPlansTableTableManager(_db, _db.medicationPlans);
  $$FamilyInvitationsTableTableManager get familyInvitations =>
      $$FamilyInvitationsTableTableManager(_db, _db.familyInvitations);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$VeterinaryContactsTableTableManager get veterinaryContacts =>
      $$VeterinaryContactsTableTableManager(_db, _db.veterinaryContacts);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
}
