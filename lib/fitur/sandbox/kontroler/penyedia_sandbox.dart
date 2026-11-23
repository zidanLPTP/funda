import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/penyedia_basis_data.dart';
import '../../../data/repositori/sandbox_repositori.dart';
import '../../../perhitungan/perhitungan_sandbox.dart';

/// Catatan riwayat hasil langkah simulasi tahunan.
class LangkahRiwayatSandbox {
  final int tahun;
  final int nilaiTotal;
  final int nilaiPU;
  final int nilaiOB;
  final int nilaiSH;
  final int selisihTahun;
  final String skenario;

  const LangkahRiwayatSandbox({
    required this.tahun,
    required this.nilaiTotal,
    required this.nilaiPU,
    required this.nilaiOB,
    required this.nilaiSH,
    required this.selisihTahun,
    required this.skenario,
  });

  Map<String, dynamic> toJson() => {
        'tahun': tahun,
        'nilaiTotal': nilaiTotal,
        'nilaiPU': nilaiPU,
        'nilaiOB': nilaiOB,
        'nilaiSH': nilaiSH,
        'selisihTahun': selisihTahun,
        'skenario': skenario,
      };

  factory LangkahRiwayatSandbox.fromJson(Map<String, dynamic> json) =>
      LangkahRiwayatSandbox(
        tahun: (json['tahun'] as num).toInt(),
        nilaiTotal: (json['nilaiTotal'] as num).toInt(),
        nilaiPU: (json['nilaiPU'] as num).toInt(),
        nilaiOB: (json['nilaiOB'] as num).toInt(),
        nilaiSH: (json['nilaiSH'] as num).toInt(),
        selisihTahun: (json['selisihTahun'] as num).toInt(),
        skenario: json['skenario'] as String,
      );
}

/// Keadaan (state) aktif simulasi Mode Sandbox investasi fiktif.
class KeadaanSandbox {
  final int saldoAwal;
  final int persenPasarUang;
  final int persenObligasi;
  final int persenSaham;
  final String skenario;
  final int tahunBerjalan;
  final int nilaiSaatIni;
  final int nilaiPasarUang;
  final int nilaiObligasi;
  final int nilaiSaham;
  final List<LangkahRiwayatSandbox> riwayat;
  final bool memuat;

  const KeadaanSandbox({
    this.saldoAwal = 10000000,
    this.persenPasarUang = 40,
    this.persenObligasi = 30,
    this.persenSaham = 30,
    this.skenario = 'normal',
    this.tahunBerjalan = 0,
    this.nilaiSaatIni = 10000000,
    this.nilaiPasarUang = 4000000,
    this.nilaiObligasi = 3000000,
    this.nilaiSaham = 3000000,
    this.riwayat = const [],
    this.memuat = false,
  });

  int get totalAlokasi => persenPasarUang + persenObligasi + persenSaham;
  bool get alokasiSah =>
      totalAlokasi == 100 &&
      persenPasarUang >= 0 &&
      persenObligasi >= 0 &&
      persenSaham >= 0;
  int get selisihDariAwal => nilaiSaatIni - saldoAwal;

  KeadaanSandbox copyWith({
    int? saldoAwal,
    int? persenPasarUang,
    int? persenObligasi,
    int? persenSaham,
    String? skenario,
    int? tahunBerjalan,
    int? nilaiSaatIni,
    int? nilaiPasarUang,
    int? nilaiObligasi,
    int? nilaiSaham,
    List<LangkahRiwayatSandbox>? riwayat,
    bool? memuat,
  }) {
    return KeadaanSandbox(
      saldoAwal: saldoAwal ?? this.saldoAwal,
      persenPasarUang: persenPasarUang ?? this.persenPasarUang,
      persenObligasi: persenObligasi ?? this.persenObligasi,
      persenSaham: persenSaham ?? this.persenSaham,
      skenario: skenario ?? this.skenario,
      tahunBerjalan: tahunBerjalan ?? this.tahunBerjalan,
      nilaiSaatIni: nilaiSaatIni ?? this.nilaiSaatIni,
      nilaiPasarUang: nilaiPasarUang ?? this.nilaiPasarUang,
      nilaiObligasi: nilaiObligasi ?? this.nilaiObligasi,
      nilaiSaham: nilaiSaham ?? this.nilaiSaham,
      riwayat: riwayat ?? this.riwayat,
      memuat: memuat ?? this.memuat,
    );
  }
}

/// Pengelola logika dan persistensi sesi simulasi sandbox berbasis Notifier.
class NotifierSandbox extends Notifier<KeadaanSandbox> {
  SandboxRepositori get _repo => ref.read(penyediaSandboxRepositori);

  @override
  KeadaanSandbox build() {
    // Inisialisasi awal dan pemicu pemuatan data lokal
    Future.microtask(() => muatSesi());
    return const KeadaanSandbox();
  }

