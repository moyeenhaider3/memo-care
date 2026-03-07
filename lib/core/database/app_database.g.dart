// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReminderChainsTable extends ReminderChains
    with TableInfo<$ReminderChainsTable, ReminderChain> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderChainsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReminderChainsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, name, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_chains';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderChain> instance, {
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
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderChain map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderChain(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: $ReminderChainsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $ReminderChainsTable createAlias(String alias) {
    return $ReminderChainsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeConverter();
}

class ReminderChain extends DataClass implements Insertable<ReminderChain> {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  const ReminderChain({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    {
      map['created_at'] = Variable<int>(
        $ReminderChainsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  ReminderChainsCompanion toCompanion(bool nullToAbsent) {
    return ReminderChainsCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory ReminderChain.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderChain(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReminderChain copyWith({
    int? id,
    String? name,
    bool? isActive,
    DateTime? createdAt,
  }) => ReminderChain(
    id: id ?? this.id,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  ReminderChain copyWithCompanion(ReminderChainsCompanion data) {
    return ReminderChain(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderChain(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderChain &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ReminderChainsCompanion extends UpdateCompanion<ReminderChain> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const ReminderChainsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReminderChainsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<ReminderChain> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReminderChainsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return ReminderChainsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
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
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ReminderChainsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderChainsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
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
  static const VerificationMeta _chainIdMeta = const VerificationMeta(
    'chainId',
  );
  @override
  late final GeneratedColumn<int> chainId = GeneratedColumn<int>(
    'chain_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminder_chains (id)',
    ),
  );
  static const VerificationMeta _medicineNameMeta = const VerificationMeta(
    'medicineName',
  );
  @override
  late final GeneratedColumn<String> medicineName = GeneratedColumn<String>(
    'medicine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineTypeMeta = const VerificationMeta(
    'medicineType',
  );
  @override
  late final GeneratedColumn<String> medicineType = GeneratedColumn<String>(
    'medicine_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> scheduledAt =
      GeneratedColumn<int>(
        'scheduled_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RemindersTable.$converterscheduledAtn);
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gapHoursMeta = const VerificationMeta(
    'gapHours',
  );
  @override
  late final GeneratedColumn<int> gapHours = GeneratedColumn<int>(
    'gap_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chainId,
    medicineName,
    medicineType,
    dosage,
    scheduledAt,
    isActive,
    gapHours,
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
    if (data.containsKey('chain_id')) {
      context.handle(
        _chainIdMeta,
        chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chainIdMeta);
    }
    if (data.containsKey('medicine_name')) {
      context.handle(
        _medicineNameMeta,
        medicineName.isAcceptableOrUnknown(
          data['medicine_name']!,
          _medicineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicineNameMeta);
    }
    if (data.containsKey('medicine_type')) {
      context.handle(
        _medicineTypeMeta,
        medicineType.isAcceptableOrUnknown(
          data['medicine_type']!,
          _medicineTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicineTypeMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('gap_hours')) {
      context.handle(
        _gapHoursMeta,
        gapHours.isAcceptableOrUnknown(data['gap_hours']!, _gapHoursMeta),
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
      chainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chain_id'],
      )!,
      medicineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_name'],
      )!,
      medicineType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_type'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      ),
      scheduledAt: $RemindersTable.$converterscheduledAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}scheduled_at'],
        ),
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      gapHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gap_hours'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterscheduledAt =
      const DateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterscheduledAtn =
      NullAwareTypeConverter.wrap($converterscheduledAt);
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int chainId;
  final String medicineName;
  final String medicineType;
  final String? dosage;
  final DateTime? scheduledAt;
  final bool isActive;
  final int? gapHours;
  const Reminder({
    required this.id,
    required this.chainId,
    required this.medicineName,
    required this.medicineType,
    this.dosage,
    this.scheduledAt,
    required this.isActive,
    this.gapHours,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chain_id'] = Variable<int>(chainId);
    map['medicine_name'] = Variable<String>(medicineName);
    map['medicine_type'] = Variable<String>(medicineType);
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<int>(
        $RemindersTable.$converterscheduledAtn.toSql(scheduledAt),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || gapHours != null) {
      map['gap_hours'] = Variable<int>(gapHours);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      chainId: Value(chainId),
      medicineName: Value(medicineName),
      medicineType: Value(medicineType),
      dosage: dosage == null && nullToAbsent
          ? const Value.absent()
          : Value(dosage),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      isActive: Value(isActive),
      gapHours: gapHours == null && nullToAbsent
          ? const Value.absent()
          : Value(gapHours),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      chainId: serializer.fromJson<int>(json['chainId']),
      medicineName: serializer.fromJson<String>(json['medicineName']),
      medicineType: serializer.fromJson<String>(json['medicineType']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      gapHours: serializer.fromJson<int?>(json['gapHours']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chainId': serializer.toJson<int>(chainId),
      'medicineName': serializer.toJson<String>(medicineName),
      'medicineType': serializer.toJson<String>(medicineType),
      'dosage': serializer.toJson<String?>(dosage),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'isActive': serializer.toJson<bool>(isActive),
      'gapHours': serializer.toJson<int?>(gapHours),
    };
  }

  Reminder copyWith({
    int? id,
    int? chainId,
    String? medicineName,
    String? medicineType,
    Value<String?> dosage = const Value.absent(),
    Value<DateTime?> scheduledAt = const Value.absent(),
    bool? isActive,
    Value<int?> gapHours = const Value.absent(),
  }) => Reminder(
    id: id ?? this.id,
    chainId: chainId ?? this.chainId,
    medicineName: medicineName ?? this.medicineName,
    medicineType: medicineType ?? this.medicineType,
    dosage: dosage.present ? dosage.value : this.dosage,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    isActive: isActive ?? this.isActive,
    gapHours: gapHours.present ? gapHours.value : this.gapHours,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      medicineName: data.medicineName.present
          ? data.medicineName.value
          : this.medicineName,
      medicineType: data.medicineType.present
          ? data.medicineType.value
          : this.medicineType,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      gapHours: data.gapHours.present ? data.gapHours.value : this.gapHours,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('chainId: $chainId, ')
          ..write('medicineName: $medicineName, ')
          ..write('medicineType: $medicineType, ')
          ..write('dosage: $dosage, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isActive: $isActive, ')
          ..write('gapHours: $gapHours')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chainId,
    medicineName,
    medicineType,
    dosage,
    scheduledAt,
    isActive,
    gapHours,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.chainId == this.chainId &&
          other.medicineName == this.medicineName &&
          other.medicineType == this.medicineType &&
          other.dosage == this.dosage &&
          other.scheduledAt == this.scheduledAt &&
          other.isActive == this.isActive &&
          other.gapHours == this.gapHours);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> chainId;
  final Value<String> medicineName;
  final Value<String> medicineType;
  final Value<String?> dosage;
  final Value<DateTime?> scheduledAt;
  final Value<bool> isActive;
  final Value<int?> gapHours;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.chainId = const Value.absent(),
    this.medicineName = const Value.absent(),
    this.medicineType = const Value.absent(),
    this.dosage = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.gapHours = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int chainId,
    required String medicineName,
    required String medicineType,
    this.dosage = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.gapHours = const Value.absent(),
  }) : chainId = Value(chainId),
       medicineName = Value(medicineName),
       medicineType = Value(medicineType);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? chainId,
    Expression<String>? medicineName,
    Expression<String>? medicineType,
    Expression<String>? dosage,
    Expression<int>? scheduledAt,
    Expression<bool>? isActive,
    Expression<int>? gapHours,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chainId != null) 'chain_id': chainId,
      if (medicineName != null) 'medicine_name': medicineName,
      if (medicineType != null) 'medicine_type': medicineType,
      if (dosage != null) 'dosage': dosage,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (isActive != null) 'is_active': isActive,
      if (gapHours != null) 'gap_hours': gapHours,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? chainId,
    Value<String>? medicineName,
    Value<String>? medicineType,
    Value<String?>? dosage,
    Value<DateTime?>? scheduledAt,
    Value<bool>? isActive,
    Value<int?>? gapHours,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      chainId: chainId ?? this.chainId,
      medicineName: medicineName ?? this.medicineName,
      medicineType: medicineType ?? this.medicineType,
      dosage: dosage ?? this.dosage,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isActive: isActive ?? this.isActive,
      gapHours: gapHours ?? this.gapHours,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chainId.present) {
      map['chain_id'] = Variable<int>(chainId.value);
    }
    if (medicineName.present) {
      map['medicine_name'] = Variable<String>(medicineName.value);
    }
    if (medicineType.present) {
      map['medicine_type'] = Variable<String>(medicineType.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(
        $RemindersTable.$converterscheduledAtn.toSql(scheduledAt.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (gapHours.present) {
      map['gap_hours'] = Variable<int>(gapHours.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('chainId: $chainId, ')
          ..write('medicineName: $medicineName, ')
          ..write('medicineType: $medicineType, ')
          ..write('dosage: $dosage, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isActive: $isActive, ')
          ..write('gapHours: $gapHours')
          ..write(')'))
        .toString();
  }
}

class $ChainEdgesTable extends ChainEdges
    with TableInfo<$ChainEdgesTable, ChainEdge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChainEdgesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _chainIdMeta = const VerificationMeta(
    'chainId',
  );
  @override
  late final GeneratedColumn<int> chainId = GeneratedColumn<int>(
    'chain_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminder_chains (id)',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminders (id)',
    ),
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminders (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, chainId, sourceId, targetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chain_edges';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChainEdge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chain_id')) {
      context.handle(
        _chainIdMeta,
        chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chainIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceId, targetId},
  ];
  @override
  ChainEdge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChainEdge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chain_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      )!,
    );
  }

  @override
  $ChainEdgesTable createAlias(String alias) {
    return $ChainEdgesTable(attachedDatabase, alias);
  }
}

class ChainEdge extends DataClass implements Insertable<ChainEdge> {
  final int id;
  final int chainId;
  final int sourceId;
  final int targetId;
  const ChainEdge({
    required this.id,
    required this.chainId,
    required this.sourceId,
    required this.targetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chain_id'] = Variable<int>(chainId);
    map['source_id'] = Variable<int>(sourceId);
    map['target_id'] = Variable<int>(targetId);
    return map;
  }

  ChainEdgesCompanion toCompanion(bool nullToAbsent) {
    return ChainEdgesCompanion(
      id: Value(id),
      chainId: Value(chainId),
      sourceId: Value(sourceId),
      targetId: Value(targetId),
    );
  }

  factory ChainEdge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChainEdge(
      id: serializer.fromJson<int>(json['id']),
      chainId: serializer.fromJson<int>(json['chainId']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      targetId: serializer.fromJson<int>(json['targetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chainId': serializer.toJson<int>(chainId),
      'sourceId': serializer.toJson<int>(sourceId),
      'targetId': serializer.toJson<int>(targetId),
    };
  }

  ChainEdge copyWith({int? id, int? chainId, int? sourceId, int? targetId}) =>
      ChainEdge(
        id: id ?? this.id,
        chainId: chainId ?? this.chainId,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
      );
  ChainEdge copyWithCompanion(ChainEdgesCompanion data) {
    return ChainEdge(
      id: data.id.present ? data.id.value : this.id,
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChainEdge(')
          ..write('id: $id, ')
          ..write('chainId: $chainId, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chainId, sourceId, targetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChainEdge &&
          other.id == this.id &&
          other.chainId == this.chainId &&
          other.sourceId == this.sourceId &&
          other.targetId == this.targetId);
}

class ChainEdgesCompanion extends UpdateCompanion<ChainEdge> {
  final Value<int> id;
  final Value<int> chainId;
  final Value<int> sourceId;
  final Value<int> targetId;
  const ChainEdgesCompanion({
    this.id = const Value.absent(),
    this.chainId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.targetId = const Value.absent(),
  });
  ChainEdgesCompanion.insert({
    this.id = const Value.absent(),
    required int chainId,
    required int sourceId,
    required int targetId,
  }) : chainId = Value(chainId),
       sourceId = Value(sourceId),
       targetId = Value(targetId);
  static Insertable<ChainEdge> custom({
    Expression<int>? id,
    Expression<int>? chainId,
    Expression<int>? sourceId,
    Expression<int>? targetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chainId != null) 'chain_id': chainId,
      if (sourceId != null) 'source_id': sourceId,
      if (targetId != null) 'target_id': targetId,
    });
  }

  ChainEdgesCompanion copyWith({
    Value<int>? id,
    Value<int>? chainId,
    Value<int>? sourceId,
    Value<int>? targetId,
  }) {
    return ChainEdgesCompanion(
      id: id ?? this.id,
      chainId: chainId ?? this.chainId,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chainId.present) {
      map['chain_id'] = Variable<int>(chainId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChainEdgesCompanion(')
          ..write('id: $id, ')
          ..write('chainId: $chainId, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId')
          ..write(')'))
        .toString();
  }
}

class $ConfirmationsTable extends Confirmations
    with TableInfo<$ConfirmationsTable, Confirmation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfirmationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<int> reminderId = GeneratedColumn<int>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminders (id)',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> confirmedAt =
      GeneratedColumn<int>(
        'confirmed_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ConfirmationsTable.$converterconfirmedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> snoozeUntil =
      GeneratedColumn<int>(
        'snooze_until',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ConfirmationsTable.$convertersnoozeUntiln);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reminderId,
    state,
    confirmedAt,
    snoozeUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'confirmations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Confirmation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Confirmation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Confirmation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      confirmedAt: $ConfirmationsTable.$converterconfirmedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}confirmed_at'],
        )!,
      ),
      snoozeUntil: $ConfirmationsTable.$convertersnoozeUntiln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}snooze_until'],
        ),
      ),
    );
  }

  @override
  $ConfirmationsTable createAlias(String alias) {
    return $ConfirmationsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterconfirmedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $convertersnoozeUntil =
      const DateTimeConverter();
  static TypeConverter<DateTime?, int?> $convertersnoozeUntiln =
      NullAwareTypeConverter.wrap($convertersnoozeUntil);
}

class Confirmation extends DataClass implements Insertable<Confirmation> {
  final int id;
  final int reminderId;
  final String state;
  final DateTime confirmedAt;
  final DateTime? snoozeUntil;
  const Confirmation({
    required this.id,
    required this.reminderId,
    required this.state,
    required this.confirmedAt,
    this.snoozeUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reminder_id'] = Variable<int>(reminderId);
    map['state'] = Variable<String>(state);
    {
      map['confirmed_at'] = Variable<int>(
        $ConfirmationsTable.$converterconfirmedAt.toSql(confirmedAt),
      );
    }
    if (!nullToAbsent || snoozeUntil != null) {
      map['snooze_until'] = Variable<int>(
        $ConfirmationsTable.$convertersnoozeUntiln.toSql(snoozeUntil),
      );
    }
    return map;
  }

  ConfirmationsCompanion toCompanion(bool nullToAbsent) {
    return ConfirmationsCompanion(
      id: Value(id),
      reminderId: Value(reminderId),
      state: Value(state),
      confirmedAt: Value(confirmedAt),
      snoozeUntil: snoozeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozeUntil),
    );
  }

  factory Confirmation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Confirmation(
      id: serializer.fromJson<int>(json['id']),
      reminderId: serializer.fromJson<int>(json['reminderId']),
      state: serializer.fromJson<String>(json['state']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
      snoozeUntil: serializer.fromJson<DateTime?>(json['snoozeUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reminderId': serializer.toJson<int>(reminderId),
      'state': serializer.toJson<String>(state),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
      'snoozeUntil': serializer.toJson<DateTime?>(snoozeUntil),
    };
  }

  Confirmation copyWith({
    int? id,
    int? reminderId,
    String? state,
    DateTime? confirmedAt,
    Value<DateTime?> snoozeUntil = const Value.absent(),
  }) => Confirmation(
    id: id ?? this.id,
    reminderId: reminderId ?? this.reminderId,
    state: state ?? this.state,
    confirmedAt: confirmedAt ?? this.confirmedAt,
    snoozeUntil: snoozeUntil.present ? snoozeUntil.value : this.snoozeUntil,
  );
  Confirmation copyWithCompanion(ConfirmationsCompanion data) {
    return Confirmation(
      id: data.id.present ? data.id.value : this.id,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      state: data.state.present ? data.state.value : this.state,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      snoozeUntil: data.snoozeUntil.present
          ? data.snoozeUntil.value
          : this.snoozeUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Confirmation(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('state: $state, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('snoozeUntil: $snoozeUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, reminderId, state, confirmedAt, snoozeUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Confirmation &&
          other.id == this.id &&
          other.reminderId == this.reminderId &&
          other.state == this.state &&
          other.confirmedAt == this.confirmedAt &&
          other.snoozeUntil == this.snoozeUntil);
}

class ConfirmationsCompanion extends UpdateCompanion<Confirmation> {
  final Value<int> id;
  final Value<int> reminderId;
  final Value<String> state;
  final Value<DateTime> confirmedAt;
  final Value<DateTime?> snoozeUntil;
  const ConfirmationsCompanion({
    this.id = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.state = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
  });
  ConfirmationsCompanion.insert({
    this.id = const Value.absent(),
    required int reminderId,
    required String state,
    required DateTime confirmedAt,
    this.snoozeUntil = const Value.absent(),
  }) : reminderId = Value(reminderId),
       state = Value(state),
       confirmedAt = Value(confirmedAt);
  static Insertable<Confirmation> custom({
    Expression<int>? id,
    Expression<int>? reminderId,
    Expression<String>? state,
    Expression<int>? confirmedAt,
    Expression<int>? snoozeUntil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderId != null) 'reminder_id': reminderId,
      if (state != null) 'state': state,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (snoozeUntil != null) 'snooze_until': snoozeUntil,
    });
  }

  ConfirmationsCompanion copyWith({
    Value<int>? id,
    Value<int>? reminderId,
    Value<String>? state,
    Value<DateTime>? confirmedAt,
    Value<DateTime?>? snoozeUntil,
  }) {
    return ConfirmationsCompanion(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      state: state ?? this.state,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<int>(reminderId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<int>(
        $ConfirmationsTable.$converterconfirmedAt.toSql(confirmedAt.value),
      );
    }
    if (snoozeUntil.present) {
      map['snooze_until'] = Variable<int>(
        $ConfirmationsTable.$convertersnoozeUntiln.toSql(snoozeUntil.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfirmationsCompanion(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('state: $state, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('snoozeUntil: $snoozeUntil')
          ..write(')'))
        .toString();
  }
}

class $MealAnchorsTable extends MealAnchors
    with TableInfo<$MealAnchorsTable, MealAnchor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealAnchorsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultTimeMeta = const VerificationMeta(
    'defaultTime',
  );
  @override
  late final GeneratedColumn<int> defaultTime = GeneratedColumn<int>(
    'default_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> confirmedAt =
      GeneratedColumn<int>(
        'confirmed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($MealAnchorsTable.$converterconfirmedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealType,
    defaultTime,
    confirmedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_anchors';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealAnchor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('default_time')) {
      context.handle(
        _defaultTimeMeta,
        defaultTime.isAcceptableOrUnknown(
          data['default_time']!,
          _defaultTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealAnchor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealAnchor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      defaultTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_time'],
      )!,
      confirmedAt: $MealAnchorsTable.$converterconfirmedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}confirmed_at'],
        ),
      ),
    );
  }

  @override
  $MealAnchorsTable createAlias(String alias) {
    return $MealAnchorsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterconfirmedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterconfirmedAtn =
      NullAwareTypeConverter.wrap($converterconfirmedAt);
}

class MealAnchor extends DataClass implements Insertable<MealAnchor> {
  final int id;
  final String mealType;
  final int defaultTime;
  final DateTime? confirmedAt;
  const MealAnchor({
    required this.id,
    required this.mealType,
    required this.defaultTime,
    this.confirmedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_type'] = Variable<String>(mealType);
    map['default_time'] = Variable<int>(defaultTime);
    if (!nullToAbsent || confirmedAt != null) {
      map['confirmed_at'] = Variable<int>(
        $MealAnchorsTable.$converterconfirmedAtn.toSql(confirmedAt),
      );
    }
    return map;
  }

  MealAnchorsCompanion toCompanion(bool nullToAbsent) {
    return MealAnchorsCompanion(
      id: Value(id),
      mealType: Value(mealType),
      defaultTime: Value(defaultTime),
      confirmedAt: confirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedAt),
    );
  }

  factory MealAnchor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealAnchor(
      id: serializer.fromJson<int>(json['id']),
      mealType: serializer.fromJson<String>(json['mealType']),
      defaultTime: serializer.fromJson<int>(json['defaultTime']),
      confirmedAt: serializer.fromJson<DateTime?>(json['confirmedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealType': serializer.toJson<String>(mealType),
      'defaultTime': serializer.toJson<int>(defaultTime),
      'confirmedAt': serializer.toJson<DateTime?>(confirmedAt),
    };
  }

  MealAnchor copyWith({
    int? id,
    String? mealType,
    int? defaultTime,
    Value<DateTime?> confirmedAt = const Value.absent(),
  }) => MealAnchor(
    id: id ?? this.id,
    mealType: mealType ?? this.mealType,
    defaultTime: defaultTime ?? this.defaultTime,
    confirmedAt: confirmedAt.present ? confirmedAt.value : this.confirmedAt,
  );
  MealAnchor copyWithCompanion(MealAnchorsCompanion data) {
    return MealAnchor(
      id: data.id.present ? data.id.value : this.id,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      defaultTime: data.defaultTime.present
          ? data.defaultTime.value
          : this.defaultTime,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealAnchor(')
          ..write('id: $id, ')
          ..write('mealType: $mealType, ')
          ..write('defaultTime: $defaultTime, ')
          ..write('confirmedAt: $confirmedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mealType, defaultTime, confirmedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealAnchor &&
          other.id == this.id &&
          other.mealType == this.mealType &&
          other.defaultTime == this.defaultTime &&
          other.confirmedAt == this.confirmedAt);
}

class MealAnchorsCompanion extends UpdateCompanion<MealAnchor> {
  final Value<int> id;
  final Value<String> mealType;
  final Value<int> defaultTime;
  final Value<DateTime?> confirmedAt;
  const MealAnchorsCompanion({
    this.id = const Value.absent(),
    this.mealType = const Value.absent(),
    this.defaultTime = const Value.absent(),
    this.confirmedAt = const Value.absent(),
  });
  MealAnchorsCompanion.insert({
    this.id = const Value.absent(),
    required String mealType,
    required int defaultTime,
    this.confirmedAt = const Value.absent(),
  }) : mealType = Value(mealType),
       defaultTime = Value(defaultTime);
  static Insertable<MealAnchor> custom({
    Expression<int>? id,
    Expression<String>? mealType,
    Expression<int>? defaultTime,
    Expression<int>? confirmedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealType != null) 'meal_type': mealType,
      if (defaultTime != null) 'default_time': defaultTime,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
    });
  }

  MealAnchorsCompanion copyWith({
    Value<int>? id,
    Value<String>? mealType,
    Value<int>? defaultTime,
    Value<DateTime?>? confirmedAt,
  }) {
    return MealAnchorsCompanion(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      defaultTime: defaultTime ?? this.defaultTime,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (defaultTime.present) {
      map['default_time'] = Variable<int>(defaultTime.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<int>(
        $MealAnchorsTable.$converterconfirmedAtn.toSql(confirmedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealAnchorsCompanion(')
          ..write('id: $id, ')
          ..write('mealType: $mealType, ')
          ..write('defaultTime: $defaultTime, ')
          ..write('confirmedAt: $confirmedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReminderChainsTable reminderChains = $ReminderChainsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ChainEdgesTable chainEdges = $ChainEdgesTable(this);
  late final $ConfirmationsTable confirmations = $ConfirmationsTable(this);
  late final $MealAnchorsTable mealAnchors = $MealAnchorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reminderChains,
    reminders,
    chainEdges,
    confirmations,
    mealAnchors,
  ];
}

typedef $$ReminderChainsTableCreateCompanionBuilder =
    ReminderChainsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$ReminderChainsTableUpdateCompanionBuilder =
    ReminderChainsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$ReminderChainsTableReferences
    extends BaseReferences<_$AppDatabase, $ReminderChainsTable, ReminderChain> {
  $$ReminderChainsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: $_aliasNameGenerator(db.reminderChains.id, db.reminders.chainId),
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.chainId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChainEdgesTable, List<ChainEdge>>
  _chainEdgesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chainEdges,
    aliasName: $_aliasNameGenerator(
      db.reminderChains.id,
      db.chainEdges.chainId,
    ),
  );

  $$ChainEdgesTableProcessedTableManager get chainEdgesRefs {
    final manager = $$ChainEdgesTableTableManager(
      $_db,
      $_db.chainEdges,
    ).filter((f) => f.chainId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chainEdgesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReminderChainsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderChainsTable> {
  $$ReminderChainsTableFilterComposer({
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

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.chainId,
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

  Expression<bool> chainEdgesRefs(
    Expression<bool> Function($$ChainEdgesTableFilterComposer f) f,
  ) {
    final $$ChainEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chainEdges,
      getReferencedColumn: (t) => t.chainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChainEdgesTableFilterComposer(
            $db: $db,
            $table: $db.chainEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReminderChainsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderChainsTable> {
  $$ReminderChainsTableOrderingComposer({
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

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderChainsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderChainsTable> {
  $$ReminderChainsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.chainId,
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

  Expression<T> chainEdgesRefs<T extends Object>(
    Expression<T> Function($$ChainEdgesTableAnnotationComposer a) f,
  ) {
    final $$ChainEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chainEdges,
      getReferencedColumn: (t) => t.chainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChainEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.chainEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReminderChainsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderChainsTable,
          ReminderChain,
          $$ReminderChainsTableFilterComposer,
          $$ReminderChainsTableOrderingComposer,
          $$ReminderChainsTableAnnotationComposer,
          $$ReminderChainsTableCreateCompanionBuilder,
          $$ReminderChainsTableUpdateCompanionBuilder,
          (ReminderChain, $$ReminderChainsTableReferences),
          ReminderChain,
          PrefetchHooks Function({bool remindersRefs, bool chainEdgesRefs})
        > {
  $$ReminderChainsTableTableManager(
    _$AppDatabase db,
    $ReminderChainsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderChainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderChainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderChainsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReminderChainsCompanion(
                id: id,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => ReminderChainsCompanion.insert(
                id: id,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderChainsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({remindersRefs = false, chainEdgesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (remindersRefs) db.reminders,
                    if (chainEdgesRefs) db.chainEdges,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          ReminderChain,
                          $ReminderChainsTable,
                          Reminder
                        >(
                          currentTable: table,
                          referencedTable: $$ReminderChainsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReminderChainsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chainId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chainEdgesRefs)
                        await $_getPrefetchedData<
                          ReminderChain,
                          $ReminderChainsTable,
                          ChainEdge
                        >(
                          currentTable: table,
                          referencedTable: $$ReminderChainsTableReferences
                              ._chainEdgesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReminderChainsTableReferences(
                                db,
                                table,
                                p0,
                              ).chainEdgesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chainId == item.id,
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

typedef $$ReminderChainsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderChainsTable,
      ReminderChain,
      $$ReminderChainsTableFilterComposer,
      $$ReminderChainsTableOrderingComposer,
      $$ReminderChainsTableAnnotationComposer,
      $$ReminderChainsTableCreateCompanionBuilder,
      $$ReminderChainsTableUpdateCompanionBuilder,
      (ReminderChain, $$ReminderChainsTableReferences),
      ReminderChain,
      PrefetchHooks Function({bool remindersRefs, bool chainEdgesRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required int chainId,
      required String medicineName,
      required String medicineType,
      Value<String?> dosage,
      Value<DateTime?> scheduledAt,
      Value<bool> isActive,
      Value<int?> gapHours,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<int> chainId,
      Value<String> medicineName,
      Value<String> medicineType,
      Value<String?> dosage,
      Value<DateTime?> scheduledAt,
      Value<bool> isActive,
      Value<int?> gapHours,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReminderChainsTable _chainIdTable(_$AppDatabase db) =>
      db.reminderChains.createAlias(
        $_aliasNameGenerator(db.reminders.chainId, db.reminderChains.id),
      );

  $$ReminderChainsTableProcessedTableManager get chainId {
    final $_column = $_itemColumn<int>('chain_id')!;

    final manager = $$ReminderChainsTableTableManager(
      $_db,
      $_db.reminderChains,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChainEdgesTable, List<ChainEdge>>
  _sourceEdgesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chainEdges,
    aliasName: $_aliasNameGenerator(db.reminders.id, db.chainEdges.sourceId),
  );

  $$ChainEdgesTableProcessedTableManager get sourceEdges {
    final manager = $$ChainEdgesTableTableManager(
      $_db,
      $_db.chainEdges,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sourceEdgesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChainEdgesTable, List<ChainEdge>>
  _targetEdgesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chainEdges,
    aliasName: $_aliasNameGenerator(db.reminders.id, db.chainEdges.targetId),
  );

  $$ChainEdgesTableProcessedTableManager get targetEdges {
    final manager = $$ChainEdgesTableTableManager(
      $_db,
      $_db.chainEdges,
    ).filter((f) => f.targetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_targetEdgesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConfirmationsTable, List<Confirmation>>
  _confirmationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.confirmations,
    aliasName: $_aliasNameGenerator(
      db.reminders.id,
      db.confirmations.reminderId,
    ),
  );

  $$ConfirmationsTableProcessedTableManager get confirmationsRefs {
    final manager = $$ConfirmationsTableTableManager(
      $_db,
      $_db.confirmations,
    ).filter((f) => f.reminderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_confirmationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineType => $composableBuilder(
    column: $table.medicineType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get scheduledAt =>
      $composableBuilder(
        column: $table.scheduledAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gapHours => $composableBuilder(
    column: $table.gapHours,
    builder: (column) => ColumnFilters(column),
  );

  $$ReminderChainsTableFilterComposer get chainId {
    final $$ReminderChainsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chainId,
      referencedTable: $db.reminderChains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderChainsTableFilterComposer(
            $db: $db,
            $table: $db.reminderChains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sourceEdges(
    Expression<bool> Function($$ChainEdgesTableFilterComposer f) f,
  ) {
    final $$ChainEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chainEdges,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChainEdgesTableFilterComposer(
            $db: $db,
            $table: $db.chainEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> targetEdges(
    Expression<bool> Function($$ChainEdgesTableFilterComposer f) f,
  ) {
    final $$ChainEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chainEdges,
      getReferencedColumn: (t) => t.targetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChainEdgesTableFilterComposer(
            $db: $db,
            $table: $db.chainEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> confirmationsRefs(
    Expression<bool> Function($$ConfirmationsTableFilterComposer f) f,
  ) {
    final $$ConfirmationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.confirmations,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfirmationsTableFilterComposer(
            $db: $db,
            $table: $db.confirmations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  ColumnOrderings<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineType => $composableBuilder(
    column: $table.medicineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gapHours => $composableBuilder(
    column: $table.gapHours,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReminderChainsTableOrderingComposer get chainId {
    final $$ReminderChainsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chainId,
      referencedTable: $db.reminderChains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderChainsTableOrderingComposer(
            $db: $db,
            $table: $db.reminderChains,
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

  GeneratedColumn<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicineType => $composableBuilder(
    column: $table.medicineType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get scheduledAt =>
      $composableBuilder(
        column: $table.scheduledAt,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get gapHours =>
      $composableBuilder(column: $table.gapHours, builder: (column) => column);

  $$ReminderChainsTableAnnotationComposer get chainId {
    final $$ReminderChainsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chainId,
      referencedTable: $db.reminderChains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderChainsTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderChains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sourceEdges<T extends Object>(
    Expression<T> Function($$ChainEdgesTableAnnotationComposer a) f,
  ) {
    final $$ChainEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chainEdges,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChainEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.chainEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> targetEdges<T extends Object>(
    Expression<T> Function($$ChainEdgesTableAnnotationComposer a) f,
  ) {
    final $$ChainEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chainEdges,
      getReferencedColumn: (t) => t.targetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChainEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.chainEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> confirmationsRefs<T extends Object>(
    Expression<T> Function($$ConfirmationsTableAnnotationComposer a) f,
  ) {
    final $$ConfirmationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.confirmations,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfirmationsTableAnnotationComposer(
            $db: $db,
            $table: $db.confirmations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({
            bool chainId,
            bool sourceEdges,
            bool targetEdges,
            bool confirmationsRefs,
          })
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
                Value<int> chainId = const Value.absent(),
                Value<String> medicineName = const Value.absent(),
                Value<String> medicineType = const Value.absent(),
                Value<String?> dosage = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> gapHours = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                chainId: chainId,
                medicineName: medicineName,
                medicineType: medicineType,
                dosage: dosage,
                scheduledAt: scheduledAt,
                isActive: isActive,
                gapHours: gapHours,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chainId,
                required String medicineName,
                required String medicineType,
                Value<String?> dosage = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> gapHours = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                chainId: chainId,
                medicineName: medicineName,
                medicineType: medicineType,
                dosage: dosage,
                scheduledAt: scheduledAt,
                isActive: isActive,
                gapHours: gapHours,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                chainId = false,
                sourceEdges = false,
                targetEdges = false,
                confirmationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceEdges) db.chainEdges,
                    if (targetEdges) db.chainEdges,
                    if (confirmationsRefs) db.confirmations,
                  ],
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
                        if (chainId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chainId,
                                    referencedTable: $$RemindersTableReferences
                                        ._chainIdTable(db),
                                    referencedColumn: $$RemindersTableReferences
                                        ._chainIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceEdges)
                        await $_getPrefetchedData<
                          Reminder,
                          $RemindersTable,
                          ChainEdge
                        >(
                          currentTable: table,
                          referencedTable: $$RemindersTableReferences
                              ._sourceEdgesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RemindersTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceEdges,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (targetEdges)
                        await $_getPrefetchedData<
                          Reminder,
                          $RemindersTable,
                          ChainEdge
                        >(
                          currentTable: table,
                          referencedTable: $$RemindersTableReferences
                              ._targetEdgesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RemindersTableReferences(
                                db,
                                table,
                                p0,
                              ).targetEdges,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (confirmationsRefs)
                        await $_getPrefetchedData<
                          Reminder,
                          $RemindersTable,
                          Confirmation
                        >(
                          currentTable: table,
                          referencedTable: $$RemindersTableReferences
                              ._confirmationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RemindersTableReferences(
                                db,
                                table,
                                p0,
                              ).confirmationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reminderId == item.id,
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
      PrefetchHooks Function({
        bool chainId,
        bool sourceEdges,
        bool targetEdges,
        bool confirmationsRefs,
      })
    >;
typedef $$ChainEdgesTableCreateCompanionBuilder =
    ChainEdgesCompanion Function({
      Value<int> id,
      required int chainId,
      required int sourceId,
      required int targetId,
    });
typedef $$ChainEdgesTableUpdateCompanionBuilder =
    ChainEdgesCompanion Function({
      Value<int> id,
      Value<int> chainId,
      Value<int> sourceId,
      Value<int> targetId,
    });

final class $$ChainEdgesTableReferences
    extends BaseReferences<_$AppDatabase, $ChainEdgesTable, ChainEdge> {
  $$ChainEdgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReminderChainsTable _chainIdTable(_$AppDatabase db) =>
      db.reminderChains.createAlias(
        $_aliasNameGenerator(db.chainEdges.chainId, db.reminderChains.id),
      );

  $$ReminderChainsTableProcessedTableManager get chainId {
    final $_column = $_itemColumn<int>('chain_id')!;

    final manager = $$ReminderChainsTableTableManager(
      $_db,
      $_db.reminderChains,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RemindersTable _sourceIdTable(_$AppDatabase db) =>
      db.reminders.createAlias(
        $_aliasNameGenerator(db.chainEdges.sourceId, db.reminders.id),
      );

  $$RemindersTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RemindersTable _targetIdTable(_$AppDatabase db) =>
      db.reminders.createAlias(
        $_aliasNameGenerator(db.chainEdges.targetId, db.reminders.id),
      );

  $$RemindersTableProcessedTableManager get targetId {
    final $_column = $_itemColumn<int>('target_id')!;

    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChainEdgesTableFilterComposer
    extends Composer<_$AppDatabase, $ChainEdgesTable> {
  $$ChainEdgesTableFilterComposer({
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

  $$ReminderChainsTableFilterComposer get chainId {
    final $$ReminderChainsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chainId,
      referencedTable: $db.reminderChains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderChainsTableFilterComposer(
            $db: $db,
            $table: $db.reminderChains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RemindersTableFilterComposer get sourceId {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$RemindersTableFilterComposer get targetId {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ChainEdgesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChainEdgesTable> {
  $$ChainEdgesTableOrderingComposer({
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

  $$ReminderChainsTableOrderingComposer get chainId {
    final $$ReminderChainsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chainId,
      referencedTable: $db.reminderChains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderChainsTableOrderingComposer(
            $db: $db,
            $table: $db.reminderChains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RemindersTableOrderingComposer get sourceId {
    final $$RemindersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableOrderingComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RemindersTableOrderingComposer get targetId {
    final $$RemindersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableOrderingComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChainEdgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChainEdgesTable> {
  $$ChainEdgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$ReminderChainsTableAnnotationComposer get chainId {
    final $$ReminderChainsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chainId,
      referencedTable: $db.reminderChains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderChainsTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderChains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RemindersTableAnnotationComposer get sourceId {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$RemindersTableAnnotationComposer get targetId {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ChainEdgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChainEdgesTable,
          ChainEdge,
          $$ChainEdgesTableFilterComposer,
          $$ChainEdgesTableOrderingComposer,
          $$ChainEdgesTableAnnotationComposer,
          $$ChainEdgesTableCreateCompanionBuilder,
          $$ChainEdgesTableUpdateCompanionBuilder,
          (ChainEdge, $$ChainEdgesTableReferences),
          ChainEdge,
          PrefetchHooks Function({bool chainId, bool sourceId, bool targetId})
        > {
  $$ChainEdgesTableTableManager(_$AppDatabase db, $ChainEdgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChainEdgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChainEdgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChainEdgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chainId = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<int> targetId = const Value.absent(),
              }) => ChainEdgesCompanion(
                id: id,
                chainId: chainId,
                sourceId: sourceId,
                targetId: targetId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chainId,
                required int sourceId,
                required int targetId,
              }) => ChainEdgesCompanion.insert(
                id: id,
                chainId: chainId,
                sourceId: sourceId,
                targetId: targetId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChainEdgesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({chainId = false, sourceId = false, targetId = false}) {
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
                        if (chainId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chainId,
                                    referencedTable: $$ChainEdgesTableReferences
                                        ._chainIdTable(db),
                                    referencedColumn:
                                        $$ChainEdgesTableReferences
                                            ._chainIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable: $$ChainEdgesTableReferences
                                        ._sourceIdTable(db),
                                    referencedColumn:
                                        $$ChainEdgesTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetId,
                                    referencedTable: $$ChainEdgesTableReferences
                                        ._targetIdTable(db),
                                    referencedColumn:
                                        $$ChainEdgesTableReferences
                                            ._targetIdTable(db)
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

typedef $$ChainEdgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChainEdgesTable,
      ChainEdge,
      $$ChainEdgesTableFilterComposer,
      $$ChainEdgesTableOrderingComposer,
      $$ChainEdgesTableAnnotationComposer,
      $$ChainEdgesTableCreateCompanionBuilder,
      $$ChainEdgesTableUpdateCompanionBuilder,
      (ChainEdge, $$ChainEdgesTableReferences),
      ChainEdge,
      PrefetchHooks Function({bool chainId, bool sourceId, bool targetId})
    >;
typedef $$ConfirmationsTableCreateCompanionBuilder =
    ConfirmationsCompanion Function({
      Value<int> id,
      required int reminderId,
      required String state,
      required DateTime confirmedAt,
      Value<DateTime?> snoozeUntil,
    });
typedef $$ConfirmationsTableUpdateCompanionBuilder =
    ConfirmationsCompanion Function({
      Value<int> id,
      Value<int> reminderId,
      Value<String> state,
      Value<DateTime> confirmedAt,
      Value<DateTime?> snoozeUntil,
    });

final class $$ConfirmationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConfirmationsTable, Confirmation> {
  $$ConfirmationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RemindersTable _reminderIdTable(_$AppDatabase db) =>
      db.reminders.createAlias(
        $_aliasNameGenerator(db.confirmations.reminderId, db.reminders.id),
      );

  $$RemindersTableProcessedTableManager get reminderId {
    final $_column = $_itemColumn<int>('reminder_id')!;

    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConfirmationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConfirmationsTable> {
  $$ConfirmationsTableFilterComposer({
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

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get confirmedAt =>
      $composableBuilder(
        column: $table.confirmedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get snoozeUntil =>
      $composableBuilder(
        column: $table.snoozeUntil,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$RemindersTableFilterComposer get reminderId {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ConfirmationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfirmationsTable> {
  $$ConfirmationsTableOrderingComposer({
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

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  $$RemindersTableOrderingComposer get reminderId {
    final $$RemindersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableOrderingComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfirmationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfirmationsTable> {
  $$ConfirmationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get confirmedAt =>
      $composableBuilder(
        column: $table.confirmedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get snoozeUntil =>
      $composableBuilder(
        column: $table.snoozeUntil,
        builder: (column) => column,
      );

  $$RemindersTableAnnotationComposer get reminderId {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ConfirmationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfirmationsTable,
          Confirmation,
          $$ConfirmationsTableFilterComposer,
          $$ConfirmationsTableOrderingComposer,
          $$ConfirmationsTableAnnotationComposer,
          $$ConfirmationsTableCreateCompanionBuilder,
          $$ConfirmationsTableUpdateCompanionBuilder,
          (Confirmation, $$ConfirmationsTableReferences),
          Confirmation,
          PrefetchHooks Function({bool reminderId})
        > {
  $$ConfirmationsTableTableManager(_$AppDatabase db, $ConfirmationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfirmationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfirmationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfirmationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reminderId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<DateTime?> snoozeUntil = const Value.absent(),
              }) => ConfirmationsCompanion(
                id: id,
                reminderId: reminderId,
                state: state,
                confirmedAt: confirmedAt,
                snoozeUntil: snoozeUntil,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reminderId,
                required String state,
                required DateTime confirmedAt,
                Value<DateTime?> snoozeUntil = const Value.absent(),
              }) => ConfirmationsCompanion.insert(
                id: id,
                reminderId: reminderId,
                state: state,
                confirmedAt: confirmedAt,
                snoozeUntil: snoozeUntil,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConfirmationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderId = false}) {
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
                    if (reminderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reminderId,
                                referencedTable: $$ConfirmationsTableReferences
                                    ._reminderIdTable(db),
                                referencedColumn: $$ConfirmationsTableReferences
                                    ._reminderIdTable(db)
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

typedef $$ConfirmationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfirmationsTable,
      Confirmation,
      $$ConfirmationsTableFilterComposer,
      $$ConfirmationsTableOrderingComposer,
      $$ConfirmationsTableAnnotationComposer,
      $$ConfirmationsTableCreateCompanionBuilder,
      $$ConfirmationsTableUpdateCompanionBuilder,
      (Confirmation, $$ConfirmationsTableReferences),
      Confirmation,
      PrefetchHooks Function({bool reminderId})
    >;
typedef $$MealAnchorsTableCreateCompanionBuilder =
    MealAnchorsCompanion Function({
      Value<int> id,
      required String mealType,
      required int defaultTime,
      Value<DateTime?> confirmedAt,
    });
typedef $$MealAnchorsTableUpdateCompanionBuilder =
    MealAnchorsCompanion Function({
      Value<int> id,
      Value<String> mealType,
      Value<int> defaultTime,
      Value<DateTime?> confirmedAt,
    });

class $$MealAnchorsTableFilterComposer
    extends Composer<_$AppDatabase, $MealAnchorsTable> {
  $$MealAnchorsTableFilterComposer({
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

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTime => $composableBuilder(
    column: $table.defaultTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get confirmedAt =>
      $composableBuilder(
        column: $table.confirmedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$MealAnchorsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealAnchorsTable> {
  $$MealAnchorsTableOrderingComposer({
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

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTime => $composableBuilder(
    column: $table.defaultTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealAnchorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealAnchorsTable> {
  $$MealAnchorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<int> get defaultTime => $composableBuilder(
    column: $table.defaultTime,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get confirmedAt =>
      $composableBuilder(
        column: $table.confirmedAt,
        builder: (column) => column,
      );
}

class $$MealAnchorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealAnchorsTable,
          MealAnchor,
          $$MealAnchorsTableFilterComposer,
          $$MealAnchorsTableOrderingComposer,
          $$MealAnchorsTableAnnotationComposer,
          $$MealAnchorsTableCreateCompanionBuilder,
          $$MealAnchorsTableUpdateCompanionBuilder,
          (
            MealAnchor,
            BaseReferences<_$AppDatabase, $MealAnchorsTable, MealAnchor>,
          ),
          MealAnchor,
          PrefetchHooks Function()
        > {
  $$MealAnchorsTableTableManager(_$AppDatabase db, $MealAnchorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealAnchorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealAnchorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealAnchorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<int> defaultTime = const Value.absent(),
                Value<DateTime?> confirmedAt = const Value.absent(),
              }) => MealAnchorsCompanion(
                id: id,
                mealType: mealType,
                defaultTime: defaultTime,
                confirmedAt: confirmedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mealType,
                required int defaultTime,
                Value<DateTime?> confirmedAt = const Value.absent(),
              }) => MealAnchorsCompanion.insert(
                id: id,
                mealType: mealType,
                defaultTime: defaultTime,
                confirmedAt: confirmedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealAnchorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealAnchorsTable,
      MealAnchor,
      $$MealAnchorsTableFilterComposer,
      $$MealAnchorsTableOrderingComposer,
      $$MealAnchorsTableAnnotationComposer,
      $$MealAnchorsTableCreateCompanionBuilder,
      $$MealAnchorsTableUpdateCompanionBuilder,
      (
        MealAnchor,
        BaseReferences<_$AppDatabase, $MealAnchorsTable, MealAnchor>,
      ),
      MealAnchor,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReminderChainsTableTableManager get reminderChains =>
      $$ReminderChainsTableTableManager(_db, _db.reminderChains);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ChainEdgesTableTableManager get chainEdges =>
      $$ChainEdgesTableTableManager(_db, _db.chainEdges);
  $$ConfirmationsTableTableManager get confirmations =>
      $$ConfirmationsTableTableManager(_db, _db.confirmations);
  $$MealAnchorsTableTableManager get mealAnchors =>
      $$MealAnchorsTableTableManager(_db, _db.mealAnchors);
}
