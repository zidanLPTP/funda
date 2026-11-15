// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basis_data.dart';

// ignore_for_file: type=lint
class $TabelPengaturanTable extends TabelPengaturan
    with TableInfo<$TabelPengaturanTable, EntitasPengaturan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelPengaturanTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kunciMeta = const VerificationMeta('kunci');
  @override
  late final GeneratedColumn<String> kunci = GeneratedColumn<String>(
    'kunci',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nilaiMeta = const VerificationMeta('nilai');
  @override
  late final GeneratedColumn<String> nilai = GeneratedColumn<String>(
    'nilai',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diubahPadaMeta = const VerificationMeta(
    'diubahPada',
  );
  @override
  late final GeneratedColumn<DateTime> diubahPada = GeneratedColumn<DateTime>(
    'diubah_pada',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [kunci, nilai, diubahPada];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_pengaturan';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasPengaturan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kunci')) {
      context.handle(
        _kunciMeta,
        kunci.isAcceptableOrUnknown(data['kunci']!, _kunciMeta),
      );
    } else if (isInserting) {
      context.missing(_kunciMeta);
    }
    if (data.containsKey('nilai')) {
      context.handle(
        _nilaiMeta,
        nilai.isAcceptableOrUnknown(data['nilai']!, _nilaiMeta),
      );
    } else if (isInserting) {
      context.missing(_nilaiMeta);
    }
    if (data.containsKey('diubah_pada')) {
      context.handle(
        _diubahPadaMeta,
        diubahPada.isAcceptableOrUnknown(data['diubah_pada']!, _diubahPadaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kunci};
  @override
  EntitasPengaturan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasPengaturan(
      kunci: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kunci'],
      )!,
      nilai: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nilai'],
      )!,
      diubahPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diubah_pada'],
      )!,
    );
  }

  @override
  $TabelPengaturanTable createAlias(String alias) {
    return $TabelPengaturanTable(attachedDatabase, alias);
  }
}

