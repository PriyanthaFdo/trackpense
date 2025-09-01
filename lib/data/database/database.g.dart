// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PaymentTable extends Payment with TableInfo<$PaymentTable, PaymentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => KjpMiscellaneous.uuid.v4(),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'is_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expense" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    date,
    description,
    amount,
    isExpense,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_expense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta),
      );
    } else if (isInserting) {
      context.missing(_isExpenseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  PaymentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentData(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expense'],
      )!,
    );
  }

  @override
  $PaymentTable createAlias(String alias) {
    return $PaymentTable(attachedDatabase, alias);
  }
}

class PaymentData extends DataClass implements Insertable<PaymentData> {
  final String uuid;
  final DateTime date;
  final String description;
  final double amount;
  final bool isExpense;
  const PaymentData({
    required this.uuid,
    required this.date,
    required this.description,
    required this.amount,
    required this.isExpense,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['date'] = Variable<DateTime>(date);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['is_expense'] = Variable<bool>(isExpense);
    return map;
  }

  PaymentCompanion toCompanion(bool nullToAbsent) {
    return PaymentCompanion(
      uuid: Value(uuid),
      date: Value(date),
      description: Value(description),
      amount: Value(amount),
      isExpense: Value(isExpense),
    );
  }

  factory PaymentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentData(
      uuid: serializer.fromJson<String>(json['uuid']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'isExpense': serializer.toJson<bool>(isExpense),
    };
  }

  PaymentData copyWith({
    String? uuid,
    DateTime? date,
    String? description,
    double? amount,
    bool? isExpense,
  }) => PaymentData(
    uuid: uuid ?? this.uuid,
    date: date ?? this.date,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    isExpense: isExpense ?? this.isExpense,
  );
  PaymentData copyWithCompanion(PaymentCompanion data) {
    return PaymentData(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentData(')
          ..write('uuid: $uuid, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('isExpense: $isExpense')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, date, description, amount, isExpense);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentData &&
          other.uuid == this.uuid &&
          other.date == this.date &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.isExpense == this.isExpense);
}

class PaymentCompanion extends UpdateCompanion<PaymentData> {
  final Value<String> uuid;
  final Value<DateTime> date;
  final Value<String> description;
  final Value<double> amount;
  final Value<bool> isExpense;
  final Value<int> rowid;
  const PaymentCompanion({
    this.uuid = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentCompanion.insert({
    this.uuid = const Value.absent(),
    this.date = const Value.absent(),
    required String description,
    required double amount,
    required bool isExpense,
    this.rowid = const Value.absent(),
  }) : description = Value(description),
       amount = Value(amount),
       isExpense = Value(isExpense);
  static Insertable<PaymentData> custom({
    Expression<String>? uuid,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<bool>? isExpense,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (isExpense != null) 'is_expense': isExpense,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentCompanion copyWith({
    Value<String>? uuid,
    Value<DateTime>? date,
    Value<String>? description,
    Value<double>? amount,
    Value<bool>? isExpense,
    Value<int>? rowid,
  }) {
    return PaymentCompanion(
      uuid: uuid ?? this.uuid,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentCompanion(')
          ..write('uuid: $uuid, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('isExpense: $isExpense, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PaymentTable payment = $PaymentTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [payment];
}

typedef $$PaymentTableCreateCompanionBuilder =
    PaymentCompanion Function({
      Value<String> uuid,
      Value<DateTime> date,
      required String description,
      required double amount,
      required bool isExpense,
      Value<int> rowid,
    });
typedef $$PaymentTableUpdateCompanionBuilder =
    PaymentCompanion Function({
      Value<String> uuid,
      Value<DateTime> date,
      Value<String> description,
      Value<double> amount,
      Value<bool> isExpense,
      Value<int> rowid,
    });

class $$PaymentTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentTable> {
  $$PaymentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentTable> {
  $$PaymentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentTable> {
  $$PaymentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);
}

class $$PaymentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentTable,
          PaymentData,
          $$PaymentTableFilterComposer,
          $$PaymentTableOrderingComposer,
          $$PaymentTableAnnotationComposer,
          $$PaymentTableCreateCompanionBuilder,
          $$PaymentTableUpdateCompanionBuilder,
          (
            PaymentData,
            BaseReferences<_$AppDatabase, $PaymentTable, PaymentData>,
          ),
          PaymentData,
          PrefetchHooks Function()
        > {
  $$PaymentTableTableManager(_$AppDatabase db, $PaymentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentCompanion(
                uuid: uuid,
                date: date,
                description: description,
                amount: amount,
                isExpense: isExpense,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                required String description,
                required double amount,
                required bool isExpense,
                Value<int> rowid = const Value.absent(),
              }) => PaymentCompanion.insert(
                uuid: uuid,
                date: date,
                description: description,
                amount: amount,
                isExpense: isExpense,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentTable,
      PaymentData,
      $$PaymentTableFilterComposer,
      $$PaymentTableOrderingComposer,
      $$PaymentTableAnnotationComposer,
      $$PaymentTableCreateCompanionBuilder,
      $$PaymentTableUpdateCompanionBuilder,
      (PaymentData, BaseReferences<_$AppDatabase, $PaymentTable, PaymentData>),
      PaymentData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PaymentTableTableManager get payment =>
      $$PaymentTableTableManager(_db, _db.payment);
}
