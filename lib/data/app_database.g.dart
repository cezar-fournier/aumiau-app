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
  final DateTime createdAt;
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.emoji,
    required this.weight,
    required this.allergies,
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
    DateTime? createdAt,
  }) => Pet(
    id: id ?? this.id,
    name: name ?? this.name,
    species: species ?? this.species,
    breed: breed ?? this.breed,
    emoji: emoji ?? this.emoji,
    weight: weight ?? this.weight,
    allergies: allergies ?? this.allergies,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    species,
    breed,
    emoji,
    weight,
    allergies,
    createdAt,
  );
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
  final Value<DateTime> createdAt;
  const PetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.emoji = const Value.absent(),
    this.weight = const Value.absent(),
    this.allergies = const Value.absent(),
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
    defaultValue: const Constant('Gratuito'),
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
  List<GeneratedColumn> get $columns => [id, name, email, plan, updatedAt];
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
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['plan'] = Variable<String>(plan);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      plan: Value(plan),
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
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? plan,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    plan: plan ?? this.plan,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      plan: data.plan.present ? data.plan.value : this.plan,
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
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, plan, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.plan == this.plan &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> plan;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.plan = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    this.plan = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       email = Value(email);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? plan,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (plan != null) 'plan': plan,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? plan,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => PetsCompanion(
                id: id,
                name: name,
                species: species,
                breed: breed,
                emoji: emoji,
                weight: weight,
                allergies: allergies,
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => PetsCompanion.insert(
                id: id,
                name: name,
                species: species,
                breed: breed,
                emoji: emoji,
                weight: weight,
                allergies: allergies,
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
                weightEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (remindersRefs) db.reminders,
                    if (vaccinesRefs) db.vaccines,
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
      Value<DateTime> updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<String> plan,
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
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                email: email,
                plan: plan,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                Value<String> plan = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                email: email,
                plan: plan,
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
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
}