class EntitasPengaturan extends DataClass
    implements Insertable<EntitasPengaturan> {
  /// Kunci pengaturan unik (misal: 'versi_aplikasi', 'tema_gelap', dll).
  final String kunci;

  /// Nilai pengaturan tersimpan dalam bentuk teks string.
  final String nilai;

  /// Waktu pengaturan terakhir kali diubah.
  final DateTime diubahPada;
  const EntitasPengaturan({
    required this.kunci,
    required this.nilai,
    required this.diubahPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kunci'] = Variable<String>(kunci);
    map['nilai'] = Variable<String>(nilai);
    map['diubah_pada'] = Variable<DateTime>(diubahPada);
    return map;
  }

  TabelPengaturanCompanion toCompanion(bool nullToAbsent) {
    return TabelPengaturanCompanion(
      kunci: Value(kunci),
      nilai: Value(nilai),
      diubahPada: Value(diubahPada),
    );
  }

  factory EntitasPengaturan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasPengaturan(
      kunci: serializer.fromJson<String>(json['kunci']),
      nilai: serializer.fromJson<String>(json['nilai']),
      diubahPada: serializer.fromJson<DateTime>(json['diubahPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kunci': serializer.toJson<String>(kunci),
      'nilai': serializer.toJson<String>(nilai),
      'diubahPada': serializer.toJson<DateTime>(diubahPada),
    };
  }

  EntitasPengaturan copyWith({
    String? kunci,
    String? nilai,
    DateTime? diubahPada,
  }) => EntitasPengaturan(
    kunci: kunci ?? this.kunci,
    nilai: nilai ?? this.nilai,
    diubahPada: diubahPada ?? this.diubahPada,
  );
  EntitasPengaturan copyWithCompanion(TabelPengaturanCompanion data) {
    return EntitasPengaturan(
      kunci: data.kunci.present ? data.kunci.value : this.kunci,
      nilai: data.nilai.present ? data.nilai.value : this.nilai,
      diubahPada: data.diubahPada.present
          ? data.diubahPada.value
          : this.diubahPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasPengaturan(')
          ..write('kunci: $kunci, ')
          ..write('nilai: $nilai, ')
          ..write('diubahPada: $diubahPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(kunci, nilai, diubahPada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasPengaturan &&
          other.kunci == this.kunci &&
          other.nilai == this.nilai &&
          other.diubahPada == this.diubahPada);
}

class TabelPengaturanCompanion extends UpdateCompanion<EntitasPengaturan> {
  final Value<String> kunci;
  final Value<String> nilai;
  final Value<DateTime> diubahPada;
  final Value<int> rowid;
  const TabelPengaturanCompanion({
    this.kunci = const Value.absent(),
    this.nilai = const Value.absent(),
    this.diubahPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelPengaturanCompanion.insert({
    required String kunci,
    required String nilai,
    this.diubahPada = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : kunci = Value(kunci),
       nilai = Value(nilai);
  static Insertable<EntitasPengaturan> custom({
    Expression<String>? kunci,
    Expression<String>? nilai,
    Expression<DateTime>? diubahPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kunci != null) 'kunci': kunci,
      if (nilai != null) 'nilai': nilai,
      if (diubahPada != null) 'diubah_pada': diubahPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelPengaturanCompanion copyWith({
    Value<String>? kunci,
    Value<String>? nilai,
    Value<DateTime>? diubahPada,
    Value<int>? rowid,
  }) {
    return TabelPengaturanCompanion(
      kunci: kunci ?? this.kunci,
      nilai: nilai ?? this.nilai,
      diubahPada: diubahPada ?? this.diubahPada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kunci.present) {
      map['kunci'] = Variable<String>(kunci.value);
    }
    if (nilai.present) {
      map['nilai'] = Variable<String>(nilai.value);
    }
    if (diubahPada.present) {
      map['diubah_pada'] = Variable<DateTime>(diubahPada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelPengaturanCompanion(')
          ..write('kunci: $kunci, ')
          ..write('nilai: $nilai, ')
          ..write('diubahPada: $diubahPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BasisDataFunda extends GeneratedDatabase {
  _$BasisDataFunda(QueryExecutor e) : super(e);
  $BasisDataFundaManager get managers => $BasisDataFundaManager(this);
  late final $TabelPengaturanTable tabelPengaturan = $TabelPengaturanTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tabelPengaturan];
}

typedef $$TabelPengaturanTableCreateCompanionBuilder =
    TabelPengaturanCompanion Function({
      required String kunci,
      required String nilai,
      Value<DateTime> diubahPada,
      Value<int> rowid,
    });
typedef $$TabelPengaturanTableUpdateCompanionBuilder =
    TabelPengaturanCompanion Function({
      Value<String> kunci,
      Value<String> nilai,
      Value<DateTime> diubahPada,
      Value<int> rowid,
    });

class $$TabelPengaturanTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelPengaturanTable> {
  $$TabelPengaturanTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kunci => $composableBuilder(
    column: $table.kunci,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nilai => $composableBuilder(
    column: $table.nilai,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diubahPada => $composableBuilder(
    column: $table.diubahPada,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabelPengaturanTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelPengaturanTable> {
  $$TabelPengaturanTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kunci => $composableBuilder(
    column: $table.kunci,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nilai => $composableBuilder(
    column: $table.nilai,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diubahPada => $composableBuilder(
    column: $table.diubahPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelPengaturanTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelPengaturanTable> {
  $$TabelPengaturanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kunci =>
      $composableBuilder(column: $table.kunci, builder: (column) => column);

  GeneratedColumn<String> get nilai =>
      $composableBuilder(column: $table.nilai, builder: (column) => column);

  GeneratedColumn<DateTime> get diubahPada => $composableBuilder(
    column: $table.diubahPada,
    builder: (column) => column,
  );
}

class $$TabelPengaturanTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelPengaturanTable,
          EntitasPengaturan,
          $$TabelPengaturanTableFilterComposer,
          $$TabelPengaturanTableOrderingComposer,
          $$TabelPengaturanTableAnnotationComposer,
          $$TabelPengaturanTableCreateCompanionBuilder,
          $$TabelPengaturanTableUpdateCompanionBuilder,
          (
            EntitasPengaturan,
            BaseReferences<
              _$BasisDataFunda,
              $TabelPengaturanTable,
              EntitasPengaturan
            >,
          ),
          EntitasPengaturan,
          PrefetchHooks Function()
        > {
  $$TabelPengaturanTableTableManager(
    _$BasisDataFunda db,
    $TabelPengaturanTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelPengaturanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelPengaturanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelPengaturanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kunci = const Value.absent(),
                Value<String> nilai = const Value.absent(),
                Value<DateTime> diubahPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelPengaturanCompanion(
                kunci: kunci,
                nilai: nilai,
                diubahPada: diubahPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kunci,
                required String nilai,
                Value<DateTime> diubahPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelPengaturanCompanion.insert(
                kunci: kunci,
                nilai: nilai,
                diubahPada: diubahPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabelPengaturanTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelPengaturanTable,
      EntitasPengaturan,
      $$TabelPengaturanTableFilterComposer,
      $$TabelPengaturanTableOrderingComposer,
      $$TabelPengaturanTableAnnotationComposer,
      $$TabelPengaturanTableCreateCompanionBuilder,
      $$TabelPengaturanTableUpdateCompanionBuilder,
      (
        EntitasPengaturan,
        BaseReferences<
          _$BasisDataFunda,
          $TabelPengaturanTable,
          EntitasPengaturan
        >,
      ),
      EntitasPengaturan,
      PrefetchHooks Function()
    >;

class $BasisDataFundaManager {
  final _$BasisDataFunda _db;
  $BasisDataFundaManager(this._db);
  $$TabelPengaturanTableTableManager get tabelPengaturan =>
      $$TabelPengaturanTableTableManager(_db, _db.tabelPengaturan);
}
