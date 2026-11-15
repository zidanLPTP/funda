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

class $TabelDompetTable extends TabelDompet
    with TableInfo<$TabelDompetTable, EntitasDompet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelDompetTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jenisMeta = const VerificationMeta('jenis');
  @override
  late final GeneratedColumn<String> jenis = GeneratedColumn<String>(
    'jenis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ikonMeta = const VerificationMeta('ikon');
  @override
  late final GeneratedColumn<String> ikon = GeneratedColumn<String>(
    'ikon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warnaMeta = const VerificationMeta('warna');
  @override
  late final GeneratedColumn<String> warna = GeneratedColumn<String>(
    'warna',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saldoAwalRupiahMeta = const VerificationMeta(
    'saldoAwalRupiah',
  );
  @override
  late final GeneratedColumn<int> saldoAwalRupiah = GeneratedColumn<int>(
    'saldo_awal_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _urutanMeta = const VerificationMeta('urutan');
  @override
  late final GeneratedColumn<int> urutan = GeneratedColumn<int>(
    'urutan',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _diarsipkanMeta = const VerificationMeta(
    'diarsipkan',
  );
  @override
  late final GeneratedColumn<bool> diarsipkan = GeneratedColumn<bool>(
    'diarsipkan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("diarsipkan" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dibuatPadaMeta = const VerificationMeta(
    'dibuatPada',
  );
  @override
  late final GeneratedColumn<DateTime> dibuatPada = GeneratedColumn<DateTime>(
    'dibuat_pada',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    jenis,
    ikon,
    warna,
    saldoAwalRupiah,
    urutan,
    diarsipkan,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_dompet';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasDompet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('jenis')) {
      context.handle(
        _jenisMeta,
        jenis.isAcceptableOrUnknown(data['jenis']!, _jenisMeta),
      );
    } else if (isInserting) {
      context.missing(_jenisMeta);
    }
    if (data.containsKey('ikon')) {
      context.handle(
        _ikonMeta,
        ikon.isAcceptableOrUnknown(data['ikon']!, _ikonMeta),
      );
    } else if (isInserting) {
      context.missing(_ikonMeta);
    }
    if (data.containsKey('warna')) {
      context.handle(
        _warnaMeta,
        warna.isAcceptableOrUnknown(data['warna']!, _warnaMeta),
      );
    } else if (isInserting) {
      context.missing(_warnaMeta);
    }
    if (data.containsKey('saldo_awal_rupiah')) {
      context.handle(
        _saldoAwalRupiahMeta,
        saldoAwalRupiah.isAcceptableOrUnknown(
          data['saldo_awal_rupiah']!,
          _saldoAwalRupiahMeta,
        ),
      );
    }
    if (data.containsKey('urutan')) {
      context.handle(
        _urutanMeta,
        urutan.isAcceptableOrUnknown(data['urutan']!, _urutanMeta),
      );
    }
    if (data.containsKey('diarsipkan')) {
      context.handle(
        _diarsipkanMeta,
        diarsipkan.isAcceptableOrUnknown(data['diarsipkan']!, _diarsipkanMeta),
      );
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasDompet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasDompet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      jenis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis'],
      )!,
      ikon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ikon'],
      )!,
      warna: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warna'],
      )!,
      saldoAwalRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_awal_rupiah'],
      )!,
      urutan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}urutan'],
      )!,
      diarsipkan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}diarsipkan'],
      )!,
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
    );
  }

  @override
  $TabelDompetTable createAlias(String alias) {
    return $TabelDompetTable(attachedDatabase, alias);
  }
}

class EntitasDompet extends DataClass implements Insertable<EntitasDompet> {
  /// Pengenal unik dompet (UUID).
  final String id;

  /// Nama dompet (misal: 'Kantong Utama', 'BCA', 'GoPay', 'Dompet Tunai').
  final String nama;

  /// Jenis dompet ('tunai', 'rekening_bank', 'e_wallet', 'lainnya').
  final String jenis;

  /// Kunci pengenal ikon dari pustaka Lucide.
  final String ikon;

  /// Kunci token warna tint (misal: 'tintHijau', 'tintBiru', 'tintUngu', dll).
  final String warna;

  /// Saldo awal saat dompet pertama kali dibuat (dalam Rupiah integer >= 0).
  final int saldoAwalRupiah;

  /// Urutan tampilan pada antarmuka.
  final int urutan;

  /// Penanda status arsip (dompet yang diarsipkan disembunyikan dari pemilihan).
  final bool diarsipkan;