  /// Memuat sesi sandbox yang tersimpan di basis data lokal.
  Future<void> muatSesi() async {
    state = state.copyWith(memuat: true);
    final entitas = await _repo.ambilSesiTerakhir();
    if (entitas != null) {
      List<LangkahRiwayatSandbox> daftarRiwayat = [];
      try {
        final decoded = jsonDecode(entitas.riwayatJson) as List<dynamic>;
        daftarRiwayat = decoded
            .map((e) => LangkahRiwayatSandbox.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        daftarRiwayat = [];
      }

      final thn = entitas.bulanBerjalan ~/ 12;
      final pPU = entitas.nilaiSaatIniRupiah * entitas.alokasiPasarUangPersen ~/ 100;
      final pOB = entitas.nilaiSaatIniRupiah * entitas.alokasiObligasiPersen ~/ 100;
      final pSH = entitas.nilaiSaatIniRupiah - pPU - pOB;

      state = KeadaanSandbox(
        saldoAwal: entitas.saldoAwalRupiah,
        persenPasarUang: entitas.alokasiPasarUangPersen,
        persenObligasi: entitas.alokasiObligasiPersen,
        persenSaham: entitas.alokasiSahamPersen,
        skenario: entitas.skenarioAktif,
        tahunBerjalan: thn,
        nilaiSaatIni: entitas.nilaiSaatIniRupiah,
        nilaiPasarUang: pPU,
        nilaiObligasi: pOB,
        nilaiSaham: pSH,
        riwayat: daftarRiwayat,
        memuat: false,
      );
    } else {
      state = state.copyWith(memuat: false);
    }
  }

  /// Mengubah pembagian alokasi portofolio.
  void ubahAlokasi({
    int? persenPasarUang,
    int? persenObligasi,
    int? persenSaham,
  }) {
    final baruPU = persenPasarUang ?? state.persenPasarUang;
    final baruOB = persenObligasi ?? state.persenObligasi;
    final baruSH = persenSaham ?? state.persenSaham;

    int nPU = state.nilaiPasarUang;
    int nOB = state.nilaiObligasi;
    int nSH = state.nilaiSaham;

    if (baruPU + baruOB + baruSH == 100) {
      nPU = state.nilaiSaatIni * baruPU ~/ 100;
      nOB = state.nilaiSaatIni * baruOB ~/ 100;
      nSH = state.nilaiSaatIni - nPU - nOB;
    }

    state = state.copyWith(
      persenPasarUang: baruPU,
      persenObligasi: baruOB,
      persenSaham: baruSH,
      nilaiPasarUang: nPU,
      nilaiObligasi: nOB,
      nilaiSaham: nSH,
    );
  }

  /// Mengubah skenario pergerakan pasar.
  void ubahSkenario(String skenarioBaru) {
    state = state.copyWith(skenario: skenarioBaru);
  }

  /// Memajukan simulasi portofolio sejauh 1 tahun kalender secara majemuk.
  Future<void> majukanSatuTahun() async {
    if (!state.alokasiSah) return;

    final hasil = hitungSimulasiSandbox(
      saldoAwal: state.nilaiSaatIni,
      persenPasarUang: state.persenPasarUang,
      persenObligasi: state.persenObligasi,
      persenSaham: state.persenSaham,
      jumlahTahun: 1,
      skenario: state.skenario,
    );

    final tahunBaru = state.tahunBerjalan + 1;
    final langkah = LangkahRiwayatSandbox(
      tahun: tahunBaru,
      nilaiTotal: hasil.nilaiAkhirTotal,
      nilaiPU: hasil.nilaiPasarUang,
      nilaiOB: hasil.nilaiObligasi,
      nilaiSH: hasil.nilaiSaham,
      selisihTahun: hasil.selisihRupiah,
      skenario: state.skenario,
    );

    final riwayatBaru = [...state.riwayat, langkah];

    state = state.copyWith(
      tahunBerjalan: tahunBaru,
      nilaiSaatIni: hasil.nilaiAkhirTotal,
      nilaiPasarUang: hasil.nilaiPasarUang,
      nilaiObligasi: hasil.nilaiObligasi,
      nilaiSaham: hasil.nilaiSaham,
      riwayat: riwayatBaru,
    );

    // Simpan ke database
    final jsonRiwayat = jsonEncode(riwayatBaru.map((r) => r.toJson()).toList());
    await _repo.simpanSesi(
      saldoAwalRupiah: state.saldoAwal,
      alokasiPasarUangPersen: state.persenPasarUang,
      alokasiObligasiPersen: state.persenObligasi,
      alokasiSahamPersen: state.persenSaham,
      bulanBerjalan: tahunBaru * 12,
      nilaiSaatIniRupiah: hasil.nilaiAkhirTotal,
      skenarioAktif: state.skenario,
      riwayatJson: jsonRiwayat,
    );
  }

  /// Mereset seluruh simulasi kembali ke kondisi awal Rp10.000.000.
  Future<void> aturUlang() async {
    await _repo.resetSesi();
    const saldo = 10000000;
    const pu = 40;
    const ob = 30;
    const sh = 30;
    state = const KeadaanSandbox(
      saldoAwal: saldo,
      persenPasarUang: pu,
      persenObligasi: ob,
      persenSaham: sh,
      skenario: 'normal',
      tahunBerjalan: 0,
      nilaiSaatIni: saldo,
      nilaiPasarUang: saldo * pu ~/ 100,
      nilaiObligasi: saldo * ob ~/ 100,
      nilaiSaham: saldo - (saldo * pu ~/ 100) - (saldo * ob ~/ 100),
      riwayat: [],
      memuat: false,
    );
  }
}

/// Provider Notifier untuk Mode Sandbox.
final penyediaSandbox =
    NotifierProvider<NotifierSandbox, KeadaanSandbox>(NotifierSandbox.new);
