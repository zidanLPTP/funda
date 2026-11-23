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

class $TabelAnggaranTable extends TabelAnggaran
    with TableInfo<$TabelAnggaranTable, EntitasAnggaran> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelAnggaranTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tahunMeta = const VerificationMeta('tahun');
  @override
  late final GeneratedColumn<int> tahun = GeneratedColumn<int>(
    'tahun',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bulanMeta = const VerificationMeta('bulan');
  @override
  late final GeneratedColumn<int> bulan = GeneratedColumn<int>(
    'bulan',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kategoriIdMeta = const VerificationMeta(
    'kategoriId',
  );
  @override
  late final GeneratedColumn<String> kategoriId = GeneratedColumn<String>(
    'kategori_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_kategori (id)',
    ),
  );
  static const VerificationMeta _batasRupiahMeta = const VerificationMeta(
    'batasRupiah',
  );
  @override
  late final GeneratedColumn<int> batasRupiah = GeneratedColumn<int>(
    'batas_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tahun,
    bulan,
    kategoriId,
    batasRupiah,
    dibuatPada,
    diubahPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_anggaran';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasAnggaran> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tahun')) {
      context.handle(
        _tahunMeta,
        tahun.isAcceptableOrUnknown(data['tahun']!, _tahunMeta),
      );
    } else if (isInserting) {
      context.missing(_tahunMeta);
    }
    if (data.containsKey('bulan')) {
      context.handle(
        _bulanMeta,
        bulan.isAcceptableOrUnknown(data['bulan']!, _bulanMeta),
      );
    } else if (isInserting) {
      context.missing(_bulanMeta);
    }
    if (data.containsKey('kategori_id')) {
      context.handle(
        _kategoriIdMeta,
        kategoriId.isAcceptableOrUnknown(data['kategori_id']!, _kategoriIdMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriIdMeta);
    }
    if (data.containsKey('batas_rupiah')) {
      context.handle(
        _batasRupiahMeta,
        batasRupiah.isAcceptableOrUnknown(
          data['batas_rupiah']!,
          _batasRupiahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batasRupiahMeta);
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    if (data.containsKey('diubah_pada')) {
      context.handle(
        _diubahPadaMeta,
        diubahPada.isAcceptableOrUnknown(data['diubah_pada']!, _diubahPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_diubahPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tahun, bulan, kategoriId},
  ];
  @override
  EntitasAnggaran map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasAnggaran(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tahun: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tahun'],
      )!,
      bulan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bulan'],
      )!,
      kategoriId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori_id'],
      )!,
      batasRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batas_rupiah'],
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
  $TabelAnggaranTable createAlias(String alias) {
    return $TabelAnggaranTable(attachedDatabase, alias);
  }
}

class EntitasAnggaran extends DataClass implements Insertable<EntitasAnggaran> {
  final String id;
  final int tahun;
  final int bulan;
  final String kategoriId;
  final int batasRupiah;
  final DateTime dibuatPada;
  final DateTime diubahPada;
  const EntitasAnggaran({
    required this.id,
    required this.tahun,
    required this.bulan,
    required this.kategoriId,
    required this.batasRupiah,
    required this.dibuatPada,
    required this.diubahPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tahun'] = Variable<int>(tahun);
    map['bulan'] = Variable<int>(bulan);
    map['kategori_id'] = Variable<String>(kategoriId);
    map['batas_rupiah'] = Variable<int>(batasRupiah);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    map['diubah_pada'] = Variable<DateTime>(diubahPada);
    return map;
  }

  TabelAnggaranCompanion toCompanion(bool nullToAbsent) {
    return TabelAnggaranCompanion(
      id: Value(id),
      tahun: Value(tahun),
      bulan: Value(bulan),
      kategoriId: Value(kategoriId),
      batasRupiah: Value(batasRupiah),
      dibuatPada: Value(dibuatPada),
      diubahPada: Value(diubahPada),
    );
  }

  factory EntitasAnggaran.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasAnggaran(
      id: serializer.fromJson<String>(json['id']),
      tahun: serializer.fromJson<int>(json['tahun']),
      bulan: serializer.fromJson<int>(json['bulan']),
      kategoriId: serializer.fromJson<String>(json['kategoriId']),
      batasRupiah: serializer.fromJson<int>(json['batasRupiah']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
      diubahPada: serializer.fromJson<DateTime>(json['diubahPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tahun': serializer.toJson<int>(tahun),
      'bulan': serializer.toJson<int>(bulan),
      'kategoriId': serializer.toJson<String>(kategoriId),
      'batasRupiah': serializer.toJson<int>(batasRupiah),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
      'diubahPada': serializer.toJson<DateTime>(diubahPada),
    };
  }

  EntitasAnggaran copyWith({
    String? id,
    int? tahun,
    int? bulan,
    String? kategoriId,
    int? batasRupiah,
    DateTime? dibuatPada,
    DateTime? diubahPada,
  }) => EntitasAnggaran(
    id: id ?? this.id,
    tahun: tahun ?? this.tahun,
    bulan: bulan ?? this.bulan,
    kategoriId: kategoriId ?? this.kategoriId,
    batasRupiah: batasRupiah ?? this.batasRupiah,
    dibuatPada: dibuatPada ?? this.dibuatPada,
    diubahPada: diubahPada ?? this.diubahPada,
  );
  EntitasAnggaran copyWithCompanion(TabelAnggaranCompanion data) {
    return EntitasAnggaran(
      id: data.id.present ? data.id.value : this.id,
      tahun: data.tahun.present ? data.tahun.value : this.tahun,
      bulan: data.bulan.present ? data.bulan.value : this.bulan,
      kategoriId: data.kategoriId.present
          ? data.kategoriId.value
          : this.kategoriId,
      batasRupiah: data.batasRupiah.present
          ? data.batasRupiah.value
          : this.batasRupiah,
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
    return (StringBuffer('EntitasAnggaran(')
          ..write('id: $id, ')
          ..write('tahun: $tahun, ')
          ..write('bulan: $bulan, ')
          ..write('kategoriId: $kategoriId, ')
          ..write('batasRupiah: $batasRupiah, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('diubahPada: $diubahPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tahun,
    bulan,
    kategoriId,
    batasRupiah,
    dibuatPada,
    diubahPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasAnggaran &&
          other.id == this.id &&
          other.tahun == this.tahun &&
          other.bulan == this.bulan &&
          other.kategoriId == this.kategoriId &&
          other.batasRupiah == this.batasRupiah &&
          other.dibuatPada == this.dibuatPada &&
          other.diubahPada == this.diubahPada);
}

class TabelAnggaranCompanion extends UpdateCompanion<EntitasAnggaran> {
  final Value<String> id;
  final Value<int> tahun;
  final Value<int> bulan;
  final Value<String> kategoriId;
  final Value<int> batasRupiah;
  final Value<DateTime> dibuatPada;
  final Value<DateTime> diubahPada;
  final Value<int> rowid;
  const TabelAnggaranCompanion({
    this.id = const Value.absent(),
    this.tahun = const Value.absent(),
    this.bulan = const Value.absent(),
    this.kategoriId = const Value.absent(),
    this.batasRupiah = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.diubahPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelAnggaranCompanion.insert({
    required String id,
    required int tahun,
    required int bulan,
    required String kategoriId,
    required int batasRupiah,
    required DateTime dibuatPada,
    required DateTime diubahPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tahun = Value(tahun),
       bulan = Value(bulan),
       kategoriId = Value(kategoriId),
       batasRupiah = Value(batasRupiah),
       dibuatPada = Value(dibuatPada),
       diubahPada = Value(diubahPada);
  static Insertable<EntitasAnggaran> custom({
    Expression<String>? id,
    Expression<int>? tahun,
    Expression<int>? bulan,
    Expression<String>? kategoriId,
    Expression<int>? batasRupiah,
    Expression<DateTime>? dibuatPada,
    Expression<DateTime>? diubahPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tahun != null) 'tahun': tahun,
      if (bulan != null) 'bulan': bulan,
      if (kategoriId != null) 'kategori_id': kategoriId,
      if (batasRupiah != null) 'batas_rupiah': batasRupiah,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (diubahPada != null) 'diubah_pada': diubahPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelAnggaranCompanion copyWith({
    Value<String>? id,
    Value<int>? tahun,
    Value<int>? bulan,
    Value<String>? kategoriId,
    Value<int>? batasRupiah,
    Value<DateTime>? dibuatPada,
    Value<DateTime>? diubahPada,
    Value<int>? rowid,
  }) {
    return TabelAnggaranCompanion(
      id: id ?? this.id,
      tahun: tahun ?? this.tahun,
      bulan: bulan ?? this.bulan,
      kategoriId: kategoriId ?? this.kategoriId,
      batasRupiah: batasRupiah ?? this.batasRupiah,
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
    if (tahun.present) {
      map['tahun'] = Variable<int>(tahun.value);
    }
    if (bulan.present) {
      map['bulan'] = Variable<int>(bulan.value);
    }
    if (kategoriId.present) {
      map['kategori_id'] = Variable<String>(kategoriId.value);
    }
    if (batasRupiah.present) {
      map['batas_rupiah'] = Variable<int>(batasRupiah.value);
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
    return (StringBuffer('TabelAnggaranCompanion(')
          ..write('id: $id, ')
          ..write('tahun: $tahun, ')
          ..write('bulan: $bulan, ')
          ..write('kategoriId: $kategoriId, ')
          ..write('batasRupiah: $batasRupiah, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('diubahPada: $diubahPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelTujuanTable extends TabelTujuan
    with TableInfo<$TabelTujuanTable, EntitasTujuan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelTujuanTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetRupiahMeta = const VerificationMeta(
    'targetRupiah',
  );
  @override
  late final GeneratedColumn<int> targetRupiah = GeneratedColumn<int>(
    'target_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenggatMeta = const VerificationMeta(
    'tenggat',
  );
  @override
  late final GeneratedColumn<DateTime> tenggat = GeneratedColumn<DateTime>(
    'tenggat',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    jenis,
    targetRupiah,
    tenggat,
    ikon,
    warna,
    status,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_tujuan';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasTujuan> instance, {
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
    if (data.containsKey('target_rupiah')) {
      context.handle(
        _targetRupiahMeta,
        targetRupiah.isAcceptableOrUnknown(
          data['target_rupiah']!,
          _targetRupiahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetRupiahMeta);
    }
    if (data.containsKey('tenggat')) {
      context.handle(
        _tenggatMeta,
        tenggat.isAcceptableOrUnknown(data['tenggat']!, _tenggatMeta),
      );
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasTujuan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasTujuan(
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
      targetRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_rupiah'],
      )!,
      tenggat: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tenggat'],
      ),
      ikon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ikon'],
      )!,
      warna: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warna'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
    );
  }

  @override
  $TabelTujuanTable createAlias(String alias) {
    return $TabelTujuanTable(attachedDatabase, alias);
  }
}

class EntitasTujuan extends DataClass implements Insertable<EntitasTujuan> {
  final String id;
  final String nama;
  final String jenis;
  final int targetRupiah;
  final DateTime? tenggat;
  final String ikon;
  final String warna;
  final String status;
  final DateTime dibuatPada;
  const EntitasTujuan({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.targetRupiah,
    this.tenggat,
    required this.ikon,
    required this.warna,
    required this.status,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['jenis'] = Variable<String>(jenis);
    map['target_rupiah'] = Variable<int>(targetRupiah);
    if (!nullToAbsent || tenggat != null) {
      map['tenggat'] = Variable<DateTime>(tenggat);
    }
    map['ikon'] = Variable<String>(ikon);
    map['warna'] = Variable<String>(warna);
    map['status'] = Variable<String>(status);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelTujuanCompanion toCompanion(bool nullToAbsent) {
    return TabelTujuanCompanion(
      id: Value(id),
      nama: Value(nama),
      jenis: Value(jenis),
      targetRupiah: Value(targetRupiah),
      tenggat: tenggat == null && nullToAbsent
          ? const Value.absent()
          : Value(tenggat),
      ikon: Value(ikon),
      warna: Value(warna),
      status: Value(status),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasTujuan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasTujuan(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      jenis: serializer.fromJson<String>(json['jenis']),
      targetRupiah: serializer.fromJson<int>(json['targetRupiah']),
      tenggat: serializer.fromJson<DateTime?>(json['tenggat']),
      ikon: serializer.fromJson<String>(json['ikon']),
      warna: serializer.fromJson<String>(json['warna']),
      status: serializer.fromJson<String>(json['status']),
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
      'targetRupiah': serializer.toJson<int>(targetRupiah),
      'tenggat': serializer.toJson<DateTime?>(tenggat),
      'ikon': serializer.toJson<String>(ikon),
      'warna': serializer.toJson<String>(warna),
      'status': serializer.toJson<String>(status),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasTujuan copyWith({
    String? id,
    String? nama,
    String? jenis,
    int? targetRupiah,
    Value<DateTime?> tenggat = const Value.absent(),
    String? ikon,
    String? warna,
    String? status,
    DateTime? dibuatPada,
  }) => EntitasTujuan(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    jenis: jenis ?? this.jenis,
    targetRupiah: targetRupiah ?? this.targetRupiah,
    tenggat: tenggat.present ? tenggat.value : this.tenggat,
    ikon: ikon ?? this.ikon,
    warna: warna ?? this.warna,
    status: status ?? this.status,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasTujuan copyWithCompanion(TabelTujuanCompanion data) {
    return EntitasTujuan(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      targetRupiah: data.targetRupiah.present
          ? data.targetRupiah.value
          : this.targetRupiah,
      tenggat: data.tenggat.present ? data.tenggat.value : this.tenggat,
      ikon: data.ikon.present ? data.ikon.value : this.ikon,
      warna: data.warna.present ? data.warna.value : this.warna,
      status: data.status.present ? data.status.value : this.status,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasTujuan(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('targetRupiah: $targetRupiah, ')
          ..write('tenggat: $tenggat, ')
          ..write('ikon: $ikon, ')
          ..write('warna: $warna, ')
          ..write('status: $status, ')
          ..write('dibuatPada: $dibuatPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nama,
    jenis,
    targetRupiah,
    tenggat,
    ikon,
    warna,
    status,
    dibuatPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasTujuan &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.jenis == this.jenis &&
          other.targetRupiah == this.targetRupiah &&
          other.tenggat == this.tenggat &&
          other.ikon == this.ikon &&
          other.warna == this.warna &&
          other.status == this.status &&
          other.dibuatPada == this.dibuatPada);
}

class TabelTujuanCompanion extends UpdateCompanion<EntitasTujuan> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> jenis;
  final Value<int> targetRupiah;
  final Value<DateTime?> tenggat;
  final Value<String> ikon;
  final Value<String> warna;
  final Value<String> status;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelTujuanCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.jenis = const Value.absent(),
    this.targetRupiah = const Value.absent(),
    this.tenggat = const Value.absent(),
    this.ikon = const Value.absent(),
    this.warna = const Value.absent(),
    this.status = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelTujuanCompanion.insert({
    required String id,
    required String nama,
    required String jenis,
    required int targetRupiah,
    this.tenggat = const Value.absent(),
    required String ikon,
    required String warna,
    required String status,
    required DateTime dibuatPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       jenis = Value(jenis),
       targetRupiah = Value(targetRupiah),
       ikon = Value(ikon),
       warna = Value(warna),
       status = Value(status),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasTujuan> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? jenis,
    Expression<int>? targetRupiah,
    Expression<DateTime>? tenggat,
    Expression<String>? ikon,
    Expression<String>? warna,
    Expression<String>? status,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (jenis != null) 'jenis': jenis,
      if (targetRupiah != null) 'target_rupiah': targetRupiah,
      if (tenggat != null) 'tenggat': tenggat,
      if (ikon != null) 'ikon': ikon,
      if (warna != null) 'warna': warna,
      if (status != null) 'status': status,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelTujuanCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? jenis,
    Value<int>? targetRupiah,
    Value<DateTime?>? tenggat,
    Value<String>? ikon,
    Value<String>? warna,
    Value<String>? status,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelTujuanCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      targetRupiah: targetRupiah ?? this.targetRupiah,
      tenggat: tenggat ?? this.tenggat,
      ikon: ikon ?? this.ikon,
      warna: warna ?? this.warna,
      status: status ?? this.status,
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
    if (targetRupiah.present) {
      map['target_rupiah'] = Variable<int>(targetRupiah.value);
    }
    if (tenggat.present) {
      map['tenggat'] = Variable<DateTime>(tenggat.value);
    }
    if (ikon.present) {
      map['ikon'] = Variable<String>(ikon.value);
    }
    if (warna.present) {
      map['warna'] = Variable<String>(warna.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('TabelTujuanCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('targetRupiah: $targetRupiah, ')
          ..write('tenggat: $tenggat, ')
          ..write('ikon: $ikon, ')
          ..write('warna: $warna, ')
          ..write('status: $status, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelKantongTable extends TabelKantong
    with TableInfo<$TabelKantongTable, EntitasKantong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelKantongTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _tujuanIdMeta = const VerificationMeta(
    'tujuanId',
  );
  @override
  late final GeneratedColumn<String> tujuanId = GeneratedColumn<String>(
    'tujuan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_tujuan (id)',
    ),
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dompetId,
    tujuanId,
    nama,
    ikon,
    warna,
    diarsipkan,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_kantong';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasKantong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dompet_id')) {
      context.handle(
        _dompetIdMeta,
        dompetId.isAcceptableOrUnknown(data['dompet_id']!, _dompetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dompetIdMeta);
    }
    if (data.containsKey('tujuan_id')) {
      context.handle(
        _tujuanIdMeta,
        tujuanId.isAcceptableOrUnknown(data['tujuan_id']!, _tujuanIdMeta),
      );
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
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
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasKantong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasKantong(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dompetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dompet_id'],
      )!,
      tujuanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tujuan_id'],
      ),
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      ikon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ikon'],
      )!,
      warna: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warna'],
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
  $TabelKantongTable createAlias(String alias) {
    return $TabelKantongTable(attachedDatabase, alias);
  }
}

class EntitasKantong extends DataClass implements Insertable<EntitasKantong> {
  final String id;
  final String dompetId;
  final String? tujuanId;
  final String nama;
  final String ikon;
  final String warna;
  final bool diarsipkan;
  final DateTime dibuatPada;
  const EntitasKantong({
    required this.id,
    required this.dompetId,
    this.tujuanId,
    required this.nama,
    required this.ikon,
    required this.warna,
    required this.diarsipkan,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dompet_id'] = Variable<String>(dompetId);
    if (!nullToAbsent || tujuanId != null) {
      map['tujuan_id'] = Variable<String>(tujuanId);
    }
    map['nama'] = Variable<String>(nama);
    map['ikon'] = Variable<String>(ikon);
    map['warna'] = Variable<String>(warna);
    map['diarsipkan'] = Variable<bool>(diarsipkan);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelKantongCompanion toCompanion(bool nullToAbsent) {
    return TabelKantongCompanion(
      id: Value(id),
      dompetId: Value(dompetId),
      tujuanId: tujuanId == null && nullToAbsent
          ? const Value.absent()
          : Value(tujuanId),
      nama: Value(nama),
      ikon: Value(ikon),
      warna: Value(warna),
      diarsipkan: Value(diarsipkan),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasKantong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasKantong(
      id: serializer.fromJson<String>(json['id']),
      dompetId: serializer.fromJson<String>(json['dompetId']),
      tujuanId: serializer.fromJson<String?>(json['tujuanId']),
      nama: serializer.fromJson<String>(json['nama']),
      ikon: serializer.fromJson<String>(json['ikon']),
      warna: serializer.fromJson<String>(json['warna']),
      diarsipkan: serializer.fromJson<bool>(json['diarsipkan']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dompetId': serializer.toJson<String>(dompetId),
      'tujuanId': serializer.toJson<String?>(tujuanId),
      'nama': serializer.toJson<String>(nama),
      'ikon': serializer.toJson<String>(ikon),
      'warna': serializer.toJson<String>(warna),
      'diarsipkan': serializer.toJson<bool>(diarsipkan),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasKantong copyWith({
    String? id,
    String? dompetId,
    Value<String?> tujuanId = const Value.absent(),
    String? nama,
    String? ikon,
    String? warna,
    bool? diarsipkan,
    DateTime? dibuatPada,
  }) => EntitasKantong(
    id: id ?? this.id,
    dompetId: dompetId ?? this.dompetId,
    tujuanId: tujuanId.present ? tujuanId.value : this.tujuanId,
    nama: nama ?? this.nama,
    ikon: ikon ?? this.ikon,
    warna: warna ?? this.warna,
    diarsipkan: diarsipkan ?? this.diarsipkan,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasKantong copyWithCompanion(TabelKantongCompanion data) {
    return EntitasKantong(
      id: data.id.present ? data.id.value : this.id,
      dompetId: data.dompetId.present ? data.dompetId.value : this.dompetId,
      tujuanId: data.tujuanId.present ? data.tujuanId.value : this.tujuanId,
      nama: data.nama.present ? data.nama.value : this.nama,
      ikon: data.ikon.present ? data.ikon.value : this.ikon,
      warna: data.warna.present ? data.warna.value : this.warna,
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
    return (StringBuffer('EntitasKantong(')
          ..write('id: $id, ')
          ..write('dompetId: $dompetId, ')
          ..write('tujuanId: $tujuanId, ')
          ..write('nama: $nama, ')
          ..write('ikon: $ikon, ')
          ..write('warna: $warna, ')
          ..write('diarsipkan: $diarsipkan, ')
          ..write('dibuatPada: $dibuatPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dompetId,
    tujuanId,
    nama,
    ikon,
    warna,
    diarsipkan,
    dibuatPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasKantong &&
          other.id == this.id &&
          other.dompetId == this.dompetId &&
          other.tujuanId == this.tujuanId &&
          other.nama == this.nama &&
          other.ikon == this.ikon &&
          other.warna == this.warna &&
          other.diarsipkan == this.diarsipkan &&
          other.dibuatPada == this.dibuatPada);
}

class TabelKantongCompanion extends UpdateCompanion<EntitasKantong> {
  final Value<String> id;
  final Value<String> dompetId;
  final Value<String?> tujuanId;
  final Value<String> nama;
  final Value<String> ikon;
  final Value<String> warna;
  final Value<bool> diarsipkan;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelKantongCompanion({
    this.id = const Value.absent(),
    this.dompetId = const Value.absent(),
    this.tujuanId = const Value.absent(),
    this.nama = const Value.absent(),
    this.ikon = const Value.absent(),
    this.warna = const Value.absent(),
    this.diarsipkan = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelKantongCompanion.insert({
    required String id,
    required String dompetId,
    this.tujuanId = const Value.absent(),
    required String nama,
    required String ikon,
    required String warna,
    this.diarsipkan = const Value.absent(),
    required DateTime dibuatPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dompetId = Value(dompetId),
       nama = Value(nama),
       ikon = Value(ikon),
       warna = Value(warna),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasKantong> custom({
    Expression<String>? id,
    Expression<String>? dompetId,
    Expression<String>? tujuanId,
    Expression<String>? nama,
    Expression<String>? ikon,
    Expression<String>? warna,
    Expression<bool>? diarsipkan,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dompetId != null) 'dompet_id': dompetId,
      if (tujuanId != null) 'tujuan_id': tujuanId,
      if (nama != null) 'nama': nama,
      if (ikon != null) 'ikon': ikon,
      if (warna != null) 'warna': warna,
      if (diarsipkan != null) 'diarsipkan': diarsipkan,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelKantongCompanion copyWith({
    Value<String>? id,
    Value<String>? dompetId,
    Value<String?>? tujuanId,
    Value<String>? nama,
    Value<String>? ikon,
    Value<String>? warna,
    Value<bool>? diarsipkan,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelKantongCompanion(
      id: id ?? this.id,
      dompetId: dompetId ?? this.dompetId,
      tujuanId: tujuanId ?? this.tujuanId,
      nama: nama ?? this.nama,
      ikon: ikon ?? this.ikon,
      warna: warna ?? this.warna,
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
    if (dompetId.present) {
      map['dompet_id'] = Variable<String>(dompetId.value);
    }
    if (tujuanId.present) {
      map['tujuan_id'] = Variable<String>(tujuanId.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (ikon.present) {
      map['ikon'] = Variable<String>(ikon.value);
    }
    if (warna.present) {
      map['warna'] = Variable<String>(warna.value);
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
    return (StringBuffer('TabelKantongCompanion(')
          ..write('id: $id, ')
          ..write('dompetId: $dompetId, ')
          ..write('tujuanId: $tujuanId, ')
          ..write('nama: $nama, ')
          ..write('ikon: $ikon, ')
          ..write('warna: $warna, ')
          ..write('diarsipkan: $diarsipkan, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelAlokasiKantongTable extends TabelAlokasiKantong
    with TableInfo<$TabelAlokasiKantongTable, EntitasAlokasiKantong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelAlokasiKantongTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kantongIdMeta = const VerificationMeta(
    'kantongId',
  );
  @override
  late final GeneratedColumn<String> kantongId = GeneratedColumn<String>(
    'kantong_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_kantong (id)',
    ),
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
  static const VerificationMeta _waktuMeta = const VerificationMeta('waktu');
  @override
  late final GeneratedColumn<DateTime> waktu = GeneratedColumn<DateTime>(
    'waktu',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kantongId,
    jenis,
    jumlahRupiah,
    catatan,
    waktu,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_alokasi_kantong';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasAlokasiKantong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kantong_id')) {
      context.handle(
        _kantongIdMeta,
        kantongId.isAcceptableOrUnknown(data['kantong_id']!, _kantongIdMeta),
      );
    } else if (isInserting) {
      context.missing(_kantongIdMeta);
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
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('waktu')) {
      context.handle(
        _waktuMeta,
        waktu.isAcceptableOrUnknown(data['waktu']!, _waktuMeta),
      );
    } else if (isInserting) {
      context.missing(_waktuMeta);
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasAlokasiKantong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasAlokasiKantong(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kantongId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kantong_id'],
      )!,
      jenis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis'],
      )!,
      jumlahRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jumlah_rupiah'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      waktu: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}waktu'],
      )!,
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
    );
  }

  @override
  $TabelAlokasiKantongTable createAlias(String alias) {
    return $TabelAlokasiKantongTable(attachedDatabase, alias);
  }
}

class EntitasAlokasiKantong extends DataClass
    implements Insertable<EntitasAlokasiKantong> {
  final String id;
  final String kantongId;
  final String jenis;
  final int jumlahRupiah;
  final String? catatan;
  final DateTime waktu;
  final DateTime dibuatPada;
  const EntitasAlokasiKantong({
    required this.id,
    required this.kantongId,
    required this.jenis,
    required this.jumlahRupiah,
    this.catatan,
    required this.waktu,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kantong_id'] = Variable<String>(kantongId);
    map['jenis'] = Variable<String>(jenis);
    map['jumlah_rupiah'] = Variable<int>(jumlahRupiah);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    map['waktu'] = Variable<DateTime>(waktu);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelAlokasiKantongCompanion toCompanion(bool nullToAbsent) {
    return TabelAlokasiKantongCompanion(
      id: Value(id),
      kantongId: Value(kantongId),
      jenis: Value(jenis),
      jumlahRupiah: Value(jumlahRupiah),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      waktu: Value(waktu),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasAlokasiKantong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasAlokasiKantong(
      id: serializer.fromJson<String>(json['id']),
      kantongId: serializer.fromJson<String>(json['kantongId']),
      jenis: serializer.fromJson<String>(json['jenis']),
      jumlahRupiah: serializer.fromJson<int>(json['jumlahRupiah']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      waktu: serializer.fromJson<DateTime>(json['waktu']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kantongId': serializer.toJson<String>(kantongId),
      'jenis': serializer.toJson<String>(jenis),
      'jumlahRupiah': serializer.toJson<int>(jumlahRupiah),
      'catatan': serializer.toJson<String?>(catatan),
      'waktu': serializer.toJson<DateTime>(waktu),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasAlokasiKantong copyWith({
    String? id,
    String? kantongId,
    String? jenis,
    int? jumlahRupiah,
    Value<String?> catatan = const Value.absent(),
    DateTime? waktu,
    DateTime? dibuatPada,
  }) => EntitasAlokasiKantong(
    id: id ?? this.id,
    kantongId: kantongId ?? this.kantongId,
    jenis: jenis ?? this.jenis,
    jumlahRupiah: jumlahRupiah ?? this.jumlahRupiah,
    catatan: catatan.present ? catatan.value : this.catatan,
    waktu: waktu ?? this.waktu,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasAlokasiKantong copyWithCompanion(TabelAlokasiKantongCompanion data) {
    return EntitasAlokasiKantong(
      id: data.id.present ? data.id.value : this.id,
      kantongId: data.kantongId.present ? data.kantongId.value : this.kantongId,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      jumlahRupiah: data.jumlahRupiah.present
          ? data.jumlahRupiah.value
          : this.jumlahRupiah,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      waktu: data.waktu.present ? data.waktu.value : this.waktu,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasAlokasiKantong(')
          ..write('id: $id, ')
          ..write('kantongId: $kantongId, ')
          ..write('jenis: $jenis, ')
          ..write('jumlahRupiah: $jumlahRupiah, ')
          ..write('catatan: $catatan, ')
          ..write('waktu: $waktu, ')
          ..write('dibuatPada: $dibuatPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kantongId,
    jenis,
    jumlahRupiah,
    catatan,
    waktu,
    dibuatPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasAlokasiKantong &&
          other.id == this.id &&
          other.kantongId == this.kantongId &&
          other.jenis == this.jenis &&
          other.jumlahRupiah == this.jumlahRupiah &&
          other.catatan == this.catatan &&
          other.waktu == this.waktu &&
          other.dibuatPada == this.dibuatPada);
}

class TabelAlokasiKantongCompanion
    extends UpdateCompanion<EntitasAlokasiKantong> {
  final Value<String> id;
  final Value<String> kantongId;
  final Value<String> jenis;
  final Value<int> jumlahRupiah;
  final Value<String?> catatan;
  final Value<DateTime> waktu;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelAlokasiKantongCompanion({
    this.id = const Value.absent(),
    this.kantongId = const Value.absent(),
    this.jenis = const Value.absent(),
    this.jumlahRupiah = const Value.absent(),
    this.catatan = const Value.absent(),
    this.waktu = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelAlokasiKantongCompanion.insert({
    required String id,
    required String kantongId,
    required String jenis,
    required int jumlahRupiah,
    this.catatan = const Value.absent(),
    required DateTime waktu,
    required DateTime dibuatPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kantongId = Value(kantongId),
       jenis = Value(jenis),
       jumlahRupiah = Value(jumlahRupiah),
       waktu = Value(waktu),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasAlokasiKantong> custom({
    Expression<String>? id,
    Expression<String>? kantongId,
    Expression<String>? jenis,
    Expression<int>? jumlahRupiah,
    Expression<String>? catatan,
    Expression<DateTime>? waktu,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kantongId != null) 'kantong_id': kantongId,
      if (jenis != null) 'jenis': jenis,
      if (jumlahRupiah != null) 'jumlah_rupiah': jumlahRupiah,
      if (catatan != null) 'catatan': catatan,
      if (waktu != null) 'waktu': waktu,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelAlokasiKantongCompanion copyWith({
    Value<String>? id,
    Value<String>? kantongId,
    Value<String>? jenis,
    Value<int>? jumlahRupiah,
    Value<String?>? catatan,
    Value<DateTime>? waktu,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelAlokasiKantongCompanion(
      id: id ?? this.id,
      kantongId: kantongId ?? this.kantongId,
      jenis: jenis ?? this.jenis,
      jumlahRupiah: jumlahRupiah ?? this.jumlahRupiah,
      catatan: catatan ?? this.catatan,
      waktu: waktu ?? this.waktu,
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
    if (kantongId.present) {
      map['kantong_id'] = Variable<String>(kantongId.value);
    }
    if (jenis.present) {
      map['jenis'] = Variable<String>(jenis.value);
    }
    if (jumlahRupiah.present) {
      map['jumlah_rupiah'] = Variable<int>(jumlahRupiah.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (waktu.present) {
      map['waktu'] = Variable<DateTime>(waktu.value);
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
    return (StringBuffer('TabelAlokasiKantongCompanion(')
          ..write('id: $id, ')
          ..write('kantongId: $kantongId, ')
          ..write('jenis: $jenis, ')
          ..write('jumlahRupiah: $jumlahRupiah, ')
          ..write('catatan: $catatan, ')
          ..write('waktu: $waktu, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelUtangTable extends TabelUtang
    with TableInfo<$TabelUtangTable, EntitasUtang> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelUtangTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pemberiMeta = const VerificationMeta(
    'pemberi',
  );
  @override
  late final GeneratedColumn<String> pemberi = GeneratedColumn<String>(
    'pemberi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sisaAwalRupiahMeta = const VerificationMeta(
    'sisaAwalRupiah',
  );
  @override
  late final GeneratedColumn<int> sisaAwalRupiah = GeneratedColumn<int>(
    'sisa_awal_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pokokAwalRupiahMeta = const VerificationMeta(
    'pokokAwalRupiah',
  );
  @override
  late final GeneratedColumn<int> pokokAwalRupiah = GeneratedColumn<int>(
    'pokok_awal_rupiah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jenisBungaMeta = const VerificationMeta(
    'jenisBunga',
  );
  @override
  late final GeneratedColumn<String> jenisBunga = GeneratedColumn<String>(
    'jenis_bunga',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bungaBasisPoinPerTahunMeta =
      const VerificationMeta('bungaBasisPoinPerTahun');
  @override
  late final GeneratedColumn<int> bungaBasisPoinPerTahun = GeneratedColumn<int>(
    'bunga_basis_poin_per_tahun',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tenorBulanMeta = const VerificationMeta(
    'tenorBulan',
  );
  @override
  late final GeneratedColumn<int> tenorBulan = GeneratedColumn<int>(
    'tenor_bulan',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cicilanBulananRupiahMeta =
      const VerificationMeta('cicilanBulananRupiah');
  @override
  late final GeneratedColumn<int> cicilanBulananRupiah = GeneratedColumn<int>(
    'cicilan_bulanan_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tanggalJatuhTempoBulananMeta =
      const VerificationMeta('tanggalJatuhTempoBulanan');
  @override
  late final GeneratedColumn<int> tanggalJatuhTempoBulanan =
      GeneratedColumn<int>(
        'tanggal_jatuh_tempo_bulanan',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tanggalMulaiMeta = const VerificationMeta(
    'tanggalMulai',
  );
  @override
  late final GeneratedColumn<DateTime> tanggalMulai = GeneratedColumn<DateTime>(
    'tanggal_mulai',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('aktif'),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    jenis,
    pemberi,
    sisaAwalRupiah,
    pokokAwalRupiah,
    jenisBunga,
    bungaBasisPoinPerTahun,
    tenorBulan,
    cicilanBulananRupiah,
    tanggalJatuhTempoBulanan,
    tanggalMulai,
    status,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_utang';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasUtang> instance, {
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
    if (data.containsKey('pemberi')) {
      context.handle(
        _pemberiMeta,
        pemberi.isAcceptableOrUnknown(data['pemberi']!, _pemberiMeta),
      );
    }
    if (data.containsKey('sisa_awal_rupiah')) {
      context.handle(
        _sisaAwalRupiahMeta,
        sisaAwalRupiah.isAcceptableOrUnknown(
          data['sisa_awal_rupiah']!,
          _sisaAwalRupiahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sisaAwalRupiahMeta);
    }
    if (data.containsKey('pokok_awal_rupiah')) {
      context.handle(
        _pokokAwalRupiahMeta,
        pokokAwalRupiah.isAcceptableOrUnknown(
          data['pokok_awal_rupiah']!,
          _pokokAwalRupiahMeta,
        ),
      );
    }
    if (data.containsKey('jenis_bunga')) {
      context.handle(
        _jenisBungaMeta,
        jenisBunga.isAcceptableOrUnknown(data['jenis_bunga']!, _jenisBungaMeta),
      );
    } else if (isInserting) {
      context.missing(_jenisBungaMeta);
    }
    if (data.containsKey('bunga_basis_poin_per_tahun')) {
      context.handle(
        _bungaBasisPoinPerTahunMeta,
        bungaBasisPoinPerTahun.isAcceptableOrUnknown(
          data['bunga_basis_poin_per_tahun']!,
          _bungaBasisPoinPerTahunMeta,
        ),
      );
    }
    if (data.containsKey('tenor_bulan')) {
      context.handle(
        _tenorBulanMeta,
        tenorBulan.isAcceptableOrUnknown(data['tenor_bulan']!, _tenorBulanMeta),
      );
    }
    if (data.containsKey('cicilan_bulanan_rupiah')) {
      context.handle(
        _cicilanBulananRupiahMeta,
        cicilanBulananRupiah.isAcceptableOrUnknown(
          data['cicilan_bulanan_rupiah']!,
          _cicilanBulananRupiahMeta,
        ),
      );
    }
    if (data.containsKey('tanggal_jatuh_tempo_bulanan')) {
      context.handle(
        _tanggalJatuhTempoBulananMeta,
        tanggalJatuhTempoBulanan.isAcceptableOrUnknown(
          data['tanggal_jatuh_tempo_bulanan']!,
          _tanggalJatuhTempoBulananMeta,
        ),
      );
    }
    if (data.containsKey('tanggal_mulai')) {
      context.handle(
        _tanggalMulaiMeta,
        tanggalMulai.isAcceptableOrUnknown(
          data['tanggal_mulai']!,
          _tanggalMulaiMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasUtang map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasUtang(
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
      pemberi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pemberi'],
      ),
      sisaAwalRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sisa_awal_rupiah'],
      )!,
      pokokAwalRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokok_awal_rupiah'],
      ),
      jenisBunga: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis_bunga'],
      )!,
      bungaBasisPoinPerTahun: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bunga_basis_poin_per_tahun'],
      )!,
      tenorBulan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tenor_bulan'],
      ),
      cicilanBulananRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cicilan_bulanan_rupiah'],
      )!,
      tanggalJatuhTempoBulanan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tanggal_jatuh_tempo_bulanan'],
      ),
      tanggalMulai: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal_mulai'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
    );
  }

  @override
  $TabelUtangTable createAlias(String alias) {
    return $TabelUtangTable(attachedDatabase, alias);
  }
}

class EntitasUtang extends DataClass implements Insertable<EntitasUtang> {
  final String id;
  final String nama;
  final String jenis;
  final String? pemberi;
  final int sisaAwalRupiah;
  final int? pokokAwalRupiah;
  final String jenisBunga;
  final int bungaBasisPoinPerTahun;
  final int? tenorBulan;
  final int cicilanBulananRupiah;
  final int? tanggalJatuhTempoBulanan;
  final DateTime? tanggalMulai;
  final String status;
  final DateTime dibuatPada;
  const EntitasUtang({
    required this.id,
    required this.nama,
    required this.jenis,
    this.pemberi,
    required this.sisaAwalRupiah,
    this.pokokAwalRupiah,
    required this.jenisBunga,
    required this.bungaBasisPoinPerTahun,
    this.tenorBulan,
    required this.cicilanBulananRupiah,
    this.tanggalJatuhTempoBulanan,
    this.tanggalMulai,
    required this.status,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['jenis'] = Variable<String>(jenis);
    if (!nullToAbsent || pemberi != null) {
      map['pemberi'] = Variable<String>(pemberi);
    }
    map['sisa_awal_rupiah'] = Variable<int>(sisaAwalRupiah);
    if (!nullToAbsent || pokokAwalRupiah != null) {
      map['pokok_awal_rupiah'] = Variable<int>(pokokAwalRupiah);
    }
    map['jenis_bunga'] = Variable<String>(jenisBunga);
    map['bunga_basis_poin_per_tahun'] = Variable<int>(bungaBasisPoinPerTahun);
    if (!nullToAbsent || tenorBulan != null) {
      map['tenor_bulan'] = Variable<int>(tenorBulan);
    }
    map['cicilan_bulanan_rupiah'] = Variable<int>(cicilanBulananRupiah);
    if (!nullToAbsent || tanggalJatuhTempoBulanan != null) {
      map['tanggal_jatuh_tempo_bulanan'] = Variable<int>(
        tanggalJatuhTempoBulanan,
      );
    }
    if (!nullToAbsent || tanggalMulai != null) {
      map['tanggal_mulai'] = Variable<DateTime>(tanggalMulai);
    }
    map['status'] = Variable<String>(status);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelUtangCompanion toCompanion(bool nullToAbsent) {
    return TabelUtangCompanion(
      id: Value(id),
      nama: Value(nama),
      jenis: Value(jenis),
      pemberi: pemberi == null && nullToAbsent
          ? const Value.absent()
          : Value(pemberi),
      sisaAwalRupiah: Value(sisaAwalRupiah),
      pokokAwalRupiah: pokokAwalRupiah == null && nullToAbsent
          ? const Value.absent()
          : Value(pokokAwalRupiah),
      jenisBunga: Value(jenisBunga),
      bungaBasisPoinPerTahun: Value(bungaBasisPoinPerTahun),
      tenorBulan: tenorBulan == null && nullToAbsent
          ? const Value.absent()
          : Value(tenorBulan),
      cicilanBulananRupiah: Value(cicilanBulananRupiah),
      tanggalJatuhTempoBulanan: tanggalJatuhTempoBulanan == null && nullToAbsent
          ? const Value.absent()
          : Value(tanggalJatuhTempoBulanan),
      tanggalMulai: tanggalMulai == null && nullToAbsent
          ? const Value.absent()
          : Value(tanggalMulai),
      status: Value(status),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasUtang.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasUtang(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      jenis: serializer.fromJson<String>(json['jenis']),
      pemberi: serializer.fromJson<String?>(json['pemberi']),
      sisaAwalRupiah: serializer.fromJson<int>(json['sisaAwalRupiah']),
      pokokAwalRupiah: serializer.fromJson<int?>(json['pokokAwalRupiah']),
      jenisBunga: serializer.fromJson<String>(json['jenisBunga']),
      bungaBasisPoinPerTahun: serializer.fromJson<int>(
        json['bungaBasisPoinPerTahun'],
      ),
      tenorBulan: serializer.fromJson<int?>(json['tenorBulan']),
      cicilanBulananRupiah: serializer.fromJson<int>(
        json['cicilanBulananRupiah'],
      ),
      tanggalJatuhTempoBulanan: serializer.fromJson<int?>(
        json['tanggalJatuhTempoBulanan'],
      ),
      tanggalMulai: serializer.fromJson<DateTime?>(json['tanggalMulai']),
      status: serializer.fromJson<String>(json['status']),
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
      'pemberi': serializer.toJson<String?>(pemberi),
      'sisaAwalRupiah': serializer.toJson<int>(sisaAwalRupiah),
      'pokokAwalRupiah': serializer.toJson<int?>(pokokAwalRupiah),
      'jenisBunga': serializer.toJson<String>(jenisBunga),
      'bungaBasisPoinPerTahun': serializer.toJson<int>(bungaBasisPoinPerTahun),
      'tenorBulan': serializer.toJson<int?>(tenorBulan),
      'cicilanBulananRupiah': serializer.toJson<int>(cicilanBulananRupiah),
      'tanggalJatuhTempoBulanan': serializer.toJson<int?>(
        tanggalJatuhTempoBulanan,
      ),
      'tanggalMulai': serializer.toJson<DateTime?>(tanggalMulai),
      'status': serializer.toJson<String>(status),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasUtang copyWith({
    String? id,
    String? nama,
    String? jenis,
    Value<String?> pemberi = const Value.absent(),
    int? sisaAwalRupiah,
    Value<int?> pokokAwalRupiah = const Value.absent(),
    String? jenisBunga,
    int? bungaBasisPoinPerTahun,
    Value<int?> tenorBulan = const Value.absent(),
    int? cicilanBulananRupiah,
    Value<int?> tanggalJatuhTempoBulanan = const Value.absent(),
    Value<DateTime?> tanggalMulai = const Value.absent(),
    String? status,
    DateTime? dibuatPada,
  }) => EntitasUtang(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    jenis: jenis ?? this.jenis,
    pemberi: pemberi.present ? pemberi.value : this.pemberi,
    sisaAwalRupiah: sisaAwalRupiah ?? this.sisaAwalRupiah,
    pokokAwalRupiah: pokokAwalRupiah.present
        ? pokokAwalRupiah.value
        : this.pokokAwalRupiah,
    jenisBunga: jenisBunga ?? this.jenisBunga,
    bungaBasisPoinPerTahun:
        bungaBasisPoinPerTahun ?? this.bungaBasisPoinPerTahun,
    tenorBulan: tenorBulan.present ? tenorBulan.value : this.tenorBulan,
    cicilanBulananRupiah: cicilanBulananRupiah ?? this.cicilanBulananRupiah,
    tanggalJatuhTempoBulanan: tanggalJatuhTempoBulanan.present
        ? tanggalJatuhTempoBulanan.value
        : this.tanggalJatuhTempoBulanan,
    tanggalMulai: tanggalMulai.present ? tanggalMulai.value : this.tanggalMulai,
    status: status ?? this.status,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasUtang copyWithCompanion(TabelUtangCompanion data) {
    return EntitasUtang(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      pemberi: data.pemberi.present ? data.pemberi.value : this.pemberi,
      sisaAwalRupiah: data.sisaAwalRupiah.present
          ? data.sisaAwalRupiah.value
          : this.sisaAwalRupiah,
      pokokAwalRupiah: data.pokokAwalRupiah.present
          ? data.pokokAwalRupiah.value
          : this.pokokAwalRupiah,
      jenisBunga: data.jenisBunga.present
          ? data.jenisBunga.value
          : this.jenisBunga,
      bungaBasisPoinPerTahun: data.bungaBasisPoinPerTahun.present
          ? data.bungaBasisPoinPerTahun.value
          : this.bungaBasisPoinPerTahun,
      tenorBulan: data.tenorBulan.present
          ? data.tenorBulan.value
          : this.tenorBulan,
      cicilanBulananRupiah: data.cicilanBulananRupiah.present
          ? data.cicilanBulananRupiah.value
          : this.cicilanBulananRupiah,
      tanggalJatuhTempoBulanan: data.tanggalJatuhTempoBulanan.present
          ? data.tanggalJatuhTempoBulanan.value
          : this.tanggalJatuhTempoBulanan,
      tanggalMulai: data.tanggalMulai.present
          ? data.tanggalMulai.value
          : this.tanggalMulai,
      status: data.status.present ? data.status.value : this.status,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasUtang(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('pemberi: $pemberi, ')
          ..write('sisaAwalRupiah: $sisaAwalRupiah, ')
          ..write('pokokAwalRupiah: $pokokAwalRupiah, ')
          ..write('jenisBunga: $jenisBunga, ')
          ..write('bungaBasisPoinPerTahun: $bungaBasisPoinPerTahun, ')
          ..write('tenorBulan: $tenorBulan, ')
          ..write('cicilanBulananRupiah: $cicilanBulananRupiah, ')
          ..write('tanggalJatuhTempoBulanan: $tanggalJatuhTempoBulanan, ')
          ..write('tanggalMulai: $tanggalMulai, ')
          ..write('status: $status, ')
          ..write('dibuatPada: $dibuatPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nama,
    jenis,
    pemberi,
    sisaAwalRupiah,
    pokokAwalRupiah,
    jenisBunga,
    bungaBasisPoinPerTahun,
    tenorBulan,
    cicilanBulananRupiah,
    tanggalJatuhTempoBulanan,
    tanggalMulai,
    status,
    dibuatPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasUtang &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.jenis == this.jenis &&
          other.pemberi == this.pemberi &&
          other.sisaAwalRupiah == this.sisaAwalRupiah &&
          other.pokokAwalRupiah == this.pokokAwalRupiah &&
          other.jenisBunga == this.jenisBunga &&
          other.bungaBasisPoinPerTahun == this.bungaBasisPoinPerTahun &&
          other.tenorBulan == this.tenorBulan &&
          other.cicilanBulananRupiah == this.cicilanBulananRupiah &&
          other.tanggalJatuhTempoBulanan == this.tanggalJatuhTempoBulanan &&
          other.tanggalMulai == this.tanggalMulai &&
          other.status == this.status &&
          other.dibuatPada == this.dibuatPada);
}

class TabelUtangCompanion extends UpdateCompanion<EntitasUtang> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> jenis;
  final Value<String?> pemberi;
  final Value<int> sisaAwalRupiah;
  final Value<int?> pokokAwalRupiah;
  final Value<String> jenisBunga;
  final Value<int> bungaBasisPoinPerTahun;
  final Value<int?> tenorBulan;
  final Value<int> cicilanBulananRupiah;
  final Value<int?> tanggalJatuhTempoBulanan;
  final Value<DateTime?> tanggalMulai;
  final Value<String> status;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelUtangCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.jenis = const Value.absent(),
    this.pemberi = const Value.absent(),
    this.sisaAwalRupiah = const Value.absent(),
    this.pokokAwalRupiah = const Value.absent(),
    this.jenisBunga = const Value.absent(),
    this.bungaBasisPoinPerTahun = const Value.absent(),
    this.tenorBulan = const Value.absent(),
    this.cicilanBulananRupiah = const Value.absent(),
    this.tanggalJatuhTempoBulanan = const Value.absent(),
    this.tanggalMulai = const Value.absent(),
    this.status = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelUtangCompanion.insert({
    required String id,
    required String nama,
    required String jenis,
    this.pemberi = const Value.absent(),
    required int sisaAwalRupiah,
    this.pokokAwalRupiah = const Value.absent(),
    required String jenisBunga,
    this.bungaBasisPoinPerTahun = const Value.absent(),
    this.tenorBulan = const Value.absent(),
    this.cicilanBulananRupiah = const Value.absent(),
    this.tanggalJatuhTempoBulanan = const Value.absent(),
    this.tanggalMulai = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime dibuatPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       jenis = Value(jenis),
       sisaAwalRupiah = Value(sisaAwalRupiah),
       jenisBunga = Value(jenisBunga),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasUtang> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? jenis,
    Expression<String>? pemberi,
    Expression<int>? sisaAwalRupiah,
    Expression<int>? pokokAwalRupiah,
    Expression<String>? jenisBunga,
    Expression<int>? bungaBasisPoinPerTahun,
    Expression<int>? tenorBulan,
    Expression<int>? cicilanBulananRupiah,
    Expression<int>? tanggalJatuhTempoBulanan,
    Expression<DateTime>? tanggalMulai,
    Expression<String>? status,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (jenis != null) 'jenis': jenis,
      if (pemberi != null) 'pemberi': pemberi,
      if (sisaAwalRupiah != null) 'sisa_awal_rupiah': sisaAwalRupiah,
      if (pokokAwalRupiah != null) 'pokok_awal_rupiah': pokokAwalRupiah,
      if (jenisBunga != null) 'jenis_bunga': jenisBunga,
      if (bungaBasisPoinPerTahun != null)
        'bunga_basis_poin_per_tahun': bungaBasisPoinPerTahun,
      if (tenorBulan != null) 'tenor_bulan': tenorBulan,
      if (cicilanBulananRupiah != null)
        'cicilan_bulanan_rupiah': cicilanBulananRupiah,
      if (tanggalJatuhTempoBulanan != null)
        'tanggal_jatuh_tempo_bulanan': tanggalJatuhTempoBulanan,
      if (tanggalMulai != null) 'tanggal_mulai': tanggalMulai,
      if (status != null) 'status': status,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelUtangCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? jenis,
    Value<String?>? pemberi,
    Value<int>? sisaAwalRupiah,
    Value<int?>? pokokAwalRupiah,
    Value<String>? jenisBunga,
    Value<int>? bungaBasisPoinPerTahun,
    Value<int?>? tenorBulan,
    Value<int>? cicilanBulananRupiah,
    Value<int?>? tanggalJatuhTempoBulanan,
    Value<DateTime?>? tanggalMulai,
    Value<String>? status,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelUtangCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      pemberi: pemberi ?? this.pemberi,
      sisaAwalRupiah: sisaAwalRupiah ?? this.sisaAwalRupiah,
      pokokAwalRupiah: pokokAwalRupiah ?? this.pokokAwalRupiah,
      jenisBunga: jenisBunga ?? this.jenisBunga,
      bungaBasisPoinPerTahun:
          bungaBasisPoinPerTahun ?? this.bungaBasisPoinPerTahun,
      tenorBulan: tenorBulan ?? this.tenorBulan,
      cicilanBulananRupiah: cicilanBulananRupiah ?? this.cicilanBulananRupiah,
      tanggalJatuhTempoBulanan:
          tanggalJatuhTempoBulanan ?? this.tanggalJatuhTempoBulanan,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      status: status ?? this.status,
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
    if (pemberi.present) {
      map['pemberi'] = Variable<String>(pemberi.value);
    }
    if (sisaAwalRupiah.present) {
      map['sisa_awal_rupiah'] = Variable<int>(sisaAwalRupiah.value);
    }
    if (pokokAwalRupiah.present) {
      map['pokok_awal_rupiah'] = Variable<int>(pokokAwalRupiah.value);
    }
    if (jenisBunga.present) {
      map['jenis_bunga'] = Variable<String>(jenisBunga.value);
    }
    if (bungaBasisPoinPerTahun.present) {
      map['bunga_basis_poin_per_tahun'] = Variable<int>(
        bungaBasisPoinPerTahun.value,
      );
    }
    if (tenorBulan.present) {
      map['tenor_bulan'] = Variable<int>(tenorBulan.value);
    }
    if (cicilanBulananRupiah.present) {
      map['cicilan_bulanan_rupiah'] = Variable<int>(cicilanBulananRupiah.value);
    }
    if (tanggalJatuhTempoBulanan.present) {
      map['tanggal_jatuh_tempo_bulanan'] = Variable<int>(
        tanggalJatuhTempoBulanan.value,
      );
    }
    if (tanggalMulai.present) {
      map['tanggal_mulai'] = Variable<DateTime>(tanggalMulai.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('TabelUtangCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('pemberi: $pemberi, ')
          ..write('sisaAwalRupiah: $sisaAwalRupiah, ')
          ..write('pokokAwalRupiah: $pokokAwalRupiah, ')
          ..write('jenisBunga: $jenisBunga, ')
          ..write('bungaBasisPoinPerTahun: $bungaBasisPoinPerTahun, ')
          ..write('tenorBulan: $tenorBulan, ')
          ..write('cicilanBulananRupiah: $cicilanBulananRupiah, ')
          ..write('tanggalJatuhTempoBulanan: $tanggalJatuhTempoBulanan, ')
          ..write('tanggalMulai: $tanggalMulai, ')
          ..write('status: $status, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelPembayaranUtangTable extends TabelPembayaranUtang
    with TableInfo<$TabelPembayaranUtangTable, EntitasPembayaranUtang> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelPembayaranUtangTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utangIdMeta = const VerificationMeta(
    'utangId',
  );
  @override
  late final GeneratedColumn<String> utangId = GeneratedColumn<String>(
    'utang_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_utang (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _transaksiIdMeta = const VerificationMeta(
    'transaksiId',
  );
  @override
  late final GeneratedColumn<String> transaksiId = GeneratedColumn<String>(
    'transaksi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES tabel_transaksi (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, utangId, transaksiId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_pembayaran_utang';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasPembayaranUtang> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('utang_id')) {
      context.handle(
        _utangIdMeta,
        utangId.isAcceptableOrUnknown(data['utang_id']!, _utangIdMeta),
      );
    } else if (isInserting) {
      context.missing(_utangIdMeta);
    }
    if (data.containsKey('transaksi_id')) {
      context.handle(
        _transaksiIdMeta,
        transaksiId.isAcceptableOrUnknown(
          data['transaksi_id']!,
          _transaksiIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transaksiIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasPembayaranUtang map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasPembayaranUtang(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      utangId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utang_id'],
      )!,
      transaksiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaksi_id'],
      )!,
    );
  }

  @override
  $TabelPembayaranUtangTable createAlias(String alias) {
    return $TabelPembayaranUtangTable(attachedDatabase, alias);
  }
}

class EntitasPembayaranUtang extends DataClass
    implements Insertable<EntitasPembayaranUtang> {
  final String id;
  final String utangId;
  final String transaksiId;
  const EntitasPembayaranUtang({
    required this.id,
    required this.utangId,
    required this.transaksiId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['utang_id'] = Variable<String>(utangId);
    map['transaksi_id'] = Variable<String>(transaksiId);
    return map;
  }

  TabelPembayaranUtangCompanion toCompanion(bool nullToAbsent) {
    return TabelPembayaranUtangCompanion(
      id: Value(id),
      utangId: Value(utangId),
      transaksiId: Value(transaksiId),
    );
  }

  factory EntitasPembayaranUtang.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasPembayaranUtang(
      id: serializer.fromJson<String>(json['id']),
      utangId: serializer.fromJson<String>(json['utangId']),
      transaksiId: serializer.fromJson<String>(json['transaksiId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'utangId': serializer.toJson<String>(utangId),
      'transaksiId': serializer.toJson<String>(transaksiId),
    };
  }

  EntitasPembayaranUtang copyWith({
    String? id,
    String? utangId,
    String? transaksiId,
  }) => EntitasPembayaranUtang(
    id: id ?? this.id,
    utangId: utangId ?? this.utangId,
    transaksiId: transaksiId ?? this.transaksiId,
  );
  EntitasPembayaranUtang copyWithCompanion(TabelPembayaranUtangCompanion data) {
    return EntitasPembayaranUtang(
      id: data.id.present ? data.id.value : this.id,
      utangId: data.utangId.present ? data.utangId.value : this.utangId,
      transaksiId: data.transaksiId.present
          ? data.transaksiId.value
          : this.transaksiId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasPembayaranUtang(')
          ..write('id: $id, ')
          ..write('utangId: $utangId, ')
          ..write('transaksiId: $transaksiId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, utangId, transaksiId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasPembayaranUtang &&
          other.id == this.id &&
          other.utangId == this.utangId &&
          other.transaksiId == this.transaksiId);
}

class TabelPembayaranUtangCompanion
    extends UpdateCompanion<EntitasPembayaranUtang> {
  final Value<String> id;
  final Value<String> utangId;
  final Value<String> transaksiId;
  final Value<int> rowid;
  const TabelPembayaranUtangCompanion({
    this.id = const Value.absent(),
    this.utangId = const Value.absent(),
    this.transaksiId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelPembayaranUtangCompanion.insert({
    required String id,
    required String utangId,
    required String transaksiId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       utangId = Value(utangId),
       transaksiId = Value(transaksiId);
  static Insertable<EntitasPembayaranUtang> custom({
    Expression<String>? id,
    Expression<String>? utangId,
    Expression<String>? transaksiId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (utangId != null) 'utang_id': utangId,
      if (transaksiId != null) 'transaksi_id': transaksiId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelPembayaranUtangCompanion copyWith({
    Value<String>? id,
    Value<String>? utangId,
    Value<String>? transaksiId,
    Value<int>? rowid,
  }) {
    return TabelPembayaranUtangCompanion(
      id: id ?? this.id,
      utangId: utangId ?? this.utangId,
      transaksiId: transaksiId ?? this.transaksiId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (utangId.present) {
      map['utang_id'] = Variable<String>(utangId.value);
    }
    if (transaksiId.present) {
      map['transaksi_id'] = Variable<String>(transaksiId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelPembayaranUtangCompanion(')
          ..write('id: $id, ')
          ..write('utangId: $utangId, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelPenyesuaianUtangTable extends TabelPenyesuaianUtang
    with TableInfo<$TabelPenyesuaianUtangTable, EntitasPenyesuaianUtang> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelPenyesuaianUtangTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utangIdMeta = const VerificationMeta(
    'utangId',
  );
  @override
  late final GeneratedColumn<String> utangId = GeneratedColumn<String>(
    'utang_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_utang (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _arahMeta = const VerificationMeta('arah');
  @override
  late final GeneratedColumn<String> arah = GeneratedColumn<String>(
    'arah',
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
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    utangId,
    arah,
    jumlahRupiah,
    catatan,
    tanggal,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_penyesuaian_utang';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasPenyesuaianUtang> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('utang_id')) {
      context.handle(
        _utangIdMeta,
        utangId.isAcceptableOrUnknown(data['utang_id']!, _utangIdMeta),
      );
    } else if (isInserting) {
      context.missing(_utangIdMeta);
    }
    if (data.containsKey('arah')) {
      context.handle(
        _arahMeta,
        arah.isAcceptableOrUnknown(data['arah']!, _arahMeta),
      );
    } else if (isInserting) {
      context.missing(_arahMeta);
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
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasPenyesuaianUtang map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasPenyesuaianUtang(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      utangId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utang_id'],
      )!,
      arah: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arah'],
      )!,
      jumlahRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jumlah_rupiah'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
    );
  }

  @override
  $TabelPenyesuaianUtangTable createAlias(String alias) {
    return $TabelPenyesuaianUtangTable(attachedDatabase, alias);
  }
}

class EntitasPenyesuaianUtang extends DataClass
    implements Insertable<EntitasPenyesuaianUtang> {
  final String id;
  final String utangId;
  final String arah;
  final int jumlahRupiah;
  final String? catatan;
  final DateTime tanggal;
  final DateTime dibuatPada;
  const EntitasPenyesuaianUtang({
    required this.id,
    required this.utangId,
    required this.arah,
    required this.jumlahRupiah,
    this.catatan,
    required this.tanggal,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['utang_id'] = Variable<String>(utangId);
    map['arah'] = Variable<String>(arah);
    map['jumlah_rupiah'] = Variable<int>(jumlahRupiah);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    map['tanggal'] = Variable<DateTime>(tanggal);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelPenyesuaianUtangCompanion toCompanion(bool nullToAbsent) {
    return TabelPenyesuaianUtangCompanion(
      id: Value(id),
      utangId: Value(utangId),
      arah: Value(arah),
      jumlahRupiah: Value(jumlahRupiah),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      tanggal: Value(tanggal),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasPenyesuaianUtang.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasPenyesuaianUtang(
      id: serializer.fromJson<String>(json['id']),
      utangId: serializer.fromJson<String>(json['utangId']),
      arah: serializer.fromJson<String>(json['arah']),
      jumlahRupiah: serializer.fromJson<int>(json['jumlahRupiah']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'utangId': serializer.toJson<String>(utangId),
      'arah': serializer.toJson<String>(arah),
      'jumlahRupiah': serializer.toJson<int>(jumlahRupiah),
      'catatan': serializer.toJson<String?>(catatan),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasPenyesuaianUtang copyWith({
    String? id,
    String? utangId,
    String? arah,
    int? jumlahRupiah,
    Value<String?> catatan = const Value.absent(),
    DateTime? tanggal,
    DateTime? dibuatPada,
  }) => EntitasPenyesuaianUtang(
    id: id ?? this.id,
    utangId: utangId ?? this.utangId,
    arah: arah ?? this.arah,
    jumlahRupiah: jumlahRupiah ?? this.jumlahRupiah,
    catatan: catatan.present ? catatan.value : this.catatan,
    tanggal: tanggal ?? this.tanggal,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasPenyesuaianUtang copyWithCompanion(
    TabelPenyesuaianUtangCompanion data,
  ) {
    return EntitasPenyesuaianUtang(
      id: data.id.present ? data.id.value : this.id,
      utangId: data.utangId.present ? data.utangId.value : this.utangId,
      arah: data.arah.present ? data.arah.value : this.arah,
      jumlahRupiah: data.jumlahRupiah.present
          ? data.jumlahRupiah.value
          : this.jumlahRupiah,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasPenyesuaianUtang(')
          ..write('id: $id, ')
          ..write('utangId: $utangId, ')
          ..write('arah: $arah, ')
          ..write('jumlahRupiah: $jumlahRupiah, ')
          ..write('catatan: $catatan, ')
          ..write('tanggal: $tanggal, ')
          ..write('dibuatPada: $dibuatPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    utangId,
    arah,
    jumlahRupiah,
    catatan,
    tanggal,
    dibuatPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasPenyesuaianUtang &&
          other.id == this.id &&
          other.utangId == this.utangId &&
          other.arah == this.arah &&
          other.jumlahRupiah == this.jumlahRupiah &&
          other.catatan == this.catatan &&
          other.tanggal == this.tanggal &&
          other.dibuatPada == this.dibuatPada);
}

class TabelPenyesuaianUtangCompanion
    extends UpdateCompanion<EntitasPenyesuaianUtang> {
  final Value<String> id;
  final Value<String> utangId;
  final Value<String> arah;
  final Value<int> jumlahRupiah;
  final Value<String?> catatan;
  final Value<DateTime> tanggal;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelPenyesuaianUtangCompanion({
    this.id = const Value.absent(),
    this.utangId = const Value.absent(),
    this.arah = const Value.absent(),
    this.jumlahRupiah = const Value.absent(),
    this.catatan = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelPenyesuaianUtangCompanion.insert({
    required String id,
    required String utangId,
    required String arah,
    required int jumlahRupiah,
    this.catatan = const Value.absent(),
    required DateTime tanggal,
    required DateTime dibuatPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       utangId = Value(utangId),
       arah = Value(arah),
       jumlahRupiah = Value(jumlahRupiah),
       tanggal = Value(tanggal),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasPenyesuaianUtang> custom({
    Expression<String>? id,
    Expression<String>? utangId,
    Expression<String>? arah,
    Expression<int>? jumlahRupiah,
    Expression<String>? catatan,
    Expression<DateTime>? tanggal,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (utangId != null) 'utang_id': utangId,
      if (arah != null) 'arah': arah,
      if (jumlahRupiah != null) 'jumlah_rupiah': jumlahRupiah,
      if (catatan != null) 'catatan': catatan,
      if (tanggal != null) 'tanggal': tanggal,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelPenyesuaianUtangCompanion copyWith({
    Value<String>? id,
    Value<String>? utangId,
    Value<String>? arah,
    Value<int>? jumlahRupiah,
    Value<String?>? catatan,
    Value<DateTime>? tanggal,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelPenyesuaianUtangCompanion(
      id: id ?? this.id,
      utangId: utangId ?? this.utangId,
      arah: arah ?? this.arah,
      jumlahRupiah: jumlahRupiah ?? this.jumlahRupiah,
      catatan: catatan ?? this.catatan,
      tanggal: tanggal ?? this.tanggal,
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
    if (utangId.present) {
      map['utang_id'] = Variable<String>(utangId.value);
    }
    if (arah.present) {
      map['arah'] = Variable<String>(arah.value);
    }
    if (jumlahRupiah.present) {
      map['jumlah_rupiah'] = Variable<int>(jumlahRupiah.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
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
    return (StringBuffer('TabelPenyesuaianUtangCompanion(')
          ..write('id: $id, ')
          ..write('utangId: $utangId, ')
          ..write('arah: $arah, ')
          ..write('jumlahRupiah: $jumlahRupiah, ')
          ..write('catatan: $catatan, ')
          ..write('tanggal: $tanggal, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelTagihanTable extends TabelTagihan
    with TableInfo<$TabelTagihanTable, EntitasTagihan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelTagihanTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _jumlahPerkiraanRupiahMeta =
      const VerificationMeta('jumlahPerkiraanRupiah');
  @override
  late final GeneratedColumn<int> jumlahPerkiraanRupiah = GeneratedColumn<int>(
    'jumlah_perkiraan_rupiah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kategoriIdMeta = const VerificationMeta(
    'kategoriId',
  );
  @override
  late final GeneratedColumn<String> kategoriId = GeneratedColumn<String>(
    'kategori_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_kategori (id)',
    ),
  );
  static const VerificationMeta _dompetIdMeta = const VerificationMeta(
    'dompetId',
  );
  @override
  late final GeneratedColumn<String> dompetId = GeneratedColumn<String>(
    'dompet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_dompet (id)',
    ),
  );
  static const VerificationMeta _frekuensiMeta = const VerificationMeta(
    'frekuensi',
  );
  @override
  late final GeneratedColumn<String> frekuensi = GeneratedColumn<String>(
    'frekuensi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jatuhTempoPertamaMeta = const VerificationMeta(
    'jatuhTempoPertama',
  );
  @override
  late final GeneratedColumn<DateTime> jatuhTempoPertama =
      GeneratedColumn<DateTime>(
        'jatuh_tempo_pertama',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _berakhirPadaMeta = const VerificationMeta(
    'berakhirPada',
  );
  @override
  late final GeneratedColumn<DateTime> berakhirPada = GeneratedColumn<DateTime>(
    'berakhir_pada',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pengingatHariSebelumMeta =
      const VerificationMeta('pengingatHariSebelum');
  @override
  late final GeneratedColumn<String> pengingatHariSebelum =
      GeneratedColumn<String>(
        'pengingat_hari_sebelum',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    jenis,
    jumlahPerkiraanRupiah,
    kategoriId,
    dompetId,
    frekuensi,
    jatuhTempoPertama,
    berakhirPada,
    pengingatHariSebelum,
    aktif,
    diarsipkan,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_tagihan';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasTagihan> instance, {
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
    if (data.containsKey('jumlah_perkiraan_rupiah')) {
      context.handle(
        _jumlahPerkiraanRupiahMeta,
        jumlahPerkiraanRupiah.isAcceptableOrUnknown(
          data['jumlah_perkiraan_rupiah']!,
          _jumlahPerkiraanRupiahMeta,
        ),
      );
    }
    if (data.containsKey('kategori_id')) {
      context.handle(
        _kategoriIdMeta,
        kategoriId.isAcceptableOrUnknown(data['kategori_id']!, _kategoriIdMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriIdMeta);
    }
    if (data.containsKey('dompet_id')) {
      context.handle(
        _dompetIdMeta,
        dompetId.isAcceptableOrUnknown(data['dompet_id']!, _dompetIdMeta),
      );
    }
    if (data.containsKey('frekuensi')) {
      context.handle(
        _frekuensiMeta,
        frekuensi.isAcceptableOrUnknown(data['frekuensi']!, _frekuensiMeta),
      );
    } else if (isInserting) {
      context.missing(_frekuensiMeta);
    }
    if (data.containsKey('jatuh_tempo_pertama')) {
      context.handle(
        _jatuhTempoPertamaMeta,
        jatuhTempoPertama.isAcceptableOrUnknown(
          data['jatuh_tempo_pertama']!,
          _jatuhTempoPertamaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jatuhTempoPertamaMeta);
    }
    if (data.containsKey('berakhir_pada')) {
      context.handle(
        _berakhirPadaMeta,
        berakhirPada.isAcceptableOrUnknown(
          data['berakhir_pada']!,
          _berakhirPadaMeta,
        ),
      );
    }
    if (data.containsKey('pengingat_hari_sebelum')) {
      context.handle(
        _pengingatHariSebelumMeta,
        pengingatHariSebelum.isAcceptableOrUnknown(
          data['pengingat_hari_sebelum']!,
          _pengingatHariSebelumMeta,
        ),
      );
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
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
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasTagihan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasTagihan(
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
      jumlahPerkiraanRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jumlah_perkiraan_rupiah'],
      ),
      kategoriId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori_id'],
      )!,
      dompetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dompet_id'],
      ),
      frekuensi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frekuensi'],
      )!,
      jatuhTempoPertama: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}jatuh_tempo_pertama'],
      )!,
      berakhirPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}berakhir_pada'],
      ),
      pengingatHariSebelum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pengingat_hari_sebelum'],
      )!,
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
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
  $TabelTagihanTable createAlias(String alias) {
    return $TabelTagihanTable(attachedDatabase, alias);
  }
}

class EntitasTagihan extends DataClass implements Insertable<EntitasTagihan> {
  final String id;
  final String nama;
  final String jenis;
  final int? jumlahPerkiraanRupiah;
  final String kategoriId;
  final String? dompetId;
  final String frekuensi;
  final DateTime jatuhTempoPertama;
  final DateTime? berakhirPada;
  final String pengingatHariSebelum;
  final bool aktif;
  final bool diarsipkan;
  final DateTime dibuatPada;
  const EntitasTagihan({
    required this.id,
    required this.nama,
    required this.jenis,
    this.jumlahPerkiraanRupiah,
    required this.kategoriId,
    this.dompetId,
    required this.frekuensi,
    required this.jatuhTempoPertama,
    this.berakhirPada,
    required this.pengingatHariSebelum,
    required this.aktif,
    required this.diarsipkan,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['jenis'] = Variable<String>(jenis);
    if (!nullToAbsent || jumlahPerkiraanRupiah != null) {
      map['jumlah_perkiraan_rupiah'] = Variable<int>(jumlahPerkiraanRupiah);
    }
    map['kategori_id'] = Variable<String>(kategoriId);
    if (!nullToAbsent || dompetId != null) {
      map['dompet_id'] = Variable<String>(dompetId);
    }
    map['frekuensi'] = Variable<String>(frekuensi);
    map['jatuh_tempo_pertama'] = Variable<DateTime>(jatuhTempoPertama);
    if (!nullToAbsent || berakhirPada != null) {
      map['berakhir_pada'] = Variable<DateTime>(berakhirPada);
    }
    map['pengingat_hari_sebelum'] = Variable<String>(pengingatHariSebelum);
    map['aktif'] = Variable<bool>(aktif);
    map['diarsipkan'] = Variable<bool>(diarsipkan);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelTagihanCompanion toCompanion(bool nullToAbsent) {
    return TabelTagihanCompanion(
      id: Value(id),
      nama: Value(nama),
      jenis: Value(jenis),
      jumlahPerkiraanRupiah: jumlahPerkiraanRupiah == null && nullToAbsent
          ? const Value.absent()
          : Value(jumlahPerkiraanRupiah),
      kategoriId: Value(kategoriId),
      dompetId: dompetId == null && nullToAbsent
          ? const Value.absent()
          : Value(dompetId),
      frekuensi: Value(frekuensi),
      jatuhTempoPertama: Value(jatuhTempoPertama),
      berakhirPada: berakhirPada == null && nullToAbsent
          ? const Value.absent()
          : Value(berakhirPada),
      pengingatHariSebelum: Value(pengingatHariSebelum),
      aktif: Value(aktif),
      diarsipkan: Value(diarsipkan),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasTagihan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasTagihan(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      jenis: serializer.fromJson<String>(json['jenis']),
      jumlahPerkiraanRupiah: serializer.fromJson<int?>(
        json['jumlahPerkiraanRupiah'],
      ),
      kategoriId: serializer.fromJson<String>(json['kategoriId']),
      dompetId: serializer.fromJson<String?>(json['dompetId']),
      frekuensi: serializer.fromJson<String>(json['frekuensi']),
      jatuhTempoPertama: serializer.fromJson<DateTime>(
        json['jatuhTempoPertama'],
      ),
      berakhirPada: serializer.fromJson<DateTime?>(json['berakhirPada']),
      pengingatHariSebelum: serializer.fromJson<String>(
        json['pengingatHariSebelum'],
      ),
      aktif: serializer.fromJson<bool>(json['aktif']),
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
      'jumlahPerkiraanRupiah': serializer.toJson<int?>(jumlahPerkiraanRupiah),
      'kategoriId': serializer.toJson<String>(kategoriId),
      'dompetId': serializer.toJson<String?>(dompetId),
      'frekuensi': serializer.toJson<String>(frekuensi),
      'jatuhTempoPertama': serializer.toJson<DateTime>(jatuhTempoPertama),
      'berakhirPada': serializer.toJson<DateTime?>(berakhirPada),
      'pengingatHariSebelum': serializer.toJson<String>(pengingatHariSebelum),
      'aktif': serializer.toJson<bool>(aktif),
      'diarsipkan': serializer.toJson<bool>(diarsipkan),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasTagihan copyWith({
    String? id,
    String? nama,
    String? jenis,
    Value<int?> jumlahPerkiraanRupiah = const Value.absent(),
    String? kategoriId,
    Value<String?> dompetId = const Value.absent(),
    String? frekuensi,
    DateTime? jatuhTempoPertama,
    Value<DateTime?> berakhirPada = const Value.absent(),
    String? pengingatHariSebelum,
    bool? aktif,
    bool? diarsipkan,
    DateTime? dibuatPada,
  }) => EntitasTagihan(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    jenis: jenis ?? this.jenis,
    jumlahPerkiraanRupiah: jumlahPerkiraanRupiah.present
        ? jumlahPerkiraanRupiah.value
        : this.jumlahPerkiraanRupiah,
    kategoriId: kategoriId ?? this.kategoriId,
    dompetId: dompetId.present ? dompetId.value : this.dompetId,
    frekuensi: frekuensi ?? this.frekuensi,
    jatuhTempoPertama: jatuhTempoPertama ?? this.jatuhTempoPertama,
    berakhirPada: berakhirPada.present ? berakhirPada.value : this.berakhirPada,
    pengingatHariSebelum: pengingatHariSebelum ?? this.pengingatHariSebelum,
    aktif: aktif ?? this.aktif,
    diarsipkan: diarsipkan ?? this.diarsipkan,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasTagihan copyWithCompanion(TabelTagihanCompanion data) {
    return EntitasTagihan(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      jumlahPerkiraanRupiah: data.jumlahPerkiraanRupiah.present
          ? data.jumlahPerkiraanRupiah.value
          : this.jumlahPerkiraanRupiah,
      kategoriId: data.kategoriId.present
          ? data.kategoriId.value
          : this.kategoriId,
      dompetId: data.dompetId.present ? data.dompetId.value : this.dompetId,
      frekuensi: data.frekuensi.present ? data.frekuensi.value : this.frekuensi,
      jatuhTempoPertama: data.jatuhTempoPertama.present
          ? data.jatuhTempoPertama.value
          : this.jatuhTempoPertama,
      berakhirPada: data.berakhirPada.present
          ? data.berakhirPada.value
          : this.berakhirPada,
      pengingatHariSebelum: data.pengingatHariSebelum.present
          ? data.pengingatHariSebelum.value
          : this.pengingatHariSebelum,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
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
    return (StringBuffer('EntitasTagihan(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('jumlahPerkiraanRupiah: $jumlahPerkiraanRupiah, ')
          ..write('kategoriId: $kategoriId, ')
          ..write('dompetId: $dompetId, ')
          ..write('frekuensi: $frekuensi, ')
          ..write('jatuhTempoPertama: $jatuhTempoPertama, ')
          ..write('berakhirPada: $berakhirPada, ')
          ..write('pengingatHariSebelum: $pengingatHariSebelum, ')
          ..write('aktif: $aktif, ')
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
    jumlahPerkiraanRupiah,
    kategoriId,
    dompetId,
    frekuensi,
    jatuhTempoPertama,
    berakhirPada,
    pengingatHariSebelum,
    aktif,
    diarsipkan,
    dibuatPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasTagihan &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.jenis == this.jenis &&
          other.jumlahPerkiraanRupiah == this.jumlahPerkiraanRupiah &&
          other.kategoriId == this.kategoriId &&
          other.dompetId == this.dompetId &&
          other.frekuensi == this.frekuensi &&
          other.jatuhTempoPertama == this.jatuhTempoPertama &&
          other.berakhirPada == this.berakhirPada &&
          other.pengingatHariSebelum == this.pengingatHariSebelum &&
          other.aktif == this.aktif &&
          other.diarsipkan == this.diarsipkan &&
          other.dibuatPada == this.dibuatPada);
}

class TabelTagihanCompanion extends UpdateCompanion<EntitasTagihan> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> jenis;
  final Value<int?> jumlahPerkiraanRupiah;
  final Value<String> kategoriId;
  final Value<String?> dompetId;
  final Value<String> frekuensi;
  final Value<DateTime> jatuhTempoPertama;
  final Value<DateTime?> berakhirPada;
  final Value<String> pengingatHariSebelum;
  final Value<bool> aktif;
  final Value<bool> diarsipkan;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelTagihanCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.jenis = const Value.absent(),
    this.jumlahPerkiraanRupiah = const Value.absent(),
    this.kategoriId = const Value.absent(),
    this.dompetId = const Value.absent(),
    this.frekuensi = const Value.absent(),
    this.jatuhTempoPertama = const Value.absent(),
    this.berakhirPada = const Value.absent(),
    this.pengingatHariSebelum = const Value.absent(),
    this.aktif = const Value.absent(),
    this.diarsipkan = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelTagihanCompanion.insert({
    required String id,
    required String nama,
    required String jenis,
    this.jumlahPerkiraanRupiah = const Value.absent(),
    required String kategoriId,
    this.dompetId = const Value.absent(),
    required String frekuensi,
    required DateTime jatuhTempoPertama,
    this.berakhirPada = const Value.absent(),
    this.pengingatHariSebelum = const Value.absent(),
    this.aktif = const Value.absent(),
    this.diarsipkan = const Value.absent(),
    required DateTime dibuatPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       jenis = Value(jenis),
       kategoriId = Value(kategoriId),
       frekuensi = Value(frekuensi),
       jatuhTempoPertama = Value(jatuhTempoPertama),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasTagihan> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? jenis,
    Expression<int>? jumlahPerkiraanRupiah,
    Expression<String>? kategoriId,
    Expression<String>? dompetId,
    Expression<String>? frekuensi,
    Expression<DateTime>? jatuhTempoPertama,
    Expression<DateTime>? berakhirPada,
    Expression<String>? pengingatHariSebelum,
    Expression<bool>? aktif,
    Expression<bool>? diarsipkan,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (jenis != null) 'jenis': jenis,
      if (jumlahPerkiraanRupiah != null)
        'jumlah_perkiraan_rupiah': jumlahPerkiraanRupiah,
      if (kategoriId != null) 'kategori_id': kategoriId,
      if (dompetId != null) 'dompet_id': dompetId,
      if (frekuensi != null) 'frekuensi': frekuensi,
      if (jatuhTempoPertama != null) 'jatuh_tempo_pertama': jatuhTempoPertama,
      if (berakhirPada != null) 'berakhir_pada': berakhirPada,
      if (pengingatHariSebelum != null)
        'pengingat_hari_sebelum': pengingatHariSebelum,
      if (aktif != null) 'aktif': aktif,
      if (diarsipkan != null) 'diarsipkan': diarsipkan,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelTagihanCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? jenis,
    Value<int?>? jumlahPerkiraanRupiah,
    Value<String>? kategoriId,
    Value<String?>? dompetId,
    Value<String>? frekuensi,
    Value<DateTime>? jatuhTempoPertama,
    Value<DateTime?>? berakhirPada,
    Value<String>? pengingatHariSebelum,
    Value<bool>? aktif,
    Value<bool>? diarsipkan,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelTagihanCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      jumlahPerkiraanRupiah:
          jumlahPerkiraanRupiah ?? this.jumlahPerkiraanRupiah,
      kategoriId: kategoriId ?? this.kategoriId,
      dompetId: dompetId ?? this.dompetId,
      frekuensi: frekuensi ?? this.frekuensi,
      jatuhTempoPertama: jatuhTempoPertama ?? this.jatuhTempoPertama,
      berakhirPada: berakhirPada ?? this.berakhirPada,
      pengingatHariSebelum: pengingatHariSebelum ?? this.pengingatHariSebelum,
      aktif: aktif ?? this.aktif,
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
    if (jumlahPerkiraanRupiah.present) {
      map['jumlah_perkiraan_rupiah'] = Variable<int>(
        jumlahPerkiraanRupiah.value,
      );
    }
    if (kategoriId.present) {
      map['kategori_id'] = Variable<String>(kategoriId.value);
    }
    if (dompetId.present) {
      map['dompet_id'] = Variable<String>(dompetId.value);
    }
    if (frekuensi.present) {
      map['frekuensi'] = Variable<String>(frekuensi.value);
    }
    if (jatuhTempoPertama.present) {
      map['jatuh_tempo_pertama'] = Variable<DateTime>(jatuhTempoPertama.value);
    }
    if (berakhirPada.present) {
      map['berakhir_pada'] = Variable<DateTime>(berakhirPada.value);
    }
    if (pengingatHariSebelum.present) {
      map['pengingat_hari_sebelum'] = Variable<String>(
        pengingatHariSebelum.value,
      );
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
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
    return (StringBuffer('TabelTagihanCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('jenis: $jenis, ')
          ..write('jumlahPerkiraanRupiah: $jumlahPerkiraanRupiah, ')
          ..write('kategoriId: $kategoriId, ')
          ..write('dompetId: $dompetId, ')
          ..write('frekuensi: $frekuensi, ')
          ..write('jatuhTempoPertama: $jatuhTempoPertama, ')
          ..write('berakhirPada: $berakhirPada, ')
          ..write('pengingatHariSebelum: $pengingatHariSebelum, ')
          ..write('aktif: $aktif, ')
          ..write('diarsipkan: $diarsipkan, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelPembayaranTagihanTable extends TabelPembayaranTagihan
    with TableInfo<$TabelPembayaranTagihanTable, EntitasPembayaranTagihan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelPembayaranTagihanTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagihanIdMeta = const VerificationMeta(
    'tagihanId',
  );
  @override
  late final GeneratedColumn<String> tagihanId = GeneratedColumn<String>(
    'tagihan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabel_tagihan (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _jatuhTempoMeta = const VerificationMeta(
    'jatuhTempo',
  );
  @override
  late final GeneratedColumn<DateTime> jatuhTempo = GeneratedColumn<DateTime>(
    'jatuh_tempo',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transaksiIdMeta = const VerificationMeta(
    'transaksiId',
  );
  @override
  late final GeneratedColumn<String> transaksiId = GeneratedColumn<String>(
    'transaksi_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES tabel_transaksi (id) ON DELETE CASCADE',
    ),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tagihanId,
    jatuhTempo,
    status,
    transaksiId,
    dibuatPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_pembayaran_tagihan';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasPembayaranTagihan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tagihan_id')) {
      context.handle(
        _tagihanIdMeta,
        tagihanId.isAcceptableOrUnknown(data['tagihan_id']!, _tagihanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagihanIdMeta);
    }
    if (data.containsKey('jatuh_tempo')) {
      context.handle(
        _jatuhTempoMeta,
        jatuhTempo.isAcceptableOrUnknown(data['jatuh_tempo']!, _jatuhTempoMeta),
      );
    } else if (isInserting) {
      context.missing(_jatuhTempoMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('transaksi_id')) {
      context.handle(
        _transaksiIdMeta,
        transaksiId.isAcceptableOrUnknown(
          data['transaksi_id']!,
          _transaksiIdMeta,
        ),
      );
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tagihanId, jatuhTempo},
  ];
  @override
  EntitasPembayaranTagihan map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasPembayaranTagihan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tagihanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tagihan_id'],
      )!,
      jatuhTempo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}jatuh_tempo'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      transaksiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaksi_id'],
      ),
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
    );
  }

  @override
  $TabelPembayaranTagihanTable createAlias(String alias) {
    return $TabelPembayaranTagihanTable(attachedDatabase, alias);
  }
}

class EntitasPembayaranTagihan extends DataClass
    implements Insertable<EntitasPembayaranTagihan> {
  final String id;
  final String tagihanId;
  final DateTime jatuhTempo;
  final String status;
  final String? transaksiId;
  final DateTime dibuatPada;
  const EntitasPembayaranTagihan({
    required this.id,
    required this.tagihanId,
    required this.jatuhTempo,
    required this.status,
    this.transaksiId,
    required this.dibuatPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tagihan_id'] = Variable<String>(tagihanId);
    map['jatuh_tempo'] = Variable<DateTime>(jatuhTempo);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || transaksiId != null) {
      map['transaksi_id'] = Variable<String>(transaksiId);
    }
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    return map;
  }

  TabelPembayaranTagihanCompanion toCompanion(bool nullToAbsent) {
    return TabelPembayaranTagihanCompanion(
      id: Value(id),
      tagihanId: Value(tagihanId),
      jatuhTempo: Value(jatuhTempo),
      status: Value(status),
      transaksiId: transaksiId == null && nullToAbsent
          ? const Value.absent()
          : Value(transaksiId),
      dibuatPada: Value(dibuatPada),
    );
  }

  factory EntitasPembayaranTagihan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasPembayaranTagihan(
      id: serializer.fromJson<String>(json['id']),
      tagihanId: serializer.fromJson<String>(json['tagihanId']),
      jatuhTempo: serializer.fromJson<DateTime>(json['jatuhTempo']),
      status: serializer.fromJson<String>(json['status']),
      transaksiId: serializer.fromJson<String?>(json['transaksiId']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tagihanId': serializer.toJson<String>(tagihanId),
      'jatuhTempo': serializer.toJson<DateTime>(jatuhTempo),
      'status': serializer.toJson<String>(status),
      'transaksiId': serializer.toJson<String?>(transaksiId),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
    };
  }

  EntitasPembayaranTagihan copyWith({
    String? id,
    String? tagihanId,
    DateTime? jatuhTempo,
    String? status,
    Value<String?> transaksiId = const Value.absent(),
    DateTime? dibuatPada,
  }) => EntitasPembayaranTagihan(
    id: id ?? this.id,
    tagihanId: tagihanId ?? this.tagihanId,
    jatuhTempo: jatuhTempo ?? this.jatuhTempo,
    status: status ?? this.status,
    transaksiId: transaksiId.present ? transaksiId.value : this.transaksiId,
    dibuatPada: dibuatPada ?? this.dibuatPada,
  );
  EntitasPembayaranTagihan copyWithCompanion(
    TabelPembayaranTagihanCompanion data,
  ) {
    return EntitasPembayaranTagihan(
      id: data.id.present ? data.id.value : this.id,
      tagihanId: data.tagihanId.present ? data.tagihanId.value : this.tagihanId,
      jatuhTempo: data.jatuhTempo.present
          ? data.jatuhTempo.value
          : this.jatuhTempo,
      status: data.status.present ? data.status.value : this.status,
      transaksiId: data.transaksiId.present
          ? data.transaksiId.value
          : this.transaksiId,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasPembayaranTagihan(')
          ..write('id: $id, ')
          ..write('tagihanId: $tagihanId, ')
          ..write('jatuhTempo: $jatuhTempo, ')
          ..write('status: $status, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('dibuatPada: $dibuatPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tagihanId, jatuhTempo, status, transaksiId, dibuatPada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasPembayaranTagihan &&
          other.id == this.id &&
          other.tagihanId == this.tagihanId &&
          other.jatuhTempo == this.jatuhTempo &&
          other.status == this.status &&
          other.transaksiId == this.transaksiId &&
          other.dibuatPada == this.dibuatPada);
}

class TabelPembayaranTagihanCompanion
    extends UpdateCompanion<EntitasPembayaranTagihan> {
  final Value<String> id;
  final Value<String> tagihanId;
  final Value<DateTime> jatuhTempo;
  final Value<String> status;
  final Value<String?> transaksiId;
  final Value<DateTime> dibuatPada;
  final Value<int> rowid;
  const TabelPembayaranTagihanCompanion({
    this.id = const Value.absent(),
    this.tagihanId = const Value.absent(),
    this.jatuhTempo = const Value.absent(),
    this.status = const Value.absent(),
    this.transaksiId = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelPembayaranTagihanCompanion.insert({
    required String id,
    required String tagihanId,
    required DateTime jatuhTempo,
    required String status,
    this.transaksiId = const Value.absent(),
    required DateTime dibuatPada,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tagihanId = Value(tagihanId),
       jatuhTempo = Value(jatuhTempo),
       status = Value(status),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasPembayaranTagihan> custom({
    Expression<String>? id,
    Expression<String>? tagihanId,
    Expression<DateTime>? jatuhTempo,
    Expression<String>? status,
    Expression<String>? transaksiId,
    Expression<DateTime>? dibuatPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagihanId != null) 'tagihan_id': tagihanId,
      if (jatuhTempo != null) 'jatuh_tempo': jatuhTempo,
      if (status != null) 'status': status,
      if (transaksiId != null) 'transaksi_id': transaksiId,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelPembayaranTagihanCompanion copyWith({
    Value<String>? id,
    Value<String>? tagihanId,
    Value<DateTime>? jatuhTempo,
    Value<String>? status,
    Value<String?>? transaksiId,
    Value<DateTime>? dibuatPada,
    Value<int>? rowid,
  }) {
    return TabelPembayaranTagihanCompanion(
      id: id ?? this.id,
      tagihanId: tagihanId ?? this.tagihanId,
      jatuhTempo: jatuhTempo ?? this.jatuhTempo,
      status: status ?? this.status,
      transaksiId: transaksiId ?? this.transaksiId,
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
    if (tagihanId.present) {
      map['tagihan_id'] = Variable<String>(tagihanId.value);
    }
    if (jatuhTempo.present) {
      map['jatuh_tempo'] = Variable<DateTime>(jatuhTempo.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (transaksiId.present) {
      map['transaksi_id'] = Variable<String>(transaksiId.value);
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
    return (StringBuffer('TabelPembayaranTagihanCompanion(')
          ..write('id: $id, ')
          ..write('tagihanId: $tagihanId, ')
          ..write('jatuhTempo: $jatuhTempo, ')
          ..write('status: $status, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelProgresPelajaranTable extends TabelProgresPelajaran
    with TableInfo<$TabelProgresPelajaranTable, EntitasProgresPelajaran> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelProgresPelajaranTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pelajaranIdMeta = const VerificationMeta(
    'pelajaranId',
  );
  @override
  late final GeneratedColumn<String> pelajaranId = GeneratedColumn<String>(
    'pelajaran_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modulIdMeta = const VerificationMeta(
    'modulId',
  );
  @override
  late final GeneratedColumn<String> modulId = GeneratedColumn<String>(
    'modul_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indeksLangkahMeta = const VerificationMeta(
    'indeksLangkah',
  );
  @override
  late final GeneratedColumn<int> indeksLangkah = GeneratedColumn<int>(
    'indeks_langkah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selesaiPadaMeta = const VerificationMeta(
    'selesaiPada',
  );
  @override
  late final GeneratedColumn<DateTime> selesaiPada = GeneratedColumn<DateTime>(
    'selesai_pada',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pelajaranId,
    modulId,
    status,
    indeksLangkah,
    dibuatPada,
    selesaiPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_progres_pelajaran';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasProgresPelajaran> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pelajaran_id')) {
      context.handle(
        _pelajaranIdMeta,
        pelajaranId.isAcceptableOrUnknown(
          data['pelajaran_id']!,
          _pelajaranIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pelajaranIdMeta);
    }
    if (data.containsKey('modul_id')) {
      context.handle(
        _modulIdMeta,
        modulId.isAcceptableOrUnknown(data['modul_id']!, _modulIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modulIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('indeks_langkah')) {
      context.handle(
        _indeksLangkahMeta,
        indeksLangkah.isAcceptableOrUnknown(
          data['indeks_langkah']!,
          _indeksLangkahMeta,
        ),
      );
    }
    if (data.containsKey('dibuat_pada')) {
      context.handle(
        _dibuatPadaMeta,
        dibuatPada.isAcceptableOrUnknown(data['dibuat_pada']!, _dibuatPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_dibuatPadaMeta);
    }
    if (data.containsKey('selesai_pada')) {
      context.handle(
        _selesaiPadaMeta,
        selesaiPada.isAcceptableOrUnknown(
          data['selesai_pada']!,
          _selesaiPadaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pelajaranId};
  @override
  EntitasProgresPelajaran map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasProgresPelajaran(
      pelajaranId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pelajaran_id'],
      )!,
      modulId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modul_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      indeksLangkah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}indeks_langkah'],
      )!,
      dibuatPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dibuat_pada'],
      )!,
      selesaiPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}selesai_pada'],
      ),
    );
  }

  @override
  $TabelProgresPelajaranTable createAlias(String alias) {
    return $TabelProgresPelajaranTable(attachedDatabase, alias);
  }
}

class EntitasProgresPelajaran extends DataClass
    implements Insertable<EntitasProgresPelajaran> {
  /// ID stabil pelajaran (contoh: 'anggaran_arus_kas_1_2').
  final String pelajaranId;

  /// ID modul induk (contoh: 'anggaran_arus_kas').
  final String modulId;

  /// Status penyelesaian: 'sedang' | 'selesai'.
  final String status;

  /// Indeks langkah kartu terakhir yang dibuka pengguna (0-based).
  final int indeksLangkah;

  /// Waktu pertama kali pelajaran dimulai.
  final DateTime dibuatPada;

  /// Waktu pelajaran dinyatakan selesai (null jika masih 'sedang').
  final DateTime? selesaiPada;
  const EntitasProgresPelajaran({
    required this.pelajaranId,
    required this.modulId,
    required this.status,
    required this.indeksLangkah,
    required this.dibuatPada,
    this.selesaiPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pelajaran_id'] = Variable<String>(pelajaranId);
    map['modul_id'] = Variable<String>(modulId);
    map['status'] = Variable<String>(status);
    map['indeks_langkah'] = Variable<int>(indeksLangkah);
    map['dibuat_pada'] = Variable<DateTime>(dibuatPada);
    if (!nullToAbsent || selesaiPada != null) {
      map['selesai_pada'] = Variable<DateTime>(selesaiPada);
    }
    return map;
  }

  TabelProgresPelajaranCompanion toCompanion(bool nullToAbsent) {
    return TabelProgresPelajaranCompanion(
      pelajaranId: Value(pelajaranId),
      modulId: Value(modulId),
      status: Value(status),
      indeksLangkah: Value(indeksLangkah),
      dibuatPada: Value(dibuatPada),
      selesaiPada: selesaiPada == null && nullToAbsent
          ? const Value.absent()
          : Value(selesaiPada),
    );
  }

  factory EntitasProgresPelajaran.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasProgresPelajaran(
      pelajaranId: serializer.fromJson<String>(json['pelajaranId']),
      modulId: serializer.fromJson<String>(json['modulId']),
      status: serializer.fromJson<String>(json['status']),
      indeksLangkah: serializer.fromJson<int>(json['indeksLangkah']),
      dibuatPada: serializer.fromJson<DateTime>(json['dibuatPada']),
      selesaiPada: serializer.fromJson<DateTime?>(json['selesaiPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pelajaranId': serializer.toJson<String>(pelajaranId),
      'modulId': serializer.toJson<String>(modulId),
      'status': serializer.toJson<String>(status),
      'indeksLangkah': serializer.toJson<int>(indeksLangkah),
      'dibuatPada': serializer.toJson<DateTime>(dibuatPada),
      'selesaiPada': serializer.toJson<DateTime?>(selesaiPada),
    };
  }

  EntitasProgresPelajaran copyWith({
    String? pelajaranId,
    String? modulId,
    String? status,
    int? indeksLangkah,
    DateTime? dibuatPada,
    Value<DateTime?> selesaiPada = const Value.absent(),
  }) => EntitasProgresPelajaran(
    pelajaranId: pelajaranId ?? this.pelajaranId,
    modulId: modulId ?? this.modulId,
    status: status ?? this.status,
    indeksLangkah: indeksLangkah ?? this.indeksLangkah,
    dibuatPada: dibuatPada ?? this.dibuatPada,
    selesaiPada: selesaiPada.present ? selesaiPada.value : this.selesaiPada,
  );
  EntitasProgresPelajaran copyWithCompanion(
    TabelProgresPelajaranCompanion data,
  ) {
    return EntitasProgresPelajaran(
      pelajaranId: data.pelajaranId.present
          ? data.pelajaranId.value
          : this.pelajaranId,
      modulId: data.modulId.present ? data.modulId.value : this.modulId,
      status: data.status.present ? data.status.value : this.status,
      indeksLangkah: data.indeksLangkah.present
          ? data.indeksLangkah.value
          : this.indeksLangkah,
      dibuatPada: data.dibuatPada.present
          ? data.dibuatPada.value
          : this.dibuatPada,
      selesaiPada: data.selesaiPada.present
          ? data.selesaiPada.value
          : this.selesaiPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasProgresPelajaran(')
          ..write('pelajaranId: $pelajaranId, ')
          ..write('modulId: $modulId, ')
          ..write('status: $status, ')
          ..write('indeksLangkah: $indeksLangkah, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('selesaiPada: $selesaiPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pelajaranId,
    modulId,
    status,
    indeksLangkah,
    dibuatPada,
    selesaiPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasProgresPelajaran &&
          other.pelajaranId == this.pelajaranId &&
          other.modulId == this.modulId &&
          other.status == this.status &&
          other.indeksLangkah == this.indeksLangkah &&
          other.dibuatPada == this.dibuatPada &&
          other.selesaiPada == this.selesaiPada);
}

class TabelProgresPelajaranCompanion
    extends UpdateCompanion<EntitasProgresPelajaran> {
  final Value<String> pelajaranId;
  final Value<String> modulId;
  final Value<String> status;
  final Value<int> indeksLangkah;
  final Value<DateTime> dibuatPada;
  final Value<DateTime?> selesaiPada;
  final Value<int> rowid;
  const TabelProgresPelajaranCompanion({
    this.pelajaranId = const Value.absent(),
    this.modulId = const Value.absent(),
    this.status = const Value.absent(),
    this.indeksLangkah = const Value.absent(),
    this.dibuatPada = const Value.absent(),
    this.selesaiPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelProgresPelajaranCompanion.insert({
    required String pelajaranId,
    required String modulId,
    required String status,
    this.indeksLangkah = const Value.absent(),
    required DateTime dibuatPada,
    this.selesaiPada = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pelajaranId = Value(pelajaranId),
       modulId = Value(modulId),
       status = Value(status),
       dibuatPada = Value(dibuatPada);
  static Insertable<EntitasProgresPelajaran> custom({
    Expression<String>? pelajaranId,
    Expression<String>? modulId,
    Expression<String>? status,
    Expression<int>? indeksLangkah,
    Expression<DateTime>? dibuatPada,
    Expression<DateTime>? selesaiPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pelajaranId != null) 'pelajaran_id': pelajaranId,
      if (modulId != null) 'modul_id': modulId,
      if (status != null) 'status': status,
      if (indeksLangkah != null) 'indeks_langkah': indeksLangkah,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada,
      if (selesaiPada != null) 'selesai_pada': selesaiPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelProgresPelajaranCompanion copyWith({
    Value<String>? pelajaranId,
    Value<String>? modulId,
    Value<String>? status,
    Value<int>? indeksLangkah,
    Value<DateTime>? dibuatPada,
    Value<DateTime?>? selesaiPada,
    Value<int>? rowid,
  }) {
    return TabelProgresPelajaranCompanion(
      pelajaranId: pelajaranId ?? this.pelajaranId,
      modulId: modulId ?? this.modulId,
      status: status ?? this.status,
      indeksLangkah: indeksLangkah ?? this.indeksLangkah,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      selesaiPada: selesaiPada ?? this.selesaiPada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pelajaranId.present) {
      map['pelajaran_id'] = Variable<String>(pelajaranId.value);
    }
    if (modulId.present) {
      map['modul_id'] = Variable<String>(modulId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (indeksLangkah.present) {
      map['indeks_langkah'] = Variable<int>(indeksLangkah.value);
    }
    if (dibuatPada.present) {
      map['dibuat_pada'] = Variable<DateTime>(dibuatPada.value);
    }
    if (selesaiPada.present) {
      map['selesai_pada'] = Variable<DateTime>(selesaiPada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelProgresPelajaranCompanion(')
          ..write('pelajaranId: $pelajaranId, ')
          ..write('modulId: $modulId, ')
          ..write('status: $status, ')
          ..write('indeksLangkah: $indeksLangkah, ')
          ..write('dibuatPada: $dibuatPada, ')
          ..write('selesaiPada: $selesaiPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelHasilMisiTable extends TabelHasilMisi
    with TableInfo<$TabelHasilMisiTable, EntitasHasilMisi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelHasilMisiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _misiIdMeta = const VerificationMeta('misiId');
  @override
  late final GeneratedColumn<String> misiId = GeneratedColumn<String>(
    'misi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pelajaranIdMeta = const VerificationMeta(
    'pelajaranId',
  );
  @override
  late final GeneratedColumn<String> pelajaranId = GeneratedColumn<String>(
    'pelajaran_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
    'tipe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muatanJsonMeta = const VerificationMeta(
    'muatanJson',
  );
  @override
  late final GeneratedColumn<String> muatanJson = GeneratedColumn<String>(
    'muatan_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selesaiPadaMeta = const VerificationMeta(
    'selesaiPada',
  );
  @override
  late final GeneratedColumn<DateTime> selesaiPada = GeneratedColumn<DateTime>(
    'selesai_pada',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    misiId,
    pelajaranId,
    tipe,
    status,
    muatanJson,
    selesaiPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_hasil_misi';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasHasilMisi> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('misi_id')) {
      context.handle(
        _misiIdMeta,
        misiId.isAcceptableOrUnknown(data['misi_id']!, _misiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_misiIdMeta);
    }
    if (data.containsKey('pelajaran_id')) {
      context.handle(
        _pelajaranIdMeta,
        pelajaranId.isAcceptableOrUnknown(
          data['pelajaran_id']!,
          _pelajaranIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pelajaranIdMeta);
    }
    if (data.containsKey('tipe')) {
      context.handle(
        _tipeMeta,
        tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta),
      );
    } else if (isInserting) {
      context.missing(_tipeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('muatan_json')) {
      context.handle(
        _muatanJsonMeta,
        muatanJson.isAcceptableOrUnknown(data['muatan_json']!, _muatanJsonMeta),
      );
    }
    if (data.containsKey('selesai_pada')) {
      context.handle(
        _selesaiPadaMeta,
        selesaiPada.isAcceptableOrUnknown(
          data['selesai_pada']!,
          _selesaiPadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selesaiPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {misiId};
  @override
  EntitasHasilMisi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasHasilMisi(
      misiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}misi_id'],
      )!,
      pelajaranId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pelajaran_id'],
      )!,
      tipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipe'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      muatanJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muatan_json'],
      ),
      selesaiPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}selesai_pada'],
      )!,
    );
  }

  @override
  $TabelHasilMisiTable createAlias(String alias) {
    return $TabelHasilMisiTable(attachedDatabase, alias);
  }
}

class EntitasHasilMisi extends DataClass
    implements Insertable<EntitasHasilMisi> {
  /// ID misi (biasanya identik dengan pelajaran_id atau kode unik misi).
  final String misiId;

  /// ID pelajaran yang memuat misi ini.
  final String pelajaranId;

  /// Tipe verifikasi misi: 'ada_data', 'aturan_data', 'lihat_hitungan', dsb.
  final String tipe;

  /// Status penyelesaian misi: 'selesai' | 'dilewati'.
  final String status;

  /// Muatan tambahan hasil misi dalam format JSON (opsional).
  final String? muatanJson;

  /// Waktu misi diselesaikan atau dilewati.
  final DateTime selesaiPada;
  const EntitasHasilMisi({
    required this.misiId,
    required this.pelajaranId,
    required this.tipe,
    required this.status,
    this.muatanJson,
    required this.selesaiPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['misi_id'] = Variable<String>(misiId);
    map['pelajaran_id'] = Variable<String>(pelajaranId);
    map['tipe'] = Variable<String>(tipe);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || muatanJson != null) {
      map['muatan_json'] = Variable<String>(muatanJson);
    }
    map['selesai_pada'] = Variable<DateTime>(selesaiPada);
    return map;
  }

  TabelHasilMisiCompanion toCompanion(bool nullToAbsent) {
    return TabelHasilMisiCompanion(
      misiId: Value(misiId),
      pelajaranId: Value(pelajaranId),
      tipe: Value(tipe),
      status: Value(status),
      muatanJson: muatanJson == null && nullToAbsent
          ? const Value.absent()
          : Value(muatanJson),
      selesaiPada: Value(selesaiPada),
    );
  }

  factory EntitasHasilMisi.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasHasilMisi(
      misiId: serializer.fromJson<String>(json['misiId']),
      pelajaranId: serializer.fromJson<String>(json['pelajaranId']),
      tipe: serializer.fromJson<String>(json['tipe']),
      status: serializer.fromJson<String>(json['status']),
      muatanJson: serializer.fromJson<String?>(json['muatanJson']),
      selesaiPada: serializer.fromJson<DateTime>(json['selesaiPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'misiId': serializer.toJson<String>(misiId),
      'pelajaranId': serializer.toJson<String>(pelajaranId),
      'tipe': serializer.toJson<String>(tipe),
      'status': serializer.toJson<String>(status),
      'muatanJson': serializer.toJson<String?>(muatanJson),
      'selesaiPada': serializer.toJson<DateTime>(selesaiPada),
    };
  }

  EntitasHasilMisi copyWith({
    String? misiId,
    String? pelajaranId,
    String? tipe,
    String? status,
    Value<String?> muatanJson = const Value.absent(),
    DateTime? selesaiPada,
  }) => EntitasHasilMisi(
    misiId: misiId ?? this.misiId,
    pelajaranId: pelajaranId ?? this.pelajaranId,
    tipe: tipe ?? this.tipe,
    status: status ?? this.status,
    muatanJson: muatanJson.present ? muatanJson.value : this.muatanJson,
    selesaiPada: selesaiPada ?? this.selesaiPada,
  );
  EntitasHasilMisi copyWithCompanion(TabelHasilMisiCompanion data) {
    return EntitasHasilMisi(
      misiId: data.misiId.present ? data.misiId.value : this.misiId,
      pelajaranId: data.pelajaranId.present
          ? data.pelajaranId.value
          : this.pelajaranId,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
      status: data.status.present ? data.status.value : this.status,
      muatanJson: data.muatanJson.present
          ? data.muatanJson.value
          : this.muatanJson,
      selesaiPada: data.selesaiPada.present
          ? data.selesaiPada.value
          : this.selesaiPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasHasilMisi(')
          ..write('misiId: $misiId, ')
          ..write('pelajaranId: $pelajaranId, ')
          ..write('tipe: $tipe, ')
          ..write('status: $status, ')
          ..write('muatanJson: $muatanJson, ')
          ..write('selesaiPada: $selesaiPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(misiId, pelajaranId, tipe, status, muatanJson, selesaiPada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasHasilMisi &&
          other.misiId == this.misiId &&
          other.pelajaranId == this.pelajaranId &&
          other.tipe == this.tipe &&
          other.status == this.status &&
          other.muatanJson == this.muatanJson &&
          other.selesaiPada == this.selesaiPada);
}

class TabelHasilMisiCompanion extends UpdateCompanion<EntitasHasilMisi> {
  final Value<String> misiId;
  final Value<String> pelajaranId;
  final Value<String> tipe;
  final Value<String> status;
  final Value<String?> muatanJson;
  final Value<DateTime> selesaiPada;
  final Value<int> rowid;
  const TabelHasilMisiCompanion({
    this.misiId = const Value.absent(),
    this.pelajaranId = const Value.absent(),
    this.tipe = const Value.absent(),
    this.status = const Value.absent(),
    this.muatanJson = const Value.absent(),
    this.selesaiPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelHasilMisiCompanion.insert({
    required String misiId,
    required String pelajaranId,
    required String tipe,
    required String status,
    this.muatanJson = const Value.absent(),
    required DateTime selesaiPada,
    this.rowid = const Value.absent(),
  }) : misiId = Value(misiId),
       pelajaranId = Value(pelajaranId),
       tipe = Value(tipe),
       status = Value(status),
       selesaiPada = Value(selesaiPada);
  static Insertable<EntitasHasilMisi> custom({
    Expression<String>? misiId,
    Expression<String>? pelajaranId,
    Expression<String>? tipe,
    Expression<String>? status,
    Expression<String>? muatanJson,
    Expression<DateTime>? selesaiPada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (misiId != null) 'misi_id': misiId,
      if (pelajaranId != null) 'pelajaran_id': pelajaranId,
      if (tipe != null) 'tipe': tipe,
      if (status != null) 'status': status,
      if (muatanJson != null) 'muatan_json': muatanJson,
      if (selesaiPada != null) 'selesai_pada': selesaiPada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabelHasilMisiCompanion copyWith({
    Value<String>? misiId,
    Value<String>? pelajaranId,
    Value<String>? tipe,
    Value<String>? status,
    Value<String?>? muatanJson,
    Value<DateTime>? selesaiPada,
    Value<int>? rowid,
  }) {
    return TabelHasilMisiCompanion(
      misiId: misiId ?? this.misiId,
      pelajaranId: pelajaranId ?? this.pelajaranId,
      tipe: tipe ?? this.tipe,
      status: status ?? this.status,
      muatanJson: muatanJson ?? this.muatanJson,
      selesaiPada: selesaiPada ?? this.selesaiPada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (misiId.present) {
      map['misi_id'] = Variable<String>(misiId.value);
    }
    if (pelajaranId.present) {
      map['pelajaran_id'] = Variable<String>(pelajaranId.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (muatanJson.present) {
      map['muatan_json'] = Variable<String>(muatanJson.value);
    }
    if (selesaiPada.present) {
      map['selesai_pada'] = Variable<DateTime>(selesaiPada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelHasilMisiCompanion(')
          ..write('misiId: $misiId, ')
          ..write('pelajaranId: $pelajaranId, ')
          ..write('tipe: $tipe, ')
          ..write('status: $status, ')
          ..write('muatanJson: $muatanJson, ')
          ..write('selesaiPada: $selesaiPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelHasilKuisTable extends TabelHasilKuis
    with TableInfo<$TabelHasilKuisTable, EntitasHasilKuis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelHasilKuisTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _modulIdMeta = const VerificationMeta(
    'modulId',
  );
  @override
  late final GeneratedColumn<String> modulId = GeneratedColumn<String>(
    'modul_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _benarMeta = const VerificationMeta('benar');
  @override
  late final GeneratedColumn<int> benar = GeneratedColumn<int>(
    'benar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skorPersenMeta = const VerificationMeta(
    'skorPersen',
  );
  @override
  late final GeneratedColumn<int> skorPersen = GeneratedColumn<int>(
    'skor_persen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lulusMeta = const VerificationMeta('lulus');
  @override
  late final GeneratedColumn<bool> lulus = GeneratedColumn<bool>(
    'lulus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lulus" IN (0, 1))',
    ),
  );
  static const VerificationMeta _waktuMeta = const VerificationMeta('waktu');
  @override
  late final GeneratedColumn<DateTime> waktu = GeneratedColumn<DateTime>(
    'waktu',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modulId,
    benar,
    total,
    skorPersen,
    lulus,
    waktu,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_hasil_kuis';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasHasilKuis> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('modul_id')) {
      context.handle(
        _modulIdMeta,
        modulId.isAcceptableOrUnknown(data['modul_id']!, _modulIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modulIdMeta);
    }
    if (data.containsKey('benar')) {
      context.handle(
        _benarMeta,
        benar.isAcceptableOrUnknown(data['benar']!, _benarMeta),
      );
    } else if (isInserting) {
      context.missing(_benarMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('skor_persen')) {
      context.handle(
        _skorPersenMeta,
        skorPersen.isAcceptableOrUnknown(data['skor_persen']!, _skorPersenMeta),
      );
    } else if (isInserting) {
      context.missing(_skorPersenMeta);
    }
    if (data.containsKey('lulus')) {
      context.handle(
        _lulusMeta,
        lulus.isAcceptableOrUnknown(data['lulus']!, _lulusMeta),
      );
    } else if (isInserting) {
      context.missing(_lulusMeta);
    }
    if (data.containsKey('waktu')) {
      context.handle(
        _waktuMeta,
        waktu.isAcceptableOrUnknown(data['waktu']!, _waktuMeta),
      );
    } else if (isInserting) {
      context.missing(_waktuMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasHasilKuis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasHasilKuis(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modulId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modul_id'],
      )!,
      benar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}benar'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      skorPersen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skor_persen'],
      )!,
      lulus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lulus'],
      )!,
      waktu: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}waktu'],
      )!,
    );
  }

  @override
  $TabelHasilKuisTable createAlias(String alias) {
    return $TabelHasilKuisTable(attachedDatabase, alias);
  }
}

class EntitasHasilKuis extends DataClass
    implements Insertable<EntitasHasilKuis> {
  /// Kunci primer bertambah otomatis.
  final int id;

  /// ID modul yang diuji.
  final String modulId;

  /// Jumlah jawaban benar.
  final int benar;

  /// Total soal dalam kuis.
  final int total;

  /// Skor dalam persentase integer (0-100).
  final int skorPersen;

  /// Status kelulusan (lulus bila skor >= ambangLulusKuis 70%).
  final bool lulus;

  /// Waktu kuis diselesaikan.
  final DateTime waktu;
  const EntitasHasilKuis({
    required this.id,
    required this.modulId,
    required this.benar,
    required this.total,
    required this.skorPersen,
    required this.lulus,
    required this.waktu,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['modul_id'] = Variable<String>(modulId);
    map['benar'] = Variable<int>(benar);
    map['total'] = Variable<int>(total);
    map['skor_persen'] = Variable<int>(skorPersen);
    map['lulus'] = Variable<bool>(lulus);
    map['waktu'] = Variable<DateTime>(waktu);
    return map;
  }

  TabelHasilKuisCompanion toCompanion(bool nullToAbsent) {
    return TabelHasilKuisCompanion(
      id: Value(id),
      modulId: Value(modulId),
      benar: Value(benar),
      total: Value(total),
      skorPersen: Value(skorPersen),
      lulus: Value(lulus),
      waktu: Value(waktu),
    );
  }

  factory EntitasHasilKuis.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasHasilKuis(
      id: serializer.fromJson<int>(json['id']),
      modulId: serializer.fromJson<String>(json['modulId']),
      benar: serializer.fromJson<int>(json['benar']),
      total: serializer.fromJson<int>(json['total']),
      skorPersen: serializer.fromJson<int>(json['skorPersen']),
      lulus: serializer.fromJson<bool>(json['lulus']),
      waktu: serializer.fromJson<DateTime>(json['waktu']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modulId': serializer.toJson<String>(modulId),
      'benar': serializer.toJson<int>(benar),
      'total': serializer.toJson<int>(total),
      'skorPersen': serializer.toJson<int>(skorPersen),
      'lulus': serializer.toJson<bool>(lulus),
      'waktu': serializer.toJson<DateTime>(waktu),
    };
  }

  EntitasHasilKuis copyWith({
    int? id,
    String? modulId,
    int? benar,
    int? total,
    int? skorPersen,
    bool? lulus,
    DateTime? waktu,
  }) => EntitasHasilKuis(
    id: id ?? this.id,
    modulId: modulId ?? this.modulId,
    benar: benar ?? this.benar,
    total: total ?? this.total,
    skorPersen: skorPersen ?? this.skorPersen,
    lulus: lulus ?? this.lulus,
    waktu: waktu ?? this.waktu,
  );
  EntitasHasilKuis copyWithCompanion(TabelHasilKuisCompanion data) {
    return EntitasHasilKuis(
      id: data.id.present ? data.id.value : this.id,
      modulId: data.modulId.present ? data.modulId.value : this.modulId,
      benar: data.benar.present ? data.benar.value : this.benar,
      total: data.total.present ? data.total.value : this.total,
      skorPersen: data.skorPersen.present
          ? data.skorPersen.value
          : this.skorPersen,
      lulus: data.lulus.present ? data.lulus.value : this.lulus,
      waktu: data.waktu.present ? data.waktu.value : this.waktu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasHasilKuis(')
          ..write('id: $id, ')
          ..write('modulId: $modulId, ')
          ..write('benar: $benar, ')
          ..write('total: $total, ')
          ..write('skorPersen: $skorPersen, ')
          ..write('lulus: $lulus, ')
          ..write('waktu: $waktu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, modulId, benar, total, skorPersen, lulus, waktu);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasHasilKuis &&
          other.id == this.id &&
          other.modulId == this.modulId &&
          other.benar == this.benar &&
          other.total == this.total &&
          other.skorPersen == this.skorPersen &&
          other.lulus == this.lulus &&
          other.waktu == this.waktu);
}

class TabelHasilKuisCompanion extends UpdateCompanion<EntitasHasilKuis> {
  final Value<int> id;
  final Value<String> modulId;
  final Value<int> benar;
  final Value<int> total;
  final Value<int> skorPersen;
  final Value<bool> lulus;
  final Value<DateTime> waktu;
  const TabelHasilKuisCompanion({
    this.id = const Value.absent(),
    this.modulId = const Value.absent(),
    this.benar = const Value.absent(),
    this.total = const Value.absent(),
    this.skorPersen = const Value.absent(),
    this.lulus = const Value.absent(),
    this.waktu = const Value.absent(),
  });
  TabelHasilKuisCompanion.insert({
    this.id = const Value.absent(),
    required String modulId,
    required int benar,
    required int total,
    required int skorPersen,
    required bool lulus,
    required DateTime waktu,
  }) : modulId = Value(modulId),
       benar = Value(benar),
       total = Value(total),
       skorPersen = Value(skorPersen),
       lulus = Value(lulus),
       waktu = Value(waktu);
  static Insertable<EntitasHasilKuis> custom({
    Expression<int>? id,
    Expression<String>? modulId,
    Expression<int>? benar,
    Expression<int>? total,
    Expression<int>? skorPersen,
    Expression<bool>? lulus,
    Expression<DateTime>? waktu,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modulId != null) 'modul_id': modulId,
      if (benar != null) 'benar': benar,
      if (total != null) 'total': total,
      if (skorPersen != null) 'skor_persen': skorPersen,
      if (lulus != null) 'lulus': lulus,
      if (waktu != null) 'waktu': waktu,
    });
  }

  TabelHasilKuisCompanion copyWith({
    Value<int>? id,
    Value<String>? modulId,
    Value<int>? benar,
    Value<int>? total,
    Value<int>? skorPersen,
    Value<bool>? lulus,
    Value<DateTime>? waktu,
  }) {
    return TabelHasilKuisCompanion(
      id: id ?? this.id,
      modulId: modulId ?? this.modulId,
      benar: benar ?? this.benar,
      total: total ?? this.total,
      skorPersen: skorPersen ?? this.skorPersen,
      lulus: lulus ?? this.lulus,
      waktu: waktu ?? this.waktu,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modulId.present) {
      map['modul_id'] = Variable<String>(modulId.value);
    }
    if (benar.present) {
      map['benar'] = Variable<int>(benar.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (skorPersen.present) {
      map['skor_persen'] = Variable<int>(skorPersen.value);
    }
    if (lulus.present) {
      map['lulus'] = Variable<bool>(lulus.value);
    }
    if (waktu.present) {
      map['waktu'] = Variable<DateTime>(waktu.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelHasilKuisCompanion(')
          ..write('id: $id, ')
          ..write('modulId: $modulId, ')
          ..write('benar: $benar, ')
          ..write('total: $total, ')
          ..write('skorPersen: $skorPersen, ')
          ..write('lulus: $lulus, ')
          ..write('waktu: $waktu')
          ..write(')'))
        .toString();
  }
}

class $TabelPernyataanTable extends TabelPernyataan
    with TableInfo<$TabelPernyataanTable, EntitasPernyataan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelPernyataanTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [kunci, nilai, diubahPada];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_pernyataan';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasPernyataan> instance, {
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
    } else if (isInserting) {
      context.missing(_diubahPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kunci};
  @override
  EntitasPernyataan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasPernyataan(
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
  $TabelPernyataanTable createAlias(String alias) {
    return $TabelPernyataanTable(attachedDatabase, alias);
  }
}

class EntitasPernyataan extends DataClass
    implements Insertable<EntitasPernyataan> {
  /// Kunci unik pernyataan (contoh: 'tidak_punya_utang', 'baru_satu_sumber_penghasilan').
  final String kunci;

  /// Nilai pernyataan (contoh: 'true', 'false', atau teks khusus).
  final String nilai;

  /// Waktu pernyataan disimpan atau terakhir kali diubah.
  final DateTime diubahPada;
  const EntitasPernyataan({
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

  TabelPernyataanCompanion toCompanion(bool nullToAbsent) {
    return TabelPernyataanCompanion(
      kunci: Value(kunci),
      nilai: Value(nilai),
      diubahPada: Value(diubahPada),
    );
  }

  factory EntitasPernyataan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasPernyataan(
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

  EntitasPernyataan copyWith({
    String? kunci,
    String? nilai,
    DateTime? diubahPada,
  }) => EntitasPernyataan(
    kunci: kunci ?? this.kunci,
    nilai: nilai ?? this.nilai,
    diubahPada: diubahPada ?? this.diubahPada,
  );
  EntitasPernyataan copyWithCompanion(TabelPernyataanCompanion data) {
    return EntitasPernyataan(
      kunci: data.kunci.present ? data.kunci.value : this.kunci,
      nilai: data.nilai.present ? data.nilai.value : this.nilai,
      diubahPada: data.diubahPada.present
          ? data.diubahPada.value
          : this.diubahPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasPernyataan(')
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
      (other is EntitasPernyataan &&
          other.kunci == this.kunci &&
          other.nilai == this.nilai &&
          other.diubahPada == this.diubahPada);
}

class TabelPernyataanCompanion extends UpdateCompanion<EntitasPernyataan> {
  final Value<String> kunci;
  final Value<String> nilai;
  final Value<DateTime> diubahPada;
  final Value<int> rowid;
  const TabelPernyataanCompanion({
    this.kunci = const Value.absent(),
    this.nilai = const Value.absent(),
    this.diubahPada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabelPernyataanCompanion.insert({
    required String kunci,
    required String nilai,
    required DateTime diubahPada,
    this.rowid = const Value.absent(),
  }) : kunci = Value(kunci),
       nilai = Value(nilai),
       diubahPada = Value(diubahPada);
  static Insertable<EntitasPernyataan> custom({
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

  TabelPernyataanCompanion copyWith({
    Value<String>? kunci,
    Value<String>? nilai,
    Value<DateTime>? diubahPada,
    Value<int>? rowid,
  }) {
    return TabelPernyataanCompanion(
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
    return (StringBuffer('TabelPernyataanCompanion(')
          ..write('kunci: $kunci, ')
          ..write('nilai: $nilai, ')
          ..write('diubahPada: $diubahPada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TabelProfilKeuanganTable extends TabelProfilKeuangan
    with TableInfo<$TabelProfilKeuanganTable, EntitasProfilKeuangan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelProfilKeuanganTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _punyaPenghasilanMeta = const VerificationMeta(
    'punyaPenghasilan',
  );
  @override
  late final GeneratedColumn<String> punyaPenghasilan = GeneratedColumn<String>(
    'punya_penghasilan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _punyaUtangMeta = const VerificationMeta(
    'punyaUtang',
  );
  @override
  late final GeneratedColumn<String> punyaUtang = GeneratedColumn<String>(
    'punya_utang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _danaDaruratMeta = const VerificationMeta(
    'danaDarurat',
  );
  @override
  late final GeneratedColumn<String> danaDarurat = GeneratedColumn<String>(
    'dana_darurat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _menabungMeta = const VerificationMeta(
    'menabung',
  );
  @override
  late final GeneratedColumn<String> menabung = GeneratedColumn<String>(
    'menabung',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _investasiMeta = const VerificationMeta(
    'investasi',
  );
  @override
  late final GeneratedColumn<String> investasi = GeneratedColumn<String>(
    'investasi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mencatatKeuanganMeta = const VerificationMeta(
    'mencatatKeuangan',
  );
  @override
  late final GeneratedColumn<String> mencatatKeuangan = GeneratedColumn<String>(
    'mencatat_keuangan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tujuanUtamaMeta = const VerificationMeta(
    'tujuanUtama',
  );
  @override
  late final GeneratedColumn<String> tujuanUtama = GeneratedColumn<String>(
    'tujuan_utama',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diisiPadaMeta = const VerificationMeta(
    'diisiPada',
  );
  @override
  late final GeneratedColumn<DateTime> diisiPada = GeneratedColumn<DateTime>(
    'diisi_pada',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diperbaruiPadaMeta = const VerificationMeta(
    'diperbaruiPada',
  );
  @override
  late final GeneratedColumn<DateTime> diperbaruiPada =
      GeneratedColumn<DateTime>(
        'diperbarui_pada',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    punyaPenghasilan,
    punyaUtang,
    danaDarurat,
    menabung,
    investasi,
    mencatatKeuangan,
    tujuanUtama,
    diisiPada,
    diperbaruiPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_profil_keuangan';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasProfilKeuangan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('punya_penghasilan')) {
      context.handle(
        _punyaPenghasilanMeta,
        punyaPenghasilan.isAcceptableOrUnknown(
          data['punya_penghasilan']!,
          _punyaPenghasilanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_punyaPenghasilanMeta);
    }
    if (data.containsKey('punya_utang')) {
      context.handle(
        _punyaUtangMeta,
        punyaUtang.isAcceptableOrUnknown(data['punya_utang']!, _punyaUtangMeta),
      );
    } else if (isInserting) {
      context.missing(_punyaUtangMeta);
    }
    if (data.containsKey('dana_darurat')) {
      context.handle(
        _danaDaruratMeta,
        danaDarurat.isAcceptableOrUnknown(
          data['dana_darurat']!,
          _danaDaruratMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_danaDaruratMeta);
    }
    if (data.containsKey('menabung')) {
      context.handle(
        _menabungMeta,
        menabung.isAcceptableOrUnknown(data['menabung']!, _menabungMeta),
      );
    } else if (isInserting) {
      context.missing(_menabungMeta);
    }
    if (data.containsKey('investasi')) {
      context.handle(
        _investasiMeta,
        investasi.isAcceptableOrUnknown(data['investasi']!, _investasiMeta),
      );
    } else if (isInserting) {
      context.missing(_investasiMeta);
    }
    if (data.containsKey('mencatat_keuangan')) {
      context.handle(
        _mencatatKeuanganMeta,
        mencatatKeuangan.isAcceptableOrUnknown(
          data['mencatat_keuangan']!,
          _mencatatKeuanganMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mencatatKeuanganMeta);
    }
    if (data.containsKey('tujuan_utama')) {
      context.handle(
        _tujuanUtamaMeta,
        tujuanUtama.isAcceptableOrUnknown(
          data['tujuan_utama']!,
          _tujuanUtamaMeta,
        ),
      );
    }
    if (data.containsKey('diisi_pada')) {
      context.handle(
        _diisiPadaMeta,
        diisiPada.isAcceptableOrUnknown(data['diisi_pada']!, _diisiPadaMeta),
      );
    } else if (isInserting) {
      context.missing(_diisiPadaMeta);
    }
    if (data.containsKey('diperbarui_pada')) {
      context.handle(
        _diperbaruiPadaMeta,
        diperbaruiPada.isAcceptableOrUnknown(
          data['diperbarui_pada']!,
          _diperbaruiPadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diperbaruiPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasProfilKeuangan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasProfilKeuangan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      punyaPenghasilan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}punya_penghasilan'],
      )!,
      punyaUtang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}punya_utang'],
      )!,
      danaDarurat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dana_darurat'],
      )!,
      menabung: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menabung'],
      )!,
      investasi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investasi'],
      )!,
      mencatatKeuangan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mencatat_keuangan'],
      )!,
      tujuanUtama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tujuan_utama'],
      ),
      diisiPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diisi_pada'],
      )!,
      diperbaruiPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diperbarui_pada'],
      )!,
    );
  }

  @override
  $TabelProfilKeuanganTable createAlias(String alias) {
    return $TabelProfilKeuanganTable(attachedDatabase, alias);
  }
}

class EntitasProfilKeuangan extends DataClass
    implements Insertable<EntitasProfilKeuangan> {
  /// Kunci primer bertambah otomatis.
  final int id;

  /// Status penghasilan pengguna: 'rutin', 'tidak_rutin', 'belum'.
  final String punyaPenghasilan;

  /// Status kepemilikan utang: 'ya', 'tidak', 'tidak_yakin'.
  final String punyaUtang;

  /// Kesiapan dana darurat: 'belum', 'sedikit', 'sudah'.
  final String danaDarurat;

  /// Kebiasaan menabung: 'belum', 'kadang', 'rutin'.
  final String menabung;

  /// Pengalaman investasi: 'belum', 'pernah', 'aktif'.
  final String investasi;

  /// Kebiasaan mencatat keuangan: 'belum', 'kadang', 'rutin'.
  final String mencatatKeuangan;

  /// Tujuan keuangan utama (opsional, maksimal 100 karakter).
  final String? tujuanUtama;

  /// Waktu pertama kali profil diisi.
  final DateTime diisiPada;

  /// Waktu profil terakhir kali diperbarui.
  final DateTime diperbaruiPada;
  const EntitasProfilKeuangan({
    required this.id,
    required this.punyaPenghasilan,
    required this.punyaUtang,
    required this.danaDarurat,
    required this.menabung,
    required this.investasi,
    required this.mencatatKeuangan,
    this.tujuanUtama,
    required this.diisiPada,
    required this.diperbaruiPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['punya_penghasilan'] = Variable<String>(punyaPenghasilan);
    map['punya_utang'] = Variable<String>(punyaUtang);
    map['dana_darurat'] = Variable<String>(danaDarurat);
    map['menabung'] = Variable<String>(menabung);
    map['investasi'] = Variable<String>(investasi);
    map['mencatat_keuangan'] = Variable<String>(mencatatKeuangan);
    if (!nullToAbsent || tujuanUtama != null) {
      map['tujuan_utama'] = Variable<String>(tujuanUtama);
    }
    map['diisi_pada'] = Variable<DateTime>(diisiPada);
    map['diperbarui_pada'] = Variable<DateTime>(diperbaruiPada);
    return map;
  }

  TabelProfilKeuanganCompanion toCompanion(bool nullToAbsent) {
    return TabelProfilKeuanganCompanion(
      id: Value(id),
      punyaPenghasilan: Value(punyaPenghasilan),
      punyaUtang: Value(punyaUtang),
      danaDarurat: Value(danaDarurat),
      menabung: Value(menabung),
      investasi: Value(investasi),
      mencatatKeuangan: Value(mencatatKeuangan),
      tujuanUtama: tujuanUtama == null && nullToAbsent
          ? const Value.absent()
          : Value(tujuanUtama),
      diisiPada: Value(diisiPada),
      diperbaruiPada: Value(diperbaruiPada),
    );
  }

  factory EntitasProfilKeuangan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasProfilKeuangan(
      id: serializer.fromJson<int>(json['id']),
      punyaPenghasilan: serializer.fromJson<String>(json['punyaPenghasilan']),
      punyaUtang: serializer.fromJson<String>(json['punyaUtang']),
      danaDarurat: serializer.fromJson<String>(json['danaDarurat']),
      menabung: serializer.fromJson<String>(json['menabung']),
      investasi: serializer.fromJson<String>(json['investasi']),
      mencatatKeuangan: serializer.fromJson<String>(json['mencatatKeuangan']),
      tujuanUtama: serializer.fromJson<String?>(json['tujuanUtama']),
      diisiPada: serializer.fromJson<DateTime>(json['diisiPada']),
      diperbaruiPada: serializer.fromJson<DateTime>(json['diperbaruiPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'punyaPenghasilan': serializer.toJson<String>(punyaPenghasilan),
      'punyaUtang': serializer.toJson<String>(punyaUtang),
      'danaDarurat': serializer.toJson<String>(danaDarurat),
      'menabung': serializer.toJson<String>(menabung),
      'investasi': serializer.toJson<String>(investasi),
      'mencatatKeuangan': serializer.toJson<String>(mencatatKeuangan),
      'tujuanUtama': serializer.toJson<String?>(tujuanUtama),
      'diisiPada': serializer.toJson<DateTime>(diisiPada),
      'diperbaruiPada': serializer.toJson<DateTime>(diperbaruiPada),
    };
  }

  EntitasProfilKeuangan copyWith({
    int? id,
    String? punyaPenghasilan,
    String? punyaUtang,
    String? danaDarurat,
    String? menabung,
    String? investasi,
    String? mencatatKeuangan,
    Value<String?> tujuanUtama = const Value.absent(),
    DateTime? diisiPada,
    DateTime? diperbaruiPada,
  }) => EntitasProfilKeuangan(
    id: id ?? this.id,
    punyaPenghasilan: punyaPenghasilan ?? this.punyaPenghasilan,
    punyaUtang: punyaUtang ?? this.punyaUtang,
    danaDarurat: danaDarurat ?? this.danaDarurat,
    menabung: menabung ?? this.menabung,
    investasi: investasi ?? this.investasi,
    mencatatKeuangan: mencatatKeuangan ?? this.mencatatKeuangan,
    tujuanUtama: tujuanUtama.present ? tujuanUtama.value : this.tujuanUtama,
    diisiPada: diisiPada ?? this.diisiPada,
    diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
  );
  EntitasProfilKeuangan copyWithCompanion(TabelProfilKeuanganCompanion data) {
    return EntitasProfilKeuangan(
      id: data.id.present ? data.id.value : this.id,
      punyaPenghasilan: data.punyaPenghasilan.present
          ? data.punyaPenghasilan.value
          : this.punyaPenghasilan,
      punyaUtang: data.punyaUtang.present
          ? data.punyaUtang.value
          : this.punyaUtang,
      danaDarurat: data.danaDarurat.present
          ? data.danaDarurat.value
          : this.danaDarurat,
      menabung: data.menabung.present ? data.menabung.value : this.menabung,
      investasi: data.investasi.present ? data.investasi.value : this.investasi,
      mencatatKeuangan: data.mencatatKeuangan.present
          ? data.mencatatKeuangan.value
          : this.mencatatKeuangan,
      tujuanUtama: data.tujuanUtama.present
          ? data.tujuanUtama.value
          : this.tujuanUtama,
      diisiPada: data.diisiPada.present ? data.diisiPada.value : this.diisiPada,
      diperbaruiPada: data.diperbaruiPada.present
          ? data.diperbaruiPada.value
          : this.diperbaruiPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasProfilKeuangan(')
          ..write('id: $id, ')
          ..write('punyaPenghasilan: $punyaPenghasilan, ')
          ..write('punyaUtang: $punyaUtang, ')
          ..write('danaDarurat: $danaDarurat, ')
          ..write('menabung: $menabung, ')
          ..write('investasi: $investasi, ')
          ..write('mencatatKeuangan: $mencatatKeuangan, ')
          ..write('tujuanUtama: $tujuanUtama, ')
          ..write('diisiPada: $diisiPada, ')
          ..write('diperbaruiPada: $diperbaruiPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    punyaPenghasilan,
    punyaUtang,
    danaDarurat,
    menabung,
    investasi,
    mencatatKeuangan,
    tujuanUtama,
    diisiPada,
    diperbaruiPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasProfilKeuangan &&
          other.id == this.id &&
          other.punyaPenghasilan == this.punyaPenghasilan &&
          other.punyaUtang == this.punyaUtang &&
          other.danaDarurat == this.danaDarurat &&
          other.menabung == this.menabung &&
          other.investasi == this.investasi &&
          other.mencatatKeuangan == this.mencatatKeuangan &&
          other.tujuanUtama == this.tujuanUtama &&
          other.diisiPada == this.diisiPada &&
          other.diperbaruiPada == this.diperbaruiPada);
}

class TabelProfilKeuanganCompanion
    extends UpdateCompanion<EntitasProfilKeuangan> {
  final Value<int> id;
  final Value<String> punyaPenghasilan;
  final Value<String> punyaUtang;
  final Value<String> danaDarurat;
  final Value<String> menabung;
  final Value<String> investasi;
  final Value<String> mencatatKeuangan;
  final Value<String?> tujuanUtama;
  final Value<DateTime> diisiPada;
  final Value<DateTime> diperbaruiPada;
  const TabelProfilKeuanganCompanion({
    this.id = const Value.absent(),
    this.punyaPenghasilan = const Value.absent(),
    this.punyaUtang = const Value.absent(),
    this.danaDarurat = const Value.absent(),
    this.menabung = const Value.absent(),
    this.investasi = const Value.absent(),
    this.mencatatKeuangan = const Value.absent(),
    this.tujuanUtama = const Value.absent(),
    this.diisiPada = const Value.absent(),
    this.diperbaruiPada = const Value.absent(),
  });
  TabelProfilKeuanganCompanion.insert({
    this.id = const Value.absent(),
    required String punyaPenghasilan,
    required String punyaUtang,
    required String danaDarurat,
    required String menabung,
    required String investasi,
    required String mencatatKeuangan,
    this.tujuanUtama = const Value.absent(),
    required DateTime diisiPada,
    required DateTime diperbaruiPada,
  }) : punyaPenghasilan = Value(punyaPenghasilan),
       punyaUtang = Value(punyaUtang),
       danaDarurat = Value(danaDarurat),
       menabung = Value(menabung),
       investasi = Value(investasi),
       mencatatKeuangan = Value(mencatatKeuangan),
       diisiPada = Value(diisiPada),
       diperbaruiPada = Value(diperbaruiPada);
  static Insertable<EntitasProfilKeuangan> custom({
    Expression<int>? id,
    Expression<String>? punyaPenghasilan,
    Expression<String>? punyaUtang,
    Expression<String>? danaDarurat,
    Expression<String>? menabung,
    Expression<String>? investasi,
    Expression<String>? mencatatKeuangan,
    Expression<String>? tujuanUtama,
    Expression<DateTime>? diisiPada,
    Expression<DateTime>? diperbaruiPada,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (punyaPenghasilan != null) 'punya_penghasilan': punyaPenghasilan,
      if (punyaUtang != null) 'punya_utang': punyaUtang,
      if (danaDarurat != null) 'dana_darurat': danaDarurat,
      if (menabung != null) 'menabung': menabung,
      if (investasi != null) 'investasi': investasi,
      if (mencatatKeuangan != null) 'mencatat_keuangan': mencatatKeuangan,
      if (tujuanUtama != null) 'tujuan_utama': tujuanUtama,
      if (diisiPada != null) 'diisi_pada': diisiPada,
      if (diperbaruiPada != null) 'diperbarui_pada': diperbaruiPada,
    });
  }

  TabelProfilKeuanganCompanion copyWith({
    Value<int>? id,
    Value<String>? punyaPenghasilan,
    Value<String>? punyaUtang,
    Value<String>? danaDarurat,
    Value<String>? menabung,
    Value<String>? investasi,
    Value<String>? mencatatKeuangan,
    Value<String?>? tujuanUtama,
    Value<DateTime>? diisiPada,
    Value<DateTime>? diperbaruiPada,
  }) {
    return TabelProfilKeuanganCompanion(
      id: id ?? this.id,
      punyaPenghasilan: punyaPenghasilan ?? this.punyaPenghasilan,
      punyaUtang: punyaUtang ?? this.punyaUtang,
      danaDarurat: danaDarurat ?? this.danaDarurat,
      menabung: menabung ?? this.menabung,
      investasi: investasi ?? this.investasi,
      mencatatKeuangan: mencatatKeuangan ?? this.mencatatKeuangan,
      tujuanUtama: tujuanUtama ?? this.tujuanUtama,
      diisiPada: diisiPada ?? this.diisiPada,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (punyaPenghasilan.present) {
      map['punya_penghasilan'] = Variable<String>(punyaPenghasilan.value);
    }
    if (punyaUtang.present) {
      map['punya_utang'] = Variable<String>(punyaUtang.value);
    }
    if (danaDarurat.present) {
      map['dana_darurat'] = Variable<String>(danaDarurat.value);
    }
    if (menabung.present) {
      map['menabung'] = Variable<String>(menabung.value);
    }
    if (investasi.present) {
      map['investasi'] = Variable<String>(investasi.value);
    }
    if (mencatatKeuangan.present) {
      map['mencatat_keuangan'] = Variable<String>(mencatatKeuangan.value);
    }
    if (tujuanUtama.present) {
      map['tujuan_utama'] = Variable<String>(tujuanUtama.value);
    }
    if (diisiPada.present) {
      map['diisi_pada'] = Variable<DateTime>(diisiPada.value);
    }
    if (diperbaruiPada.present) {
      map['diperbarui_pada'] = Variable<DateTime>(diperbaruiPada.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelProfilKeuanganCompanion(')
          ..write('id: $id, ')
          ..write('punyaPenghasilan: $punyaPenghasilan, ')
          ..write('punyaUtang: $punyaUtang, ')
          ..write('danaDarurat: $danaDarurat, ')
          ..write('menabung: $menabung, ')
          ..write('investasi: $investasi, ')
          ..write('mencatatKeuangan: $mencatatKeuangan, ')
          ..write('tujuanUtama: $tujuanUtama, ')
          ..write('diisiPada: $diisiPada, ')
          ..write('diperbaruiPada: $diperbaruiPada')
          ..write(')'))
        .toString();
  }
}

class $TabelHasilTesAwalTable extends TabelHasilTesAwal
    with TableInfo<$TabelHasilTesAwalTable, EntitasHasilTesAwal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelHasilTesAwalTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _waktuMeta = const VerificationMeta('waktu');
  @override
  late final GeneratedColumn<DateTime> waktu = GeneratedColumn<DateTime>(
    'waktu',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jawabanJsonMeta = const VerificationMeta(
    'jawabanJson',
  );
  @override
  late final GeneratedColumn<String> jawabanJson = GeneratedColumn<String>(
    'jawaban_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skorPerModulJsonMeta = const VerificationMeta(
    'skorPerModulJson',
  );
  @override
  late final GeneratedColumn<String> skorPerModulJson = GeneratedColumn<String>(
    'skor_per_modul_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skorTotalPersenMeta = const VerificationMeta(
    'skorTotalPersen',
  );
  @override
  late final GeneratedColumn<int> skorTotalPersen = GeneratedColumn<int>(
    'skor_total_persen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    waktu,
    jawabanJson,
    skorPerModulJson,
    skorTotalPersen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_hasil_tes_awal';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasHasilTesAwal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('waktu')) {
      context.handle(
        _waktuMeta,
        waktu.isAcceptableOrUnknown(data['waktu']!, _waktuMeta),
      );
    } else if (isInserting) {
      context.missing(_waktuMeta);
    }
    if (data.containsKey('jawaban_json')) {
      context.handle(
        _jawabanJsonMeta,
        jawabanJson.isAcceptableOrUnknown(
          data['jawaban_json']!,
          _jawabanJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jawabanJsonMeta);
    }
    if (data.containsKey('skor_per_modul_json')) {
      context.handle(
        _skorPerModulJsonMeta,
        skorPerModulJson.isAcceptableOrUnknown(
          data['skor_per_modul_json']!,
          _skorPerModulJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_skorPerModulJsonMeta);
    }
    if (data.containsKey('skor_total_persen')) {
      context.handle(
        _skorTotalPersenMeta,
        skorTotalPersen.isAcceptableOrUnknown(
          data['skor_total_persen']!,
          _skorTotalPersenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_skorTotalPersenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasHasilTesAwal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasHasilTesAwal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      waktu: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}waktu'],
      )!,
      jawabanJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jawaban_json'],
      )!,
      skorPerModulJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skor_per_modul_json'],
      )!,
      skorTotalPersen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skor_total_persen'],
      )!,
    );
  }

  @override
  $TabelHasilTesAwalTable createAlias(String alias) {
    return $TabelHasilTesAwalTable(attachedDatabase, alias);
  }
}

class EntitasHasilTesAwal extends DataClass
    implements Insertable<EntitasHasilTesAwal> {
  /// Kunci primer bertambah otomatis.
  final int id;

  /// Waktu tes awal diselesaikan.
  final DateTime waktu;

  /// Jawaban detail pengguna per butir soal dalam format JSON string.
  final String jawabanJson;

  /// Rincian skor persentase per modul dalam format JSON string.
  final String skorPerModulJson;

  /// Skor total tes awal dalam persentase integer (0-100).
  final int skorTotalPersen;
  const EntitasHasilTesAwal({
    required this.id,
    required this.waktu,
    required this.jawabanJson,
    required this.skorPerModulJson,
    required this.skorTotalPersen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['waktu'] = Variable<DateTime>(waktu);
    map['jawaban_json'] = Variable<String>(jawabanJson);
    map['skor_per_modul_json'] = Variable<String>(skorPerModulJson);
    map['skor_total_persen'] = Variable<int>(skorTotalPersen);
    return map;
  }

  TabelHasilTesAwalCompanion toCompanion(bool nullToAbsent) {
    return TabelHasilTesAwalCompanion(
      id: Value(id),
      waktu: Value(waktu),
      jawabanJson: Value(jawabanJson),
      skorPerModulJson: Value(skorPerModulJson),
      skorTotalPersen: Value(skorTotalPersen),
    );
  }

  factory EntitasHasilTesAwal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasHasilTesAwal(
      id: serializer.fromJson<int>(json['id']),
      waktu: serializer.fromJson<DateTime>(json['waktu']),
      jawabanJson: serializer.fromJson<String>(json['jawabanJson']),
      skorPerModulJson: serializer.fromJson<String>(json['skorPerModulJson']),
      skorTotalPersen: serializer.fromJson<int>(json['skorTotalPersen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'waktu': serializer.toJson<DateTime>(waktu),
      'jawabanJson': serializer.toJson<String>(jawabanJson),
      'skorPerModulJson': serializer.toJson<String>(skorPerModulJson),
      'skorTotalPersen': serializer.toJson<int>(skorTotalPersen),
    };
  }

  EntitasHasilTesAwal copyWith({
    int? id,
    DateTime? waktu,
    String? jawabanJson,
    String? skorPerModulJson,
    int? skorTotalPersen,
  }) => EntitasHasilTesAwal(
    id: id ?? this.id,
    waktu: waktu ?? this.waktu,
    jawabanJson: jawabanJson ?? this.jawabanJson,
    skorPerModulJson: skorPerModulJson ?? this.skorPerModulJson,
    skorTotalPersen: skorTotalPersen ?? this.skorTotalPersen,
  );
  EntitasHasilTesAwal copyWithCompanion(TabelHasilTesAwalCompanion data) {
    return EntitasHasilTesAwal(
      id: data.id.present ? data.id.value : this.id,
      waktu: data.waktu.present ? data.waktu.value : this.waktu,
      jawabanJson: data.jawabanJson.present
          ? data.jawabanJson.value
          : this.jawabanJson,
      skorPerModulJson: data.skorPerModulJson.present
          ? data.skorPerModulJson.value
          : this.skorPerModulJson,
      skorTotalPersen: data.skorTotalPersen.present
          ? data.skorTotalPersen.value
          : this.skorTotalPersen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasHasilTesAwal(')
          ..write('id: $id, ')
          ..write('waktu: $waktu, ')
          ..write('jawabanJson: $jawabanJson, ')
          ..write('skorPerModulJson: $skorPerModulJson, ')
          ..write('skorTotalPersen: $skorTotalPersen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, waktu, jawabanJson, skorPerModulJson, skorTotalPersen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasHasilTesAwal &&
          other.id == this.id &&
          other.waktu == this.waktu &&
          other.jawabanJson == this.jawabanJson &&
          other.skorPerModulJson == this.skorPerModulJson &&
          other.skorTotalPersen == this.skorTotalPersen);
}

class TabelHasilTesAwalCompanion extends UpdateCompanion<EntitasHasilTesAwal> {
  final Value<int> id;
  final Value<DateTime> waktu;
  final Value<String> jawabanJson;
  final Value<String> skorPerModulJson;
  final Value<int> skorTotalPersen;
  const TabelHasilTesAwalCompanion({
    this.id = const Value.absent(),
    this.waktu = const Value.absent(),
    this.jawabanJson = const Value.absent(),
    this.skorPerModulJson = const Value.absent(),
    this.skorTotalPersen = const Value.absent(),
  });
  TabelHasilTesAwalCompanion.insert({
    this.id = const Value.absent(),
    required DateTime waktu,
    required String jawabanJson,
    required String skorPerModulJson,
    required int skorTotalPersen,
  }) : waktu = Value(waktu),
       jawabanJson = Value(jawabanJson),
       skorPerModulJson = Value(skorPerModulJson),
       skorTotalPersen = Value(skorTotalPersen);
  static Insertable<EntitasHasilTesAwal> custom({
    Expression<int>? id,
    Expression<DateTime>? waktu,
    Expression<String>? jawabanJson,
    Expression<String>? skorPerModulJson,
    Expression<int>? skorTotalPersen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (waktu != null) 'waktu': waktu,
      if (jawabanJson != null) 'jawaban_json': jawabanJson,
      if (skorPerModulJson != null) 'skor_per_modul_json': skorPerModulJson,
      if (skorTotalPersen != null) 'skor_total_persen': skorTotalPersen,
    });
  }

  TabelHasilTesAwalCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? waktu,
    Value<String>? jawabanJson,
    Value<String>? skorPerModulJson,
    Value<int>? skorTotalPersen,
  }) {
    return TabelHasilTesAwalCompanion(
      id: id ?? this.id,
      waktu: waktu ?? this.waktu,
      jawabanJson: jawabanJson ?? this.jawabanJson,
      skorPerModulJson: skorPerModulJson ?? this.skorPerModulJson,
      skorTotalPersen: skorTotalPersen ?? this.skorTotalPersen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (waktu.present) {
      map['waktu'] = Variable<DateTime>(waktu.value);
    }
    if (jawabanJson.present) {
      map['jawaban_json'] = Variable<String>(jawabanJson.value);
    }
    if (skorPerModulJson.present) {
      map['skor_per_modul_json'] = Variable<String>(skorPerModulJson.value);
    }
    if (skorTotalPersen.present) {
      map['skor_total_persen'] = Variable<int>(skorTotalPersen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelHasilTesAwalCompanion(')
          ..write('id: $id, ')
          ..write('waktu: $waktu, ')
          ..write('jawabanJson: $jawabanJson, ')
          ..write('skorPerModulJson: $skorPerModulJson, ')
          ..write('skorTotalPersen: $skorTotalPersen')
          ..write(')'))
        .toString();
  }
}

class $TabelSesiSandboxTable extends TabelSesiSandbox
    with TableInfo<$TabelSesiSandboxTable, EntitasSesiSandbox> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabelSesiSandboxTable(this.attachedDatabase, [this._alias]);
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
    defaultValue: const Constant(10000000),
  );
  static const VerificationMeta _alokasiPasarUangPersenMeta =
      const VerificationMeta('alokasiPasarUangPersen');
  @override
  late final GeneratedColumn<int> alokasiPasarUangPersen = GeneratedColumn<int>(
    'alokasi_pasar_uang_persen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alokasiObligasiPersenMeta =
      const VerificationMeta('alokasiObligasiPersen');
  @override
  late final GeneratedColumn<int> alokasiObligasiPersen = GeneratedColumn<int>(
    'alokasi_obligasi_persen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alokasiSahamPersenMeta =
      const VerificationMeta('alokasiSahamPersen');
  @override
  late final GeneratedColumn<int> alokasiSahamPersen = GeneratedColumn<int>(
    'alokasi_saham_persen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bulanBerjalanMeta = const VerificationMeta(
    'bulanBerjalan',
  );
  @override
  late final GeneratedColumn<int> bulanBerjalan = GeneratedColumn<int>(
    'bulan_berjalan',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nilaiSaatIniRupiahMeta =
      const VerificationMeta('nilaiSaatIniRupiah');
  @override
  late final GeneratedColumn<int> nilaiSaatIniRupiah = GeneratedColumn<int>(
    'nilai_saat_ini_rupiah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skenarioAktifMeta = const VerificationMeta(
    'skenarioAktif',
  );
  @override
  late final GeneratedColumn<String> skenarioAktif = GeneratedColumn<String>(
    'skenario_aktif',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riwayatJsonMeta = const VerificationMeta(
    'riwayatJson',
  );
  @override
  late final GeneratedColumn<String> riwayatJson = GeneratedColumn<String>(
    'riwayat_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diperbaruiPadaMeta = const VerificationMeta(
    'diperbaruiPada',
  );
  @override
  late final GeneratedColumn<DateTime> diperbaruiPada =
      GeneratedColumn<DateTime>(
        'diperbarui_pada',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saldoAwalRupiah,
    alokasiPasarUangPersen,
    alokasiObligasiPersen,
    alokasiSahamPersen,
    bulanBerjalan,
    nilaiSaatIniRupiah,
    skenarioAktif,
    riwayatJson,
    diperbaruiPada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabel_sesi_sandbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitasSesiSandbox> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('alokasi_pasar_uang_persen')) {
      context.handle(
        _alokasiPasarUangPersenMeta,
        alokasiPasarUangPersen.isAcceptableOrUnknown(
          data['alokasi_pasar_uang_persen']!,
          _alokasiPasarUangPersenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alokasiPasarUangPersenMeta);
    }
    if (data.containsKey('alokasi_obligasi_persen')) {
      context.handle(
        _alokasiObligasiPersenMeta,
        alokasiObligasiPersen.isAcceptableOrUnknown(
          data['alokasi_obligasi_persen']!,
          _alokasiObligasiPersenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alokasiObligasiPersenMeta);
    }
    if (data.containsKey('alokasi_saham_persen')) {
      context.handle(
        _alokasiSahamPersenMeta,
        alokasiSahamPersen.isAcceptableOrUnknown(
          data['alokasi_saham_persen']!,
          _alokasiSahamPersenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alokasiSahamPersenMeta);
    }
    if (data.containsKey('bulan_berjalan')) {
      context.handle(
        _bulanBerjalanMeta,
        bulanBerjalan.isAcceptableOrUnknown(
          data['bulan_berjalan']!,
          _bulanBerjalanMeta,
        ),
      );
    }
    if (data.containsKey('nilai_saat_ini_rupiah')) {
      context.handle(
        _nilaiSaatIniRupiahMeta,
        nilaiSaatIniRupiah.isAcceptableOrUnknown(
          data['nilai_saat_ini_rupiah']!,
          _nilaiSaatIniRupiahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nilaiSaatIniRupiahMeta);
    }
    if (data.containsKey('skenario_aktif')) {
      context.handle(
        _skenarioAktifMeta,
        skenarioAktif.isAcceptableOrUnknown(
          data['skenario_aktif']!,
          _skenarioAktifMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_skenarioAktifMeta);
    }
    if (data.containsKey('riwayat_json')) {
      context.handle(
        _riwayatJsonMeta,
        riwayatJson.isAcceptableOrUnknown(
          data['riwayat_json']!,
          _riwayatJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_riwayatJsonMeta);
    }
    if (data.containsKey('diperbarui_pada')) {
      context.handle(
        _diperbaruiPadaMeta,
        diperbaruiPada.isAcceptableOrUnknown(
          data['diperbarui_pada']!,
          _diperbaruiPadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diperbaruiPadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitasSesiSandbox map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitasSesiSandbox(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      saldoAwalRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_awal_rupiah'],
      )!,
      alokasiPasarUangPersen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alokasi_pasar_uang_persen'],
      )!,
      alokasiObligasiPersen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alokasi_obligasi_persen'],
      )!,
      alokasiSahamPersen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alokasi_saham_persen'],
      )!,
      bulanBerjalan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bulan_berjalan'],
      )!,
      nilaiSaatIniRupiah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nilai_saat_ini_rupiah'],
      )!,
      skenarioAktif: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skenario_aktif'],
      )!,
      riwayatJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}riwayat_json'],
      )!,
      diperbaruiPada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diperbarui_pada'],
      )!,
    );
  }

  @override
  $TabelSesiSandboxTable createAlias(String alias) {
    return $TabelSesiSandboxTable(attachedDatabase, alias);
  }
}

class EntitasSesiSandbox extends DataClass
    implements Insertable<EntitasSesiSandbox> {
  /// ID sesi sandbox (primary key).
  final int id;

  /// Saldo modal fiktif awal dalam satuan Rupiah penuh.
  final int saldoAwalRupiah;

  /// Persentase alokasi ke instrumen pasar uang (0..100).
  final int alokasiPasarUangPersen;

  /// Persentase alokasi ke instrumen obligasi (0..100).
  final int alokasiObligasiPersen;

  /// Persentase alokasi ke instrumen saham (0..100).
  final int alokasiSahamPersen;

  /// Jumlah bulan simulasi yang sudah berjalan (tiap loncatan 1 tahun = 12 bulan).
  final int bulanBerjalan;

  /// Nilai portofolio fiktif saat ini dalam satuan Rupiah penuh.
  final int nilaiSaatIniRupiah;

  /// Skenario pasar yang aktif: 'normal' | 'turun' | 'naik'.
  final String skenarioAktif;

  /// Rekaman JSON riwayat langkah simulasi tahun demi tahun.
  final String riwayatJson;

  /// Waktu sesi terakhir kali disimpan atau dimodifikasi.
  final DateTime diperbaruiPada;
  const EntitasSesiSandbox({
    required this.id,
    required this.saldoAwalRupiah,
    required this.alokasiPasarUangPersen,
    required this.alokasiObligasiPersen,
    required this.alokasiSahamPersen,
    required this.bulanBerjalan,
    required this.nilaiSaatIniRupiah,
    required this.skenarioAktif,
    required this.riwayatJson,
    required this.diperbaruiPada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['saldo_awal_rupiah'] = Variable<int>(saldoAwalRupiah);
    map['alokasi_pasar_uang_persen'] = Variable<int>(alokasiPasarUangPersen);
    map['alokasi_obligasi_persen'] = Variable<int>(alokasiObligasiPersen);
    map['alokasi_saham_persen'] = Variable<int>(alokasiSahamPersen);
    map['bulan_berjalan'] = Variable<int>(bulanBerjalan);
    map['nilai_saat_ini_rupiah'] = Variable<int>(nilaiSaatIniRupiah);
    map['skenario_aktif'] = Variable<String>(skenarioAktif);
    map['riwayat_json'] = Variable<String>(riwayatJson);
    map['diperbarui_pada'] = Variable<DateTime>(diperbaruiPada);
    return map;
  }

  TabelSesiSandboxCompanion toCompanion(bool nullToAbsent) {
    return TabelSesiSandboxCompanion(
      id: Value(id),
      saldoAwalRupiah: Value(saldoAwalRupiah),
      alokasiPasarUangPersen: Value(alokasiPasarUangPersen),
      alokasiObligasiPersen: Value(alokasiObligasiPersen),
      alokasiSahamPersen: Value(alokasiSahamPersen),
      bulanBerjalan: Value(bulanBerjalan),
      nilaiSaatIniRupiah: Value(nilaiSaatIniRupiah),
      skenarioAktif: Value(skenarioAktif),
      riwayatJson: Value(riwayatJson),
      diperbaruiPada: Value(diperbaruiPada),
    );
  }

  factory EntitasSesiSandbox.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitasSesiSandbox(
      id: serializer.fromJson<int>(json['id']),
      saldoAwalRupiah: serializer.fromJson<int>(json['saldoAwalRupiah']),
      alokasiPasarUangPersen: serializer.fromJson<int>(
        json['alokasiPasarUangPersen'],
      ),
      alokasiObligasiPersen: serializer.fromJson<int>(
        json['alokasiObligasiPersen'],
      ),
      alokasiSahamPersen: serializer.fromJson<int>(json['alokasiSahamPersen']),
      bulanBerjalan: serializer.fromJson<int>(json['bulanBerjalan']),
      nilaiSaatIniRupiah: serializer.fromJson<int>(json['nilaiSaatIniRupiah']),
      skenarioAktif: serializer.fromJson<String>(json['skenarioAktif']),
      riwayatJson: serializer.fromJson<String>(json['riwayatJson']),
      diperbaruiPada: serializer.fromJson<DateTime>(json['diperbaruiPada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saldoAwalRupiah': serializer.toJson<int>(saldoAwalRupiah),
      'alokasiPasarUangPersen': serializer.toJson<int>(alokasiPasarUangPersen),
      'alokasiObligasiPersen': serializer.toJson<int>(alokasiObligasiPersen),
      'alokasiSahamPersen': serializer.toJson<int>(alokasiSahamPersen),
      'bulanBerjalan': serializer.toJson<int>(bulanBerjalan),
      'nilaiSaatIniRupiah': serializer.toJson<int>(nilaiSaatIniRupiah),
      'skenarioAktif': serializer.toJson<String>(skenarioAktif),
      'riwayatJson': serializer.toJson<String>(riwayatJson),
      'diperbaruiPada': serializer.toJson<DateTime>(diperbaruiPada),
    };
  }

  EntitasSesiSandbox copyWith({
    int? id,
    int? saldoAwalRupiah,
    int? alokasiPasarUangPersen,
    int? alokasiObligasiPersen,
    int? alokasiSahamPersen,
    int? bulanBerjalan,
    int? nilaiSaatIniRupiah,
    String? skenarioAktif,
    String? riwayatJson,
    DateTime? diperbaruiPada,
  }) => EntitasSesiSandbox(
    id: id ?? this.id,
    saldoAwalRupiah: saldoAwalRupiah ?? this.saldoAwalRupiah,
    alokasiPasarUangPersen:
        alokasiPasarUangPersen ?? this.alokasiPasarUangPersen,
    alokasiObligasiPersen: alokasiObligasiPersen ?? this.alokasiObligasiPersen,
    alokasiSahamPersen: alokasiSahamPersen ?? this.alokasiSahamPersen,
    bulanBerjalan: bulanBerjalan ?? this.bulanBerjalan,
    nilaiSaatIniRupiah: nilaiSaatIniRupiah ?? this.nilaiSaatIniRupiah,
    skenarioAktif: skenarioAktif ?? this.skenarioAktif,
    riwayatJson: riwayatJson ?? this.riwayatJson,
    diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
  );
  EntitasSesiSandbox copyWithCompanion(TabelSesiSandboxCompanion data) {
    return EntitasSesiSandbox(
      id: data.id.present ? data.id.value : this.id,
      saldoAwalRupiah: data.saldoAwalRupiah.present
          ? data.saldoAwalRupiah.value
          : this.saldoAwalRupiah,
      alokasiPasarUangPersen: data.alokasiPasarUangPersen.present
          ? data.alokasiPasarUangPersen.value
          : this.alokasiPasarUangPersen,
      alokasiObligasiPersen: data.alokasiObligasiPersen.present
          ? data.alokasiObligasiPersen.value
          : this.alokasiObligasiPersen,
      alokasiSahamPersen: data.alokasiSahamPersen.present
          ? data.alokasiSahamPersen.value
          : this.alokasiSahamPersen,
      bulanBerjalan: data.bulanBerjalan.present
          ? data.bulanBerjalan.value
          : this.bulanBerjalan,
      nilaiSaatIniRupiah: data.nilaiSaatIniRupiah.present
          ? data.nilaiSaatIniRupiah.value
          : this.nilaiSaatIniRupiah,
      skenarioAktif: data.skenarioAktif.present
          ? data.skenarioAktif.value
          : this.skenarioAktif,
      riwayatJson: data.riwayatJson.present
          ? data.riwayatJson.value
          : this.riwayatJson,
      diperbaruiPada: data.diperbaruiPada.present
          ? data.diperbaruiPada.value
          : this.diperbaruiPada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitasSesiSandbox(')
          ..write('id: $id, ')
          ..write('saldoAwalRupiah: $saldoAwalRupiah, ')
          ..write('alokasiPasarUangPersen: $alokasiPasarUangPersen, ')
          ..write('alokasiObligasiPersen: $alokasiObligasiPersen, ')
          ..write('alokasiSahamPersen: $alokasiSahamPersen, ')
          ..write('bulanBerjalan: $bulanBerjalan, ')
          ..write('nilaiSaatIniRupiah: $nilaiSaatIniRupiah, ')
          ..write('skenarioAktif: $skenarioAktif, ')
          ..write('riwayatJson: $riwayatJson, ')
          ..write('diperbaruiPada: $diperbaruiPada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saldoAwalRupiah,
    alokasiPasarUangPersen,
    alokasiObligasiPersen,
    alokasiSahamPersen,
    bulanBerjalan,
    nilaiSaatIniRupiah,
    skenarioAktif,
    riwayatJson,
    diperbaruiPada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitasSesiSandbox &&
          other.id == this.id &&
          other.saldoAwalRupiah == this.saldoAwalRupiah &&
          other.alokasiPasarUangPersen == this.alokasiPasarUangPersen &&
          other.alokasiObligasiPersen == this.alokasiObligasiPersen &&
          other.alokasiSahamPersen == this.alokasiSahamPersen &&
          other.bulanBerjalan == this.bulanBerjalan &&
          other.nilaiSaatIniRupiah == this.nilaiSaatIniRupiah &&
          other.skenarioAktif == this.skenarioAktif &&
          other.riwayatJson == this.riwayatJson &&
          other.diperbaruiPada == this.diperbaruiPada);
}

class TabelSesiSandboxCompanion extends UpdateCompanion<EntitasSesiSandbox> {
  final Value<int> id;
  final Value<int> saldoAwalRupiah;
  final Value<int> alokasiPasarUangPersen;
  final Value<int> alokasiObligasiPersen;
  final Value<int> alokasiSahamPersen;
  final Value<int> bulanBerjalan;
  final Value<int> nilaiSaatIniRupiah;
  final Value<String> skenarioAktif;
  final Value<String> riwayatJson;
  final Value<DateTime> diperbaruiPada;
  const TabelSesiSandboxCompanion({
    this.id = const Value.absent(),
    this.saldoAwalRupiah = const Value.absent(),
    this.alokasiPasarUangPersen = const Value.absent(),
    this.alokasiObligasiPersen = const Value.absent(),
    this.alokasiSahamPersen = const Value.absent(),
    this.bulanBerjalan = const Value.absent(),
    this.nilaiSaatIniRupiah = const Value.absent(),
    this.skenarioAktif = const Value.absent(),
    this.riwayatJson = const Value.absent(),
    this.diperbaruiPada = const Value.absent(),
  });
  TabelSesiSandboxCompanion.insert({
    this.id = const Value.absent(),
    this.saldoAwalRupiah = const Value.absent(),
    required int alokasiPasarUangPersen,
    required int alokasiObligasiPersen,
    required int alokasiSahamPersen,
    this.bulanBerjalan = const Value.absent(),
    required int nilaiSaatIniRupiah,
    required String skenarioAktif,
    required String riwayatJson,
    required DateTime diperbaruiPada,
  }) : alokasiPasarUangPersen = Value(alokasiPasarUangPersen),
       alokasiObligasiPersen = Value(alokasiObligasiPersen),
       alokasiSahamPersen = Value(alokasiSahamPersen),
       nilaiSaatIniRupiah = Value(nilaiSaatIniRupiah),
       skenarioAktif = Value(skenarioAktif),
       riwayatJson = Value(riwayatJson),
       diperbaruiPada = Value(diperbaruiPada);
  static Insertable<EntitasSesiSandbox> custom({
    Expression<int>? id,
    Expression<int>? saldoAwalRupiah,
    Expression<int>? alokasiPasarUangPersen,
    Expression<int>? alokasiObligasiPersen,
    Expression<int>? alokasiSahamPersen,
    Expression<int>? bulanBerjalan,
    Expression<int>? nilaiSaatIniRupiah,
    Expression<String>? skenarioAktif,
    Expression<String>? riwayatJson,
    Expression<DateTime>? diperbaruiPada,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saldoAwalRupiah != null) 'saldo_awal_rupiah': saldoAwalRupiah,
      if (alokasiPasarUangPersen != null)
        'alokasi_pasar_uang_persen': alokasiPasarUangPersen,
      if (alokasiObligasiPersen != null)
        'alokasi_obligasi_persen': alokasiObligasiPersen,
      if (alokasiSahamPersen != null)
        'alokasi_saham_persen': alokasiSahamPersen,
      if (bulanBerjalan != null) 'bulan_berjalan': bulanBerjalan,
      if (nilaiSaatIniRupiah != null)
        'nilai_saat_ini_rupiah': nilaiSaatIniRupiah,
      if (skenarioAktif != null) 'skenario_aktif': skenarioAktif,
      if (riwayatJson != null) 'riwayat_json': riwayatJson,
      if (diperbaruiPada != null) 'diperbarui_pada': diperbaruiPada,
    });
  }

  TabelSesiSandboxCompanion copyWith({
    Value<int>? id,
    Value<int>? saldoAwalRupiah,
    Value<int>? alokasiPasarUangPersen,
    Value<int>? alokasiObligasiPersen,
    Value<int>? alokasiSahamPersen,
    Value<int>? bulanBerjalan,
    Value<int>? nilaiSaatIniRupiah,
    Value<String>? skenarioAktif,
    Value<String>? riwayatJson,
    Value<DateTime>? diperbaruiPada,
  }) {
    return TabelSesiSandboxCompanion(
      id: id ?? this.id,
      saldoAwalRupiah: saldoAwalRupiah ?? this.saldoAwalRupiah,
      alokasiPasarUangPersen:
          alokasiPasarUangPersen ?? this.alokasiPasarUangPersen,
      alokasiObligasiPersen:
          alokasiObligasiPersen ?? this.alokasiObligasiPersen,
      alokasiSahamPersen: alokasiSahamPersen ?? this.alokasiSahamPersen,
      bulanBerjalan: bulanBerjalan ?? this.bulanBerjalan,
      nilaiSaatIniRupiah: nilaiSaatIniRupiah ?? this.nilaiSaatIniRupiah,
      skenarioAktif: skenarioAktif ?? this.skenarioAktif,
      riwayatJson: riwayatJson ?? this.riwayatJson,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saldoAwalRupiah.present) {
      map['saldo_awal_rupiah'] = Variable<int>(saldoAwalRupiah.value);
    }
    if (alokasiPasarUangPersen.present) {
      map['alokasi_pasar_uang_persen'] = Variable<int>(
        alokasiPasarUangPersen.value,
      );
    }
    if (alokasiObligasiPersen.present) {
      map['alokasi_obligasi_persen'] = Variable<int>(
        alokasiObligasiPersen.value,
      );
    }
    if (alokasiSahamPersen.present) {
      map['alokasi_saham_persen'] = Variable<int>(alokasiSahamPersen.value);
    }
    if (bulanBerjalan.present) {
      map['bulan_berjalan'] = Variable<int>(bulanBerjalan.value);
    }
    if (nilaiSaatIniRupiah.present) {
      map['nilai_saat_ini_rupiah'] = Variable<int>(nilaiSaatIniRupiah.value);
    }
    if (skenarioAktif.present) {
      map['skenario_aktif'] = Variable<String>(skenarioAktif.value);
    }
    if (riwayatJson.present) {
      map['riwayat_json'] = Variable<String>(riwayatJson.value);
    }
    if (diperbaruiPada.present) {
      map['diperbarui_pada'] = Variable<DateTime>(diperbaruiPada.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabelSesiSandboxCompanion(')
          ..write('id: $id, ')
          ..write('saldoAwalRupiah: $saldoAwalRupiah, ')
          ..write('alokasiPasarUangPersen: $alokasiPasarUangPersen, ')
          ..write('alokasiObligasiPersen: $alokasiObligasiPersen, ')
          ..write('alokasiSahamPersen: $alokasiSahamPersen, ')
          ..write('bulanBerjalan: $bulanBerjalan, ')
          ..write('nilaiSaatIniRupiah: $nilaiSaatIniRupiah, ')
          ..write('skenarioAktif: $skenarioAktif, ')
          ..write('riwayatJson: $riwayatJson, ')
          ..write('diperbaruiPada: $diperbaruiPada')
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
  late final $TabelAnggaranTable tabelAnggaran = $TabelAnggaranTable(this);
  late final $TabelTujuanTable tabelTujuan = $TabelTujuanTable(this);
  late final $TabelKantongTable tabelKantong = $TabelKantongTable(this);
  late final $TabelAlokasiKantongTable tabelAlokasiKantong =
      $TabelAlokasiKantongTable(this);
  late final $TabelUtangTable tabelUtang = $TabelUtangTable(this);
  late final $TabelPembayaranUtangTable tabelPembayaranUtang =
      $TabelPembayaranUtangTable(this);
  late final $TabelPenyesuaianUtangTable tabelPenyesuaianUtang =
      $TabelPenyesuaianUtangTable(this);
  late final $TabelTagihanTable tabelTagihan = $TabelTagihanTable(this);
  late final $TabelPembayaranTagihanTable tabelPembayaranTagihan =
      $TabelPembayaranTagihanTable(this);
  late final $TabelProgresPelajaranTable tabelProgresPelajaran =
      $TabelProgresPelajaranTable(this);
  late final $TabelHasilMisiTable tabelHasilMisi = $TabelHasilMisiTable(this);
  late final $TabelHasilKuisTable tabelHasilKuis = $TabelHasilKuisTable(this);
  late final $TabelPernyataanTable tabelPernyataan = $TabelPernyataanTable(
    this,
  );
  late final $TabelProfilKeuanganTable tabelProfilKeuangan =
      $TabelProfilKeuanganTable(this);
  late final $TabelHasilTesAwalTable tabelHasilTesAwal =
      $TabelHasilTesAwalTable(this);
  late final $TabelSesiSandboxTable tabelSesiSandbox = $TabelSesiSandboxTable(
    this,
  );
  late final Index idxTransaksiWaktu = Index(
    'idx_transaksi_waktu',
    'CREATE INDEX idx_transaksi_waktu ON tabel_transaksi (waktu_transaksi)',
  );
  late final Index idxTransaksiDompet = Index(
    'idx_transaksi_dompet',
    'CREATE INDEX idx_transaksi_dompet ON tabel_transaksi (dompet_id)',
  );
  late final Index idxTransaksiJenis = Index(
    'idx_transaksi_jenis',
    'CREATE INDEX idx_transaksi_jenis ON tabel_transaksi (jenis)',
  );
  late final Index idxTransaksiJenisKategori = Index(
    'idx_transaksi_jenis_kategori',
    'CREATE INDEX idx_transaksi_jenis_kategori ON tabel_transaksi (jenis, kategori_id)',
  );
  late final Index idxTransaksiWaktuId = Index(
    'idx_transaksi_waktu_id',
    'CREATE INDEX idx_transaksi_waktu_id ON tabel_transaksi (waktu_transaksi, id)',
  );
  late final Index idxTransaksiWaktuJenis = Index(
    'idx_transaksi_waktu_jenis',
    'CREATE INDEX idx_transaksi_waktu_jenis ON tabel_transaksi (waktu_transaksi, jenis)',
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
    tabelAnggaran,
    tabelTujuan,
    tabelKantong,
    tabelAlokasiKantong,
    tabelUtang,
    tabelPembayaranUtang,
    tabelPenyesuaianUtang,
    tabelTagihan,
    tabelPembayaranTagihan,
    tabelProgresPelajaran,
    tabelHasilMisi,
    tabelHasilKuis,
    tabelPernyataan,
    tabelProfilKeuangan,
    tabelHasilTesAwal,
    tabelSesiSandbox,
    idxTransaksiWaktu,
    idxTransaksiDompet,
    idxTransaksiJenis,
    idxTransaksiJenisKategori,
    idxTransaksiWaktuId,
    idxTransaksiWaktuJenis,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabel_utang',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabel_pembayaran_utang', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabel_transaksi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabel_pembayaran_utang', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabel_utang',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabel_penyesuaian_utang', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabel_tagihan',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('tabel_pembayaran_tagihan', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabel_transaksi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('tabel_pembayaran_tagihan', kind: UpdateKind.delete),
      ],
    ),
  ]);
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

  static MultiTypedResultKey<$TabelKantongTable, List<EntitasKantong>>
  _tabelKantongRefsTable(_$BasisDataFunda db) => MultiTypedResultKey.fromTable(
    db.tabelKantong,
    aliasName: $_aliasNameGenerator(
      db.tabelDompet.id,
      db.tabelKantong.dompetId,
    ),
  );

  $$TabelKantongTableProcessedTableManager get tabelKantongRefs {
    final manager = $$TabelKantongTableTableManager(
      $_db,
      $_db.tabelKantong,
    ).filter((f) => f.dompetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabelKantongRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TabelTagihanTable, List<EntitasTagihan>>
  _tabelTagihanRefsTable(_$BasisDataFunda db) => MultiTypedResultKey.fromTable(
    db.tabelTagihan,
    aliasName: $_aliasNameGenerator(
      db.tabelDompet.id,
      db.tabelTagihan.dompetId,
    ),
  );

  $$TabelTagihanTableProcessedTableManager get tabelTagihanRefs {
    final manager = $$TabelTagihanTableTableManager(
      $_db,
      $_db.tabelTagihan,
    ).filter((f) => f.dompetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabelTagihanRefsTable($_db));
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

  Expression<bool> tabelKantongRefs(
    Expression<bool> Function($$TabelKantongTableFilterComposer f) f,
  ) {
    final $$TabelKantongTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelKantong,
      getReferencedColumn: (t) => t.dompetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKantongTableFilterComposer(
            $db: $db,
            $table: $db.tabelKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tabelTagihanRefs(
    Expression<bool> Function($$TabelTagihanTableFilterComposer f) f,
  ) {
    final $$TabelTagihanTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTagihan,
      getReferencedColumn: (t) => t.dompetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTagihanTableFilterComposer(
            $db: $db,
            $table: $db.tabelTagihan,
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

  Expression<T> tabelKantongRefs<T extends Object>(
    Expression<T> Function($$TabelKantongTableAnnotationComposer a) f,
  ) {
    final $$TabelKantongTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelKantong,
      getReferencedColumn: (t) => t.dompetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKantongTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tabelTagihanRefs<T extends Object>(
    Expression<T> Function($$TabelTagihanTableAnnotationComposer a) f,
  ) {
    final $$TabelTagihanTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTagihan,
      getReferencedColumn: (t) => t.dompetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTagihanTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelTagihan,
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
            bool tabelKantongRefs,
            bool tabelTagihanRefs,
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
              ({
                transaksiDompetAsal = false,
                transaksiDompetTujuan = false,
                tabelKantongRefs = false,
                tabelTagihanRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transaksiDompetAsal) db.tabelTransaksi,
                    if (transaksiDompetTujuan) db.tabelTransaksi,
                    if (tabelKantongRefs) db.tabelKantong,
                    if (tabelTagihanRefs) db.tabelTagihan,
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
                      if (tabelKantongRefs)
                        await $_getPrefetchedData<
                          EntitasDompet,
                          $TabelDompetTable,
                          EntitasKantong
                        >(
                          currentTable: table,
                          referencedTable: $$TabelDompetTableReferences
                              ._tabelKantongRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelDompetTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelKantongRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dompetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tabelTagihanRefs)
                        await $_getPrefetchedData<
                          EntitasDompet,
                          $TabelDompetTable,
                          EntitasTagihan
                        >(
                          currentTable: table,
                          referencedTable: $$TabelDompetTableReferences
                              ._tabelTagihanRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelDompetTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelTagihanRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dompetId == item.id,
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
        bool tabelKantongRefs,
        bool tabelTagihanRefs,
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

  static MultiTypedResultKey<$TabelAnggaranTable, List<EntitasAnggaran>>
  _tabelAnggaranRefsTable(_$BasisDataFunda db) => MultiTypedResultKey.fromTable(
    db.tabelAnggaran,
    aliasName: $_aliasNameGenerator(
      db.tabelKategori.id,
      db.tabelAnggaran.kategoriId,
    ),
  );

  $$TabelAnggaranTableProcessedTableManager get tabelAnggaranRefs {
    final manager = $$TabelAnggaranTableTableManager(
      $_db,
      $_db.tabelAnggaran,
    ).filter((f) => f.kategoriId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabelAnggaranRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TabelTagihanTable, List<EntitasTagihan>>
  _tabelTagihanRefsTable(_$BasisDataFunda db) => MultiTypedResultKey.fromTable(
    db.tabelTagihan,
    aliasName: $_aliasNameGenerator(
      db.tabelKategori.id,
      db.tabelTagihan.kategoriId,
    ),
  );

  $$TabelTagihanTableProcessedTableManager get tabelTagihanRefs {
    final manager = $$TabelTagihanTableTableManager(
      $_db,
      $_db.tabelTagihan,
    ).filter((f) => f.kategoriId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabelTagihanRefsTable($_db));
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

  Expression<bool> tabelAnggaranRefs(
    Expression<bool> Function($$TabelAnggaranTableFilterComposer f) f,
  ) {
    final $$TabelAnggaranTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelAnggaran,
      getReferencedColumn: (t) => t.kategoriId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelAnggaranTableFilterComposer(
            $db: $db,
            $table: $db.tabelAnggaran,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tabelTagihanRefs(
    Expression<bool> Function($$TabelTagihanTableFilterComposer f) f,
  ) {
    final $$TabelTagihanTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTagihan,
      getReferencedColumn: (t) => t.kategoriId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTagihanTableFilterComposer(
            $db: $db,
            $table: $db.tabelTagihan,
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

  Expression<T> tabelAnggaranRefs<T extends Object>(
    Expression<T> Function($$TabelAnggaranTableAnnotationComposer a) f,
  ) {
    final $$TabelAnggaranTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelAnggaran,
      getReferencedColumn: (t) => t.kategoriId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelAnggaranTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelAnggaran,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tabelTagihanRefs<T extends Object>(
    Expression<T> Function($$TabelTagihanTableAnnotationComposer a) f,
  ) {
    final $$TabelTagihanTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelTagihan,
      getReferencedColumn: (t) => t.kategoriId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTagihanTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelTagihan,
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
          PrefetchHooks Function({
            bool tabelTransaksiRefs,
            bool tabelAnggaranRefs,
            bool tabelTagihanRefs,
          })
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
          prefetchHooksCallback:
              ({
                tabelTransaksiRefs = false,
                tabelAnggaranRefs = false,
                tabelTagihanRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tabelTransaksiRefs) db.tabelTransaksi,
                    if (tabelAnggaranRefs) db.tabelAnggaran,
                    if (tabelTagihanRefs) db.tabelTagihan,
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.kategoriId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tabelAnggaranRefs)
                        await $_getPrefetchedData<
                          EntitasKategori,
                          $TabelKategoriTable,
                          EntitasAnggaran
                        >(
                          currentTable: table,
                          referencedTable: $$TabelKategoriTableReferences
                              ._tabelAnggaranRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelKategoriTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelAnggaranRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.kategoriId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tabelTagihanRefs)
                        await $_getPrefetchedData<
                          EntitasKategori,
                          $TabelKategoriTable,
                          EntitasTagihan
                        >(
                          currentTable: table,
                          referencedTable: $$TabelKategoriTableReferences
                              ._tabelTagihanRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelKategoriTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelTagihanRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.kategoriId == item.id,
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
      PrefetchHooks Function({
        bool tabelTransaksiRefs,
        bool tabelAnggaranRefs,
        bool tabelTagihanRefs,
      })
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

  static MultiTypedResultKey<
    $TabelPembayaranUtangTable,
    List<EntitasPembayaranUtang>
  >
  _tabelPembayaranUtangRefsTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelPembayaranUtang,
        aliasName: $_aliasNameGenerator(
          db.tabelTransaksi.id,
          db.tabelPembayaranUtang.transaksiId,
        ),
      );

  $$TabelPembayaranUtangTableProcessedTableManager
  get tabelPembayaranUtangRefs {
    final manager = $$TabelPembayaranUtangTableTableManager(
      $_db,
      $_db.tabelPembayaranUtang,
    ).filter((f) => f.transaksiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tabelPembayaranUtangRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TabelPembayaranTagihanTable,
    List<EntitasPembayaranTagihan>
  >
  _tabelPembayaranTagihanRefsTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelPembayaranTagihan,
        aliasName: $_aliasNameGenerator(
          db.tabelTransaksi.id,
          db.tabelPembayaranTagihan.transaksiId,
        ),
      );

  $$TabelPembayaranTagihanTableProcessedTableManager
  get tabelPembayaranTagihanRefs {
    final manager = $$TabelPembayaranTagihanTableTableManager(
      $_db,
      $_db.tabelPembayaranTagihan,
    ).filter((f) => f.transaksiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tabelPembayaranTagihanRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  Expression<bool> tabelPembayaranUtangRefs(
    Expression<bool> Function($$TabelPembayaranUtangTableFilterComposer f) f,
  ) {
    final $$TabelPembayaranUtangTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelPembayaranUtang,
      getReferencedColumn: (t) => t.transaksiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelPembayaranUtangTableFilterComposer(
            $db: $db,
            $table: $db.tabelPembayaranUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tabelPembayaranTagihanRefs(
    Expression<bool> Function($$TabelPembayaranTagihanTableFilterComposer f) f,
  ) {
    final $$TabelPembayaranTagihanTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPembayaranTagihan,
          getReferencedColumn: (t) => t.transaksiId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPembayaranTagihanTableFilterComposer(
                $db: $db,
                $table: $db.tabelPembayaranTagihan,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
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

  Expression<T> tabelPembayaranUtangRefs<T extends Object>(
    Expression<T> Function($$TabelPembayaranUtangTableAnnotationComposer a) f,
  ) {
    final $$TabelPembayaranUtangTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPembayaranUtang,
          getReferencedColumn: (t) => t.transaksiId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPembayaranUtangTableAnnotationComposer(
                $db: $db,
                $table: $db.tabelPembayaranUtang,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tabelPembayaranTagihanRefs<T extends Object>(
    Expression<T> Function($$TabelPembayaranTagihanTableAnnotationComposer a) f,
  ) {
    final $$TabelPembayaranTagihanTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPembayaranTagihan,
          getReferencedColumn: (t) => t.transaksiId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPembayaranTagihanTableAnnotationComposer(
                $db: $db,
                $table: $db.tabelPembayaranTagihan,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
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
            bool tabelPembayaranUtangRefs,
            bool tabelPembayaranTagihanRefs,
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
              ({
                dompetId = false,
                dompetTujuanId = false,
                kategoriId = false,
                tabelPembayaranUtangRefs = false,
                tabelPembayaranTagihanRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tabelPembayaranUtangRefs) db.tabelPembayaranUtang,
                    if (tabelPembayaranTagihanRefs) db.tabelPembayaranTagihan,
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
                    return [
                      if (tabelPembayaranUtangRefs)
                        await $_getPrefetchedData<
                          EntitasTransaksi,
                          $TabelTransaksiTable,
                          EntitasPembayaranUtang
                        >(
                          currentTable: table,
                          referencedTable: $$TabelTransaksiTableReferences
                              ._tabelPembayaranUtangRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelTransaksiTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelPembayaranUtangRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transaksiId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tabelPembayaranTagihanRefs)
                        await $_getPrefetchedData<
                          EntitasTransaksi,
                          $TabelTransaksiTable,
                          EntitasPembayaranTagihan
                        >(
                          currentTable: table,
                          referencedTable: $$TabelTransaksiTableReferences
                              ._tabelPembayaranTagihanRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelTransaksiTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelPembayaranTagihanRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transaksiId == item.id,
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
        bool tabelPembayaranUtangRefs,
        bool tabelPembayaranTagihanRefs,
      })
    >;
typedef $$TabelAnggaranTableCreateCompanionBuilder =
    TabelAnggaranCompanion Function({
      required String id,
      required int tahun,
      required int bulan,
      required String kategoriId,
      required int batasRupiah,
      required DateTime dibuatPada,
      required DateTime diubahPada,
      Value<int> rowid,
    });
typedef $$TabelAnggaranTableUpdateCompanionBuilder =
    TabelAnggaranCompanion Function({
      Value<String> id,
      Value<int> tahun,
      Value<int> bulan,
      Value<String> kategoriId,
      Value<int> batasRupiah,
      Value<DateTime> dibuatPada,
      Value<DateTime> diubahPada,
      Value<int> rowid,
    });

final class $$TabelAnggaranTableReferences
    extends
        BaseReferences<_$BasisDataFunda, $TabelAnggaranTable, EntitasAnggaran> {
  $$TabelAnggaranTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TabelKategoriTable _kategoriIdTable(_$BasisDataFunda db) =>
      db.tabelKategori.createAlias(
        $_aliasNameGenerator(db.tabelAnggaran.kategoriId, db.tabelKategori.id),
      );

  $$TabelKategoriTableProcessedTableManager get kategoriId {
    final $_column = $_itemColumn<String>('kategori_id')!;

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

class $$TabelAnggaranTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelAnggaranTable> {
  $$TabelAnggaranTableFilterComposer({
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

  ColumnFilters<int> get tahun => $composableBuilder(
    column: $table.tahun,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bulan => $composableBuilder(
    column: $table.bulan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batasRupiah => $composableBuilder(
    column: $table.batasRupiah,
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

class $$TabelAnggaranTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelAnggaranTable> {
  $$TabelAnggaranTableOrderingComposer({
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

  ColumnOrderings<int> get tahun => $composableBuilder(
    column: $table.tahun,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bulan => $composableBuilder(
    column: $table.bulan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batasRupiah => $composableBuilder(
    column: $table.batasRupiah,
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

class $$TabelAnggaranTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelAnggaranTable> {
  $$TabelAnggaranTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tahun =>
      $composableBuilder(column: $table.tahun, builder: (column) => column);

  GeneratedColumn<int> get bulan =>
      $composableBuilder(column: $table.bulan, builder: (column) => column);

  GeneratedColumn<int> get batasRupiah => $composableBuilder(
    column: $table.batasRupiah,
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

class $$TabelAnggaranTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelAnggaranTable,
          EntitasAnggaran,
          $$TabelAnggaranTableFilterComposer,
          $$TabelAnggaranTableOrderingComposer,
          $$TabelAnggaranTableAnnotationComposer,
          $$TabelAnggaranTableCreateCompanionBuilder,
          $$TabelAnggaranTableUpdateCompanionBuilder,
          (EntitasAnggaran, $$TabelAnggaranTableReferences),
          EntitasAnggaran,
          PrefetchHooks Function({bool kategoriId})
        > {
  $$TabelAnggaranTableTableManager(
    _$BasisDataFunda db,
    $TabelAnggaranTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelAnggaranTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelAnggaranTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelAnggaranTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> tahun = const Value.absent(),
                Value<int> bulan = const Value.absent(),
                Value<String> kategoriId = const Value.absent(),
                Value<int> batasRupiah = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<DateTime> diubahPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelAnggaranCompanion(
                id: id,
                tahun: tahun,
                bulan: bulan,
                kategoriId: kategoriId,
                batasRupiah: batasRupiah,
                dibuatPada: dibuatPada,
                diubahPada: diubahPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int tahun,
                required int bulan,
                required String kategoriId,
                required int batasRupiah,
                required DateTime dibuatPada,
                required DateTime diubahPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelAnggaranCompanion.insert(
                id: id,
                tahun: tahun,
                bulan: bulan,
                kategoriId: kategoriId,
                batasRupiah: batasRupiah,
                dibuatPada: dibuatPada,
                diubahPada: diubahPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelAnggaranTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({kategoriId = false}) {
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
                    if (kategoriId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.kategoriId,
                                referencedTable: $$TabelAnggaranTableReferences
                                    ._kategoriIdTable(db),
                                referencedColumn: $$TabelAnggaranTableReferences
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

typedef $$TabelAnggaranTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelAnggaranTable,
      EntitasAnggaran,
      $$TabelAnggaranTableFilterComposer,
      $$TabelAnggaranTableOrderingComposer,
      $$TabelAnggaranTableAnnotationComposer,
      $$TabelAnggaranTableCreateCompanionBuilder,
      $$TabelAnggaranTableUpdateCompanionBuilder,
      (EntitasAnggaran, $$TabelAnggaranTableReferences),
      EntitasAnggaran,
      PrefetchHooks Function({bool kategoriId})
    >;
typedef $$TabelTujuanTableCreateCompanionBuilder =
    TabelTujuanCompanion Function({
      required String id,
      required String nama,
      required String jenis,
      required int targetRupiah,
      Value<DateTime?> tenggat,
      required String ikon,
      required String warna,
      required String status,
      required DateTime dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelTujuanTableUpdateCompanionBuilder =
    TabelTujuanCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> jenis,
      Value<int> targetRupiah,
      Value<DateTime?> tenggat,
      Value<String> ikon,
      Value<String> warna,
      Value<String> status,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelTujuanTableReferences
    extends BaseReferences<_$BasisDataFunda, $TabelTujuanTable, EntitasTujuan> {
  $$TabelTujuanTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TabelKantongTable, List<EntitasKantong>>
  _tabelKantongRefsTable(_$BasisDataFunda db) => MultiTypedResultKey.fromTable(
    db.tabelKantong,
    aliasName: $_aliasNameGenerator(
      db.tabelTujuan.id,
      db.tabelKantong.tujuanId,
    ),
  );

  $$TabelKantongTableProcessedTableManager get tabelKantongRefs {
    final manager = $$TabelKantongTableTableManager(
      $_db,
      $_db.tabelKantong,
    ).filter((f) => f.tujuanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabelKantongRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TabelTujuanTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelTujuanTable> {
  $$TabelTujuanTableFilterComposer({
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

  ColumnFilters<int> get targetRupiah => $composableBuilder(
    column: $table.targetRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tenggat => $composableBuilder(
    column: $table.tenggat,
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tabelKantongRefs(
    Expression<bool> Function($$TabelKantongTableFilterComposer f) f,
  ) {
    final $$TabelKantongTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelKantong,
      getReferencedColumn: (t) => t.tujuanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKantongTableFilterComposer(
            $db: $db,
            $table: $db.tabelKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TabelTujuanTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelTujuanTable> {
  $$TabelTujuanTableOrderingComposer({
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

  ColumnOrderings<int> get targetRupiah => $composableBuilder(
    column: $table.targetRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tenggat => $composableBuilder(
    column: $table.tenggat,
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelTujuanTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelTujuanTable> {
  $$TabelTujuanTableAnnotationComposer({
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

  GeneratedColumn<int> get targetRupiah => $composableBuilder(
    column: $table.targetRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tenggat =>
      $composableBuilder(column: $table.tenggat, builder: (column) => column);

  GeneratedColumn<String> get ikon =>
      $composableBuilder(column: $table.ikon, builder: (column) => column);

  GeneratedColumn<String> get warna =>
      $composableBuilder(column: $table.warna, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  Expression<T> tabelKantongRefs<T extends Object>(
    Expression<T> Function($$TabelKantongTableAnnotationComposer a) f,
  ) {
    final $$TabelKantongTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelKantong,
      getReferencedColumn: (t) => t.tujuanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKantongTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TabelTujuanTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelTujuanTable,
          EntitasTujuan,
          $$TabelTujuanTableFilterComposer,
          $$TabelTujuanTableOrderingComposer,
          $$TabelTujuanTableAnnotationComposer,
          $$TabelTujuanTableCreateCompanionBuilder,
          $$TabelTujuanTableUpdateCompanionBuilder,
          (EntitasTujuan, $$TabelTujuanTableReferences),
          EntitasTujuan,
          PrefetchHooks Function({bool tabelKantongRefs})
        > {
  $$TabelTujuanTableTableManager(_$BasisDataFunda db, $TabelTujuanTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelTujuanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelTujuanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelTujuanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> jenis = const Value.absent(),
                Value<int> targetRupiah = const Value.absent(),
                Value<DateTime?> tenggat = const Value.absent(),
                Value<String> ikon = const Value.absent(),
                Value<String> warna = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelTujuanCompanion(
                id: id,
                nama: nama,
                jenis: jenis,
                targetRupiah: targetRupiah,
                tenggat: tenggat,
                ikon: ikon,
                warna: warna,
                status: status,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String jenis,
                required int targetRupiah,
                Value<DateTime?> tenggat = const Value.absent(),
                required String ikon,
                required String warna,
                required String status,
                required DateTime dibuatPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelTujuanCompanion.insert(
                id: id,
                nama: nama,
                jenis: jenis,
                targetRupiah: targetRupiah,
                tenggat: tenggat,
                ikon: ikon,
                warna: warna,
                status: status,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelTujuanTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tabelKantongRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tabelKantongRefs) db.tabelKantong],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tabelKantongRefs)
                    await $_getPrefetchedData<
                      EntitasTujuan,
                      $TabelTujuanTable,
                      EntitasKantong
                    >(
                      currentTable: table,
                      referencedTable: $$TabelTujuanTableReferences
                          ._tabelKantongRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TabelTujuanTableReferences(
                            db,
                            table,
                            p0,
                          ).tabelKantongRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tujuanId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TabelTujuanTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelTujuanTable,
      EntitasTujuan,
      $$TabelTujuanTableFilterComposer,
      $$TabelTujuanTableOrderingComposer,
      $$TabelTujuanTableAnnotationComposer,
      $$TabelTujuanTableCreateCompanionBuilder,
      $$TabelTujuanTableUpdateCompanionBuilder,
      (EntitasTujuan, $$TabelTujuanTableReferences),
      EntitasTujuan,
      PrefetchHooks Function({bool tabelKantongRefs})
    >;
typedef $$TabelKantongTableCreateCompanionBuilder =
    TabelKantongCompanion Function({
      required String id,
      required String dompetId,
      Value<String?> tujuanId,
      required String nama,
      required String ikon,
      required String warna,
      Value<bool> diarsipkan,
      required DateTime dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelKantongTableUpdateCompanionBuilder =
    TabelKantongCompanion Function({
      Value<String> id,
      Value<String> dompetId,
      Value<String?> tujuanId,
      Value<String> nama,
      Value<String> ikon,
      Value<String> warna,
      Value<bool> diarsipkan,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelKantongTableReferences
    extends
        BaseReferences<_$BasisDataFunda, $TabelKantongTable, EntitasKantong> {
  $$TabelKantongTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TabelDompetTable _dompetIdTable(_$BasisDataFunda db) =>
      db.tabelDompet.createAlias(
        $_aliasNameGenerator(db.tabelKantong.dompetId, db.tabelDompet.id),
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

  static $TabelTujuanTable _tujuanIdTable(_$BasisDataFunda db) =>
      db.tabelTujuan.createAlias(
        $_aliasNameGenerator(db.tabelKantong.tujuanId, db.tabelTujuan.id),
      );

  $$TabelTujuanTableProcessedTableManager? get tujuanId {
    final $_column = $_itemColumn<String>('tujuan_id');
    if ($_column == null) return null;
    final manager = $$TabelTujuanTableTableManager(
      $_db,
      $_db.tabelTujuan,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tujuanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TabelAlokasiKantongTable,
    List<EntitasAlokasiKantong>
  >
  _tabelAlokasiKantongRefsTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelAlokasiKantong,
        aliasName: $_aliasNameGenerator(
          db.tabelKantong.id,
          db.tabelAlokasiKantong.kantongId,
        ),
      );

  $$TabelAlokasiKantongTableProcessedTableManager get tabelAlokasiKantongRefs {
    final manager = $$TabelAlokasiKantongTableTableManager(
      $_db,
      $_db.tabelAlokasiKantong,
    ).filter((f) => f.kantongId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tabelAlokasiKantongRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TabelKantongTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelKantongTable> {
  $$TabelKantongTableFilterComposer({
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

  ColumnFilters<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warna => $composableBuilder(
    column: $table.warna,
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

  $$TabelTujuanTableFilterComposer get tujuanId {
    final $$TabelTujuanTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tujuanId,
      referencedTable: $db.tabelTujuan,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTujuanTableFilterComposer(
            $db: $db,
            $table: $db.tabelTujuan,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tabelAlokasiKantongRefs(
    Expression<bool> Function($$TabelAlokasiKantongTableFilterComposer f) f,
  ) {
    final $$TabelAlokasiKantongTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelAlokasiKantong,
      getReferencedColumn: (t) => t.kantongId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelAlokasiKantongTableFilterComposer(
            $db: $db,
            $table: $db.tabelAlokasiKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TabelKantongTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelKantongTable> {
  $$TabelKantongTableOrderingComposer({
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

  ColumnOrderings<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warna => $composableBuilder(
    column: $table.warna,
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

  $$TabelTujuanTableOrderingComposer get tujuanId {
    final $$TabelTujuanTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tujuanId,
      referencedTable: $db.tabelTujuan,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTujuanTableOrderingComposer(
            $db: $db,
            $table: $db.tabelTujuan,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelKantongTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelKantongTable> {
  $$TabelKantongTableAnnotationComposer({
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

  GeneratedColumn<String> get ikon =>
      $composableBuilder(column: $table.ikon, builder: (column) => column);

  GeneratedColumn<String> get warna =>
      $composableBuilder(column: $table.warna, builder: (column) => column);

  GeneratedColumn<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
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

  $$TabelTujuanTableAnnotationComposer get tujuanId {
    final $$TabelTujuanTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tujuanId,
      referencedTable: $db.tabelTujuan,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTujuanTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelTujuan,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tabelAlokasiKantongRefs<T extends Object>(
    Expression<T> Function($$TabelAlokasiKantongTableAnnotationComposer a) f,
  ) {
    final $$TabelAlokasiKantongTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelAlokasiKantong,
          getReferencedColumn: (t) => t.kantongId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelAlokasiKantongTableAnnotationComposer(
                $db: $db,
                $table: $db.tabelAlokasiKantong,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TabelKantongTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelKantongTable,
          EntitasKantong,
          $$TabelKantongTableFilterComposer,
          $$TabelKantongTableOrderingComposer,
          $$TabelKantongTableAnnotationComposer,
          $$TabelKantongTableCreateCompanionBuilder,
          $$TabelKantongTableUpdateCompanionBuilder,
          (EntitasKantong, $$TabelKantongTableReferences),
          EntitasKantong,
          PrefetchHooks Function({
            bool dompetId,
            bool tujuanId,
            bool tabelAlokasiKantongRefs,
          })
        > {
  $$TabelKantongTableTableManager(_$BasisDataFunda db, $TabelKantongTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelKantongTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelKantongTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelKantongTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dompetId = const Value.absent(),
                Value<String?> tujuanId = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> ikon = const Value.absent(),
                Value<String> warna = const Value.absent(),
                Value<bool> diarsipkan = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelKantongCompanion(
                id: id,
                dompetId: dompetId,
                tujuanId: tujuanId,
                nama: nama,
                ikon: ikon,
                warna: warna,
                diarsipkan: diarsipkan,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dompetId,
                Value<String?> tujuanId = const Value.absent(),
                required String nama,
                required String ikon,
                required String warna,
                Value<bool> diarsipkan = const Value.absent(),
                required DateTime dibuatPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelKantongCompanion.insert(
                id: id,
                dompetId: dompetId,
                tujuanId: tujuanId,
                nama: nama,
                ikon: ikon,
                warna: warna,
                diarsipkan: diarsipkan,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelKantongTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                dompetId = false,
                tujuanId = false,
                tabelAlokasiKantongRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tabelAlokasiKantongRefs) db.tabelAlokasiKantong,
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
                        if (dompetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dompetId,
                                    referencedTable:
                                        $$TabelKantongTableReferences
                                            ._dompetIdTable(db),
                                    referencedColumn:
                                        $$TabelKantongTableReferences
                                            ._dompetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (tujuanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tujuanId,
                                    referencedTable:
                                        $$TabelKantongTableReferences
                                            ._tujuanIdTable(db),
                                    referencedColumn:
                                        $$TabelKantongTableReferences
                                            ._tujuanIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tabelAlokasiKantongRefs)
                        await $_getPrefetchedData<
                          EntitasKantong,
                          $TabelKantongTable,
                          EntitasAlokasiKantong
                        >(
                          currentTable: table,
                          referencedTable: $$TabelKantongTableReferences
                              ._tabelAlokasiKantongRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelKantongTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelAlokasiKantongRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.kantongId == item.id,
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

typedef $$TabelKantongTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelKantongTable,
      EntitasKantong,
      $$TabelKantongTableFilterComposer,
      $$TabelKantongTableOrderingComposer,
      $$TabelKantongTableAnnotationComposer,
      $$TabelKantongTableCreateCompanionBuilder,
      $$TabelKantongTableUpdateCompanionBuilder,
      (EntitasKantong, $$TabelKantongTableReferences),
      EntitasKantong,
      PrefetchHooks Function({
        bool dompetId,
        bool tujuanId,
        bool tabelAlokasiKantongRefs,
      })
    >;
typedef $$TabelAlokasiKantongTableCreateCompanionBuilder =
    TabelAlokasiKantongCompanion Function({
      required String id,
      required String kantongId,
      required String jenis,
      required int jumlahRupiah,
      Value<String?> catatan,
      required DateTime waktu,
      required DateTime dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelAlokasiKantongTableUpdateCompanionBuilder =
    TabelAlokasiKantongCompanion Function({
      Value<String> id,
      Value<String> kantongId,
      Value<String> jenis,
      Value<int> jumlahRupiah,
      Value<String?> catatan,
      Value<DateTime> waktu,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelAlokasiKantongTableReferences
    extends
        BaseReferences<
          _$BasisDataFunda,
          $TabelAlokasiKantongTable,
          EntitasAlokasiKantong
        > {
  $$TabelAlokasiKantongTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TabelKantongTable _kantongIdTable(_$BasisDataFunda db) =>
      db.tabelKantong.createAlias(
        $_aliasNameGenerator(
          db.tabelAlokasiKantong.kantongId,
          db.tabelKantong.id,
        ),
      );

  $$TabelKantongTableProcessedTableManager get kantongId {
    final $_column = $_itemColumn<String>('kantong_id')!;

    final manager = $$TabelKantongTableTableManager(
      $_db,
      $_db.tabelKantong,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_kantongIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TabelAlokasiKantongTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelAlokasiKantongTable> {
  $$TabelAlokasiKantongTableFilterComposer({
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

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get waktu => $composableBuilder(
    column: $table.waktu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  $$TabelKantongTableFilterComposer get kantongId {
    final $$TabelKantongTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.kantongId,
      referencedTable: $db.tabelKantong,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKantongTableFilterComposer(
            $db: $db,
            $table: $db.tabelKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelAlokasiKantongTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelAlokasiKantongTable> {
  $$TabelAlokasiKantongTableOrderingComposer({
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

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get waktu => $composableBuilder(
    column: $table.waktu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );

  $$TabelKantongTableOrderingComposer get kantongId {
    final $$TabelKantongTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.kantongId,
      referencedTable: $db.tabelKantong,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKantongTableOrderingComposer(
            $db: $db,
            $table: $db.tabelKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelAlokasiKantongTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelAlokasiKantongTable> {
  $$TabelAlokasiKantongTableAnnotationComposer({
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

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<DateTime> get waktu =>
      $composableBuilder(column: $table.waktu, builder: (column) => column);

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  $$TabelKantongTableAnnotationComposer get kantongId {
    final $$TabelKantongTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.kantongId,
      referencedTable: $db.tabelKantong,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelKantongTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelKantong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelAlokasiKantongTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelAlokasiKantongTable,
          EntitasAlokasiKantong,
          $$TabelAlokasiKantongTableFilterComposer,
          $$TabelAlokasiKantongTableOrderingComposer,
          $$TabelAlokasiKantongTableAnnotationComposer,
          $$TabelAlokasiKantongTableCreateCompanionBuilder,
          $$TabelAlokasiKantongTableUpdateCompanionBuilder,
          (EntitasAlokasiKantong, $$TabelAlokasiKantongTableReferences),
          EntitasAlokasiKantong,
          PrefetchHooks Function({bool kantongId})
        > {
  $$TabelAlokasiKantongTableTableManager(
    _$BasisDataFunda db,
    $TabelAlokasiKantongTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelAlokasiKantongTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelAlokasiKantongTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TabelAlokasiKantongTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kantongId = const Value.absent(),
                Value<String> jenis = const Value.absent(),
                Value<int> jumlahRupiah = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<DateTime> waktu = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelAlokasiKantongCompanion(
                id: id,
                kantongId: kantongId,
                jenis: jenis,
                jumlahRupiah: jumlahRupiah,
                catatan: catatan,
                waktu: waktu,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kantongId,
                required String jenis,
                required int jumlahRupiah,
                Value<String?> catatan = const Value.absent(),
                required DateTime waktu,
                required DateTime dibuatPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelAlokasiKantongCompanion.insert(
                id: id,
                kantongId: kantongId,
                jenis: jenis,
                jumlahRupiah: jumlahRupiah,
                catatan: catatan,
                waktu: waktu,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelAlokasiKantongTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({kantongId = false}) {
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
                    if (kantongId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.kantongId,
                                referencedTable:
                                    $$TabelAlokasiKantongTableReferences
                                        ._kantongIdTable(db),
                                referencedColumn:
                                    $$TabelAlokasiKantongTableReferences
                                        ._kantongIdTable(db)
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

typedef $$TabelAlokasiKantongTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelAlokasiKantongTable,
      EntitasAlokasiKantong,
      $$TabelAlokasiKantongTableFilterComposer,
      $$TabelAlokasiKantongTableOrderingComposer,
      $$TabelAlokasiKantongTableAnnotationComposer,
      $$TabelAlokasiKantongTableCreateCompanionBuilder,
      $$TabelAlokasiKantongTableUpdateCompanionBuilder,
      (EntitasAlokasiKantong, $$TabelAlokasiKantongTableReferences),
      EntitasAlokasiKantong,
      PrefetchHooks Function({bool kantongId})
    >;
typedef $$TabelUtangTableCreateCompanionBuilder =
    TabelUtangCompanion Function({
      required String id,
      required String nama,
      required String jenis,
      Value<String?> pemberi,
      required int sisaAwalRupiah,
      Value<int?> pokokAwalRupiah,
      required String jenisBunga,
      Value<int> bungaBasisPoinPerTahun,
      Value<int?> tenorBulan,
      Value<int> cicilanBulananRupiah,
      Value<int?> tanggalJatuhTempoBulanan,
      Value<DateTime?> tanggalMulai,
      Value<String> status,
      required DateTime dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelUtangTableUpdateCompanionBuilder =
    TabelUtangCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> jenis,
      Value<String?> pemberi,
      Value<int> sisaAwalRupiah,
      Value<int?> pokokAwalRupiah,
      Value<String> jenisBunga,
      Value<int> bungaBasisPoinPerTahun,
      Value<int?> tenorBulan,
      Value<int> cicilanBulananRupiah,
      Value<int?> tanggalJatuhTempoBulanan,
      Value<DateTime?> tanggalMulai,
      Value<String> status,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelUtangTableReferences
    extends BaseReferences<_$BasisDataFunda, $TabelUtangTable, EntitasUtang> {
  $$TabelUtangTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $TabelPembayaranUtangTable,
    List<EntitasPembayaranUtang>
  >
  _tabelPembayaranUtangRefsTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelPembayaranUtang,
        aliasName: $_aliasNameGenerator(
          db.tabelUtang.id,
          db.tabelPembayaranUtang.utangId,
        ),
      );

  $$TabelPembayaranUtangTableProcessedTableManager
  get tabelPembayaranUtangRefs {
    final manager = $$TabelPembayaranUtangTableTableManager(
      $_db,
      $_db.tabelPembayaranUtang,
    ).filter((f) => f.utangId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tabelPembayaranUtangRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TabelPenyesuaianUtangTable,
    List<EntitasPenyesuaianUtang>
  >
  _tabelPenyesuaianUtangRefsTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelPenyesuaianUtang,
        aliasName: $_aliasNameGenerator(
          db.tabelUtang.id,
          db.tabelPenyesuaianUtang.utangId,
        ),
      );

  $$TabelPenyesuaianUtangTableProcessedTableManager
  get tabelPenyesuaianUtangRefs {
    final manager = $$TabelPenyesuaianUtangTableTableManager(
      $_db,
      $_db.tabelPenyesuaianUtang,
    ).filter((f) => f.utangId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tabelPenyesuaianUtangRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TabelUtangTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelUtangTable> {
  $$TabelUtangTableFilterComposer({
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

  ColumnFilters<String> get pemberi => $composableBuilder(
    column: $table.pemberi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sisaAwalRupiah => $composableBuilder(
    column: $table.sisaAwalRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pokokAwalRupiah => $composableBuilder(
    column: $table.pokokAwalRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jenisBunga => $composableBuilder(
    column: $table.jenisBunga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bungaBasisPoinPerTahun => $composableBuilder(
    column: $table.bungaBasisPoinPerTahun,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tenorBulan => $composableBuilder(
    column: $table.tenorBulan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicilanBulananRupiah => $composableBuilder(
    column: $table.cicilanBulananRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tanggalJatuhTempoBulanan => $composableBuilder(
    column: $table.tanggalJatuhTempoBulanan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggalMulai => $composableBuilder(
    column: $table.tanggalMulai,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tabelPembayaranUtangRefs(
    Expression<bool> Function($$TabelPembayaranUtangTableFilterComposer f) f,
  ) {
    final $$TabelPembayaranUtangTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tabelPembayaranUtang,
      getReferencedColumn: (t) => t.utangId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelPembayaranUtangTableFilterComposer(
            $db: $db,
            $table: $db.tabelPembayaranUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tabelPenyesuaianUtangRefs(
    Expression<bool> Function($$TabelPenyesuaianUtangTableFilterComposer f) f,
  ) {
    final $$TabelPenyesuaianUtangTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPenyesuaianUtang,
          getReferencedColumn: (t) => t.utangId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPenyesuaianUtangTableFilterComposer(
                $db: $db,
                $table: $db.tabelPenyesuaianUtang,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TabelUtangTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelUtangTable> {
  $$TabelUtangTableOrderingComposer({
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

  ColumnOrderings<String> get pemberi => $composableBuilder(
    column: $table.pemberi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sisaAwalRupiah => $composableBuilder(
    column: $table.sisaAwalRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pokokAwalRupiah => $composableBuilder(
    column: $table.pokokAwalRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jenisBunga => $composableBuilder(
    column: $table.jenisBunga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bungaBasisPoinPerTahun => $composableBuilder(
    column: $table.bungaBasisPoinPerTahun,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tenorBulan => $composableBuilder(
    column: $table.tenorBulan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicilanBulananRupiah => $composableBuilder(
    column: $table.cicilanBulananRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tanggalJatuhTempoBulanan => $composableBuilder(
    column: $table.tanggalJatuhTempoBulanan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggalMulai => $composableBuilder(
    column: $table.tanggalMulai,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelUtangTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelUtangTable> {
  $$TabelUtangTableAnnotationComposer({
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

  GeneratedColumn<String> get pemberi =>
      $composableBuilder(column: $table.pemberi, builder: (column) => column);

  GeneratedColumn<int> get sisaAwalRupiah => $composableBuilder(
    column: $table.sisaAwalRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pokokAwalRupiah => $composableBuilder(
    column: $table.pokokAwalRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jenisBunga => $composableBuilder(
    column: $table.jenisBunga,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bungaBasisPoinPerTahun => $composableBuilder(
    column: $table.bungaBasisPoinPerTahun,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tenorBulan => $composableBuilder(
    column: $table.tenorBulan,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cicilanBulananRupiah => $composableBuilder(
    column: $table.cicilanBulananRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tanggalJatuhTempoBulanan => $composableBuilder(
    column: $table.tanggalJatuhTempoBulanan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tanggalMulai => $composableBuilder(
    column: $table.tanggalMulai,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  Expression<T> tabelPembayaranUtangRefs<T extends Object>(
    Expression<T> Function($$TabelPembayaranUtangTableAnnotationComposer a) f,
  ) {
    final $$TabelPembayaranUtangTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPembayaranUtang,
          getReferencedColumn: (t) => t.utangId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPembayaranUtangTableAnnotationComposer(
                $db: $db,
                $table: $db.tabelPembayaranUtang,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tabelPenyesuaianUtangRefs<T extends Object>(
    Expression<T> Function($$TabelPenyesuaianUtangTableAnnotationComposer a) f,
  ) {
    final $$TabelPenyesuaianUtangTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPenyesuaianUtang,
          getReferencedColumn: (t) => t.utangId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPenyesuaianUtangTableAnnotationComposer(
                $db: $db,
                $table: $db.tabelPenyesuaianUtang,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TabelUtangTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelUtangTable,
          EntitasUtang,
          $$TabelUtangTableFilterComposer,
          $$TabelUtangTableOrderingComposer,
          $$TabelUtangTableAnnotationComposer,
          $$TabelUtangTableCreateCompanionBuilder,
          $$TabelUtangTableUpdateCompanionBuilder,
          (EntitasUtang, $$TabelUtangTableReferences),
          EntitasUtang,
          PrefetchHooks Function({
            bool tabelPembayaranUtangRefs,
            bool tabelPenyesuaianUtangRefs,
          })
        > {
  $$TabelUtangTableTableManager(_$BasisDataFunda db, $TabelUtangTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelUtangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelUtangTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelUtangTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> jenis = const Value.absent(),
                Value<String?> pemberi = const Value.absent(),
                Value<int> sisaAwalRupiah = const Value.absent(),
                Value<int?> pokokAwalRupiah = const Value.absent(),
                Value<String> jenisBunga = const Value.absent(),
                Value<int> bungaBasisPoinPerTahun = const Value.absent(),
                Value<int?> tenorBulan = const Value.absent(),
                Value<int> cicilanBulananRupiah = const Value.absent(),
                Value<int?> tanggalJatuhTempoBulanan = const Value.absent(),
                Value<DateTime?> tanggalMulai = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelUtangCompanion(
                id: id,
                nama: nama,
                jenis: jenis,
                pemberi: pemberi,
                sisaAwalRupiah: sisaAwalRupiah,
                pokokAwalRupiah: pokokAwalRupiah,
                jenisBunga: jenisBunga,
                bungaBasisPoinPerTahun: bungaBasisPoinPerTahun,
                tenorBulan: tenorBulan,
                cicilanBulananRupiah: cicilanBulananRupiah,
                tanggalJatuhTempoBulanan: tanggalJatuhTempoBulanan,
                tanggalMulai: tanggalMulai,
                status: status,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String jenis,
                Value<String?> pemberi = const Value.absent(),
                required int sisaAwalRupiah,
                Value<int?> pokokAwalRupiah = const Value.absent(),
                required String jenisBunga,
                Value<int> bungaBasisPoinPerTahun = const Value.absent(),
                Value<int?> tenorBulan = const Value.absent(),
                Value<int> cicilanBulananRupiah = const Value.absent(),
                Value<int?> tanggalJatuhTempoBulanan = const Value.absent(),
                Value<DateTime?> tanggalMulai = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime dibuatPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelUtangCompanion.insert(
                id: id,
                nama: nama,
                jenis: jenis,
                pemberi: pemberi,
                sisaAwalRupiah: sisaAwalRupiah,
                pokokAwalRupiah: pokokAwalRupiah,
                jenisBunga: jenisBunga,
                bungaBasisPoinPerTahun: bungaBasisPoinPerTahun,
                tenorBulan: tenorBulan,
                cicilanBulananRupiah: cicilanBulananRupiah,
                tanggalJatuhTempoBulanan: tanggalJatuhTempoBulanan,
                tanggalMulai: tanggalMulai,
                status: status,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelUtangTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tabelPembayaranUtangRefs = false,
                tabelPenyesuaianUtangRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tabelPembayaranUtangRefs) db.tabelPembayaranUtang,
                    if (tabelPenyesuaianUtangRefs) db.tabelPenyesuaianUtang,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tabelPembayaranUtangRefs)
                        await $_getPrefetchedData<
                          EntitasUtang,
                          $TabelUtangTable,
                          EntitasPembayaranUtang
                        >(
                          currentTable: table,
                          referencedTable: $$TabelUtangTableReferences
                              ._tabelPembayaranUtangRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelUtangTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelPembayaranUtangRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.utangId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tabelPenyesuaianUtangRefs)
                        await $_getPrefetchedData<
                          EntitasUtang,
                          $TabelUtangTable,
                          EntitasPenyesuaianUtang
                        >(
                          currentTable: table,
                          referencedTable: $$TabelUtangTableReferences
                              ._tabelPenyesuaianUtangRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelUtangTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelPenyesuaianUtangRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.utangId == item.id,
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

typedef $$TabelUtangTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelUtangTable,
      EntitasUtang,
      $$TabelUtangTableFilterComposer,
      $$TabelUtangTableOrderingComposer,
      $$TabelUtangTableAnnotationComposer,
      $$TabelUtangTableCreateCompanionBuilder,
      $$TabelUtangTableUpdateCompanionBuilder,
      (EntitasUtang, $$TabelUtangTableReferences),
      EntitasUtang,
      PrefetchHooks Function({
        bool tabelPembayaranUtangRefs,
        bool tabelPenyesuaianUtangRefs,
      })
    >;
typedef $$TabelPembayaranUtangTableCreateCompanionBuilder =
    TabelPembayaranUtangCompanion Function({
      required String id,
      required String utangId,
      required String transaksiId,
      Value<int> rowid,
    });
typedef $$TabelPembayaranUtangTableUpdateCompanionBuilder =
    TabelPembayaranUtangCompanion Function({
      Value<String> id,
      Value<String> utangId,
      Value<String> transaksiId,
      Value<int> rowid,
    });

final class $$TabelPembayaranUtangTableReferences
    extends
        BaseReferences<
          _$BasisDataFunda,
          $TabelPembayaranUtangTable,
          EntitasPembayaranUtang
        > {
  $$TabelPembayaranUtangTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TabelUtangTable _utangIdTable(_$BasisDataFunda db) =>
      db.tabelUtang.createAlias(
        $_aliasNameGenerator(db.tabelPembayaranUtang.utangId, db.tabelUtang.id),
      );

  $$TabelUtangTableProcessedTableManager get utangId {
    final $_column = $_itemColumn<String>('utang_id')!;

    final manager = $$TabelUtangTableTableManager(
      $_db,
      $_db.tabelUtang,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utangIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TabelTransaksiTable _transaksiIdTable(_$BasisDataFunda db) =>
      db.tabelTransaksi.createAlias(
        $_aliasNameGenerator(
          db.tabelPembayaranUtang.transaksiId,
          db.tabelTransaksi.id,
        ),
      );

  $$TabelTransaksiTableProcessedTableManager get transaksiId {
    final $_column = $_itemColumn<String>('transaksi_id')!;

    final manager = $$TabelTransaksiTableTableManager(
      $_db,
      $_db.tabelTransaksi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaksiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TabelPembayaranUtangTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelPembayaranUtangTable> {
  $$TabelPembayaranUtangTableFilterComposer({
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

  $$TabelUtangTableFilterComposer get utangId {
    final $$TabelUtangTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utangId,
      referencedTable: $db.tabelUtang,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelUtangTableFilterComposer(
            $db: $db,
            $table: $db.tabelUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelTransaksiTableFilterComposer get transaksiId {
    final $$TabelTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$TabelPembayaranUtangTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelPembayaranUtangTable> {
  $$TabelPembayaranUtangTableOrderingComposer({
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

  $$TabelUtangTableOrderingComposer get utangId {
    final $$TabelUtangTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utangId,
      referencedTable: $db.tabelUtang,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelUtangTableOrderingComposer(
            $db: $db,
            $table: $db.tabelUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelTransaksiTableOrderingComposer get transaksiId {
    final $$TabelTransaksiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableOrderingComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelPembayaranUtangTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelPembayaranUtangTable> {
  $$TabelPembayaranUtangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$TabelUtangTableAnnotationComposer get utangId {
    final $$TabelUtangTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utangId,
      referencedTable: $db.tabelUtang,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelUtangTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelTransaksiTableAnnotationComposer get transaksiId {
    final $$TabelTransaksiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$TabelPembayaranUtangTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelPembayaranUtangTable,
          EntitasPembayaranUtang,
          $$TabelPembayaranUtangTableFilterComposer,
          $$TabelPembayaranUtangTableOrderingComposer,
          $$TabelPembayaranUtangTableAnnotationComposer,
          $$TabelPembayaranUtangTableCreateCompanionBuilder,
          $$TabelPembayaranUtangTableUpdateCompanionBuilder,
          (EntitasPembayaranUtang, $$TabelPembayaranUtangTableReferences),
          EntitasPembayaranUtang,
          PrefetchHooks Function({bool utangId, bool transaksiId})
        > {
  $$TabelPembayaranUtangTableTableManager(
    _$BasisDataFunda db,
    $TabelPembayaranUtangTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelPembayaranUtangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelPembayaranUtangTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TabelPembayaranUtangTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> utangId = const Value.absent(),
                Value<String> transaksiId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelPembayaranUtangCompanion(
                id: id,
                utangId: utangId,
                transaksiId: transaksiId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String utangId,
                required String transaksiId,
                Value<int> rowid = const Value.absent(),
              }) => TabelPembayaranUtangCompanion.insert(
                id: id,
                utangId: utangId,
                transaksiId: transaksiId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelPembayaranUtangTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({utangId = false, transaksiId = false}) {
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
                    if (utangId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.utangId,
                                referencedTable:
                                    $$TabelPembayaranUtangTableReferences
                                        ._utangIdTable(db),
                                referencedColumn:
                                    $$TabelPembayaranUtangTableReferences
                                        ._utangIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (transaksiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transaksiId,
                                referencedTable:
                                    $$TabelPembayaranUtangTableReferences
                                        ._transaksiIdTable(db),
                                referencedColumn:
                                    $$TabelPembayaranUtangTableReferences
                                        ._transaksiIdTable(db)
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

typedef $$TabelPembayaranUtangTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelPembayaranUtangTable,
      EntitasPembayaranUtang,
      $$TabelPembayaranUtangTableFilterComposer,
      $$TabelPembayaranUtangTableOrderingComposer,
      $$TabelPembayaranUtangTableAnnotationComposer,
      $$TabelPembayaranUtangTableCreateCompanionBuilder,
      $$TabelPembayaranUtangTableUpdateCompanionBuilder,
      (EntitasPembayaranUtang, $$TabelPembayaranUtangTableReferences),
      EntitasPembayaranUtang,
      PrefetchHooks Function({bool utangId, bool transaksiId})
    >;
typedef $$TabelPenyesuaianUtangTableCreateCompanionBuilder =
    TabelPenyesuaianUtangCompanion Function({
      required String id,
      required String utangId,
      required String arah,
      required int jumlahRupiah,
      Value<String?> catatan,
      required DateTime tanggal,
      required DateTime dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelPenyesuaianUtangTableUpdateCompanionBuilder =
    TabelPenyesuaianUtangCompanion Function({
      Value<String> id,
      Value<String> utangId,
      Value<String> arah,
      Value<int> jumlahRupiah,
      Value<String?> catatan,
      Value<DateTime> tanggal,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelPenyesuaianUtangTableReferences
    extends
        BaseReferences<
          _$BasisDataFunda,
          $TabelPenyesuaianUtangTable,
          EntitasPenyesuaianUtang
        > {
  $$TabelPenyesuaianUtangTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TabelUtangTable _utangIdTable(_$BasisDataFunda db) =>
      db.tabelUtang.createAlias(
        $_aliasNameGenerator(
          db.tabelPenyesuaianUtang.utangId,
          db.tabelUtang.id,
        ),
      );

  $$TabelUtangTableProcessedTableManager get utangId {
    final $_column = $_itemColumn<String>('utang_id')!;

    final manager = $$TabelUtangTableTableManager(
      $_db,
      $_db.tabelUtang,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utangIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TabelPenyesuaianUtangTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelPenyesuaianUtangTable> {
  $$TabelPenyesuaianUtangTableFilterComposer({
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

  ColumnFilters<String> get arah => $composableBuilder(
    column: $table.arah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jumlahRupiah => $composableBuilder(
    column: $table.jumlahRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  $$TabelUtangTableFilterComposer get utangId {
    final $$TabelUtangTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utangId,
      referencedTable: $db.tabelUtang,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelUtangTableFilterComposer(
            $db: $db,
            $table: $db.tabelUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelPenyesuaianUtangTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelPenyesuaianUtangTable> {
  $$TabelPenyesuaianUtangTableOrderingComposer({
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

  ColumnOrderings<String> get arah => $composableBuilder(
    column: $table.arah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jumlahRupiah => $composableBuilder(
    column: $table.jumlahRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );

  $$TabelUtangTableOrderingComposer get utangId {
    final $$TabelUtangTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utangId,
      referencedTable: $db.tabelUtang,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelUtangTableOrderingComposer(
            $db: $db,
            $table: $db.tabelUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelPenyesuaianUtangTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelPenyesuaianUtangTable> {
  $$TabelPenyesuaianUtangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get arah =>
      $composableBuilder(column: $table.arah, builder: (column) => column);

  GeneratedColumn<int> get jumlahRupiah => $composableBuilder(
    column: $table.jumlahRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  $$TabelUtangTableAnnotationComposer get utangId {
    final $$TabelUtangTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utangId,
      referencedTable: $db.tabelUtang,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelUtangTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelUtang,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelPenyesuaianUtangTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelPenyesuaianUtangTable,
          EntitasPenyesuaianUtang,
          $$TabelPenyesuaianUtangTableFilterComposer,
          $$TabelPenyesuaianUtangTableOrderingComposer,
          $$TabelPenyesuaianUtangTableAnnotationComposer,
          $$TabelPenyesuaianUtangTableCreateCompanionBuilder,
          $$TabelPenyesuaianUtangTableUpdateCompanionBuilder,
          (EntitasPenyesuaianUtang, $$TabelPenyesuaianUtangTableReferences),
          EntitasPenyesuaianUtang,
          PrefetchHooks Function({bool utangId})
        > {
  $$TabelPenyesuaianUtangTableTableManager(
    _$BasisDataFunda db,
    $TabelPenyesuaianUtangTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelPenyesuaianUtangTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TabelPenyesuaianUtangTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TabelPenyesuaianUtangTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> utangId = const Value.absent(),
                Value<String> arah = const Value.absent(),
                Value<int> jumlahRupiah = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelPenyesuaianUtangCompanion(
                id: id,
                utangId: utangId,
                arah: arah,
                jumlahRupiah: jumlahRupiah,
                catatan: catatan,
                tanggal: tanggal,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String utangId,
                required String arah,
                required int jumlahRupiah,
                Value<String?> catatan = const Value.absent(),
                required DateTime tanggal,
                required DateTime dibuatPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelPenyesuaianUtangCompanion.insert(
                id: id,
                utangId: utangId,
                arah: arah,
                jumlahRupiah: jumlahRupiah,
                catatan: catatan,
                tanggal: tanggal,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelPenyesuaianUtangTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({utangId = false}) {
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
                    if (utangId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.utangId,
                                referencedTable:
                                    $$TabelPenyesuaianUtangTableReferences
                                        ._utangIdTable(db),
                                referencedColumn:
                                    $$TabelPenyesuaianUtangTableReferences
                                        ._utangIdTable(db)
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

typedef $$TabelPenyesuaianUtangTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelPenyesuaianUtangTable,
      EntitasPenyesuaianUtang,
      $$TabelPenyesuaianUtangTableFilterComposer,
      $$TabelPenyesuaianUtangTableOrderingComposer,
      $$TabelPenyesuaianUtangTableAnnotationComposer,
      $$TabelPenyesuaianUtangTableCreateCompanionBuilder,
      $$TabelPenyesuaianUtangTableUpdateCompanionBuilder,
      (EntitasPenyesuaianUtang, $$TabelPenyesuaianUtangTableReferences),
      EntitasPenyesuaianUtang,
      PrefetchHooks Function({bool utangId})
    >;
typedef $$TabelTagihanTableCreateCompanionBuilder =
    TabelTagihanCompanion Function({
      required String id,
      required String nama,
      required String jenis,
      Value<int?> jumlahPerkiraanRupiah,
      required String kategoriId,
      Value<String?> dompetId,
      required String frekuensi,
      required DateTime jatuhTempoPertama,
      Value<DateTime?> berakhirPada,
      Value<String> pengingatHariSebelum,
      Value<bool> aktif,
      Value<bool> diarsipkan,
      required DateTime dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelTagihanTableUpdateCompanionBuilder =
    TabelTagihanCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> jenis,
      Value<int?> jumlahPerkiraanRupiah,
      Value<String> kategoriId,
      Value<String?> dompetId,
      Value<String> frekuensi,
      Value<DateTime> jatuhTempoPertama,
      Value<DateTime?> berakhirPada,
      Value<String> pengingatHariSebelum,
      Value<bool> aktif,
      Value<bool> diarsipkan,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelTagihanTableReferences
    extends
        BaseReferences<_$BasisDataFunda, $TabelTagihanTable, EntitasTagihan> {
  $$TabelTagihanTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TabelKategoriTable _kategoriIdTable(_$BasisDataFunda db) =>
      db.tabelKategori.createAlias(
        $_aliasNameGenerator(db.tabelTagihan.kategoriId, db.tabelKategori.id),
      );

  $$TabelKategoriTableProcessedTableManager get kategoriId {
    final $_column = $_itemColumn<String>('kategori_id')!;

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

  static $TabelDompetTable _dompetIdTable(_$BasisDataFunda db) =>
      db.tabelDompet.createAlias(
        $_aliasNameGenerator(db.tabelTagihan.dompetId, db.tabelDompet.id),
      );

  $$TabelDompetTableProcessedTableManager? get dompetId {
    final $_column = $_itemColumn<String>('dompet_id');
    if ($_column == null) return null;
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

  static MultiTypedResultKey<
    $TabelPembayaranTagihanTable,
    List<EntitasPembayaranTagihan>
  >
  _tabelPembayaranTagihanRefsTable(_$BasisDataFunda db) =>
      MultiTypedResultKey.fromTable(
        db.tabelPembayaranTagihan,
        aliasName: $_aliasNameGenerator(
          db.tabelTagihan.id,
          db.tabelPembayaranTagihan.tagihanId,
        ),
      );

  $$TabelPembayaranTagihanTableProcessedTableManager
  get tabelPembayaranTagihanRefs {
    final manager = $$TabelPembayaranTagihanTableTableManager(
      $_db,
      $_db.tabelPembayaranTagihan,
    ).filter((f) => f.tagihanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tabelPembayaranTagihanRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TabelTagihanTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelTagihanTable> {
  $$TabelTagihanTableFilterComposer({
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

  ColumnFilters<int> get jumlahPerkiraanRupiah => $composableBuilder(
    column: $table.jumlahPerkiraanRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frekuensi => $composableBuilder(
    column: $table.frekuensi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get jatuhTempoPertama => $composableBuilder(
    column: $table.jatuhTempoPertama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get berakhirPada => $composableBuilder(
    column: $table.berakhirPada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pengingatHariSebelum => $composableBuilder(
    column: $table.pengingatHariSebelum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
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

  Expression<bool> tabelPembayaranTagihanRefs(
    Expression<bool> Function($$TabelPembayaranTagihanTableFilterComposer f) f,
  ) {
    final $$TabelPembayaranTagihanTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPembayaranTagihan,
          getReferencedColumn: (t) => t.tagihanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPembayaranTagihanTableFilterComposer(
                $db: $db,
                $table: $db.tabelPembayaranTagihan,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TabelTagihanTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelTagihanTable> {
  $$TabelTagihanTableOrderingComposer({
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

  ColumnOrderings<int> get jumlahPerkiraanRupiah => $composableBuilder(
    column: $table.jumlahPerkiraanRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frekuensi => $composableBuilder(
    column: $table.frekuensi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get jatuhTempoPertama => $composableBuilder(
    column: $table.jatuhTempoPertama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get berakhirPada => $composableBuilder(
    column: $table.berakhirPada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pengingatHariSebelum => $composableBuilder(
    column: $table.pengingatHariSebelum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
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
}

class $$TabelTagihanTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelTagihanTable> {
  $$TabelTagihanTableAnnotationComposer({
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

  GeneratedColumn<int> get jumlahPerkiraanRupiah => $composableBuilder(
    column: $table.jumlahPerkiraanRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frekuensi =>
      $composableBuilder(column: $table.frekuensi, builder: (column) => column);

  GeneratedColumn<DateTime> get jatuhTempoPertama => $composableBuilder(
    column: $table.jatuhTempoPertama,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get berakhirPada => $composableBuilder(
    column: $table.berakhirPada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pengingatHariSebelum => $composableBuilder(
    column: $table.pengingatHariSebelum,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);

  GeneratedColumn<bool> get diarsipkan => $composableBuilder(
    column: $table.diarsipkan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

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

  Expression<T> tabelPembayaranTagihanRefs<T extends Object>(
    Expression<T> Function($$TabelPembayaranTagihanTableAnnotationComposer a) f,
  ) {
    final $$TabelPembayaranTagihanTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tabelPembayaranTagihan,
          getReferencedColumn: (t) => t.tagihanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TabelPembayaranTagihanTableAnnotationComposer(
                $db: $db,
                $table: $db.tabelPembayaranTagihan,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TabelTagihanTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelTagihanTable,
          EntitasTagihan,
          $$TabelTagihanTableFilterComposer,
          $$TabelTagihanTableOrderingComposer,
          $$TabelTagihanTableAnnotationComposer,
          $$TabelTagihanTableCreateCompanionBuilder,
          $$TabelTagihanTableUpdateCompanionBuilder,
          (EntitasTagihan, $$TabelTagihanTableReferences),
          EntitasTagihan,
          PrefetchHooks Function({
            bool kategoriId,
            bool dompetId,
            bool tabelPembayaranTagihanRefs,
          })
        > {
  $$TabelTagihanTableTableManager(_$BasisDataFunda db, $TabelTagihanTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelTagihanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelTagihanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelTagihanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> jenis = const Value.absent(),
                Value<int?> jumlahPerkiraanRupiah = const Value.absent(),
                Value<String> kategoriId = const Value.absent(),
                Value<String?> dompetId = const Value.absent(),
                Value<String> frekuensi = const Value.absent(),
                Value<DateTime> jatuhTempoPertama = const Value.absent(),
                Value<DateTime?> berakhirPada = const Value.absent(),
                Value<String> pengingatHariSebelum = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<bool> diarsipkan = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelTagihanCompanion(
                id: id,
                nama: nama,
                jenis: jenis,
                jumlahPerkiraanRupiah: jumlahPerkiraanRupiah,
                kategoriId: kategoriId,
                dompetId: dompetId,
                frekuensi: frekuensi,
                jatuhTempoPertama: jatuhTempoPertama,
                berakhirPada: berakhirPada,
                pengingatHariSebelum: pengingatHariSebelum,
                aktif: aktif,
                diarsipkan: diarsipkan,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String jenis,
                Value<int?> jumlahPerkiraanRupiah = const Value.absent(),
                required String kategoriId,
                Value<String?> dompetId = const Value.absent(),
                required String frekuensi,
                required DateTime jatuhTempoPertama,
                Value<DateTime?> berakhirPada = const Value.absent(),
                Value<String> pengingatHariSebelum = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<bool> diarsipkan = const Value.absent(),
                required DateTime dibuatPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelTagihanCompanion.insert(
                id: id,
                nama: nama,
                jenis: jenis,
                jumlahPerkiraanRupiah: jumlahPerkiraanRupiah,
                kategoriId: kategoriId,
                dompetId: dompetId,
                frekuensi: frekuensi,
                jatuhTempoPertama: jatuhTempoPertama,
                berakhirPada: berakhirPada,
                pengingatHariSebelum: pengingatHariSebelum,
                aktif: aktif,
                diarsipkan: diarsipkan,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelTagihanTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                kategoriId = false,
                dompetId = false,
                tabelPembayaranTagihanRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tabelPembayaranTagihanRefs) db.tabelPembayaranTagihan,
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
                        if (kategoriId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.kategoriId,
                                    referencedTable:
                                        $$TabelTagihanTableReferences
                                            ._kategoriIdTable(db),
                                    referencedColumn:
                                        $$TabelTagihanTableReferences
                                            ._kategoriIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (dompetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dompetId,
                                    referencedTable:
                                        $$TabelTagihanTableReferences
                                            ._dompetIdTable(db),
                                    referencedColumn:
                                        $$TabelTagihanTableReferences
                                            ._dompetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tabelPembayaranTagihanRefs)
                        await $_getPrefetchedData<
                          EntitasTagihan,
                          $TabelTagihanTable,
                          EntitasPembayaranTagihan
                        >(
                          currentTable: table,
                          referencedTable: $$TabelTagihanTableReferences
                              ._tabelPembayaranTagihanRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TabelTagihanTableReferences(
                                db,
                                table,
                                p0,
                              ).tabelPembayaranTagihanRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagihanId == item.id,
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

typedef $$TabelTagihanTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelTagihanTable,
      EntitasTagihan,
      $$TabelTagihanTableFilterComposer,
      $$TabelTagihanTableOrderingComposer,
      $$TabelTagihanTableAnnotationComposer,
      $$TabelTagihanTableCreateCompanionBuilder,
      $$TabelTagihanTableUpdateCompanionBuilder,
      (EntitasTagihan, $$TabelTagihanTableReferences),
      EntitasTagihan,
      PrefetchHooks Function({
        bool kategoriId,
        bool dompetId,
        bool tabelPembayaranTagihanRefs,
      })
    >;
typedef $$TabelPembayaranTagihanTableCreateCompanionBuilder =
    TabelPembayaranTagihanCompanion Function({
      required String id,
      required String tagihanId,
      required DateTime jatuhTempo,
      required String status,
      Value<String?> transaksiId,
      required DateTime dibuatPada,
      Value<int> rowid,
    });
typedef $$TabelPembayaranTagihanTableUpdateCompanionBuilder =
    TabelPembayaranTagihanCompanion Function({
      Value<String> id,
      Value<String> tagihanId,
      Value<DateTime> jatuhTempo,
      Value<String> status,
      Value<String?> transaksiId,
      Value<DateTime> dibuatPada,
      Value<int> rowid,
    });

final class $$TabelPembayaranTagihanTableReferences
    extends
        BaseReferences<
          _$BasisDataFunda,
          $TabelPembayaranTagihanTable,
          EntitasPembayaranTagihan
        > {
  $$TabelPembayaranTagihanTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TabelTagihanTable _tagihanIdTable(_$BasisDataFunda db) =>
      db.tabelTagihan.createAlias(
        $_aliasNameGenerator(
          db.tabelPembayaranTagihan.tagihanId,
          db.tabelTagihan.id,
        ),
      );

  $$TabelTagihanTableProcessedTableManager get tagihanId {
    final $_column = $_itemColumn<String>('tagihan_id')!;

    final manager = $$TabelTagihanTableTableManager(
      $_db,
      $_db.tabelTagihan,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagihanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TabelTransaksiTable _transaksiIdTable(_$BasisDataFunda db) =>
      db.tabelTransaksi.createAlias(
        $_aliasNameGenerator(
          db.tabelPembayaranTagihan.transaksiId,
          db.tabelTransaksi.id,
        ),
      );

  $$TabelTransaksiTableProcessedTableManager? get transaksiId {
    final $_column = $_itemColumn<String>('transaksi_id');
    if ($_column == null) return null;
    final manager = $$TabelTransaksiTableTableManager(
      $_db,
      $_db.tabelTransaksi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaksiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TabelPembayaranTagihanTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelPembayaranTagihanTable> {
  $$TabelPembayaranTagihanTableFilterComposer({
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

  ColumnFilters<DateTime> get jatuhTempo => $composableBuilder(
    column: $table.jatuhTempo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  $$TabelTagihanTableFilterComposer get tagihanId {
    final $$TabelTagihanTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagihanId,
      referencedTable: $db.tabelTagihan,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTagihanTableFilterComposer(
            $db: $db,
            $table: $db.tabelTagihan,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelTransaksiTableFilterComposer get transaksiId {
    final $$TabelTransaksiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$TabelPembayaranTagihanTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelPembayaranTagihanTable> {
  $$TabelPembayaranTagihanTableOrderingComposer({
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

  ColumnOrderings<DateTime> get jatuhTempo => $composableBuilder(
    column: $table.jatuhTempo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );

  $$TabelTagihanTableOrderingComposer get tagihanId {
    final $$TabelTagihanTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagihanId,
      referencedTable: $db.tabelTagihan,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTagihanTableOrderingComposer(
            $db: $db,
            $table: $db.tabelTagihan,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelTransaksiTableOrderingComposer get transaksiId {
    final $$TabelTransaksiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTransaksiTableOrderingComposer(
            $db: $db,
            $table: $db.tabelTransaksi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabelPembayaranTagihanTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelPembayaranTagihanTable> {
  $$TabelPembayaranTagihanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get jatuhTempo => $composableBuilder(
    column: $table.jatuhTempo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  $$TabelTagihanTableAnnotationComposer get tagihanId {
    final $$TabelTagihanTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagihanId,
      referencedTable: $db.tabelTagihan,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabelTagihanTableAnnotationComposer(
            $db: $db,
            $table: $db.tabelTagihan,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TabelTransaksiTableAnnotationComposer get transaksiId {
    final $$TabelTransaksiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.tabelTransaksi,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$TabelPembayaranTagihanTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelPembayaranTagihanTable,
          EntitasPembayaranTagihan,
          $$TabelPembayaranTagihanTableFilterComposer,
          $$TabelPembayaranTagihanTableOrderingComposer,
          $$TabelPembayaranTagihanTableAnnotationComposer,
          $$TabelPembayaranTagihanTableCreateCompanionBuilder,
          $$TabelPembayaranTagihanTableUpdateCompanionBuilder,
          (EntitasPembayaranTagihan, $$TabelPembayaranTagihanTableReferences),
          EntitasPembayaranTagihan,
          PrefetchHooks Function({bool tagihanId, bool transaksiId})
        > {
  $$TabelPembayaranTagihanTableTableManager(
    _$BasisDataFunda db,
    $TabelPembayaranTagihanTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelPembayaranTagihanTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TabelPembayaranTagihanTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TabelPembayaranTagihanTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tagihanId = const Value.absent(),
                Value<DateTime> jatuhTempo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> transaksiId = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelPembayaranTagihanCompanion(
                id: id,
                tagihanId: tagihanId,
                jatuhTempo: jatuhTempo,
                status: status,
                transaksiId: transaksiId,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tagihanId,
                required DateTime jatuhTempo,
                required String status,
                Value<String?> transaksiId = const Value.absent(),
                required DateTime dibuatPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelPembayaranTagihanCompanion.insert(
                id: id,
                tagihanId: tagihanId,
                jatuhTempo: jatuhTempo,
                status: status,
                transaksiId: transaksiId,
                dibuatPada: dibuatPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TabelPembayaranTagihanTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tagihanId = false, transaksiId = false}) {
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
                    if (tagihanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagihanId,
                                referencedTable:
                                    $$TabelPembayaranTagihanTableReferences
                                        ._tagihanIdTable(db),
                                referencedColumn:
                                    $$TabelPembayaranTagihanTableReferences
                                        ._tagihanIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (transaksiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transaksiId,
                                referencedTable:
                                    $$TabelPembayaranTagihanTableReferences
                                        ._transaksiIdTable(db),
                                referencedColumn:
                                    $$TabelPembayaranTagihanTableReferences
                                        ._transaksiIdTable(db)
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

typedef $$TabelPembayaranTagihanTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelPembayaranTagihanTable,
      EntitasPembayaranTagihan,
      $$TabelPembayaranTagihanTableFilterComposer,
      $$TabelPembayaranTagihanTableOrderingComposer,
      $$TabelPembayaranTagihanTableAnnotationComposer,
      $$TabelPembayaranTagihanTableCreateCompanionBuilder,
      $$TabelPembayaranTagihanTableUpdateCompanionBuilder,
      (EntitasPembayaranTagihan, $$TabelPembayaranTagihanTableReferences),
      EntitasPembayaranTagihan,
      PrefetchHooks Function({bool tagihanId, bool transaksiId})
    >;
typedef $$TabelProgresPelajaranTableCreateCompanionBuilder =
    TabelProgresPelajaranCompanion Function({
      required String pelajaranId,
      required String modulId,
      required String status,
      Value<int> indeksLangkah,
      required DateTime dibuatPada,
      Value<DateTime?> selesaiPada,
      Value<int> rowid,
    });
typedef $$TabelProgresPelajaranTableUpdateCompanionBuilder =
    TabelProgresPelajaranCompanion Function({
      Value<String> pelajaranId,
      Value<String> modulId,
      Value<String> status,
      Value<int> indeksLangkah,
      Value<DateTime> dibuatPada,
      Value<DateTime?> selesaiPada,
      Value<int> rowid,
    });

class $$TabelProgresPelajaranTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelProgresPelajaranTable> {
  $$TabelProgresPelajaranTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pelajaranId => $composableBuilder(
    column: $table.pelajaranId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modulId => $composableBuilder(
    column: $table.modulId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indeksLangkah => $composableBuilder(
    column: $table.indeksLangkah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get selesaiPada => $composableBuilder(
    column: $table.selesaiPada,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabelProgresPelajaranTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelProgresPelajaranTable> {
  $$TabelProgresPelajaranTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pelajaranId => $composableBuilder(
    column: $table.pelajaranId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modulId => $composableBuilder(
    column: $table.modulId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indeksLangkah => $composableBuilder(
    column: $table.indeksLangkah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get selesaiPada => $composableBuilder(
    column: $table.selesaiPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelProgresPelajaranTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelProgresPelajaranTable> {
  $$TabelProgresPelajaranTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pelajaranId => $composableBuilder(
    column: $table.pelajaranId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modulId =>
      $composableBuilder(column: $table.modulId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get indeksLangkah => $composableBuilder(
    column: $table.indeksLangkah,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dibuatPada => $composableBuilder(
    column: $table.dibuatPada,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get selesaiPada => $composableBuilder(
    column: $table.selesaiPada,
    builder: (column) => column,
  );
}

class $$TabelProgresPelajaranTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelProgresPelajaranTable,
          EntitasProgresPelajaran,
          $$TabelProgresPelajaranTableFilterComposer,
          $$TabelProgresPelajaranTableOrderingComposer,
          $$TabelProgresPelajaranTableAnnotationComposer,
          $$TabelProgresPelajaranTableCreateCompanionBuilder,
          $$TabelProgresPelajaranTableUpdateCompanionBuilder,
          (
            EntitasProgresPelajaran,
            BaseReferences<
              _$BasisDataFunda,
              $TabelProgresPelajaranTable,
              EntitasProgresPelajaran
            >,
          ),
          EntitasProgresPelajaran,
          PrefetchHooks Function()
        > {
  $$TabelProgresPelajaranTableTableManager(
    _$BasisDataFunda db,
    $TabelProgresPelajaranTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelProgresPelajaranTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TabelProgresPelajaranTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TabelProgresPelajaranTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> pelajaranId = const Value.absent(),
                Value<String> modulId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> indeksLangkah = const Value.absent(),
                Value<DateTime> dibuatPada = const Value.absent(),
                Value<DateTime?> selesaiPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelProgresPelajaranCompanion(
                pelajaranId: pelajaranId,
                modulId: modulId,
                status: status,
                indeksLangkah: indeksLangkah,
                dibuatPada: dibuatPada,
                selesaiPada: selesaiPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pelajaranId,
                required String modulId,
                required String status,
                Value<int> indeksLangkah = const Value.absent(),
                required DateTime dibuatPada,
                Value<DateTime?> selesaiPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelProgresPelajaranCompanion.insert(
                pelajaranId: pelajaranId,
                modulId: modulId,
                status: status,
                indeksLangkah: indeksLangkah,
                dibuatPada: dibuatPada,
                selesaiPada: selesaiPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabelProgresPelajaranTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelProgresPelajaranTable,
      EntitasProgresPelajaran,
      $$TabelProgresPelajaranTableFilterComposer,
      $$TabelProgresPelajaranTableOrderingComposer,
      $$TabelProgresPelajaranTableAnnotationComposer,
      $$TabelProgresPelajaranTableCreateCompanionBuilder,
      $$TabelProgresPelajaranTableUpdateCompanionBuilder,
      (
        EntitasProgresPelajaran,
        BaseReferences<
          _$BasisDataFunda,
          $TabelProgresPelajaranTable,
          EntitasProgresPelajaran
        >,
      ),
      EntitasProgresPelajaran,
      PrefetchHooks Function()
    >;
typedef $$TabelHasilMisiTableCreateCompanionBuilder =
    TabelHasilMisiCompanion Function({
      required String misiId,
      required String pelajaranId,
      required String tipe,
      required String status,
      Value<String?> muatanJson,
      required DateTime selesaiPada,
      Value<int> rowid,
    });
typedef $$TabelHasilMisiTableUpdateCompanionBuilder =
    TabelHasilMisiCompanion Function({
      Value<String> misiId,
      Value<String> pelajaranId,
      Value<String> tipe,
      Value<String> status,
      Value<String?> muatanJson,
      Value<DateTime> selesaiPada,
      Value<int> rowid,
    });

class $$TabelHasilMisiTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelHasilMisiTable> {
  $$TabelHasilMisiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get misiId => $composableBuilder(
    column: $table.misiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pelajaranId => $composableBuilder(
    column: $table.pelajaranId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muatanJson => $composableBuilder(
    column: $table.muatanJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get selesaiPada => $composableBuilder(
    column: $table.selesaiPada,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabelHasilMisiTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelHasilMisiTable> {
  $$TabelHasilMisiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get misiId => $composableBuilder(
    column: $table.misiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pelajaranId => $composableBuilder(
    column: $table.pelajaranId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muatanJson => $composableBuilder(
    column: $table.muatanJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get selesaiPada => $composableBuilder(
    column: $table.selesaiPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelHasilMisiTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelHasilMisiTable> {
  $$TabelHasilMisiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get misiId =>
      $composableBuilder(column: $table.misiId, builder: (column) => column);

  GeneratedColumn<String> get pelajaranId => $composableBuilder(
    column: $table.pelajaranId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get muatanJson => $composableBuilder(
    column: $table.muatanJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get selesaiPada => $composableBuilder(
    column: $table.selesaiPada,
    builder: (column) => column,
  );
}

class $$TabelHasilMisiTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelHasilMisiTable,
          EntitasHasilMisi,
          $$TabelHasilMisiTableFilterComposer,
          $$TabelHasilMisiTableOrderingComposer,
          $$TabelHasilMisiTableAnnotationComposer,
          $$TabelHasilMisiTableCreateCompanionBuilder,
          $$TabelHasilMisiTableUpdateCompanionBuilder,
          (
            EntitasHasilMisi,
            BaseReferences<
              _$BasisDataFunda,
              $TabelHasilMisiTable,
              EntitasHasilMisi
            >,
          ),
          EntitasHasilMisi,
          PrefetchHooks Function()
        > {
  $$TabelHasilMisiTableTableManager(
    _$BasisDataFunda db,
    $TabelHasilMisiTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelHasilMisiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelHasilMisiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelHasilMisiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> misiId = const Value.absent(),
                Value<String> pelajaranId = const Value.absent(),
                Value<String> tipe = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> muatanJson = const Value.absent(),
                Value<DateTime> selesaiPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelHasilMisiCompanion(
                misiId: misiId,
                pelajaranId: pelajaranId,
                tipe: tipe,
                status: status,
                muatanJson: muatanJson,
                selesaiPada: selesaiPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String misiId,
                required String pelajaranId,
                required String tipe,
                required String status,
                Value<String?> muatanJson = const Value.absent(),
                required DateTime selesaiPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelHasilMisiCompanion.insert(
                misiId: misiId,
                pelajaranId: pelajaranId,
                tipe: tipe,
                status: status,
                muatanJson: muatanJson,
                selesaiPada: selesaiPada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabelHasilMisiTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelHasilMisiTable,
      EntitasHasilMisi,
      $$TabelHasilMisiTableFilterComposer,
      $$TabelHasilMisiTableOrderingComposer,
      $$TabelHasilMisiTableAnnotationComposer,
      $$TabelHasilMisiTableCreateCompanionBuilder,
      $$TabelHasilMisiTableUpdateCompanionBuilder,
      (
        EntitasHasilMisi,
        BaseReferences<
          _$BasisDataFunda,
          $TabelHasilMisiTable,
          EntitasHasilMisi
        >,
      ),
      EntitasHasilMisi,
      PrefetchHooks Function()
    >;
typedef $$TabelHasilKuisTableCreateCompanionBuilder =
    TabelHasilKuisCompanion Function({
      Value<int> id,
      required String modulId,
      required int benar,
      required int total,
      required int skorPersen,
      required bool lulus,
      required DateTime waktu,
    });
typedef $$TabelHasilKuisTableUpdateCompanionBuilder =
    TabelHasilKuisCompanion Function({
      Value<int> id,
      Value<String> modulId,
      Value<int> benar,
      Value<int> total,
      Value<int> skorPersen,
      Value<bool> lulus,
      Value<DateTime> waktu,
    });

class $$TabelHasilKuisTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelHasilKuisTable> {
  $$TabelHasilKuisTableFilterComposer({
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

  ColumnFilters<String> get modulId => $composableBuilder(
    column: $table.modulId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get benar => $composableBuilder(
    column: $table.benar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skorPersen => $composableBuilder(
    column: $table.skorPersen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lulus => $composableBuilder(
    column: $table.lulus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get waktu => $composableBuilder(
    column: $table.waktu,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabelHasilKuisTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelHasilKuisTable> {
  $$TabelHasilKuisTableOrderingComposer({
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

  ColumnOrderings<String> get modulId => $composableBuilder(
    column: $table.modulId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get benar => $composableBuilder(
    column: $table.benar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skorPersen => $composableBuilder(
    column: $table.skorPersen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lulus => $composableBuilder(
    column: $table.lulus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get waktu => $composableBuilder(
    column: $table.waktu,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelHasilKuisTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelHasilKuisTable> {
  $$TabelHasilKuisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modulId =>
      $composableBuilder(column: $table.modulId, builder: (column) => column);

  GeneratedColumn<int> get benar =>
      $composableBuilder(column: $table.benar, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get skorPersen => $composableBuilder(
    column: $table.skorPersen,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lulus =>
      $composableBuilder(column: $table.lulus, builder: (column) => column);

  GeneratedColumn<DateTime> get waktu =>
      $composableBuilder(column: $table.waktu, builder: (column) => column);
}

class $$TabelHasilKuisTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelHasilKuisTable,
          EntitasHasilKuis,
          $$TabelHasilKuisTableFilterComposer,
          $$TabelHasilKuisTableOrderingComposer,
          $$TabelHasilKuisTableAnnotationComposer,
          $$TabelHasilKuisTableCreateCompanionBuilder,
          $$TabelHasilKuisTableUpdateCompanionBuilder,
          (
            EntitasHasilKuis,
            BaseReferences<
              _$BasisDataFunda,
              $TabelHasilKuisTable,
              EntitasHasilKuis
            >,
          ),
          EntitasHasilKuis,
          PrefetchHooks Function()
        > {
  $$TabelHasilKuisTableTableManager(
    _$BasisDataFunda db,
    $TabelHasilKuisTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelHasilKuisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelHasilKuisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelHasilKuisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> modulId = const Value.absent(),
                Value<int> benar = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> skorPersen = const Value.absent(),
                Value<bool> lulus = const Value.absent(),
                Value<DateTime> waktu = const Value.absent(),
              }) => TabelHasilKuisCompanion(
                id: id,
                modulId: modulId,
                benar: benar,
                total: total,
                skorPersen: skorPersen,
                lulus: lulus,
                waktu: waktu,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String modulId,
                required int benar,
                required int total,
                required int skorPersen,
                required bool lulus,
                required DateTime waktu,
              }) => TabelHasilKuisCompanion.insert(
                id: id,
                modulId: modulId,
                benar: benar,
                total: total,
                skorPersen: skorPersen,
                lulus: lulus,
                waktu: waktu,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabelHasilKuisTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelHasilKuisTable,
      EntitasHasilKuis,
      $$TabelHasilKuisTableFilterComposer,
      $$TabelHasilKuisTableOrderingComposer,
      $$TabelHasilKuisTableAnnotationComposer,
      $$TabelHasilKuisTableCreateCompanionBuilder,
      $$TabelHasilKuisTableUpdateCompanionBuilder,
      (
        EntitasHasilKuis,
        BaseReferences<
          _$BasisDataFunda,
          $TabelHasilKuisTable,
          EntitasHasilKuis
        >,
      ),
      EntitasHasilKuis,
      PrefetchHooks Function()
    >;
typedef $$TabelPernyataanTableCreateCompanionBuilder =
    TabelPernyataanCompanion Function({
      required String kunci,
      required String nilai,
      required DateTime diubahPada,
      Value<int> rowid,
    });
typedef $$TabelPernyataanTableUpdateCompanionBuilder =
    TabelPernyataanCompanion Function({
      Value<String> kunci,
      Value<String> nilai,
      Value<DateTime> diubahPada,
      Value<int> rowid,
    });

class $$TabelPernyataanTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelPernyataanTable> {
  $$TabelPernyataanTableFilterComposer({
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

class $$TabelPernyataanTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelPernyataanTable> {
  $$TabelPernyataanTableOrderingComposer({
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

class $$TabelPernyataanTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelPernyataanTable> {
  $$TabelPernyataanTableAnnotationComposer({
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

class $$TabelPernyataanTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelPernyataanTable,
          EntitasPernyataan,
          $$TabelPernyataanTableFilterComposer,
          $$TabelPernyataanTableOrderingComposer,
          $$TabelPernyataanTableAnnotationComposer,
          $$TabelPernyataanTableCreateCompanionBuilder,
          $$TabelPernyataanTableUpdateCompanionBuilder,
          (
            EntitasPernyataan,
            BaseReferences<
              _$BasisDataFunda,
              $TabelPernyataanTable,
              EntitasPernyataan
            >,
          ),
          EntitasPernyataan,
          PrefetchHooks Function()
        > {
  $$TabelPernyataanTableTableManager(
    _$BasisDataFunda db,
    $TabelPernyataanTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelPernyataanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelPernyataanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelPernyataanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kunci = const Value.absent(),
                Value<String> nilai = const Value.absent(),
                Value<DateTime> diubahPada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabelPernyataanCompanion(
                kunci: kunci,
                nilai: nilai,
                diubahPada: diubahPada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kunci,
                required String nilai,
                required DateTime diubahPada,
                Value<int> rowid = const Value.absent(),
              }) => TabelPernyataanCompanion.insert(
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

typedef $$TabelPernyataanTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelPernyataanTable,
      EntitasPernyataan,
      $$TabelPernyataanTableFilterComposer,
      $$TabelPernyataanTableOrderingComposer,
      $$TabelPernyataanTableAnnotationComposer,
      $$TabelPernyataanTableCreateCompanionBuilder,
      $$TabelPernyataanTableUpdateCompanionBuilder,
      (
        EntitasPernyataan,
        BaseReferences<
          _$BasisDataFunda,
          $TabelPernyataanTable,
          EntitasPernyataan
        >,
      ),
      EntitasPernyataan,
      PrefetchHooks Function()
    >;
typedef $$TabelProfilKeuanganTableCreateCompanionBuilder =
    TabelProfilKeuanganCompanion Function({
      Value<int> id,
      required String punyaPenghasilan,
      required String punyaUtang,
      required String danaDarurat,
      required String menabung,
      required String investasi,
      required String mencatatKeuangan,
      Value<String?> tujuanUtama,
      required DateTime diisiPada,
      required DateTime diperbaruiPada,
    });
typedef $$TabelProfilKeuanganTableUpdateCompanionBuilder =
    TabelProfilKeuanganCompanion Function({
      Value<int> id,
      Value<String> punyaPenghasilan,
      Value<String> punyaUtang,
      Value<String> danaDarurat,
      Value<String> menabung,
      Value<String> investasi,
      Value<String> mencatatKeuangan,
      Value<String?> tujuanUtama,
      Value<DateTime> diisiPada,
      Value<DateTime> diperbaruiPada,
    });

class $$TabelProfilKeuanganTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelProfilKeuanganTable> {
  $$TabelProfilKeuanganTableFilterComposer({
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

  ColumnFilters<String> get punyaPenghasilan => $composableBuilder(
    column: $table.punyaPenghasilan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get punyaUtang => $composableBuilder(
    column: $table.punyaUtang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get danaDarurat => $composableBuilder(
    column: $table.danaDarurat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get menabung => $composableBuilder(
    column: $table.menabung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get investasi => $composableBuilder(
    column: $table.investasi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mencatatKeuangan => $composableBuilder(
    column: $table.mencatatKeuangan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tujuanUtama => $composableBuilder(
    column: $table.tujuanUtama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diisiPada => $composableBuilder(
    column: $table.diisiPada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diperbaruiPada => $composableBuilder(
    column: $table.diperbaruiPada,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabelProfilKeuanganTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelProfilKeuanganTable> {
  $$TabelProfilKeuanganTableOrderingComposer({
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

  ColumnOrderings<String> get punyaPenghasilan => $composableBuilder(
    column: $table.punyaPenghasilan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get punyaUtang => $composableBuilder(
    column: $table.punyaUtang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get danaDarurat => $composableBuilder(
    column: $table.danaDarurat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get menabung => $composableBuilder(
    column: $table.menabung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get investasi => $composableBuilder(
    column: $table.investasi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mencatatKeuangan => $composableBuilder(
    column: $table.mencatatKeuangan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tujuanUtama => $composableBuilder(
    column: $table.tujuanUtama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diisiPada => $composableBuilder(
    column: $table.diisiPada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diperbaruiPada => $composableBuilder(
    column: $table.diperbaruiPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelProfilKeuanganTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelProfilKeuanganTable> {
  $$TabelProfilKeuanganTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get punyaPenghasilan => $composableBuilder(
    column: $table.punyaPenghasilan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get punyaUtang => $composableBuilder(
    column: $table.punyaUtang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get danaDarurat => $composableBuilder(
    column: $table.danaDarurat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get menabung =>
      $composableBuilder(column: $table.menabung, builder: (column) => column);

  GeneratedColumn<String> get investasi =>
      $composableBuilder(column: $table.investasi, builder: (column) => column);

  GeneratedColumn<String> get mencatatKeuangan => $composableBuilder(
    column: $table.mencatatKeuangan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tujuanUtama => $composableBuilder(
    column: $table.tujuanUtama,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get diisiPada =>
      $composableBuilder(column: $table.diisiPada, builder: (column) => column);

  GeneratedColumn<DateTime> get diperbaruiPada => $composableBuilder(
    column: $table.diperbaruiPada,
    builder: (column) => column,
  );
}

class $$TabelProfilKeuanganTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelProfilKeuanganTable,
          EntitasProfilKeuangan,
          $$TabelProfilKeuanganTableFilterComposer,
          $$TabelProfilKeuanganTableOrderingComposer,
          $$TabelProfilKeuanganTableAnnotationComposer,
          $$TabelProfilKeuanganTableCreateCompanionBuilder,
          $$TabelProfilKeuanganTableUpdateCompanionBuilder,
          (
            EntitasProfilKeuangan,
            BaseReferences<
              _$BasisDataFunda,
              $TabelProfilKeuanganTable,
              EntitasProfilKeuangan
            >,
          ),
          EntitasProfilKeuangan,
          PrefetchHooks Function()
        > {
  $$TabelProfilKeuanganTableTableManager(
    _$BasisDataFunda db,
    $TabelProfilKeuanganTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelProfilKeuanganTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelProfilKeuanganTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TabelProfilKeuanganTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> punyaPenghasilan = const Value.absent(),
                Value<String> punyaUtang = const Value.absent(),
                Value<String> danaDarurat = const Value.absent(),
                Value<String> menabung = const Value.absent(),
                Value<String> investasi = const Value.absent(),
                Value<String> mencatatKeuangan = const Value.absent(),
                Value<String?> tujuanUtama = const Value.absent(),
                Value<DateTime> diisiPada = const Value.absent(),
                Value<DateTime> diperbaruiPada = const Value.absent(),
              }) => TabelProfilKeuanganCompanion(
                id: id,
                punyaPenghasilan: punyaPenghasilan,
                punyaUtang: punyaUtang,
                danaDarurat: danaDarurat,
                menabung: menabung,
                investasi: investasi,
                mencatatKeuangan: mencatatKeuangan,
                tujuanUtama: tujuanUtama,
                diisiPada: diisiPada,
                diperbaruiPada: diperbaruiPada,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String punyaPenghasilan,
                required String punyaUtang,
                required String danaDarurat,
                required String menabung,
                required String investasi,
                required String mencatatKeuangan,
                Value<String?> tujuanUtama = const Value.absent(),
                required DateTime diisiPada,
                required DateTime diperbaruiPada,
              }) => TabelProfilKeuanganCompanion.insert(
                id: id,
                punyaPenghasilan: punyaPenghasilan,
                punyaUtang: punyaUtang,
                danaDarurat: danaDarurat,
                menabung: menabung,
                investasi: investasi,
                mencatatKeuangan: mencatatKeuangan,
                tujuanUtama: tujuanUtama,
                diisiPada: diisiPada,
                diperbaruiPada: diperbaruiPada,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabelProfilKeuanganTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelProfilKeuanganTable,
      EntitasProfilKeuangan,
      $$TabelProfilKeuanganTableFilterComposer,
      $$TabelProfilKeuanganTableOrderingComposer,
      $$TabelProfilKeuanganTableAnnotationComposer,
      $$TabelProfilKeuanganTableCreateCompanionBuilder,
      $$TabelProfilKeuanganTableUpdateCompanionBuilder,
      (
        EntitasProfilKeuangan,
        BaseReferences<
          _$BasisDataFunda,
          $TabelProfilKeuanganTable,
          EntitasProfilKeuangan
        >,
      ),
      EntitasProfilKeuangan,
      PrefetchHooks Function()
    >;
typedef $$TabelHasilTesAwalTableCreateCompanionBuilder =
    TabelHasilTesAwalCompanion Function({
      Value<int> id,
      required DateTime waktu,
      required String jawabanJson,
      required String skorPerModulJson,
      required int skorTotalPersen,
    });
typedef $$TabelHasilTesAwalTableUpdateCompanionBuilder =
    TabelHasilTesAwalCompanion Function({
      Value<int> id,
      Value<DateTime> waktu,
      Value<String> jawabanJson,
      Value<String> skorPerModulJson,
      Value<int> skorTotalPersen,
    });

class $$TabelHasilTesAwalTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelHasilTesAwalTable> {
  $$TabelHasilTesAwalTableFilterComposer({
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

  ColumnFilters<DateTime> get waktu => $composableBuilder(
    column: $table.waktu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jawabanJson => $composableBuilder(
    column: $table.jawabanJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skorPerModulJson => $composableBuilder(
    column: $table.skorPerModulJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skorTotalPersen => $composableBuilder(
    column: $table.skorTotalPersen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabelHasilTesAwalTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelHasilTesAwalTable> {
  $$TabelHasilTesAwalTableOrderingComposer({
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

  ColumnOrderings<DateTime> get waktu => $composableBuilder(
    column: $table.waktu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jawabanJson => $composableBuilder(
    column: $table.jawabanJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skorPerModulJson => $composableBuilder(
    column: $table.skorPerModulJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skorTotalPersen => $composableBuilder(
    column: $table.skorTotalPersen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelHasilTesAwalTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelHasilTesAwalTable> {
  $$TabelHasilTesAwalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get waktu =>
      $composableBuilder(column: $table.waktu, builder: (column) => column);

  GeneratedColumn<String> get jawabanJson => $composableBuilder(
    column: $table.jawabanJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skorPerModulJson => $composableBuilder(
    column: $table.skorPerModulJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skorTotalPersen => $composableBuilder(
    column: $table.skorTotalPersen,
    builder: (column) => column,
  );
}

class $$TabelHasilTesAwalTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelHasilTesAwalTable,
          EntitasHasilTesAwal,
          $$TabelHasilTesAwalTableFilterComposer,
          $$TabelHasilTesAwalTableOrderingComposer,
          $$TabelHasilTesAwalTableAnnotationComposer,
          $$TabelHasilTesAwalTableCreateCompanionBuilder,
          $$TabelHasilTesAwalTableUpdateCompanionBuilder,
          (
            EntitasHasilTesAwal,
            BaseReferences<
              _$BasisDataFunda,
              $TabelHasilTesAwalTable,
              EntitasHasilTesAwal
            >,
          ),
          EntitasHasilTesAwal,
          PrefetchHooks Function()
        > {
  $$TabelHasilTesAwalTableTableManager(
    _$BasisDataFunda db,
    $TabelHasilTesAwalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelHasilTesAwalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelHasilTesAwalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelHasilTesAwalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> waktu = const Value.absent(),
                Value<String> jawabanJson = const Value.absent(),
                Value<String> skorPerModulJson = const Value.absent(),
                Value<int> skorTotalPersen = const Value.absent(),
              }) => TabelHasilTesAwalCompanion(
                id: id,
                waktu: waktu,
                jawabanJson: jawabanJson,
                skorPerModulJson: skorPerModulJson,
                skorTotalPersen: skorTotalPersen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime waktu,
                required String jawabanJson,
                required String skorPerModulJson,
                required int skorTotalPersen,
              }) => TabelHasilTesAwalCompanion.insert(
                id: id,
                waktu: waktu,
                jawabanJson: jawabanJson,
                skorPerModulJson: skorPerModulJson,
                skorTotalPersen: skorTotalPersen,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabelHasilTesAwalTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelHasilTesAwalTable,
      EntitasHasilTesAwal,
      $$TabelHasilTesAwalTableFilterComposer,
      $$TabelHasilTesAwalTableOrderingComposer,
      $$TabelHasilTesAwalTableAnnotationComposer,
      $$TabelHasilTesAwalTableCreateCompanionBuilder,
      $$TabelHasilTesAwalTableUpdateCompanionBuilder,
      (
        EntitasHasilTesAwal,
        BaseReferences<
          _$BasisDataFunda,
          $TabelHasilTesAwalTable,
          EntitasHasilTesAwal
        >,
      ),
      EntitasHasilTesAwal,
      PrefetchHooks Function()
    >;
typedef $$TabelSesiSandboxTableCreateCompanionBuilder =
    TabelSesiSandboxCompanion Function({
      Value<int> id,
      Value<int> saldoAwalRupiah,
      required int alokasiPasarUangPersen,
      required int alokasiObligasiPersen,
      required int alokasiSahamPersen,
      Value<int> bulanBerjalan,
      required int nilaiSaatIniRupiah,
      required String skenarioAktif,
      required String riwayatJson,
      required DateTime diperbaruiPada,
    });
typedef $$TabelSesiSandboxTableUpdateCompanionBuilder =
    TabelSesiSandboxCompanion Function({
      Value<int> id,
      Value<int> saldoAwalRupiah,
      Value<int> alokasiPasarUangPersen,
      Value<int> alokasiObligasiPersen,
      Value<int> alokasiSahamPersen,
      Value<int> bulanBerjalan,
      Value<int> nilaiSaatIniRupiah,
      Value<String> skenarioAktif,
      Value<String> riwayatJson,
      Value<DateTime> diperbaruiPada,
    });

class $$TabelSesiSandboxTableFilterComposer
    extends Composer<_$BasisDataFunda, $TabelSesiSandboxTable> {
  $$TabelSesiSandboxTableFilterComposer({
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

  ColumnFilters<int> get saldoAwalRupiah => $composableBuilder(
    column: $table.saldoAwalRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alokasiPasarUangPersen => $composableBuilder(
    column: $table.alokasiPasarUangPersen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alokasiObligasiPersen => $composableBuilder(
    column: $table.alokasiObligasiPersen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alokasiSahamPersen => $composableBuilder(
    column: $table.alokasiSahamPersen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bulanBerjalan => $composableBuilder(
    column: $table.bulanBerjalan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nilaiSaatIniRupiah => $composableBuilder(
    column: $table.nilaiSaatIniRupiah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skenarioAktif => $composableBuilder(
    column: $table.skenarioAktif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riwayatJson => $composableBuilder(
    column: $table.riwayatJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diperbaruiPada => $composableBuilder(
    column: $table.diperbaruiPada,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabelSesiSandboxTableOrderingComposer
    extends Composer<_$BasisDataFunda, $TabelSesiSandboxTable> {
  $$TabelSesiSandboxTableOrderingComposer({
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

  ColumnOrderings<int> get saldoAwalRupiah => $composableBuilder(
    column: $table.saldoAwalRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alokasiPasarUangPersen => $composableBuilder(
    column: $table.alokasiPasarUangPersen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alokasiObligasiPersen => $composableBuilder(
    column: $table.alokasiObligasiPersen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alokasiSahamPersen => $composableBuilder(
    column: $table.alokasiSahamPersen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bulanBerjalan => $composableBuilder(
    column: $table.bulanBerjalan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nilaiSaatIniRupiah => $composableBuilder(
    column: $table.nilaiSaatIniRupiah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skenarioAktif => $composableBuilder(
    column: $table.skenarioAktif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riwayatJson => $composableBuilder(
    column: $table.riwayatJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diperbaruiPada => $composableBuilder(
    column: $table.diperbaruiPada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabelSesiSandboxTableAnnotationComposer
    extends Composer<_$BasisDataFunda, $TabelSesiSandboxTable> {
  $$TabelSesiSandboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get saldoAwalRupiah => $composableBuilder(
    column: $table.saldoAwalRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alokasiPasarUangPersen => $composableBuilder(
    column: $table.alokasiPasarUangPersen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alokasiObligasiPersen => $composableBuilder(
    column: $table.alokasiObligasiPersen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alokasiSahamPersen => $composableBuilder(
    column: $table.alokasiSahamPersen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bulanBerjalan => $composableBuilder(
    column: $table.bulanBerjalan,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nilaiSaatIniRupiah => $composableBuilder(
    column: $table.nilaiSaatIniRupiah,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skenarioAktif => $composableBuilder(
    column: $table.skenarioAktif,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riwayatJson => $composableBuilder(
    column: $table.riwayatJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get diperbaruiPada => $composableBuilder(
    column: $table.diperbaruiPada,
    builder: (column) => column,
  );
}

class $$TabelSesiSandboxTableTableManager
    extends
        RootTableManager<
          _$BasisDataFunda,
          $TabelSesiSandboxTable,
          EntitasSesiSandbox,
          $$TabelSesiSandboxTableFilterComposer,
          $$TabelSesiSandboxTableOrderingComposer,
          $$TabelSesiSandboxTableAnnotationComposer,
          $$TabelSesiSandboxTableCreateCompanionBuilder,
          $$TabelSesiSandboxTableUpdateCompanionBuilder,
          (
            EntitasSesiSandbox,
            BaseReferences<
              _$BasisDataFunda,
              $TabelSesiSandboxTable,
              EntitasSesiSandbox
            >,
          ),
          EntitasSesiSandbox,
          PrefetchHooks Function()
        > {
  $$TabelSesiSandboxTableTableManager(
    _$BasisDataFunda db,
    $TabelSesiSandboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabelSesiSandboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabelSesiSandboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabelSesiSandboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> saldoAwalRupiah = const Value.absent(),
                Value<int> alokasiPasarUangPersen = const Value.absent(),
                Value<int> alokasiObligasiPersen = const Value.absent(),
                Value<int> alokasiSahamPersen = const Value.absent(),
                Value<int> bulanBerjalan = const Value.absent(),
                Value<int> nilaiSaatIniRupiah = const Value.absent(),
                Value<String> skenarioAktif = const Value.absent(),
                Value<String> riwayatJson = const Value.absent(),
                Value<DateTime> diperbaruiPada = const Value.absent(),
              }) => TabelSesiSandboxCompanion(
                id: id,
                saldoAwalRupiah: saldoAwalRupiah,
                alokasiPasarUangPersen: alokasiPasarUangPersen,
                alokasiObligasiPersen: alokasiObligasiPersen,
                alokasiSahamPersen: alokasiSahamPersen,
                bulanBerjalan: bulanBerjalan,
                nilaiSaatIniRupiah: nilaiSaatIniRupiah,
                skenarioAktif: skenarioAktif,
                riwayatJson: riwayatJson,
                diperbaruiPada: diperbaruiPada,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> saldoAwalRupiah = const Value.absent(),
                required int alokasiPasarUangPersen,
                required int alokasiObligasiPersen,
                required int alokasiSahamPersen,
                Value<int> bulanBerjalan = const Value.absent(),
                required int nilaiSaatIniRupiah,
                required String skenarioAktif,
                required String riwayatJson,
                required DateTime diperbaruiPada,
              }) => TabelSesiSandboxCompanion.insert(
                id: id,
                saldoAwalRupiah: saldoAwalRupiah,
                alokasiPasarUangPersen: alokasiPasarUangPersen,
                alokasiObligasiPersen: alokasiObligasiPersen,
                alokasiSahamPersen: alokasiSahamPersen,
                bulanBerjalan: bulanBerjalan,
                nilaiSaatIniRupiah: nilaiSaatIniRupiah,
                skenarioAktif: skenarioAktif,
                riwayatJson: riwayatJson,
                diperbaruiPada: diperbaruiPada,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabelSesiSandboxTableProcessedTableManager =
    ProcessedTableManager<
      _$BasisDataFunda,
      $TabelSesiSandboxTable,
      EntitasSesiSandbox,
      $$TabelSesiSandboxTableFilterComposer,
      $$TabelSesiSandboxTableOrderingComposer,
      $$TabelSesiSandboxTableAnnotationComposer,
      $$TabelSesiSandboxTableCreateCompanionBuilder,
      $$TabelSesiSandboxTableUpdateCompanionBuilder,
      (
        EntitasSesiSandbox,
        BaseReferences<
          _$BasisDataFunda,
          $TabelSesiSandboxTable,
          EntitasSesiSandbox
        >,
      ),
      EntitasSesiSandbox,
      PrefetchHooks Function()
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
  $$TabelAnggaranTableTableManager get tabelAnggaran =>
      $$TabelAnggaranTableTableManager(_db, _db.tabelAnggaran);
  $$TabelTujuanTableTableManager get tabelTujuan =>
      $$TabelTujuanTableTableManager(_db, _db.tabelTujuan);
  $$TabelKantongTableTableManager get tabelKantong =>
      $$TabelKantongTableTableManager(_db, _db.tabelKantong);
  $$TabelAlokasiKantongTableTableManager get tabelAlokasiKantong =>
      $$TabelAlokasiKantongTableTableManager(_db, _db.tabelAlokasiKantong);
  $$TabelUtangTableTableManager get tabelUtang =>
      $$TabelUtangTableTableManager(_db, _db.tabelUtang);
  $$TabelPembayaranUtangTableTableManager get tabelPembayaranUtang =>
      $$TabelPembayaranUtangTableTableManager(_db, _db.tabelPembayaranUtang);
  $$TabelPenyesuaianUtangTableTableManager get tabelPenyesuaianUtang =>
      $$TabelPenyesuaianUtangTableTableManager(_db, _db.tabelPenyesuaianUtang);
  $$TabelTagihanTableTableManager get tabelTagihan =>
      $$TabelTagihanTableTableManager(_db, _db.tabelTagihan);
  $$TabelPembayaranTagihanTableTableManager get tabelPembayaranTagihan =>
      $$TabelPembayaranTagihanTableTableManager(
        _db,
        _db.tabelPembayaranTagihan,
      );
  $$TabelProgresPelajaranTableTableManager get tabelProgresPelajaran =>
      $$TabelProgresPelajaranTableTableManager(_db, _db.tabelProgresPelajaran);
  $$TabelHasilMisiTableTableManager get tabelHasilMisi =>
      $$TabelHasilMisiTableTableManager(_db, _db.tabelHasilMisi);
  $$TabelHasilKuisTableTableManager get tabelHasilKuis =>
      $$TabelHasilKuisTableTableManager(_db, _db.tabelHasilKuis);
  $$TabelPernyataanTableTableManager get tabelPernyataan =>
      $$TabelPernyataanTableTableManager(_db, _db.tabelPernyataan);
  $$TabelProfilKeuanganTableTableManager get tabelProfilKeuangan =>
      $$TabelProfilKeuanganTableTableManager(_db, _db.tabelProfilKeuangan);
  $$TabelHasilTesAwalTableTableManager get tabelHasilTesAwal =>
      $$TabelHasilTesAwalTableTableManager(_db, _db.tabelHasilTesAwal);
  $$TabelSesiSandboxTableTableManager get tabelSesiSandbox =>
      $$TabelSesiSandboxTableTableManager(_db, _db.tabelSesiSandbox);
}