  /// Waktu pembuatan catatan dompet.
  final DateTime dibuatPada;
  const EntitasDompet({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.ikon,
    required this.warna,
    required this.saldoAwalRupiah,
    required this.urutan,
    required this.diarsipkan,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['jenis'] = Variable<String>(jenis);
    map['ikon'] = Variable<String>(ikon);
    map['warna'] = Variable<String>(warna);
    map['saldo_awal_rupiah'] = Variable<int>(saldoAwalRupiah);
    map['urutan'] = Variable<int>(urutan);
    map['diarsipkan'] = Variable<bool>(diarsipkan);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelDompetCompanion toCompanion(bool nullToAbsent) {
    return TabelDompetCompanion(
      id: Value(id),
      nama: Value(nama),
      jenis: Value(jenis),
      ikon: Value(ikon),
      warna: Value(warna),
      saldoAwalRupiah: Value(saldoAwalRupiah),
      urutan: Value(urutan),
      diarsipkan: Value(diarsipkan),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasDompet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasDompet(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      jenis: serializer.fromJson<String>(json['jenis']),
      ikon: serializer.fromJson<String>(json['ikon']),
      warna: serializer.fromJson<String>(json['warna']),
      saldoAwalRupiah: serializer.fromJson<int>(json['saldoAwalRupiah']),
      urutan: serializer.fromJson<int>(json['urutan']),
      diarsipkan: serializer.fromJson<bool>(json['diarsipkan']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'jenis': serializer.toJson<String>(jenis),
      'ikon': serializer.toJson<String>(ikon),
      'warna': serializer.toJson<String>(warna),
      'saldoAwalRupiah': serializer.toJson<int>(saldoAwalRupiah),
      'urutan': serializer.toJson<int>(urutan),
      'diarsipkan': serializer.toJson<bool>(diarsipkan),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasDompet copyWith({
    String? id,
    String? nama,
    String? jenis,
    String? ikon,
    String? warna,
    int? saldoAwalRupiah,
    int? urutan,
    bool? diarsipkan,
    DateTime? dibuatPada,
  }) => EntitasDompet(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    jenis: jenis ?? this.jenis,
    ikon: ikon ?? this.ikon,
    warna: warna ?? this.warna,
    saldoAwalRupiah: saldoAwalRupiah ?? this.saldoAwalRupiah,
    urutan: urutan ?? this.urutan,
    diarsipkan: diarsipkan ?? this.diarsipkan,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasDompet copyWithCompanion(TabelDompetCompanion data) {
    return EntitasDompet(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      ikon: data.ikon.present ? data.ikon.value : this.ikon,
      warna: data.warna.present ? data.warna.value : this.warna,
      saldoAwalRupiah: data.saldoAwalRupiah.present
          ? data.saldoAwalRupiah.value
          : this.saldoAwalRupiah,
      urutan: data.urutan.present ? data.urutan.value : this.urutan,
      diarsipkan: data.diarsipkan.present
          ? data.diarsipkan.value
          : this.diarsipkan,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasDompet(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('ikon: $ikon, ')
          ..write('warna: $warna, ')
          ..write('saldoAwalRupiah: $saldoAwalRupiah, ')
          ..write('urutan: $urutan, ')
          ..write('diarsipkan: $diarsipkan, ')
          ..write('dibuatPada: $dibuatPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nama,
    jenis,
    ikon,
    warna,
    saldoAwalRupiah,
    urutan,
    diarsipkan,
    dibuatPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasDompet &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.jenis == this.jenis &&
          other.ikon == this.ikon &&
          other.warna == this.warna &&
          other.saldoAwalRupiah == this.saldoAwalRupiah &&
          other.urutan == this.urutan &&
          other.diarsipkan == this.diarsipkan &&
          other.dibuatPada == this.dibuatPada);
}

class TabelDompetCompanion extends UpdateCompanion<EntitasDompet> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> jenis;
  final Value<String> ikon;
  final Value<String> warna;
  final Value<int> saldoAwalRupiah;
  final Value<int> urutan;
  final Value<bool> diarsipkan;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelDompetCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.jenis = const Value.absent(),
    this.ikon = const Value.absent(),
    this.warna = const Value.absent(),
    this.saldoAwalRupiah = const Value.absent(),
    this.urutan = const Value.absent(),
    this.diarsipkan = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelDompetCompanion.insert({
    required String id,
    required String nama,
    required String jenis,
    required String ikon,
    required String warna,
    this.saldoAwalRupiah = const Value.absent(),
    this.urutan = const Value.absent(),
    this.diarsipkan = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       jenis = Value(jenis),
       ikon = Value(ikon),
       warna = Value(warna);
  static Insertable<EntitasDompet> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? jenis,
    Expression<String>? ikon,
    Expression<String>? warna,
    Expression<int>? saldoAwalRupiah,
    Expression<int>? urutan,
    Expression<bool>? diarsipkan,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (jenis != null) 'jenis': jenis,
      if (ikon != null) 'ikon': ikon,
      if (warna != null) 'warna': warna,
      if (saldoAwalRupiah != null) 'saldo_awal_rupiah': saldoAwalRupiah,
      if (urutan != null) 'urutan': urutan,
      if (diarsipkan != null) 'diarsipkan': diarsipkan,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelDompetCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? jenis,
    Value<String>? ikon,
    Value<String>? warna,
    Value<int>? saldoAwalRupiah,
    Value<int>? urutan,
    Value<bool>? diarsipkan,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelDompetCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      ikon: ikon ?? this.ikon,
      warna: warna ?? this.warna,
      saldoAwalRupiah: saldoAwalRupiah ?? this.saldoAwalRupiah,
      urutan: urutan ?? this.urutan,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (jenis.present) {
      map['jenis'] = Variable<String>(jenis.value);
    }
    if (ikon.present) {
      map['ikon'] = Variable<String>(ikon.value);
    }
    if (warna.present) {
      map['warna'] = Variable<String>(warna.value);
    }
    if (saldoAwalRupiah.present) {
      map['saldo_awal_rupiah'] = Variable<int>(saldoAwalRupiah.value);
    }
    if (urutan.present) {
      map['urutan'] = Variable<int>(urutan.value);
    }
    if (diarsipkan.present) {
      map['diarsipkan'] = Variable<bool>(diarsipkan.value);
    }
    if (dibuatPada.present) {
      map['dibuat_pada'] = Variable<DateTime>(dibuatPada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelDompetCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('ikon: $ikon, ')
          ..write('warna: $warna, ')
          ..write('saldoAwalRupiah: $saldoAwalRupiah, ')
          ..write('urutan: $urutan, ')
          ..write('diarsipkan: $diarsipkan, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelKategoriTable extends TabelKategori
    with TableInfo<$TabelKategoriTable, EntitasKategori> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelKategoriTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arusMeta = const VerificationMeta('arus');
  @override
  late final GeneratedColumn<String> arus = GeneratedColumn<String>(
    'arus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sifatMeta = const VerificationMeta('sifat');
  @override
  late final GeneratedColumn<String> sifat = GeneratedColumn<String>(
    'sifat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ikonMeta = const VerificationMeta('ikon');
  @override
  late final GeneratedColumn<String> ikon = GeneratedColumn<String>(
    'ikon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bawaanMeta = const VerificationMeta('bawaan');
  @override
  late final GeneratedColumn<bool> bawaan = GeneratedColumn<bool>(
    'bawaan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bawaan" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _diarsipkanMeta = const VerificationMeta(
    'diarsipkan',
  );
  @override
  late final GeneratedColumn<bool> diarsipkan = GeneratedColumn<bool>(
    'diarsipkan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("diarsipkan" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    arus,
    sifat,
    ikon,
    bawaan,
    diarsipkan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_kategori';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasKategori> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('arus')) {
      context.handle(
        _arusMeta,
        arus.isAcceptableOrUnknown(data['arus']!, _arusMeta),
      );
    } else if (isInserting) {
      context.missing(_arusMeta);
    }
    if (data.containsKey('sifat')) {
      context.handle(
        _sifatMeta,
        sifat.isAcceptableOrUnknown(data['sifat']!, _sifatMeta),
      );
    } else if (isInserting) {
      context.missing(_sifatMeta);
    }
    if (data.containsKey('ikon')) {
      context.handle(
        _ikonMeta,
        ikon.isAcceptableOrUnknown(data['ikon']!, _ikonMeta),
      );
    } else if (isInserting) {
      context.missing(_ikonMeta);
    }
    if (data.containsKey('bawaan')) {
      context.handle(
        _bawaanMeta,
        bawaan.isAcceptableOrUnknown(data['bawaan']!, _bawaanMeta),
      );
    }
    if (data.containsKey('diarsipkan')) {
      context.handle(
        _diarsipkanMeta,
        diarsipkan.isAcceptableOrUnknown(data['diarsipkan']!, _diarsipkanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasKategori map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasKategori(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      arus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arus'],
      )!,
      sifat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sifat'],
      )!,
      ikon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ikon'],
      )!,
      bawaan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bawaan'],
      )!,
      diarsipkan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}diarsipkan'],
      )!,
    );
  }

  @override
  $TabelKategoriTable createAlias(String alias) {
    return $TabelKategoriTable(attachedDatabase, alias);
  }
}

class EntitasKategori extends DataClass implements Insertable<EntitasKategori> {
  /// Pengenal unik kategori (UUID).
  final String id;

  /// Nama kategori (misal: 'Makan Harian', 'Gaji', 'Hiburan').
  final String nama;

  /// Arah arus kas ('masuk' atau 'keluar').
  final String arus;

  /// Sifat pengeluaran ('kebutuhan', 'keinginan', 'tabungan', 'utang', 'belum_dilabeli', 'tidak_berlaku').
  final String sifat;

  /// Kunci pengenal ikon dari pustaka Lucide.
  final String ikon;

  /// Penanda apakah kategori ini adalah kategori bawaan sistem.
  final bool bawaan;

  /// Penanda apakah kategori diarsipkan oleh pengguna.
  final bool diarsipkan;
  const EntitasKategori({
    required this.id,
    required this.nama,
    required this.arus,
    required this.sifat,
    required this.ikon,
    required this.bawaan,
    required this.diarsipkan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['arus'] = Variable<String>(arus);
    map['sifat'] = Variable<String>(sifat);
    map['ikon'] = Variable<String>(ikon);
    map['bawaan'] = Variable<bool>(bawaan);
    map['diarsipkan'] = Variable<bool>(diarsipkan);
    return map;
  }

  TabelKategoriCompanion toCompanion(bool nullToAbsent) {
    return TabelKategoriCompanion(
      id: Value(id),
      nama: Value(nama),
      arus: Value(arus),
      sifat: Value(sifat),
      ikon: Value(ikon),
      bawaan: Value(bawaan),
      diarsipkan: Value(diarsipkan),
    );
  }

  factory EntitasKategori.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasKategori(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      arus: serializer.fromJson<String>(json['arus']),
      sifat: serializer.fromJson<String>(json['sifat']),
      ikon: serializer.fromJson<String>(json['ikon']),
      bawaan: serializer.fromJson<bool>(json['bawaan']),
      diarsipkan: serializer.fromJson<bool>(json['diarsipkan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'arus': serializer.toJson<String>(arus),
      'sifat': serializer.toJson<String>(sifat),
      'ikon': serializer.toJson<String>(ikon),
      'bawaan': serializer.toJson<bool>(bawaan),
      'diarsipkan': serializer.toJson<bool>(diarsipkan),
    };
  }

  EntitasKategori copyWith({
    String? id,
    String? nama,
    String? arus,
    String? sifat,
    String? ikon,
    bool? bawaan,
    bool? diarsipkan,
  }) => EntitasKategori(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    arus: arus ?? this.arus,
    sifat: sifat ?? this.sifat,
    ikon: ikon ?? this.ikon,
    bawaan: bawaan ?? this.bawaan,
    diarsipkan: diarsipkan ?? this.diarsipkan,
  );
  EntitasKategori copyWithCompanion(TabelKategoriCompanion data) {
    return EntitasKategori(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      arus: data.arus.present ? data.arus.value : this.arus,
      sifat: data.sifat.present ? data.sifat.value : this.sifat,
      ikon: data.ikon.present ? data.ikon.value : this.ikon,
      bawaan: data.bawaan.present ? data.bawaan.value : this.bawaan,
      diarsipkan: data.diarsipkan.present
          ? data.diarsipkan.value
          : this.diarsipkan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasKategori(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('arus: $arus, ')
          ..write('sifat: $sifat, ')
          ..write('ikon: $ikon, ')
          ..write('bawaan: $bawaan, ')
          ..write('diarsipkan: $diarsipkan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nama, arus, sifat, ikon, bawaan, diarsipkan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasKategori &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.arus == this.arus &&
          other.sifat == this.sifat &&
          other.ikon == this.ikon &&
          other.bawaan == this.bawaan &&
          other.diarsipkan == this.diarsipkan);
}

class TabelKategoriCompanion extends UpdateCompanion<EntitasKategori> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> arus;
  final Value<String> sifat;
  final Value<String> ikon;
  final Value<bool> bawaan;
  final Value<bool> diarsipkan;
  final Value<int> rowid;
  const TabelKategoriCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.arus = const Value.absent(),
    this.sifat = const Value.absent(),
    this.ikon = const Value.absent(),
    this.bawaan = const Value.absent(),
    this.diarsipkan = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelKategoriCompanion.insert({
    required String id,
    required String nama,
    required String arus,
    required String sifat,
    required String ikon,
    this.bawaan = const Value.absent(),
    this.diarsipkan = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       arus = Value(arus),
       sifat = Value(sifat),
       ikon = Value(ikon);
  static Insertable<EntitasKategori> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? arus,
    Expression<String>? sifat,
    Expression<String>? ikon,
    Expression<bool>? bawaan,
    Expression<bool>? diarsipkan,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (arus != null) 'arus': arus,
      if (sifat != null) 'sifat': sifat,
      if (ikon != null) 'ikon': ikon,
      if (bawaan != null) 'bawaan': bawaan,
      if (diarsipkan != null) 'diarsipkan': diarsipkan,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelKategoriCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? arus,
    Value<String>? sifat,
    Value<String>? ikon,
    Value<bool>? bawaan,
    Value<bool>? diarsipkan,
    Value<int>? rowid,
  }) {
    return TabelKategoriCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      arus: arus ?? this.arus,
      sifat: sifat ?? this.sifat,
      ikon: ikon ?? this.ikon,
      bawaan: bawaan ?? this.bawaan,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (arus.present) {
      map['arus'] = Variable<String>(arus.value);
    }
    if (sifat.present) {
      map['sifat'] = Variable<String>(sifat.value);
    }
    if (ikon.present) {
      map['ikon'] = Variable<String>(ikon.value);
    }
    if (bawaan.present) {
      map['bawaan'] = Variable<bool>(bawaan.value);
    }
    if (diarsipkan.present) {
      map['diarsipkan'] = Variable<bool>(diarsipkan.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelKategoriCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('arus: $arus, ')
          ..write('sifat: $sifat, ')
          ..write('ikon: $ikon, ')
          ..write('bawaan: $bawaan, ')
          ..write('diarsipkan: $diarsipkan, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelTransaksiTable extends TabelTransaksi
    with TableInfo<$TabelTransaksiTable, EntitasTransaksi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelTransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jenisMeta = const VerificationMeta('jenis');
  @override
  late final GeneratedColumn<String> jenis = GeneratedColumn<String>(
    'jenis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jumlahRupiahMeta = const VerificationMeta(
    'jumlahRupiah',
  );
  @override
  late final GeneratedColumn<int> jumlahRupiah = GeneratedColumn<int>(
    'jumlah_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dompetIdMeta = const VerificationMeta(
    'dompetId',
  );
  @override
  late final GeneratedColumn<String> dompetId = GeneratedColumn<String>(
    'dompet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_dompet (id)',
    ),
  );
  static const VerificationMeta _dompetTujuanIdMeta = const VerificationMeta(
    'dompetTujuanId',
  );
  @override
  late final GeneratedColumn<String> dompetTujuanId = GeneratedColumn<String>(
    'dompet_tujuan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_dompet (id)',
    ),
  );
  static const VerificationMeta _kategoriIdMeta = const VerificationMeta(
    'kategoriId',
  );
  @override
  late final GeneratedColumn<String> kategoriId = GeneratedColumn<String>(
    'kategori_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_kategori (id)',
    ),
  );
  static const VerificationMeta _biayaAdminRupiahMeta = const VerificationMeta(
    'biayaAdminRupiah',
  );
  @override
  late final GeneratedColumn<int> biayaAdminRupiah = GeneratedColumn<int>(
    'biaya_admin_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waktuTransaksiMeta = const VerificationMeta(
    'waktuTransaksi',
  );
  @override
  late final GeneratedColumn<DateTime> waktuTransaksi =
      GeneratedColumn<DateTime>(
        'waktu_transaksi',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dibuatPadaMeta = const VerificationMeta(
    'dibuatPada',
  );
  @override
  late final GeneratedColumn<DateTime> dibuatPada = GeneratedColumn<DateTime>(
    'dibuat_pada',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    jenis,
    jumlahRupiah,
    dompetId,
    dompetTujuanId,
    kategoriId,
    biayaAdminRupiah,
    catatan,
    waktuTransaksi,
    dibuatPada,
    diubahPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_transaksi';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasTransaksi> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('jenis')) {
      context.handle(
        _jenisMeta,
        jenis.isAcceptableOrUnknown(data['jenis']!, _jenisMeta),
      );
    } else if (isInserting) {
      context.missing(_jenisMeta);
    }
    if (data.containsKey('jumlah_rupiah')) {
      context.handle(
        _jumlahRupiahMeta,
        jumlahRupiah.isAcceptableOrUnknown(
          data['jumlah_rupiah']!,
          _jumlahRupiahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jumlahRupiahMeta);
    }
    if (data.containsKey('dompet_id')) {
      context.handle(
        _dompetIdMeta,
        dompetId.isAcceptableOrUnknown(data['dompet_id']!, _dompetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dompetIdMeta);
    }
    if (data.containsKey('dompet_tujuan_id')) {
      context.handle(
        _dompetTujuanIdMeta,
        dompetTujuanId.isAcceptableOrUnknown(
          data['dompet_tujuan_id']!,
          _dompetTujuanIdMeta,
        ),
      );
    }
    if (data.containsKey('kategori_id')) {
      context.handle(
        _kategoriIdMeta,
        kategoriId.isAcceptableOrUnknown(data['kategori_id']!, _kategoriIdMeta),
      );
    }
    if (data.containsKey('biaya_admin_rupiah')) {
      context.handle(
        _biayaAdminRupiahMeta,
        biayaAdminRupiah.isAcceptableOrUnknown(
          data['biaya_admin_rupiah']!,
          _biayaAdminRupiahMeta,
        ),
      );
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('waktu_transaksi')) {
      context.handle(
        _waktuTransaksiMeta,
        waktuTransaksi.isAcceptableOrUnknown(
          data['waktu_transaksi']!,
          _waktuTransaksiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waktuTransaksiMeta);
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasTransaksi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasTransaksi(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jenis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis'],
      )!,
      jumlahRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jumlah_rupiah'],
      )!,
      dompetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dompet_id'],
      )!,
      dompetTujuanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dompet_tujuan_id'],
      ),
      kategoriId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori_id'],
      ),
      biayaAdminRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}biaya_admin_rupiah'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      waktuTransaksi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}waktu_transaksi'],
      )!,
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
      diubahPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diubah_pada'],
      )!,
    );
  }

  @override
  $TabelTransaksiTable createAlias(String alias) {
    return $TabelTransaksiTable(attachedDatabase, alias);
  }
}

class EntitasTransaksi extends DataClass
    implements Insertable<EntitasTransaksi> {
  /// Pengenal unik transaksi (UUID).
  final String id;

  /// Jenis transaksi: 'masuk', 'keluar', 'transfer', 'penyesuaian_masuk', 'penyesuaian_keluar'.
  final String jenis;

  /// Jumlah nominal transaksi dalam bilangan bulat Rupiah (selalu > 0).
  final int jumlahRupiah;

  /// ID dompet sumber / dompet utama yang terpengaruh.
  final String dompetId;

  /// ID dompet tujuan (khusus jenis 'transfer').
  final String? dompetTujuanId;

  /// ID kategori transaksi (wajib untuk masuk/keluar, null untuk transfer dan penyesuaian).
  final String? kategoriId;

  /// Biaya administrasi transfer dalam Rupiah (hanya untuk transfer, >= 0).
  final int biayaAdminRupiah;

  /// Catatan atau deskripsi transaksi opsional.
  final String? catatan;

  /// Waktu pelaksanaan transaksi (disimpan dalam DateTime UTC).
  final DateTime waktuTransaksi;

  /// Waktu baris data ini dibuat di perangkat.
  final DateTime dibuatPada;

  /// Waktu baris data ini terakhir kali diubah.
  final DateTime diubahPada;
  const EntitasTransaksi({
    required this.id,
    required this.jenis,
    required this.jumlahRupiah,
    required this.dompetId,
    this.dompetTujuanId,
    this.kategoriId,
    required this.biayaAdminRupiah,
    this.catatan,
    required this.waktuTransaksi,
    required this.dibuatPada,
    required this.diubahPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['jenis'] = Variable<String>(jenis);
    map['jumlah_rupiah'] = Variable<int>(jumlahRupiah);
    map['dompet_id'] = Variable<String>(dompetId);
    if (!nullToAbsent || dompetTujuanId != null) {
      map['dompet_tujuan_id'] = Variable<String>(dompetTujuanId);
    }
    if (!nullToAbsent || kategoriId != null) {
      map['kategori_id'] = Variable<String>(kategoriId);
    }
    map['biaya_admin_rupiah'] = Variable<int>(biayaAdminRupiah);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    map['waktu_transaksi'] = Variable<DateTime>(waktuTransaksi);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    map['diubah_pada'] = Variable<DateTime>(diubahPada);
    return map;
  }

  TabelTransaksiCompanion toCompanion(bool nullToAbsent) {
    return TabelTransaksiCompanion(
      id: Value(id),
      jenis: Value(jenis),
      jumlahRupiah: Value(jumlahRupiah),
      dompetId: Value(dompetId),
      dompetTujuanId: dompetTujuanId == null && nullToAbsent
          ? const Value.absent()
          : Value(dompetTujuanId),
      kategoriId: kategoriId == null && nullToAbsent
          ? const Value.absent()
          : Value(kategoriId),
      biayaAdminRupiah: Value(biayaAdminRupiah),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      waktuTransaksi: Value(waktuTransaksi),
      dibuatPada: Value(dibuatPada),
      diubahPada: Value(diubahPada),
    );
  }

  factory EntitasTransaksi.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasTransaksi(
      id: serializer.fromJson<String>(json['id']),
      jenis: serializer.fromJson<String>(json['jenis']),
      jumlahRupiah: serializer.fromJson<int>(json['jumlahRupiah']),
      dompetId: serializer.fromJson<String>(json['dompetId']),
      dompetTujuanId: serializer.fromJson<String?>(json['dompetTujuanId']),
      kategoriId: serializer.fromJson<String?>(json['kategoriId']),
      biayaAdminRupiah: serializer.fromJson<int>(json['biayaAdminRupiah']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      waktuTransaksi: serializer.fromJson<DateTime>(json['waktuTransaksi']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
      diubahPada: serializer.fromJson<DateTime>(json['diubahPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jenis': serializer.toJson<String>(jenis),
      'jumlahRupiah': serializer.toJson<int>(jumlahRupiah),
      'dompetId': serializer.toJson<String>(dompetId),
      'dompetTujuanId': serializer.toJson<String?>(dompetTujuanId),
      'kategoriId': serializer.toJson<String?>(kategoriId),
      'biayaAdminRupiah': serializer.toJson<int>(biayaAdminRupiah),
      'catatan': serializer.toJson<String?>(catatan),
      'waktuTransaksi': serializer.toJson<DateTime>(waktuTransaksi),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
      'diubahPada': serializer.toJson<DateTime>(diubahPada),
    };
  }

  EntitasTransaksi copyWith({
    String? id,
    String? jenis,
    int? jumlahRupiah,
    String? dompetId,
    Value<String?> dompetTujuanId = const Value.absent(),
    Value<String?> kategoriId = const Value.absent(),
    int? biayaAdminRupiah,
    Value<String?> catatan = const Value.absent(),
    DateTime? waktuTransaksi,
    DateTime? dibuatPada,
    DateTime? diubahPada,
  }) => EntitasTransaksi(
    id: id ?? this.id,
    jenis: jenis ?? this.jenis,
    jumlahRupiah: jumlahRupiah ?? this.jumlahRupiah,
    dompetId: dompetId ?? this.dompetId,
    dompetTujuanId: dompetTujuanId.present
        ? dompetTujuanId.value
        : this.dompetTujuanId,
    kategoriId: kategoriId.present ? kategoriId.value : this.kategoriId,
    biayaAdminRupiah: biayaAdminRupiah ?? this.biayaAdminRupiah,
    catatan: catatan.present ? catatan.value : this.catatan,
    waktuTransaksi: waktuTransaksi ?? this.waktuTransaksi,
    dibuatPada: dibuatPada ?? this.dibuatPada,
    diubahPada: diubahPada ?? this.diubahPada,
  );
  EntitasTransaksi copyWithCompanion(TabelTransaksiCompanion data) {
    return EntitasTransaksi(
      id: data.id.present ? data.id.value : this.id,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      jumlahRupiah: data.jumlahRupiah.present
          ? data.jumlahRupiah.value
          : this.jumlahRupiah,
      dompetId: data.dompetId.present ? data.dompetId.value : this.dompetId,
      dompetTujuanId: data.dompetTujuanId.present
          ? data.dompetTujuanId.value
          : this.dompetTujuanId,
      kategoriId: data.kategoriId.present
          ? data.kategoriId.value
          : this.kategoriId,
      biayaAdminRupiah: data.biayaAdminRupiah.present
          ? data.biayaAdminRupiah.value
          : this.biayaAdminRupiah,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      waktuTransaksi: data.waktuTransaksi.present
          ? data.waktuTransaksi.value
          : this.waktuTransaksi,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
      diubahPada: data.diubahPada.present
          ? data.diubahPada.value
          : this.diubahPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasTransaksi(')
          ..write('id: $id, ')
          ..write('jenis: $jenis, ')
          ..write('jumlahRupiah: $jumlahRupiah, ')
          ..write('dompetId: $dompetId, ')
          ..write('dompetTujuanId: $dompetTujuanId, ')
          ..write('kategoriId: $kategoriId, ')
          ..write('biayaAdminRupiah: $biayaAdminRupiah, ')
          ..write('catatan: $catatan, ')
          ..write('waktuTransaksi: $waktuTransaksi, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('diubahPada: $diubahPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jenis,
    jumlahRupiah,
    dompetId,
    dompetTujuanId,
    kategoriId,
    biayaAdminRupiah,
    catatan,
    waktuTransaksi,
    dibuatPada,
    diubahPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasTransaksi &&
          other.id == this.id &&
          other.jenis == this.jenis &&
          other.jumlahRupiah == this.jumlahRupiah &&
          other.dompetId == this.dompetId &&
          other.dompetTujuanId == this.dompetTujuanId &&
          other.kategoriId == this.kategoriId &&
          other.biayaAdminRupiah == this.biayaAdminRupiah &&
          other.catatan == this.catatan &&
          other.waktuTransaksi == this.waktuTransaksi &&
          other.dibuatPada == this.dibuatPada &&
          other.diubahPada == this.diubahPada);
}

class TabelTransaksiCompanion extends UpdateCompanion<EntitasTransaksi> {
  final Value<String> id;
  final Value<String> jenis;
  final Value<int> jumlahRupiah;
  final Value<String> dompetId;
  final Value<String?> dompetTujuanId;
  final Value<String?> kategoriId;
  final Value<int> biayaAdminRupiah;
  final Value<String?> catatan;
  final Value<DateTime> waktuTransaksi;
  final Value<DateTime> dibuatPada;
  final Value<DateTime> diubahPada;
  final Value<int> rowid;
  const TabelTransaksiCompanion({
    this.id = const Value.absent(),
    this.jenis = const Value.absent(),
    this.jumlahRupiah = const Value.absent(),
    this.dompetId = const Value.absent(),
    this.dompetTujuanId = const Value.absent(),
    this.kategoriId = const Value.absent(),
    this.biayaAdminRupiah = const Value.absent(),
    this.catatan = const Value.absent(),
    this.waktuTransaksi = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.diubahPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelTransaksiCompanion.insert({
    required String id,
    required String jenis,
    required int jumlahRupiah,
    required String dompetId,
    this.dompetTujuanId = const Value.absent(),
    this.kategoriId = const Value.absent(),
    this.biayaAdminRupiah = const Value.absent(),
    this.catatan = const Value.absent(),
    required DateTime waktuTransaksi,
    this.dibuatPada = const Value.absent(),
    this.diubahPada = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jenis = Value(jenis),
       jumlahRupiah = Value(jumlahRupiah),
       dompetId = Value(dompetId),
       waktuTransaksi = Value(waktuTransaksi);
  static Insertable<EntitasTransaksi> custom({
    Expression<String>? id,
    Expression<String>? jenis,
    Expression<int>? jumlahRupiah,
    Expression<String>? dompetId,
    Expression<String>? dompetTujuanId,
    Expression<String>? kategoriId,
    Expression<int>? biayaAdminRupiah,
    Expression<String>? catatan,
    Expression<DateTime>? waktuTransaksi,
    Expression<DateTime>? dibuatPada,
    Expression<DateTime>? diubahPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jenis != null) 'jenis': jenis,
      if (jumlahRupiah != null) 'jumlah_rupiah': jumlahRupiah,
      if (dompetId != null) 'dompet_id': dompetId,
      if (dompetTujuanId != null) 'dompet_tujuan_id': dompetTujuanId,
      if (kategoriId != null) 'kategori_id': kategoriId,
      if (biayaAdminRupiah != null) 'biaya_admin_rupiah': biayaAdminRupiah,
      if (catatan != null) 'catatan': catatan,
      if (waktuTransaksi != null) 'waktu_transaksi': waktuTransaksi,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (diubahPada != null) 'diubah_pada': diubahPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelTransaksiCompanion copyWith({
    Value<String>? id,
    Value<String>? jenis,
    Value<int>? jumlahRupiah,
    Value<String>? dompetId,
    Value<String?>? dompetTujuanId,
    Value<String?>? kategoriId,
    Value<int>? biayaAdminRupiah,
    Value<String?>? catatan,
    Value<DateTime>? waktuTransaksi,
    Value<DateTime>? dibuatPada,
    Value<DateTime>? diubahPada,
    Value<int>? rowid,
  }) {
    return TabelTransaksiCompanion(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      jumlahRupiah: jumlahRupiah ?? this.jumlahRupiah,
      dompetId: dompetId ?? this.dompetId,
      dompetTujuanId: dompetTujuanId ?? this.dompetTujuanId,
      kategoriId: kategoriId ?? this.kategoriId,
      biayaAdminRupiah: biayaAdminRupiah ?? this.biayaAdminRupiah,
      catatan: catatan ?? this.catatan,
      waktuTransaksi: waktuTransaksi ?? this.waktuTransaksi,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diubahPada: diubahPada ?? this.diubahPada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jenis.present) {
      map['jenis'] = Variable<String>(jenis.value);
    }
    if (jumlahRupiah.present) {
      map['jumlah_rupiah'] = Variable<int>(jumlahRupiah.value);
    }
    if (dompetId.present) {
      map['dompet_id'] = Variable<String>(dompetId.value);
    }
    if (dompetTujuanId.present) {
      map['dompet_tujuan_id'] = Variable<String>(dompetTujuanId.value);
    }
    if (kategoriId.present) {
      map['kategori_id'] = Variable<String>(kategoriId.value);
    }
    if (biayaAdminRupiah.present) {
      map['biaya_admin_rupiah'] = Variable<int>(biayaAdminRupiah.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (waktuTransaksi.present) {
      map['waktu_transaksi'] = Variable<DateTime>(waktuTransaksi.value);
    }
    if (dibuatPada.present) {
      map['dibuat_pada'] = Variable<DateTime>(dibuatPada.value);
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
    return (StringBuffer('TabelTransaksiCompanion(')
          ..write('id: $id, ')
          ..write('jenis: $jenis, ')
          ..write('jumlahRupiah: $jumlahRupiah, ')
          ..write('dompetId: $dompetId, ')
          ..write('dompetTujuanId: $dompetTujuanId, ')
          ..write('kategoriId: $kategoriId, ')
          ..write('biayaAdminRupiah: $biayaAdminRupiah, ')
          ..write('catatan: $catatan, ')
          ..write('waktuTransaksi: $waktuTransaksi, ')
          ..write('dibuatPada: $dibuatPada, ')
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
  late final $TabelDompetTable tabelDompet = $TabelDompetTable(this);
  late final $TabelKategoriTable tabelKategori = $TabelKategoriTable(this);
  late final $TabelTransaksiTable tabelTransaksi = $TabelTransaksiTable(this);
  late final Index idxTransaksiWaktu = Index(
    'idx_transaksi_waktu',
    'CREATE INDEX idx_transaksi_waktu ON tabel_transaksi (waktu_transaksi)',
  );
  late final Index idxTransaksiDompet = Index(
    'idx_transaksi_dompet',
    'CREATE INDEX idx_transaksi_dompet ON tabel_transaksi (dompet_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tabelPengaturan,
    tabelDompet,
    tabelKategori,
    tabelTransaksi,
    idxTransaksiWaktu,
    idxTransaksiDompet,
  ];
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
typedef $$TabelDompetTableCreateCompanionBuilder =
    TabelDompetCompanion Function({
      required String id,
      required String nama,
      required String jenis,
      required String ikon,
      required String warna,
      Value<int> saldoAwalRupiah,
      Value<int> urutan,
      Value<bool> diarsipkan,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelDompetTableUpdateCompanionBuilder =
    TabelDompetCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> jenis,
      Value<String> ikon,
      Value<String> warna,
      Value<int> saldoAwalRupiah,
      Value<int> urutan,
      Value<bool> diarsipkan,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelDompetTableReferences
    extends BaseReferences<_$BasisDataFunda, $TabelDompetTable, EntitasDompet> {
  $$TabelDompetTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TabelTransaksiTable, List<EntitasTransaksi>>
  _transaksiDompetAsalTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelTransaksi,
        aliasName: $_aliasNameGenerator(
          db.tabelDompet.id,
          db.tabelTransaksi.dompetId,
        ),
      );

  $$TabelTransaksiTableProcessedTableManager get transaksiDompetAsal {
    final manager = $$TabelTransaksiTableTableManager(
      $_db,
      $_db.tabelTransaksi,
    ).filter((f) => f.dompetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transaksiDompetAsalTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TabelTransaksiTable, List<EntitasTransaksi>>
  _transaksiDompetTujuanTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelTransaksi,
        aliasName: $_aliasNameGenerator(
          db.tabelDompet.id,
          db.tabelTransaksi.dompetTujuanId,
        ),
      );

  $$TabelTransaksiTableProcessedTableManager get transaksiDompetTujuan {
    final manager = $$TabelTransaksiTableTableManager(
      $_db,
      $_db.tabelTransaksi,
    ).filter((f) => f.dompetTujuanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transaksiDompetTujuanTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TabelDompetTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelDompetTable> {
  $$TabelDompetTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warna => $composableBuilder(
    column: $table.warna,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saldoAwalRupiah => $composableBuilder(
    column: $table.saldoAwalRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get urutan => $composableBuilder(
    column: $table.urutan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transaksiDompetAsal(
    Expression<bool> Function($$TabelTransaksiTableFilterComposer f) f,
  ) {
    final $$TabelTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.dompetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableFilterComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transaksiDompetTujuan(
    Expression<bool> Function($$TabelTransaksiTableFilterComposer f) f,
  ) {
    final $$TabelTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.dompetTujuanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableFilterComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TabelDompetTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelDompetTable> {
  $$TabelDompetTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warna => $composableBuilder(
    column: $table.warna,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoAwalRupiah => $composableBuilder(
    column: $table.saldoAwalRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get urutan => $composableBuilder(
    column: $table.urutan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelDompetTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelDompetTable> {
  $$TabelDompetTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get jenis =>
      $composableBuilder(column: $table.jenis, builder: (column) => column);

  GeneratedColumn<String> get ikon =>
      $composableBuilder(column: $table.ikon, builder: (column) => column);

  GeneratedColumn<String> get warna =>
      $composableBuilder(column: $table.warna, builder: (column) => column);

  GeneratedColumn<int> get saldoAwalRupiah => $composableBuilder(
    column: $table.saldoAwalRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get urutan =>
      $composableBuilder(column: $table.urutan, builder: (column) => column);

  GeneratedColumn<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  Expression<T> transaksiDompetAsal<T extends Object>(
    Expression<T> Function($$TabelTransaksiTableAnnotationComposer a) f,
  ) {
    final $$TabelTransaksiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.dompetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transaksiDompetTujuan<T extends Object>(
    Expression<T> Function($$TabelTransaksiTableAnnotationComposer a) f,
  ) {
    final $$TabelTransaksiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.dompetTujuanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TabelDompetTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelDompetTable,
          EntitasDompet,
          $$TabelDompetTableFilterComposer,
          $$TabelDompetTableOrderingComposer,
          $$TabelDompetTableAnnotationComposer,
          $$TabelDompetTableCreateCompanionBuilder,
          $$TabelDompetTableUpdateCompanionBuilder,
          (EntitasDompet, $$TabelDompetTableReferences),
          EntitasDompet,
          PrefetchHooks Function({
            bool transaksiDompetAsal,
            bool transaksiDompetTujuan,
          })
        > {
  $$TabelDompetTableTableManager(_$BasisDataFunda db, $TabelDompetTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelDompetTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelDompetTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelDompetTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> jenis = const Value.absent(),
                Value<String> ikon = const Value.absent(),
                Value<String> warna = const Value.absent(),
                Value<int> saldoAwalRupiah = const Value.absent(),
                Value<int> urutan = const Value.absent(),
                Value<bool> diarsipkan = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelDompetCompanion(
                id: id,
                nama: nama,
                jenis: jenis,
                ikon: ikon,
                warna: warna,
                saldoAwalRupiah: saldoAwalRupiah,
                urutan: urutan,
                diarsipkan: diarsipkan,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String jenis,
                required String ikon,
                required String warna,
                Value<int> saldoAwalRupiah = const Value.absent(),
                Value<int> urutan = const Value.absent(),
                Value<bool> diarsipkan = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelDompetCompanion.insert(
                id: id,
                nama: nama,
                jenis: jenis,
                ikon: ikon,
                warna: warna,
                saldoAwalRupiah: saldoAwalRupiah,
                urutan: urutan,
                diarsipkan: diarsipkan,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelDompetTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transaksiDompetAsal = false, transaksiDompetTujuan = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transaksiDompetAsal) db.tabelTransaksi,
                    if (transaksiDompetTujuan) db.tabelTransaksi,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transaksiDompetAsal)
                        await $_getPrefetchedData<
                          EntitasDompet,
                          $TabelDompetTable,
                          EntitasTransaksi
                        >(
                          currentTable: table,
                          referencedTable: $$TabelDompetTableReferences
                              ._transaksiDompetAsalTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelDompetTableReferences(
                                db,
                                table,
                                p0,
                              ).transaksiDompetAsal,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dompetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transaksiDompetTujuan)
                        await $_getPrefetchedData<
                          EntitasDompet,
                          $TabelDompetTable,
                          EntitasTransaksi
                        >(
                          currentTable: table,
                          referencedTable: $$TabelDompetTableReferences
                              ._transaksiDompetTujuanTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelDompetTableReferences(
                                db,
                                table,
                                p0,
                              ).transaksiDompetTujuan,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dompetTujuanId == item.id,
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

typedef $$TabelDompetTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelDompetTable,
      EntitasDompet,
      $$TabelDompetTableFilterComposer,
      $$TabelDompetTableOrderingComposer,
      $$TabelDompetTableAnnotationComposer,
      $$TabelDompetTableCreateCompanionBuilder,
      $$TabelDompetTableUpdateCompanionBuilder,
      (EntitasDompet, $$TabelDompetTableReferences),
      EntitasDompet,
      PrefetchHooks Function({
        bool transaksiDompetAsal,
        bool transaksiDompetTujuan,
      })
    >;
typedef $$TabelKategoriTableCreateCompanionBuilder =
    TabelKategoriCompanion Function({
      required String id,
      required String nama,
      required String arus,
      required String sifat,
      required String ikon,
      Value<bool> bawaan,
      Value<bool> diarsipkan,
      Value<int> rowid,
    });
typedef $$TabelKategoriTableUpdateCompanionBuilder =
    TabelKategoriCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> arus,
      Value<String> sifat,
      Value<String> ikon,
      Value<bool> bawaan,
      Value<bool> diarsipkan,
      Value<int> rowid,
    });

final class $$TabelKategoriTableReferences
    extends
        BaseReferences<_$BasisDataFunda, $TabelKategoriTable, EntitasKategori> {
  $$TabelKategoriTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TabelTransaksiTable, List<EntitasTransaksi>>
  _tabelTransaksiRefsTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelTransaksi,
        aliasName: $_aliasNameGenerator(
          db.tabelKategori.id,
          db.tabelTransaksi.kategoriId,
        ),
      );

  $$TabelTransaksiTableProcessedTableManager get tabelTransaksiRefs {
    final manager = $$TabelTransaksiTableTableManager(
      $_db,
      $_db.tabelTransaksi,
    ).filter((f) => f.kategoriId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabelTransaksiRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TabelKategoriTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelKategoriTable> {
  $$TabelKategoriTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arus => $composableBuilder(
    column: $table.arus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sifat => $composableBuilder(
    column: $table.sifat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bawaan => $composableBuilder(
    column: $table.bawaan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tabelTransaksiRefs(
    Expression<bool> Function($$TabelTransaksiTableFilterComposer f) f,
  ) {
    final $$TabelTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.kategoriId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableFilterComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TabelKategoriTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelKategoriTable> {
  $$TabelKategoriTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arus => $composableBuilder(
    column: $table.arus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sifat => $composableBuilder(
    column: $table.sifat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bawaan => $composableBuilder(
    column: $table.bawaan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelKategoriTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelKategoriTable> {
  $$TabelKategoriTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get arus =>
      $composableBuilder(column: $table.arus, builder: (column) => column);

  GeneratedColumn<String> get sifat =>
      $composableBuilder(column: $table.sifat, builder: (column) => column);

  GeneratedColumn<String> get ikon =>
      $composableBuilder(column: $table.ikon, builder: (column) => column);

  GeneratedColumn<bool> get bawaan =>
      $composableBuilder(column: $table.bawaan, builder: (column) => column);

  GeneratedColumn<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => column,
  );

  Expression<T> tabelTransaksiRefs<T extends Object>(
    Expression<T> Function($$TabelTransaksiTableAnnotationComposer a) f,
  ) {
    final $$TabelTransaksiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.kategoriId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TabelKategoriTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelKategoriTable,
          EntitasKategori,
          $$TabelKategoriTableFilterComposer,
          $$TabelKategoriTableOrderingComposer,
          $$TabelKategoriTableAnnotationComposer,
          $$TabelKategoriTableCreateCompanionBuilder,
          $$TabelKategoriTableUpdateCompanionBuilder,
          (EntitasKategori, $$TabelKategoriTableReferences),
          EntitasKategori,
          PrefetchHooks Function({bool tabelTransaksiRefs})
        > {
  $$TabelKategoriTableTableManager(
    _$BasisDataFunda db,
    $TabelKategoriTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelKategoriTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelKategoriTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelKategoriTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> arus = const Value.absent(),
                Value<String> sifat = const Value.absent(),
                Value<String> ikon = const Value.absent(),
                Value<bool> bawaan = const Value.absent(),
                Value<bool> diarsipkan = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelKategoriCompanion(
                id: id,
                nama: nama,
                arus: arus,
                sifat: sifat,
                ikon: ikon,
                bawaan: bawaan,
                diarsipkan: diarsipkan,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String arus,
                required String sifat,
                required String ikon,
                Value<bool> bawaan = const Value.absent(),
                Value<bool> diarsipkan = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelKategoriCompanion.insert(
                id: id,
                nama: nama,
                arus: arus,
                sifat: sifat,
                ikon: ikon,
                bawaan: bawaan,
                diarsipkan: diarsipkan,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelKategoriTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tabelTransaksiRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tabelTransaksiRefs) db.tabelTransaksi,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tabelTransaksiRefs)
                    await $_getPrefetchedData<
                      EntitasKategori,
                      $TabelKategoriTable,
                      EntitasTransaksi
                    >(
                      currentTable: table,
                      referencedTable: $$TabelKategoriTableReferences
                          ._tabelTransaksiRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TabelKategoriTableReferences(
                            db,
                            table,
                            p0,
                          ).tabelTransaksiRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.kategoriId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TabelKategoriTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelKategoriTable,
      EntitasKategori,
      $$TabelKategoriTableFilterComposer,
      $$TabelKategoriTableOrderingComposer,
      $$TabelKategoriTableAnnotationComposer,
      $$TabelKategoriTableCreateCompanionBuilder,
      $$TabelKategoriTableUpdateCompanionBuilder,
      (EntitasKategori, $$TabelKategoriTableReferences),
      EntitasKategori,
      PrefetchHooks Function({bool tabelTransaksiRefs})
    >;
typedef $$TabelTransaksiTableCreateCompanionBuilder =
    TabelTransaksiCompanion Function({
      required String id,
      required String jenis,
      required int jumlahRupiah,
      required String dompetId,
      Value<String?> dompetTujuanId,
      Value<String?> kategoriId,
      Value<int> biayaAdminRupiah,
      Value<String?> catatan,
      required DateTime waktuTransaksi,
      Value<DateTime> dibuatPada,
      Value<DateTime> diubahPada,
      Value<int> rowid,
    });
typedef $$TabelTransaksiTableUpdateCompanionBuilder =
    TabelTransaksiCompanion Function({
      Value<String> id,
      Value<String> jenis,
      Value<int> jumlahRupiah,
      Value<String> dompetId,
      Value<String?> dompetTujuanId,
      Value<String?> kategoriId,
      Value<int> biayaAdminRupiah,
      Value<String?> catatan,
      Value<DateTime> waktuTransaksi,
      Value<DateTime> dibuatPada,
      Value<DateTime> diubahPada,
      Value<int> rowid,
    });

final class $$TabelTransaksiTableReferences
    extends
        BaseReferences<
          _$BasisDataFunda,
          $TabelTransaksiTable,
          EntitasTransaksi
        > {
  $$TabelTransaksiTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TabelDompetTable _dompetIdTable(_$BasisDataFunda db) =>
      db.tabelDompet.createAlias(
        $_aliasNameGenerator(db.tabelTransaksi.dompetId, db.tabelDompet.id),
      );

  $$TabelDompetTableProcessedTableManager get dompetId {
    final $_column = $_itemColumn<String>('dompet_id')!;

    final manager = $$TabelDompetTableTableManager(
      $_db,
      $_db.tabelDompet,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dompetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TabelDompetTable _dompetTujuanIdTable(_$BasisDataFunda db) =>
      db.tabelDompet.createAlias(
        $_aliasNameGenerator(
          db.tabelTransaksi.dompetTujuanId,
          db.tabelDompet.id,
        ),
      );

  $$TabelDompetTableProcessedTableManager? get dompetTujuanId {
    final $_column = $_itemColumn<String>('dompet_tujuan_id');
    if ($_column == null) return null;
    final manager = $$TabelDompetTableTableManager(
      $_db,
      $_db.tabelDompet,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dompetTujuanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TabelKategoriTable _kategoriIdTable(_$BasisDataFunda db) =>
      db.tabelKategori.createAlias(
        $_aliasNameGenerator(db.tabelTransaksi.kategoriId, db.tabelKategori.id),
      );

  $$TabelKategoriTableProcessedTableManager? get kategoriId {
    final $_column = $_itemColumn<String>('kategori_id');
    if ($_column == null) return null;
    final manager = $$TabelKategoriTableTableManager(
      $_db,
      $_db.tabelKategori,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_kategoriIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TabelTransaksiTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelTransaksiTable> {
  $$TabelTransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jumlahRupiah => $composableBuilder(
    column: $table.jumlahRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get biayaAdminRupiah => $composableBuilder(
    column: $table.biayaAdminRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get waktuTransaksi => $composableBuilder(
    column: $table.waktuTransaksi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diubahPada => $composableBuilder(
    column: $table.diubahPada,
    builder: (column) => ColumnFilters(column),
  );

  $$TabelDompetTableFilterComposer get dompetId {
    final $$TabelDompetTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetId,
      referencedTable: $db.tabelDompet,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelDompetTableFilterComposer(
            $db: $db,
            $table: $db.tabelDompet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelDompetTableFilterComposer get dompetTujuanId {
    final $$TabelDompetTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetTujuanId,
      referencedTable: $db.tabelDompet,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelDompetTableFilterComposer(
            $db: $db,
            $table: $db.tabelDompet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelKategoriTableFilterComposer get kategoriId {
    final $$TabelKategoriTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.kategoriId,
      referencedTable: $db.tabelKategori,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKategoriTableFilterComposer(
            $db: $db,
            $table: $db.tabelKategori,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelTransaksiTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelTransaksiTable> {
  $$TabelTransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jumlahRupiah => $composableBuilder(
    column: $table.jumlahRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get biayaAdminRupiah => $composableBuilder(
    column: $table.biayaAdminRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get waktuTransaksi => $composableBuilder(
    column: $table.waktuTransaksi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diubahPada => $composableBuilder(
    column: $table.diubahPada,
    builder: (column) => ColumnOrderings(column),
  );

  $$TabelDompetTableOrderingComposer get dompetId {
    final $$TabelDompetTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetId,
      referencedTable: $db.tabelDompet,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelDompetTableOrderingComposer(
            $db: $db,
            $table: $db.tabelDompet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelDompetTableOrderingComposer get dompetTujuanId {
    final $$TabelDompetTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetTujuanId,
      referencedTable: $db.tabelDompet,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelDompetTableOrderingComposer(
            $db: $db,
            $table: $db.tabelDompet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelKategoriTableOrderingComposer get kategoriId {
    final $$TabelKategoriTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.kategoriId,
      referencedTable: $db.tabelKategori,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKategoriTableOrderingComposer(
            $db: $db,
            $table: $db.tabelKategori,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelTransaksiTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelTransaksiTable> {
  $$TabelTransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jenis =>
      $composableBuilder(column: $table.jenis, builder: (column) => column);

  GeneratedColumn<int> get jumlahRupiah => $composableBuilder(
    column: $table.jumlahRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get biayaAdminRupiah => $composableBuilder(
    column: $table.biayaAdminRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<DateTime> get waktuTransaksi => $composableBuilder(
    column: $table.waktuTransaksi,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get diubahPada => $composableBuilder(
    column: $table.diubahPada,
    builder: (column) => column,
  );

  $$TabelDompetTableAnnotationComposer get dompetId {
    final $$TabelDompetTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetId,
      referencedTable: $db.tabelDompet,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelDompetTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelDompet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelDompetTableAnnotationComposer get dompetTujuanId {
    final $$TabelDompetTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetTujuanId,
      referencedTable: $db.tabelDompet,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelDompetTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelDompet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelKategoriTableAnnotationComposer get kategoriId {
    final $$TabelKategoriTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.kategoriId,
      referencedTable: $db.tabelKategori,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKategoriTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelKategori,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelTransaksiTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelTransaksiTable,
          EntitasTransaksi,
          $$TabelTransaksiTableFilterComposer,
          $$TabelTransaksiTableOrderingComposer,
          $$TabelTransaksiTableAnnotationComposer,
          $$TabelTransaksiTableCreateCompanionBuilder,
          $$TabelTransaksiTableUpdateCompanionBuilder,
          (EntitasTransaksi, $$TabelTransaksiTableReferences),
          EntitasTransaksi,
          PrefetchHooks Function({
            bool dompetId,
            bool dompetTujuanId,
            bool kategoriId,
          })
        > {
  $$TabelTransaksiTableTableManager(
    _$BasisDataFunda db,
    $TabelTransaksiTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelTransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelTransaksiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelTransaksiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jenis = const Value.absent(),
                Value<int> jumlahRupiah = const Value.absent(),
                Value<String> dompetId = const Value.absent(),
                Value<String?> dompetTujuanId = const Value.absent(),
                Value<String?> kategoriId = const Value.absent(),
                Value<int> biayaAdminRupiah = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<DateTime> waktuTransaksi = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<DateTime> diubahPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelTransaksiCompanion(
                id: id,
                jenis: jenis,
                jumlahRupiah: jumlahRupiah,
                dompetId: dompetId,
                dompetTujuanId: dompetTujuanId,
                kategoriId: kategoriId,
                biayaAdminRupiah: biayaAdminRupiah,
                catatan: catatan,
                waktuTransaksi: waktuTransaksi,
                dibuatPada: dibuatPada,
                diubahPada: diubahPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jenis,
                required int jumlahRupiah,
                required String dompetId,
                Value<String?> dompetTujuanId = const Value.absent(),
                Value<String?> kategoriId = const Value.absent(),
                Value<int> biayaAdminRupiah = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                required DateTime waktuTransaksi,
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<DateTime> diubahPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelTransaksiCompanion.insert(
                id: id,
                jenis: jenis,
                jumlahRupiah: jumlahRupiah,
                dompetId: dompetId,
                dompetTujuanId: dompetTujuanId,
                kategoriId: kategoriId,
                biayaAdminRupiah: biayaAdminRupiah,
                catatan: catatan,
                waktuTransaksi: waktuTransaksi,
                dibuatPada: dibuatPada,
                diubahPada: diubahPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelTransaksiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({dompetId = false, dompetTujuanId = false, kategoriId = false}) {
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
                        if (dompetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dompetId,
                                    referencedTable:
                                        $$TabelTransaksiTableReferences
                                            ._dompetIdTable(db),
                                    referencedColumn:
                                        $$TabelTransaksiTableReferences
                                            ._dompetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (dompetTujuanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dompetTujuanId,
                                    referencedTable:
                                        $$TabelTransaksiTableReferences
                                            ._dompetTujuanIdTable(db),
                                    referencedColumn:
                                        $$TabelTransaksiTableReferences
                                            ._dompetTujuanIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (kategoriId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.kategoriId,
                                    referencedTable:
                                        $$TabelTransaksiTableReferences
                                            ._kategoriIdTable(db),
                                    referencedColumn:
                                        $$TabelTransaksiTableReferences
                                            ._kategoriIdTable(db)
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

typedef $$TabelTransaksiTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelTransaksiTable,
      EntitasTransaksi,
      $$TabelTransaksiTableFilterComposer,
      $$TabelTransaksiTableOrderingComposer,
      $$TabelTransaksiTableAnnotationComposer,
      $$TabelTransaksiTableCreateCompanionBuilder,
      $$TabelTransaksiTableUpdateCompanionBuilder,
      (EntitasTransaksi, $$TabelTransaksiTableReferences),
      EntitasTransaksi,
      PrefetchHooks Function({
        bool dompetId,
        bool dompetTujuanId,
        bool kategoriId,
      })
    >;

class $BasisDataFundaManager {
  final _$BasisDataFunda _db;
  $BasisDataFundaManager(this._db);
  $$TabelPengaturanTableTableManager get tabelPengaturan =>
      $$TabelPengaturanTableTableManager(_db, _db.tabelPengaturan);
  $$TabelDompetTableTableManager get tabelDompet =>
      $$TabelDompetTableTableManager(_db, _db.tabelDompet);
  $$TabelKategoriTableTableManager get tabelKategori =>
      $$TabelKategoriTableTableManager(_db, _db.tabelKategori);
  $$TabelTransaksiTableTableManager get tabelTransaksi =>
      $$TabelTransaksiTableTableManager(_db, _db.tabelTransaksi);
}
