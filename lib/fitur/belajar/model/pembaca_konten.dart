import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../perhitungan/perhitungan_belajar.dart';

/// Model istilah kamus keuangan Funda.
class IstilahKamus {
  final String istilah;
  final String arti;
  final String contohRupiah;

  const IstilahKamus({
    required this.istilah,
    required this.arti,
    required this.contohRupiah,
  });

  factory IstilahKamus.fromJson(Map<String, dynamic> json) {
    return IstilahKamus(
      istilah: json['istilah'] as String? ?? '',
      arti: json['arti'] as String? ?? '',
      contohRupiah: json['contohRupiah'] as String? ?? '',
    );
  }
}

/// Eksepsi terstruktur untuk galat pembacaan dan validasi konten JSON.
class GalatKonten implements Exception {
  final String pesan;
  final String berkas;
  final String? kolom;

  const GalatKonten(this.pesan, {required this.berkas, this.kolom});

  @override
  String toString() {
    if (kolom != null) {
      return 'GalatKonten [$berkas -> kolom "$kolom"]: $pesan';
    }
    return 'GalatKonten [$berkas]: $pesan';
  }
}

/// Pembaca dan validator konten materi micro-learning Funda.
class PembacaKonten {
  static final RegExp _polaIstilahKamus = RegExp(r'\{\{([^}]+)\}\}');
  static const List<String> kataTerlarang = [
    'boros',
    'bodoh',
    'malas',
    'ceroboh',
    'payah',
  ];
  static const List<String> istilahTeknisWajibKurung = [
    'surplus',
    'defisit',
    'aset',
    'liabilitas',
  ];
  static const Set<String> objekGerbangValid = {
    'dompet',
    'pemasukan',
    'pengeluaran',
    'transaksi',
    'arus_kas',
    'anggaran',
    'tujuan',
    'utang',
    'kategori',
    'profil',
    'tujuan_tabungan',
    'isi_tujuan_tabungan',
    'pengeluaran_kebutuhan',
    'tujuan_dana_darurat',
    'isi_dana_darurat',
  };
  static const Set<String> umpanBalikMisiValid = {
    'catatan_pengeluaran_terbaru',
    'arus_kas_bulan_ini',
    'komposisi_sifat_bulan_ini',
    'perbandingan_pola_anggaran',
    'realisasi_anggaran_bulan_ini',
    'ringkasan_tujuan_tabungan',
    'estimasi_tabungan',
    'pengeluaran_wajib_bulanan',
    'target_dana_darurat',
    'progres_dana_darurat',
    'ringkasan_utang',
    'biaya_pinjaman_tercatat',
    'rasio_cicilan_bulan_ini',
    'urutan_pelunasan',
  };

  /// Mengurai string JSON kamus menjadi daftar istilah terindeks.
  static Map<String, IstilahKamus> uraiKamus(String jsonString, {String namaBerkas = 'kamus.json'}) {
    final dynamic data = jsonDecode(jsonString);
    if (data is! List) {
      throw GalatKonten('Format kamus harus berupa array objek JSON', berkas: namaBerkas);
    }
    final hasil = <String, IstilahKamus>{};
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map<String, dynamic>) {
        throw GalatKonten('Item kamus indeks $i bukan objek JSON', berkas: namaBerkas);
      }
      final istilah = item['istilah'] as String?;
      final arti = item['arti'] as String?;
      final contoh = item['contohRupiah'] as String?;

      if (istilah == null || istilah.trim().isEmpty) {
        throw GalatKonten('Kolom istilah wajib ada dan tidak boleh kosong', berkas: namaBerkas, kolom: 'istilah');
      }
      if (arti == null || arti.trim().isEmpty) {
        throw GalatKonten('Kolom arti wajib ada dan tidak boleh kosong', berkas: namaBerkas, kolom: 'arti');
      }
      if (contoh == null || contoh.trim().isEmpty) {
        throw GalatKonten('Kolom contohRupiah wajib ada', berkas: namaBerkas, kolom: 'contohRupiah');
      }

      hasil[istilah.toLowerCase().trim()] = IstilahKamus.fromJson(item);
    }
    return hasil;
  }

  /// Mengurai string JSON modul dan memvalidasi integritasnya.
  static ModulKonten uraiModul(String jsonString, {String namaBerkas = 'modul.json'}) {
    final dynamic data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      throw GalatKonten('Modul harus berupa objek JSON', berkas: namaBerkas);
    }
    validasiKontenModul(data, namaBerkas: namaBerkas);
    return ModulKonten.fromJson(data);
  }

  /// Memvalidasi struktur dan kolom wajib modul.
  static void validasiKontenModul(Map<String, dynamic> data, {required String namaBerkas}) {
    final id = data['id'] as String?;
    if (id == null || id.trim().isEmpty) {
      throw GalatKonten('Kolom id modul wajib ada', berkas: namaBerkas, kolom: 'id');
    }
    final judul = data['judul'] as String?;
    if (judul == null || judul.trim().isEmpty) {
      throw GalatKonten('Kolom judul modul wajib ada', berkas: namaBerkas, kolom: 'judul');
    }
    final tingkat = data['tingkat'] as String?;
    if (tingkat == null || !['pemula', 'menengah', 'lanjutan'].contains(tingkat)) {
      throw GalatKonten('Kolom tingkat harus bernilai pemula, menengah, atau lanjutan', berkas: namaBerkas, kolom: 'tingkat');
    }
    if (!data.containsKey('urutan') || data['urutan'] is! num) {
      throw GalatKonten('Kolom urutan wajib berupa angka', berkas: namaBerkas, kolom: 'urutan');
    }
    if (!data.containsKey('tersedia') || data['tersedia'] is! bool) {
      throw GalatKonten('Kolom tersedia wajib berupa boolean', berkas: namaBerkas, kolom: 'tersedia');
    }
    final daftarPelajaran = data['daftarPelajaran'];
    if (daftarPelajaran is! List) {
      throw GalatKonten('Kolom daftarPelajaran wajib berupa array', berkas: namaBerkas, kolom: 'daftarPelajaran');
    }
    // Cek ID pelajaran duplikat
    final setPelajaran = <String>{};
    for (final pel in daftarPelajaran) {
      final pelId = pel.toString();
      if (!setPelajaran.add(pelId)) {
        throw GalatKonten('Ditemukan ID pelajaran duplikat di daftarPelajaran: "$pelId"', berkas: namaBerkas, kolom: 'daftarPelajaran');
      }
    }

    // Validasi gerbang modul bila ada
    final gerbang = data['gerbang'];
    if (gerbang is List) {
      for (var i = 0; i < gerbang.length; i++) {
        final g = gerbang[i];
        if (g is Map<String, dynamic>) {
          final tipe = g['tipe'] as String?;
          final obj = g['objek'] as String?;
          if (tipe == 'ada_data' && obj != null && !objekGerbangValid.contains(obj.toLowerCase())) {
            throw GalatKonten('Objek gerbang data tidak dikenal: "$obj"', berkas: namaBerkas, kolom: 'gerbang[$i].objek');
          }
          if (g.containsKey('atauPernyataan')) {
            final atau = g['atauPernyataan'];
            if (atau is! String || atau.trim().isEmpty) {
              throw GalatKonten('Kolom atauPernyataan harus berupa string tidak kosong', berkas: namaBerkas, kolom: 'gerbang[$i].atauPernyataan');
            }
          }
        }
      }
    }

    final tersedia = data['tersedia'] as bool? ?? false;
    final jenis = data['jenis'] as String?;
    final kuis = data['kuis'];
    if (tersedia && jenis != 'tes_awal' && kuis is Map<String, dynamic>) {
      final jmlSoal = kuis['jumlahSoal'];
      if (jmlSoal is num && jmlSoal <= 0) {
        throw GalatKonten('Kolom kuis.jumlahSoal harus bernilai > 0 untuk modul yang tersedia', berkas: namaBerkas, kolom: 'kuis.jumlahSoal');
      }
      final bankSoal = kuis['bankSoal'];
      if (bankSoal is List) {
        if (jmlSoal is num && bankSoal.length < jmlSoal) {
          throw GalatKonten('Jumlah bankSoal (${bankSoal.length}) tidak boleh lebih sedikit dari jumlahSoal ($jmlSoal)', berkas: namaBerkas, kolom: 'kuis.bankSoal');
        }
        final setSoal = <String>{};
        for (var i = 0; i < bankSoal.length; i++) {
          final soal = bankSoal[i];
          if (soal is Map<String, dynamic>) {
            final soalId = soal['id'] as String?;
            if (soalId != null && !setSoal.add(soalId)) {
              throw GalatKonten('Ditemukan ID soal kuis duplikat: "$soalId"', berkas: namaBerkas, kolom: 'kuis.bankSoal[$i].id');
            }
            final pelId = soal['pelajaranId'] as String?;
            if (pelId == null || pelId.trim().isEmpty) {
              throw GalatKonten('Kolom pelajaranId pada soal kuis "$soalId" wajib ada', berkas: namaBerkas, kolom: 'kuis.bankSoal[$i].pelajaranId');
            }
            if (setPelajaran.isNotEmpty && !setPelajaran.contains(pelId)) {
              throw GalatKonten('Soal "$soalId" mereferensikan pelajaranId "$pelId" yang tidak terdaftar di modul', berkas: namaBerkas, kolom: 'kuis.bankSoal[$i].pelajaranId');
            }

            final tanya = soal['tanya'] as String? ?? '';
            final penjelasan = soal['penjelasan'] as String? ?? '';
            final pilihan = (soal['pilihan'] as List<dynamic>?)?.map((e) => e.toString()).join(' ') ?? '';
            final teksSoal = '$tanya $penjelasan $pilihan';

            final isModul5 = namaBerkas.contains('waspada_penipuan') || id == 'waspada_penipuan';
            if (isModul5) {
              periksaTeksSensitifModul5(tanya, namaBerkas: namaBerkas, kolom: 'kuis.bankSoal[$i].tanya');
              periksaTeksSensitifModul5(penjelasan, namaBerkas: namaBerkas, kolom: 'kuis.bankSoal[$i].penjelasan');
              if (soal['pilihan'] is List) {
                for (var pIdx = 0; pIdx < (soal['pilihan'] as List).length; pIdx++) {
                  final pText = (soal['pilihan'] as List)[pIdx].toString();
                  periksaTeksSensitifModul5(pText, namaBerkas: namaBerkas, kolom: 'kuis.bankSoal[$i].pilihan[$pIdx]');
                }
              }
            }

            final polaAturanPraktis = RegExp(r'(50/30/20|50-30-20|\b50\s*persen\b|\b30\s*persen\b|\b20\s*persen\b)', caseSensitive: false);
            final adaAturanPraktis = polaAturanPraktis.hasMatch(teksSoal);
            final isAturanPraktis = soal['aturanPraktis'] == true;
            final catatanReviewer = (soal['catatanReviewer'] as String?) ?? (data['catatanReviewer'] as String?);

            if (isAturanPraktis) {
              if (catatanReviewer == null || !catatanReviewer.contains('TODO-VERIFIKASI')) {
                throw GalatKonten('Soal kuis dengan aturanPraktis: true wajib memuat catatanReviewer dengan "TODO-VERIFIKASI"', berkas: namaBerkas, kolom: 'kuis.bankSoal[$i].catatanReviewer');
              }
            } else if (adaAturanPraktis) {
              throw GalatKonten('Soal kuis memuat angka aturan praktis tanpa penanda aturanPraktis: true dan catatanReviewer "TODO-VERIFIKASI"', berkas: namaBerkas, kolom: 'kuis.bankSoal[$i]');
            }
          }
        }
      }
    }
  }

  /// Mengurai string JSON pelajaran dan memvalidasi aturan penulisan kartu, kamus, dan bahasa.
  static PelajaranKonten uraiPelajaran(
    String jsonString, {
    required String namaBerkas,
    Set<String>? daftarIstilahKamus,
    List<String>? daftarPeringatan,
  }) {
    final dynamic data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      throw GalatKonten('Pelajaran harus berupa objek JSON', berkas: namaBerkas);
    }
    validasiKontenPelajaran(
      data,
      namaBerkas: namaBerkas,
      daftarIstilahKamus: daftarIstilahKamus,
      daftarPeringatan: daftarPeringatan,
    );
    return PelajaranKonten.fromJson(data);
  }

  /// Validasi ketat konten pelajaran.
  static void validasiKontenPelajaran(
    Map<String, dynamic> data, {
    required String namaBerkas,
    Set<String>? daftarIstilahKamus,
    List<String>? daftarPeringatan,
  }) {
    // 1. Validasi ID berformat stabil <modul>_<nomor>
    final id = data['id'] as String?;
    if (id == null || !RegExp(r'^[a-z0-9_]+_\d+_\d+$').hasMatch(id)) {
      throw GalatKonten('ID pelajaran harus berformat stabil <modul>_<nomor> (contoh: anggaran_arus_kas_1_2)', berkas: namaBerkas, kolom: 'id');
    }

    // 2. Judul
    final judul = data['judul'] as String?;
    if (judul == null || judul.trim().isEmpty) {
      throw GalatKonten('Kolom judul pelajaran wajib ada', berkas: namaBerkas, kolom: 'judul');
    }

    final isModul5 = namaBerkas.contains('waspada_penipuan') || id.startsWith('waspada_penipuan');
    if (isModul5) {
      if (RegExp(r'\b(aman|bahaya)\b', caseSensitive: false).hasMatch(judul)) {
        throw GalatKonten('Judul pelajaran Modul 5 dilarang memuat label "aman" atau "bahaya": "$judul"', berkas: namaBerkas, kolom: 'judul');
      }
      periksaTeksSensitifModul5(judul, namaBerkas: namaBerkas, kolom: 'judul');
    }

    // 3. Durasi menit (3 sampai 8 menit)
    final durasi = data['durasiMenit'];
    if (durasi is! num || durasi < 3 || durasi > 8) {
      throw GalatKonten('Kolom durasiMenit harus berupa angka antara 3 sampai 8', berkas: namaBerkas, kolom: 'durasiMenit');
    }

    // 4. Status (draf | ditinjau)
    final status = data['status'] as String?;
    if (status != 'draf' && status != 'ditinjau') {
      throw GalatKonten('Kolom status pelajaran harus "draf" atau "ditinjau"', berkas: namaBerkas, kolom: 'status');
    }

    // Validasi gerbang pelajaran bila ada
    final gerbang = data['gerbang'];
    if (gerbang is List) {
      for (var i = 0; i < gerbang.length; i++) {
        final g = gerbang[i];
        if (g is Map<String, dynamic>) {
          final tipe = g['tipe'] as String?;
          final obj = g['objek'] as String?;
          if (tipe == 'ada_data' && obj != null && !objekGerbangValid.contains(obj.toLowerCase())) {
            throw GalatKonten('Objek gerbang data tidak dikenal: "$obj"', berkas: namaBerkas, kolom: 'gerbang[$i].objek');
          }
          if (g.containsKey('atauPernyataan')) {
            final atau = g['atauPernyataan'];
            if (atau is! String || atau.trim().isEmpty) {
              throw GalatKonten('Kolom atauPernyataan harus berupa string tidak kosong', berkas: namaBerkas, kolom: 'gerbang[$i].atauPernyataan');
            }
          }
        }
      }
    }

    // 5. Kartu konsep (maksimal 3 kartu)
    final kartuList = data['kartu'];
    if (kartuList is! List || kartuList.isEmpty || kartuList.length > 3) {
      throw GalatKonten('Kolom kartu harus berupa array dengan 1 sampai maksimal 3 kartu', berkas: namaBerkas, kolom: 'kartu');
    }

    // Periksa istilah kamus & bahasa pada pemantik
    final pemantik = data['pemantik'] as String? ?? '';
    _periksaIstilahKamus(pemantik, daftarIstilahKamus, namaBerkas, 'pemantik');
    periksaBahasaTeks(pemantik, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    if (isModul5) {
      periksaTeksSensitifModul5(pemantik, namaBerkas: namaBerkas, kolom: 'pemantik');
    }

    // Periksa kartu
    for (var i = 0; i < kartuList.length; i++) {
      final kartu = kartuList[i];
      if (kartu is! Map<String, dynamic>) {
        throw GalatKonten('Kartu indeks $i bukan objek', berkas: namaBerkas, kolom: 'kartu[$i]');
      }
      final judulKartu = kartu['judul'] as String? ?? '';
      final isiKartu = kartu['isi'] as String? ?? '';

      _periksaIstilahKamus(isiKartu, daftarIstilahKamus, namaBerkas, 'kartu[$i].isi');
      periksaBahasaTeks(judulKartu, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      periksaBahasaTeks(isiKartu, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      if (isModul5) {
        periksaTeksSensitifModul5(judulKartu, namaBerkas: namaBerkas, kolom: 'kartu[$i].judul');
        periksaTeksSensitifModul5(isiKartu, namaBerkas: namaBerkas, kolom: 'kartu[$i].isi');
      }
    }

    // 6. Cek Paham (2 sampai 3 soal)
    final cekPaham = data['cekPaham'];
    if (cekPaham is! List || cekPaham.length < 2 || cekPaham.length > 3) {
      throw GalatKonten('Kolom cekPaham harus berisi 2 sampai 3 soal', berkas: namaBerkas, kolom: 'cekPaham');
    }
    for (var i = 0; i < cekPaham.length; i++) {
      final soal = cekPaham[i];
      if (soal is Map<String, dynamic>) {
        final tanya = soal['tanya'] as String? ?? '';
        final penjelasan = soal['penjelasan'] as String? ?? '';
        final pilihan = soal['pilihan'];
        final benar = soal['benar'];

        _periksaIstilahKamus(tanya, daftarIstilahKamus, namaBerkas, 'cekPaham[$i].tanya');
        _periksaIstilahKamus(penjelasan, daftarIstilahKamus, namaBerkas, 'cekPaham[$i].penjelasan');
        periksaBahasaTeks(tanya, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
        periksaBahasaTeks(penjelasan, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
        if (isModul5) {
          periksaTeksSensitifModul5(tanya, namaBerkas: namaBerkas, kolom: 'cekPaham[$i].tanya');
          periksaTeksSensitifModul5(penjelasan, namaBerkas: namaBerkas, kolom: 'cekPaham[$i].penjelasan');
        }

        if (pilihan is List) {
          for (var j = 0; j < pilihan.length; j++) {
            final teksPilihan = pilihan[j].toString();
            _periksaIstilahKamus(teksPilihan, daftarIstilahKamus, namaBerkas, 'cekPaham[$i].pilihan[$j]');
            periksaBahasaTeks(teksPilihan, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
            if (isModul5) {
              periksaTeksSensitifModul5(teksPilihan, namaBerkas: namaBerkas, kolom: 'cekPaham[$i].pilihan[$j]');
            }
          }
          if (benar is num) {
            if (benar < 0 || benar >= pilihan.length) {
              throw GalatKonten('Indeks benar di luar rentang pilihan', berkas: namaBerkas, kolom: 'cekPaham.benar');
            }
          }
        }
      }
    }

    // 7. Contoh Angka (opsional, jika ada harus berstruktur valid)
    final contohAngka = data['contohAngka'];
    var teksContohAngka = '';
    if (contohAngka != null && contohAngka is! num) {
      if (contohAngka is! Map<String, dynamic>) {
        throw GalatKonten('Kolom contohAngka wajib berupa objek', berkas: namaBerkas, kolom: 'contohAngka');
      }
      final judulContoh = contohAngka['judul'] as String?;
      if (judulContoh == null || judulContoh.trim().isEmpty) {
        throw GalatKonten('Kolom contohAngka.judul wajib ada', berkas: namaBerkas, kolom: 'contohAngka.judul');
      }
      final kesimpulan = contohAngka['kesimpulan'] as String?;
      if (kesimpulan == null || kesimpulan.trim().isEmpty) {
        throw GalatKonten('Kolom contohAngka.kesimpulan wajib ada', berkas: namaBerkas, kolom: 'contohAngka.kesimpulan');
      }

      teksContohAngka = '$judulContoh $kesimpulan ';
      _periksaIstilahKamus(judulContoh, daftarIstilahKamus, namaBerkas, 'contohAngka.judul');
      _periksaIstilahKamus(kesimpulan, daftarIstilahKamus, namaBerkas, 'contohAngka.kesimpulan');
      periksaBahasaTeks(judulContoh, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      periksaBahasaTeks(kesimpulan, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      if (isModul5) {
        periksaTeksSensitifModul5(judulContoh, namaBerkas: namaBerkas, kolom: 'contohAngka.judul');
        periksaTeksSensitifModul5(kesimpulan, namaBerkas: namaBerkas, kolom: 'contohAngka.kesimpulan');
      }

      if (contohAngka.containsKey('baris')) {
        final baris = contohAngka['baris'];
        if (baris is! List || baris.isEmpty) {
          throw GalatKonten('Kolom contohAngka.baris wajib berupa array tidak kosong', berkas: namaBerkas, kolom: 'contohAngka.baris');
        }
        for (var bIdx = 0; bIdx < baris.length; bIdx++) {
          final b = baris[bIdx];
          if (b is! Map<String, dynamic>) {
            throw GalatKonten('Baris contohAngka indeks $bIdx harus berupa objek', berkas: namaBerkas, kolom: 'contohAngka.baris[$bIdx]');
          }
          final label = b['label'] as String?;
          if (label == null || label.trim().isEmpty) {
            throw GalatKonten('Kolom label pada baris contohAngka wajib ada', berkas: namaBerkas, kolom: 'contohAngka.baris[$bIdx].label');
          }
          if (!b.containsKey('jumlah') || b['jumlah'] is! num) {
            throw GalatKonten('Kolom jumlah pada baris contohAngka wajib berupa angka int Rupiah', berkas: namaBerkas, kolom: 'contohAngka.baris[$bIdx].jumlah');
          }
          teksContohAngka += '$label ';
          _periksaIstilahKamus(label, daftarIstilahKamus, namaBerkas, 'contohAngka.baris[$bIdx].label');
          periksaBahasaTeks(label, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
          if (isModul5) {
            periksaTeksSensitifModul5(label, namaBerkas: namaBerkas, kolom: 'contohAngka.baris[$bIdx].label');
          }
        }
      } else {
        // Mendukung bentuk lama {masuk, keluar, hasil}
        if (!contohAngka.containsKey('masuk') && !contohAngka.containsKey('keluar') && !contohAngka.containsKey('hasil')) {
          throw GalatKonten('Kolom contohAngka wajib memuat array "baris" atau format {masuk, keluar, hasil}', berkas: namaBerkas, kolom: 'contohAngka');
        }
      }
    }

    // 8. Validasi Aturan Praktis & Catatan Reviewer
    final teksSemuaKartu = kartuList.map((k) => '${(k as Map)["judul"]} ${(k)["isi"]}').join(' ');
    final teksSemuaCekPaham = cekPaham.map((c) => '${(c as Map)["tanya"]} ${(c)["penjelasan"]}').join(' ');
    final seluruhTeks = '$pemantik $teksSemuaKartu $teksSemuaCekPaham $teksContohAngka';

    final polaAturanPraktis = RegExp(r'(50/30/20|50-30-20|\b50\s*persen\b|\b30\s*persen\b|\b20\s*persen\b)', caseSensitive: false);
    final adaAturanPraktis = polaAturanPraktis.hasMatch(seluruhTeks);
    final isAturanPraktis = data['aturanPraktis'] == true;
    final catatanReviewer = data['catatanReviewer'] as String?;

    if (isAturanPraktis) {
      if (catatanReviewer == null || !catatanReviewer.contains('TODO-VERIFIKASI')) {
        throw GalatKonten('Pelajaran dengan aturanPraktis: true wajib memuat catatanReviewer dengan "TODO-VERIFIKASI"', berkas: namaBerkas, kolom: 'catatanReviewer');
      }
    } else if (adaAturanPraktis) {
      throw GalatKonten('Pelajaran memuat angka aturan praktis tanpa penanda aturanPraktis: true dan catatanReviewer "TODO-VERIFIKASI"', berkas: namaBerkas);
    }

    // 9. Misi
    final misi = data['misi'];
    if (misi is! Map<String, dynamic>) {
      throw GalatKonten('Kolom misi wajib berupa objek', berkas: namaBerkas, kolom: 'misi');
    }
    final tipeMisi = misi['tipe'] as String?;
    if (tipeMisi == null) {
      throw GalatKonten('Kolom misi.tipe wajib ada', berkas: namaBerkas, kolom: 'misi.tipe');
    }
    const jenisMisiDidukung = {
      'ada_data',
      'aturan_data',
      'lihat_hitungan',
      'keputusan',
      'daftar_periksa',
    };
    if (!jenisMisiDidukung.contains(tipeMisi)) {
      throw GalatKonten('Jenis misi "$tipeMisi" belum didukung pada versi ini', berkas: namaBerkas, kolom: 'misi.tipe');
    }
    final judulMisi = misi['judul'] as String?;
    if (judulMisi == null || judulMisi.trim().isEmpty) {
      throw GalatKonten('Kolom misi.judul wajib ada dan tidak kosong', berkas: namaBerkas, kolom: 'misi.judul');
    }
    _periksaIstilahKamus(judulMisi, daftarIstilahKamus, namaBerkas, 'misi.judul');
    periksaBahasaTeks(judulMisi, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    if (isModul5) {
      periksaTeksSensitifModul5(judulMisi, namaBerkas: namaBerkas, kolom: 'misi.judul');
    }
    final instruksiMisi = (misi['instruksi'] ?? misi['deskripsi']) as String?;
    if (instruksiMisi != null) {
      if (instruksiMisi.trim().isEmpty) {
        throw GalatKonten('Kolom misi.instruksi wajib ada dan tidak kosong', berkas: namaBerkas, kolom: 'misi.instruksi');
      }
      _periksaIstilahKamus(instruksiMisi, daftarIstilahKamus, namaBerkas, 'misi.instruksi');
      periksaBahasaTeks(instruksiMisi, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      if (isModul5) {
        periksaTeksSensitifModul5(instruksiMisi, namaBerkas: namaBerkas, kolom: 'misi.instruksi');
      }
    } else if (tipeMisi == 'keputusan' || tipeMisi == 'daftar_periksa') {
      throw GalatKonten('Kolom misi.instruksi wajib ada dan tidak kosong', berkas: namaBerkas, kolom: 'misi.instruksi');
    }

    if (tipeMisi == 'keputusan') {
      final skenario = misi['skenario'];
      if (skenario is! Map<String, dynamic>) {
        throw GalatKonten('Kolom misi.skenario wajib berupa objek untuk misi keputusan', berkas: namaBerkas, kolom: 'misi.skenario');
      }
      final pemantikSkenario = skenario['pemantik'] as String?;
      if (pemantikSkenario == null || pemantikSkenario.trim().isEmpty) {
        throw GalatKonten('Kolom misi.skenario.pemantik wajib ada dan tidak kosong', berkas: namaBerkas, kolom: 'misi.skenario.pemantik');
      }
      _periksaIstilahKamus(pemantikSkenario, daftarIstilahKamus, namaBerkas, 'misi.skenario.pemantik');
      periksaBahasaTeks(pemantikSkenario, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      if (isModul5) {
        periksaTeksSensitifModul5(pemantikSkenario, namaBerkas: namaBerkas, kolom: 'misi.skenario.pemantik');
      }

      final opsiList = skenario['opsi'];
      if (opsiList is! List || opsiList.length < 2) {
        throw GalatKonten('Kolom misi.skenario.opsi wajib berupa list minimal 2 opsi', berkas: namaBerkas, kolom: 'misi.skenario.opsi');
      }

      var adaOpsiAman = false;
      for (var oIdx = 0; oIdx < opsiList.length; oIdx++) {
        final opt = opsiList[oIdx];
        if (opt is! Map<String, dynamic>) {
          throw GalatKonten('Opsi keputusan indeks $oIdx harus berupa objek', berkas: namaBerkas, kolom: 'misi.skenario.opsi[$oIdx]');
        }
        final optId = opt['id'] as String?;
        if (optId == null || optId.trim().isEmpty) {
          throw GalatKonten('Kolom id pada opsi keputusan wajib ada', berkas: namaBerkas, kolom: 'misi.skenario.opsi[$oIdx].id');
        }
        final optTeks = opt['teks'] as String?;
        if (optTeks == null || optTeks.trim().isEmpty) {
          throw GalatKonten('Kolom teks pada opsi keputusan wajib ada', berkas: namaBerkas, kolom: 'misi.skenario.opsi[$oIdx].teks');
        }
        final optAman = opt['aman'];
        if (optAman is! bool) {
          throw GalatKonten('Kolom aman pada opsi keputusan wajib berupa boolean', berkas: namaBerkas, kolom: 'misi.skenario.opsi[$oIdx].aman');
        }
        if (optAman) adaOpsiAman = true;

        final optUmpanBalik = opt['umpanBalik'] as String?;
        if (optUmpanBalik == null || optUmpanBalik.trim().isEmpty) {
          throw GalatKonten('Kolom umpanBalik pada opsi keputusan wajib ada dan tidak kosong', berkas: namaBerkas, kolom: 'misi.skenario.opsi[$oIdx].umpanBalik');
        }

        _periksaIstilahKamus(optTeks, daftarIstilahKamus, namaBerkas, 'misi.skenario.opsi[$oIdx].teks');
        _periksaIstilahKamus(optUmpanBalik, daftarIstilahKamus, namaBerkas, 'misi.skenario.opsi[$oIdx].umpanBalik');
        periksaBahasaTeks(optTeks, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
        periksaBahasaTeks(optUmpanBalik, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
        if (isModul5) {
          periksaTeksSensitifModul5(optTeks, namaBerkas: namaBerkas, kolom: 'misi.skenario.opsi[$oIdx].teks');
          periksaTeksSensitifModul5(optUmpanBalik, namaBerkas: namaBerkas, kolom: 'misi.skenario.opsi[$oIdx].umpanBalik');
        }
      }

      if (!adaOpsiAman) {
        throw GalatKonten('Misi keputusan wajib memiliki minimal 1 opsi dengan aman: true', berkas: namaBerkas, kolom: 'misi.skenario.opsi');
      }
    } else if (tipeMisi == 'daftar_periksa') {
      final disclaimer = misi['disclaimer'];
      if (disclaimer != true) {
        throw GalatKonten('Kolom misi.disclaimer wajib bernilai true untuk misi daftar_periksa', berkas: namaBerkas, kolom: 'misi.disclaimer');
      }

      final langkahList = misi['langkah'];
      if (langkahList is! List || langkahList.length < 3) {
        throw GalatKonten('Kolom misi.langkah wajib berupa list minimal 3 langkah', berkas: namaBerkas, kolom: 'misi.langkah');
      }

      final minimalDicentang = misi['minimalDicentang'];
      if (minimalDicentang is! int || minimalDicentang < 1 || minimalDicentang > langkahList.length) {
        throw GalatKonten('Kolom misi.minimalDicentang wajib bernilai antara 1 sampai jumlah langkah', berkas: namaBerkas, kolom: 'misi.minimalDicentang');
      }

      final catatanReviewer = data['catatanReviewer'] as String? ?? '';
      if (!catatanReviewer.contains('TODO-VERIFIKASI')) {
        throw GalatKonten('Pelajaran dengan misi daftar_periksa wajib memuat "TODO-VERIFIKASI" pada catatanReviewer', berkas: namaBerkas, kolom: 'catatanReviewer');
      }

      for (var lIdx = 0; lIdx < langkahList.length; lIdx++) {
        final lk = langkahList[lIdx];
        if (lk is! Map<String, dynamic>) {
          throw GalatKonten('Langkah indeks $lIdx harus berupa objek', berkas: namaBerkas, kolom: 'misi.langkah[$lIdx]');
        }
        final lkId = lk['id'] as String?;
        if (lkId == null || lkId.trim().isEmpty) {
          throw GalatKonten('Kolom id pada langkah wajib ada', berkas: namaBerkas, kolom: 'misi.langkah[$lIdx].id');
        }
        final lkTeks = lk['teks'] as String?;
        if (lkTeks == null || lkTeks.trim().isEmpty) {
          throw GalatKonten('Kolom teks pada langkah wajib ada', berkas: namaBerkas, kolom: 'misi.langkah[$lIdx].teks');
        }

        _periksaIstilahKamus(lkTeks, daftarIstilahKamus, namaBerkas, 'misi.langkah[$lIdx].teks');
        periksaBahasaTeks(lkTeks, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
        if (isModul5) {
          periksaTeksSensitifModul5(lkTeks, namaBerkas: namaBerkas, kolom: 'misi.langkah[$lIdx].teks');
        }
      }
    }

    if (misi.containsKey('min')) {
      final minVal = misi['min'];
      if (minVal is num && minVal < 1) {
        throw GalatKonten('Kolom misi.min harus bernilai >= 1', berkas: namaBerkas, kolom: 'misi.min');
      }
    }
    final objekMisi = misi['objek'] as String?;
    if (objekMisi != null && !objekGerbangValid.contains(objekMisi.toLowerCase())) {
      throw GalatKonten('Objek misi tidak dikenal: "$objekMisi"', berkas: namaBerkas, kolom: 'misi.objek');
    }
    final umpanBalik = misi['umpanBalik'] as String?;
    if (umpanBalik != null && !umpanBalikMisiValid.contains(umpanBalik)) {
      throw GalatKonten('Umpan balik misi "$umpanBalik" tidak terdaftar di registri umpan balik', berkas: namaBerkas, kolom: 'misi.umpanBalik');
    }

    // 8. Validasi Relasi Misi vs Gerbang Pelajaran
    // Pemeriksa konten GAGAL bila sebuah misi sudah otomatis terpenuhi oleh gerbang pelajarannya sendiri
    // (misi tidak boleh lebih longgar atau sama dengan gerbang), kecuali bertipe lihat_hitungan, keputusan, dan daftar_periksa.
    if (tipeMisi != 'lihat_hitungan' &&
        tipeMisi != 'keputusan' &&
        tipeMisi != 'daftar_periksa' &&
        gerbang is List) {
      final minMisi = (misi['min'] as num?)?.toInt() ?? 1;
      final aturanMisi = misi['aturan'] as String?;

      for (var i = 0; i < gerbang.length; i++) {
        final g = gerbang[i];
        if (g is Map<String, dynamic>) {
          final tipeG = g['tipe'] as String?;
          final objG = g['objek'] as String?;
          final minG = (g['min'] as num?)?.toInt() ?? 1;
          final aturanG = g['aturan'] as String?;

          if (tipeMisi == 'ada_data' && tipeG == 'ada_data') {
            // Objek sama dan syarat misi <= syarat gerbang
            if (objG != null && objekMisi != null && objG.toLowerCase() == objekMisi.toLowerCase() && minMisi <= minG) {
              throw GalatKonten(
                'Misi ada_data ($objekMisi min: $minMisi) otomatis terpenuhi oleh gerbang pelajaran ($objG min: $minG). Misi tidak boleh lebih longgar atau sama dengan gerbang.',
                berkas: namaBerkas,
                kolom: 'misi',
              );
            }
            // Objek transaksi mencakup pemasukan dan pengeluaran
            if ((objG == 'pengeluaran' || objG == 'pemasukan') && objekMisi == 'transaksi' && minMisi <= minG) {
              throw GalatKonten(
                'Misi ada_data ($objekMisi min: $minMisi) otomatis terpenuhi oleh gerbang pelajaran ($objG min: $minG). Misi tidak boleh lebih longgar atau sama dengan gerbang.',
                berkas: namaBerkas,
                kolom: 'misi',
              );
            }
          }

          if (tipeMisi == 'aturan_data' && tipeG == 'aturan_data') {
            if (aturanG != null && aturanMisi != null && aturanG == aturanMisi) {
              throw GalatKonten(
                'Misi aturan_data ($aturanMisi) otomatis terpenuhi oleh gerbang pelajaran dengan aturan yang sama. Misi tidak boleh sama dengan gerbang.',
                berkas: namaBerkas,
                kolom: 'misi',
              );
            }
          }
        }
      }
    }

    final tindakLanjut = data['tindakLanjut'] as String?;
    if (tindakLanjut != null && tindakLanjut.isNotEmpty) {
      _periksaIstilahKamus(tindakLanjut, daftarIstilahKamus, namaBerkas, 'tindakLanjut');
      periksaBahasaTeks(tindakLanjut, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      if (isModul5) {
        periksaTeksSensitifModul5(tindakLanjut, namaBerkas: namaBerkas, kolom: 'tindakLanjut');
      }
    }
  }

  static void _periksaIstilahKamus(
    String teks,
    Set<String>? daftarIstilahKamus,
    String namaBerkas,
    String kolom,
  ) {
    if (daftarIstilahKamus == null) return;
    final matches = _polaIstilahKamus.allMatches(teks);
    for (final m in matches) {
      final istilah = m.group(1)?.toLowerCase().trim();
      if (istilah != null && !daftarIstilahKamus.contains(istilah)) {
        throw GalatKonten('Istilah {{$istilah}} tidak ditemukan di kamus.json', berkas: namaBerkas, kolom: kolom);
      }
    }
  }

  /// Pemeriksa bahasa ringan sesuai styleguide Funda.
  static void periksaBahasaTeks(
    String teks, {
    required String namaBerkas,
    List<String>? daftarPeringatan,
  }) {
    final lower = teks.toLowerCase();

    // 1. Cek kata terlarang (boros, bodoh, malas, salah untuk perilaku pengguna)
    for (final kata in kataTerlarang) {
      final reg = RegExp('\\b$kata\\b', caseSensitive: false);
      if (reg.hasMatch(lower)) {
        throw GalatKonten('Kata terlarang "$kata" ditemukan di teks. Gunakan bahasa yang memberdayakan tanpa menghakimi.', berkas: namaBerkas);
      }
    }

    // Cek kata "salah" yang menghakimi perilaku pengguna (misal: "kamu salah", "cara yang salah", dll)
    if (RegExp(r'\b(kamu salah|cara.*salah|perilaku.*salah|tindakan.*salah)\b', caseSensitive: false).hasMatch(lower)) {
      throw GalatKonten('Frasa menghakimi "salah" ditemukan. Hindari menyalahkan perilaku pengguna.', berkas: namaBerkas);
    }

    // 2. Cek istilah teknis yang dilarang muncul sebagai teks polos tanpa {{ }}
    final teksTanpaKurung = teks.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '');
    for (final istilah in istilahTeknisWajibKurung) {
      final reg = RegExp('\\b$istilah\\b', caseSensitive: false);
      if (reg.hasMatch(teksTanpaKurung)) {
        throw GalatKonten(
          'Istilah teknis "$istilah" dilarang muncul sebagai teks polos tanpa tooltip. Wajib dibungkus format {{$istilah}} agar memiliki penjelasan bantuan.',
          berkas: namaBerkas,
        );
      }
    }

    // 3. Kalimat > 25 kata -> Peringatan
    final kalimatList = teks.split(RegExp(r'[.!?]')).map((s) => s.trim()).where((s) => s.isNotEmpty);
    for (final k in kalimatList) {
      final jumlahKata = k.split(RegExp(r'\s+')).length;
      if (jumlahKata > 25) {
        daftarPeringatan?.add('[$namaBerkas] Kalimat panjang ($jumlahKata kata > 25 kata): "$k"');
      }
    }
  }

  /// Pemeriksa khusus teks sensitif Modul 5 (waspada penipuan):
  /// Galat bila memuat "http", "www", "@", "OJK", "BSSN", atau urutan digit >= 8 tanpa titik pemisah.
  static void periksaTeksSensitifModul5(
    String teks, {
    required String namaBerkas,
    required String kolom,
  }) {
    final lower = teks.toLowerCase();
    if (lower.contains('http')) {
      throw GalatKonten('Teks pada $kolom memuat tautan web ("http") yang dilarang pada Modul 5: "$teks"', berkas: namaBerkas, kolom: kolom);
    }
    if (lower.contains('www')) {
      throw GalatKonten('Teks pada $kolom memuat alamat web ("www") yang dilarang pada Modul 5: "$teks"', berkas: namaBerkas, kolom: kolom);
    }
    if (teks.contains('@')) {
      throw GalatKonten('Teks pada $kolom memuat simbol surel/sosial media ("@") yang dilarang pada Modul 5: "$teks"', berkas: namaBerkas, kolom: kolom);
    }
    if (RegExp(r'\bojk\b', caseSensitive: false).hasMatch(teks)) {
      throw GalatKonten('Teks pada $kolom menyebut nama lembaga "OJK" yang dilarang pada Modul 5: "$teks"', berkas: namaBerkas, kolom: kolom);
    }
    if (RegExp(r'\bbssn\b', caseSensitive: false).hasMatch(teks)) {
      throw GalatKonten('Teks pada $kolom menyebut nama lembaga "BSSN" yang dilarang pada Modul 5: "$teks"', berkas: namaBerkas, kolom: kolom);
    }
    if (RegExp(r'\d{8,}').hasMatch(teks)) {
      throw GalatKonten('Teks pada $kolom memuat urutan digit >= 8 tanpa titik pemisah (indikasi nomor telepon) yang dilarang pada Modul 5: "$teks"', berkas: namaBerkas, kolom: kolom);
    }
  }

  /// Memvalidasi berkas aset/konten/disclaimer.json
  static void validasiBerkasDisclaimer(Map<String, dynamic> data, {required String namaBerkas}) {
    if (!data.containsKey('langkahDuniaNyata')) {
      throw GalatKonten('Kunci "langkahDuniaNyata" wajib ada pada disclaimer.json', berkas: namaBerkas, kolom: 'langkahDuniaNyata');
    }
    final teks = data['langkahDuniaNyata'];
    if (teks is! String || teks.trim().isEmpty) {
      throw GalatKonten('Nilai "langkahDuniaNyata" wajib berupa string tidak kosong', berkas: namaBerkas, kolom: 'langkahDuniaNyata');
    }
    const teksResmi =
        'Funda hanya memberi edukasi umum. Ini bukan ajakan membeli produk keuangan atau '
        'nasihat keuangan, hukum, maupun pajak. Keputusan dan risikonya ada padamu. '
        'Funda tidak bertanggung jawab atas kerugian dari tindakan di luar aplikasi. '
        'Pastikan penyedia berizin sebelum memakai uangmu.';
    if (teks.replaceAll(RegExp(r'\s+'), ' ').trim() != teksResmi.replaceAll(RegExp(r'\s+'), ' ').trim()) {
      throw GalatKonten('Isi teks langkahDuniaNyata pada disclaimer.json tidak sesuai dengan lampiran resmi', berkas: namaBerkas, kolom: 'langkahDuniaNyata');
    }
  }

  static const Set<String> kunciProfilValid = {
    'punya_penghasilan',
    'punya_utang',
    'dana_darurat',
    'menabung',
    'investasi',
    'mencatat_keuangan',
  };

  static const Map<String, Set<String>> nilaiPilihanProfilValid = {
    'punya_penghasilan': {'rutin', 'tidak_rutin', 'belum'},
    'punya_utang': {'ya', 'tidak', 'tidak_yakin'},
    'dana_darurat': {'belum', 'sedikit', 'sudah'},
    'menabung': {'belum', 'kadang', 'rutin'},
    'investasi': {'belum', 'pernah', 'aktif'},
    'mencatat_keuangan': {'belum', 'kadang', 'rutin'},
  };

  static const Set<String> kodeAlasanRekomendasiValid = {
    'skor_tes_rendah',
    'punya_utang_tercatat',
    'dana_darurat_kosong',
    'keinginan_terbesar',
    'belum_ada_modul_selesai',
  };

  static const Set<String> modulTesAwalValid = {
    'anggaran_arus_kas',
    'tabungan',
    'dana_darurat',
    'utang_cicilan',
    'waspada_penipuan',
    'psikologi_uang',
  };

  /// Memuat kamus dari aset aplikasi.
  static Future<Map<String, IstilahKamus>> muatKamusDariAset(AssetBundle bundle) async {
    final jsonString = await bundle.loadString('aset/konten/kamus.json');
    return uraiKamus(jsonString, namaBerkas: 'aset/konten/kamus.json');
  }

  /// Memuat modul dari aset aplikasi.
  static Future<ModulKonten> muatModulDariAset(
    AssetBundle bundle, {
    required String tingkat,
    required String modulId,
  }) async {
    final path = 'aset/konten/$tingkat/$modulId/modul.json';
    final jsonString = await bundle.loadString(path);
    return uraiModul(jsonString, namaBerkas: path);
  }

  static final Map<String, PelajaranKonten> _cachePelajaran = {};

  /// Membersihkan cache pelajaran (untuk keperluan pengujian jika diperlukan).
  static void bersihkanCachePelajaran() {
    _cachePelajaran.clear();
  }

  /// Memuat pelajaran dari aset aplikasi (dengan cache in-memory O(1)).
  static Future<PelajaranKonten> muatPelajaranDariAset(
    AssetBundle bundle, {
    required String tingkat,
    required String modulId,
    required String pelajaranId,
    Set<String>? daftarIstilahKamus,
  }) async {
    final path = 'aset/konten/$tingkat/$modulId/$pelajaranId.json';
    if (_cachePelajaran.containsKey(path)) {
      return _cachePelajaran[path]!;
    }
    final jsonString = await bundle.loadString(path);
    final pel = uraiPelajaran(
      jsonString,
      namaBerkas: path,
      daftarIstilahKamus: daftarIstilahKamus,
    );
    _cachePelajaran[path] = pel;
    return pel;
  }

  /// Mengurai dan memvalidasi berkas tes awal.
  static KontenTesAwal uraiTesAwal(
    String jsonString, {
    String namaBerkas = 'tes_awal.json',
    Set<String>? daftarIstilahKamus,
    List<String>? daftarPeringatan,
  }) {
    final dynamic data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      throw GalatKonten('Tes awal harus berupa objek JSON', berkas: namaBerkas);
    }
    validasiKontenTesAwal(
      data,
      namaBerkas: namaBerkas,
      daftarIstilahKamus: daftarIstilahKamus,
      daftarPeringatan: daftarPeringatan,
    );
    return KontenTesAwal.fromJson(data);
  }

  /// Memvalidasi berkas tes awal.
  static void validasiKontenTesAwal(
    Map<String, dynamic> data, {
    required String namaBerkas,
    Set<String>? daftarIstilahKamus,
    List<String>? daftarPeringatan,
  }) {
    final judul = data['judul'] as String?;
    if (judul == null || judul.trim().isEmpty) {
      throw GalatKonten('Kolom judul tes awal wajib ada', berkas: namaBerkas, kolom: 'judul');
    }
    final deskripsi = data['deskripsi'] as String?;
    if (deskripsi == null || deskripsi.trim().isEmpty) {
      throw GalatKonten('Kolom deskripsi tes awal wajib ada', berkas: namaBerkas, kolom: 'deskripsi');
    }

    periksaBahasaTeks(judul, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    periksaBahasaTeks(deskripsi, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);

    // 1. Validasi 6 pertanyaan profil
    final pertanyaanProfil = data['pertanyaanProfil'];
    if (pertanyaanProfil is! List || pertanyaanProfil.length != 6) {
      throw GalatKonten(
        'Kolom pertanyaanProfil wajib berisi tepat 6 pertanyaan kondisi profil',
        berkas: namaBerkas,
        kolom: 'pertanyaanProfil',
      );
    }

    final setKunci = <String>{};
    for (var i = 0; i < pertanyaanProfil.length; i++) {
      final p = pertanyaanProfil[i];
      if (p is! Map<String, dynamic>) {
        throw GalatKonten('Pertanyaan profil indeks $i bukan objek JSON', berkas: namaBerkas, kolom: 'pertanyaanProfil[$i]');
      }
      final kunci = p['kunci'] as String?;
      if (kunci == null || !kunciProfilValid.contains(kunci)) {
        throw GalatKonten('Kunci profil tidak dikenal: "$kunci"', berkas: namaBerkas, kolom: 'pertanyaanProfil[$i].kunci');
      }
      if (!setKunci.add(kunci)) {
        throw GalatKonten('Kunci profil duplikat: "$kunci"', berkas: namaBerkas, kolom: 'pertanyaanProfil[$i].kunci');
      }
      final tanya = p['tanya'] as String?;
      if (tanya == null || tanya.trim().isEmpty) {
        throw GalatKonten('Kolom tanya wajib diisi', berkas: namaBerkas, kolom: 'pertanyaanProfil[$i].tanya');
      }
      periksaBahasaTeks(tanya, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);

      final pilihan = p['pilihan'];
      if (pilihan is! List || pilihan.length < 2) {
        throw GalatKonten('Pilihan pertanyaan profil minimal 2 opsi', berkas: namaBerkas, kolom: 'pertanyaanProfil[$i].pilihan');
      }
      for (final pil in pilihan) {
        if (pil is! Map<String, dynamic> || pil['nilai'] == null || pil['teks'] == null) {
          throw GalatKonten('Format pilihan profil tidak valid', berkas: namaBerkas, kolom: 'pertanyaanProfil[$i].pilihan');
        }
        final nilai = pil['nilai'] as String;
        if (!nilaiPilihanProfilValid[kunci]!.contains(nilai)) {
          throw GalatKonten(
            'Nilai pilihan profil tidak valid: "$nilai" untuk kunci "$kunci"',
            berkas: namaBerkas,
            kolom: 'pertanyaanProfil[$i].pilihan',
          );
        }
        final teksPil = pil['teks'] as String;
        periksaBahasaTeks(teksPil, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      }
    }

    // 2. Validasi tujuan utama
    final tujuanUtama = data['tujuanUtama'];
    if (tujuanUtama is! Map<String, dynamic>) {
      throw GalatKonten('Kolom tujuanUtama wajib ada sebagai objek JSON', berkas: namaBerkas, kolom: 'tujuanUtama');
    }
    final maxChar = tujuanUtama['maksimalKarakter'];
    if (maxChar is! num || maxChar <= 0) {
      throw GalatKonten('Kolom maksimalKarakter wajib berupa angka > 0', berkas: namaBerkas, kolom: 'tujuanUtama.maksimalKarakter');
    }

    // 3. Validasi 12 butir soal tes awal (tepat 2 per modul pemula)
    final soalTesAwal = data['soalTesAwal'];
    if (soalTesAwal is! List || soalTesAwal.length != 12) {
      throw GalatKonten(
        'Kolom soalTesAwal wajib berisi tepat 12 soal (tepat 2 soal per modul)',
        berkas: namaBerkas,
        kolom: 'soalTesAwal',
      );
    }

    final hitungModul = <String, int>{};
    final setSoalId = <String>{};

    for (var i = 0; i < soalTesAwal.length; i++) {
      final s = soalTesAwal[i];
      if (s is! Map<String, dynamic>) {
        throw GalatKonten('Soal tes awal indeks $i bukan objek JSON', berkas: namaBerkas, kolom: 'soalTesAwal[$i]');
      }
      final sId = s['id'] as String?;
      if (sId == null || !setSoalId.add(sId)) {
        throw GalatKonten('ID soal tes awal kosong atau duplikat: "$sId"', berkas: namaBerkas, kolom: 'soalTesAwal[$i].id');
      }
      final modulId = s['modulId'] as String?;
      if (modulId == null || !modulTesAwalValid.contains(modulId)) {
        throw GalatKonten('Soal mereferensikan modulId tidak valid: "$modulId"', berkas: namaBerkas, kolom: 'soalTesAwal[$i].modulId');
      }
      hitungModul[modulId] = (hitungModul[modulId] ?? 0) + 1;

      final tanya = s['tanya'] as String?;
      if (tanya == null || tanya.trim().isEmpty) {
        throw GalatKonten('Pertanyaan soal wajib diisi', berkas: namaBerkas, kolom: 'soalTesAwal[$i].tanya');
      }
      periksaBahasaTeks(tanya, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      if (daftarIstilahKamus != null) {
        _periksaIstilahKamus(tanya, daftarIstilahKamus, namaBerkas, 'soalTesAwal[$i].tanya');
      }

      final pilihan = s['pilihan'];
      if (pilihan is! List || pilihan.length != 4) {
        throw GalatKonten('Setiap soal tes awal wajib memiliki tepat 4 pilihan jawaban', berkas: namaBerkas, kolom: 'soalTesAwal[$i].pilihan');
      }

      for (var pIdx = 0; pIdx < pilihan.length; pIdx++) {
        final pilTeks = pilihan[pIdx]?.toString().trim() ?? '';
        periksaBahasaTeks(pilTeks, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
        if (daftarIstilahKamus != null) {
          _periksaIstilahKamus(pilTeks, daftarIstilahKamus, namaBerkas, 'soalTesAwal[$i].pilihan[$pIdx]');
        }
      }

      final opsiTerakhir = pilihan[3]?.toString().trim();
      if (opsiTerakhir != 'Belum tahu, nggak apa-apa') {
        throw GalatKonten(
          'Opsi ke-4 wajib berupa "Belum tahu, nggak apa-apa" untuk menjaga kenyamanan pengguna',
          berkas: namaBerkas,
          kolom: 'soalTesAwal[$i].pilihan[3]',
        );
      }

      final benar = s['benar'];
      if (benar is! num || benar < 0 || benar >= 3) {
        throw GalatKonten(
          'Indeks jawaban benar harus antara 0 sampai 2 (tidak boleh menunjuk ke opsi "Belum tahu, nggak apa-apa")',
          berkas: namaBerkas,
          kolom: 'soalTesAwal[$i].benar',
        );
      }

      final penjelasan = s['penjelasan'] as String?;
      if (penjelasan == null || penjelasan.trim().isEmpty) {
        throw GalatKonten('Penjelasan soal wajib diisi', berkas: namaBerkas, kolom: 'soalTesAwal[$i].penjelasan');
      }
      periksaBahasaTeks(penjelasan, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      if (daftarIstilahKamus != null) {
        _periksaIstilahKamus(penjelasan, daftarIstilahKamus, namaBerkas, 'soalTesAwal[$i].penjelasan');
      }

      // Larangan angka aturan praktis, tarif, atau regulasi
      final cekAturanPraktis = RegExp(
        r'(50/30/20|aturan 50|aturan 20|tarif pajak \d+%|bunga pinjol \d+%|pasal \d+|uu no|peraturan ojk)',
        caseSensitive: false,
      );
      if (cekAturanPraktis.hasMatch(tanya) || cekAturanPraktis.hasMatch(penjelasan)) {
        throw GalatKonten(
          'Soal tes awal dilarang memuat angka aturan praktis, tarif spesifik, atau regulasi',
          berkas: namaBerkas,
          kolom: 'soalTesAwal[$i]',
        );
      }
    }

    // Pastikan setiap modul pemula diuji tepat 2 soal
    for (final m in modulTesAwalValid) {
      if ((hitungModul[m] ?? 0) != 2) {
        throw GalatKonten('Modul "$m" harus memiliki tepat 2 butir soal di tes awal', berkas: namaBerkas, kolom: 'soalTesAwal');
      }
    }
  }

  /// Mengurai dan memvalidasi berkas rekomendasi.
  static KontenRekomendasi uraiRekomendasi(
    String jsonString, {
    String namaBerkas = 'rekomendasi.json',
    List<String>? daftarPeringatan,
  }) {
    final dynamic data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      throw GalatKonten('Rekomendasi harus berupa objek JSON', berkas: namaBerkas);
    }
    final alasan = data['alasan'];
    if (alasan is! Map<String, dynamic> || alasan.isEmpty) {
      throw GalatKonten('Kolom alasan wajib berupa objek tidak kosong', berkas: namaBerkas, kolom: 'alasan');
    }

    for (final kodeResmi in kodeAlasanRekomendasiValid) {
      if (!alasan.containsKey(kodeResmi)) {
        throw GalatKonten('Kode alasan resmi "$kodeResmi" wajib ada di rekomendasi.json', berkas: namaBerkas, kolom: 'alasan');
      }
    }
    for (final key in alasan.keys) {
      if (!kodeAlasanRekomendasiValid.contains(key)) {
        throw GalatKonten('Kode alasan asing "$key" tidak didukung oleh kode murni aplikasi', berkas: namaBerkas, kolom: 'alasan.$key');
      }
      final item = alasan[key];
      if (item is! Map<String, dynamic>) {
        throw GalatKonten('Item alasan "$key" harus berupa objek JSON', berkas: namaBerkas, kolom: 'alasan.$key');
      }
      final judul = item['judul'] as String?;
      final deskripsi = item['deskripsi'] as String?;
      if (judul == null || judul.trim().isEmpty) {
        throw GalatKonten('Kolom judul alasan wajib ada', berkas: namaBerkas, kolom: 'alasan.$key.judul');
      }
      if (deskripsi == null || deskripsi.trim().isEmpty) {
        throw GalatKonten('Kolom deskripsi alasan wajib ada', berkas: namaBerkas, kolom: 'alasan.$key.deskripsi');
      }
      periksaBahasaTeks(judul, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      periksaBahasaTeks(deskripsi, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);

      final cekKlaim = RegExp(r'(terlalu tinggi|terlalu rendah|keuangan buruk|keuangan rusak|boros|harus hemat)', caseSensitive: false);
      if (cekKlaim.hasMatch(judul) || cekKlaim.hasMatch(deskripsi)) {
        throw GalatKonten('Teks rekomendasi tidak boleh memuat klaim keuangan atau penilaian', berkas: namaBerkas, kolom: 'alasan.$key');
      }
    }

    return KontenRekomendasi.fromJson(data);
  }

  /// Memuat tes awal dari aset aplikasi.
  static Future<KontenTesAwal> muatTesAwalDariAset(AssetBundle bundle) async {
    const path = 'aset/konten/pemula/mulai_tes_awal/tes_awal.json';
    final jsonString = await bundle.loadString(path);
    return uraiTesAwal(jsonString, namaBerkas: path);
  }

  /// Memuat rekomendasi dari aset aplikasi.
  static Future<KontenRekomendasi> muatRekomendasiDariAset(AssetBundle bundle) async {
    const path = 'aset/konten/rekomendasi.json';
    final jsonString = await bundle.loadString(path);
    return uraiRekomendasi(jsonString, namaBerkas: path);
  }

  static const Set<String> placeholderLaporanValid = {
    'nama',
    'jumlah',
    'persen',
    'sifat',
    'tanggal',
    'n',
    'a',
    'b',
    'c',
    'target',
    'dana',
    'terpakai',
    'batas',
  };

  static const Set<String> kodeTemuanLaporanResmi = {
    'pos_melewati',
    'arus_kas_tanpa_pemasukan',
    'arus_kas_negatif',
    'sifat_terbesar',
    'arus_kas_positif',
    'data_belum_cukup',
  };

  static const Set<String> kodeSaranLaporanResmi = {
    'buat_anggaran',
    'tinjau_pos',
    'beri_label',
    'salin_anggaran',
  };

  static void _periksaPlaceholderLaporan(String teks, String namaBerkas, String kolom) {
    final matches = RegExp(r'\{([^}]+)\}').allMatches(teks);
    for (final m in matches) {
      final tag = m.group(1)?.trim();
      if (tag != null && !placeholderLaporanValid.contains(tag)) {
        throw GalatKonten('Placeholder {$tag} tidak dikenal dalam template laporan', berkas: namaBerkas, kolom: kolom);
      }
    }
  }

  static void _periksaKlaimKeuangan(String teks, String namaBerkas, String kolom) {
    final reg = RegExp(r'(pasti untung|dijamin untung|pasti kaya|bebas finansial dalam)', caseSensitive: false);
    if (reg.hasMatch(teks)) {
      throw GalatKonten('Klaim keuangan tidak berdasar terdeteksi pada teks laporan', berkas: namaBerkas, kolom: kolom);
    }
  }

  /// Mengurai dan memvalidasi berkas laporan.json.
  static KontenLaporan uraiLaporan(
    String jsonString, {
    String namaBerkas = 'laporan.json',
    List<String>? daftarPeringatan,
  }) {
    final dynamic data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      throw GalatKonten('Laporan harus berupa objek JSON', berkas: namaBerkas);
    }
    validasiKontenLaporan(data, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    return KontenLaporan.fromJson(data);
  }

  /// Memvalidasi integritas struktur berkas laporan.json.
  static void validasiKontenLaporan(
    Map<String, dynamic> data, {
    required String namaBerkas,
    List<String>? daftarPeringatan,
  }) {
    // 1. Judul Bagian
    final judul = data['judulBagian'];
    if (judul is! Map<String, dynamic>) {
      throw GalatKonten('Kolom judulBagian wajib berupa objek JSON', berkas: namaBerkas, kolom: 'judulBagian');
    }
    const kunciJudulWajib = ['arusKas', 'komposisi', 'anggaran', 'tujuan', 'kekayaan', 'temuan', 'saran'];
    for (final k in kunciJudulWajib) {
      final val = judul[k] as String?;
      if (val == null || val.trim().isEmpty) {
        throw GalatKonten('Judul bagian "$k" wajib ada dan tidak boleh kosong', berkas: namaBerkas, kolom: 'judulBagian.$k');
      }
      periksaBahasaTeks(val, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    // 2. Label
    final label = data['label'];
    if (label is! Map<String, dynamic>) {
      throw GalatKonten('Kolom label wajib berupa objek JSON', berkas: namaBerkas, kolom: 'label');
    }
    const kunciLabelWajib = ['uangMasuk', 'uangKeluar', 'selisih', 'perTanggal', 'disembunyikan'];
    for (final k in kunciLabelWajib) {
      final val = label[k] as String?;
      if (val == null || val.trim().isEmpty) {
        throw GalatKonten('Label "$k" wajib ada dan tidak boleh kosong', berkas: namaBerkas, kolom: 'label.$k');
      }
      _periksaPlaceholderLaporan(val, namaBerkas, 'label.$k');
      periksaBahasaTeks(val, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    // 3. Frasa Sifat
    final frasaSifat = data['frasaSifat'];
    if (frasaSifat is! Map<String, dynamic>) {
      throw GalatKonten('Kolom frasaSifat wajib berupa objek JSON', berkas: namaBerkas, kolom: 'frasaSifat');
    }
    const kunciSifatWajib = ['kebutuhan', 'keinginan', 'tabungan', 'utang', 'belumDilabeli'];
    for (final k in kunciSifatWajib) {
      final val = frasaSifat[k] as String?;
      if (val == null || val.trim().isEmpty) {
        throw GalatKonten('Frasa sifat "$k" wajib ada dan tidak boleh kosong', berkas: namaBerkas, kolom: 'frasaSifat.$k');
      }
      periksaBahasaTeks(val, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    // 4. Catatan Kaki
    final catatanKaki = data['catatanKaki'];
    if (catatanKaki is! Map<String, dynamic>) {
      throw GalatKonten('Kolom catatanKaki wajib berupa objek JSON', berkas: namaBerkas, kolom: 'catatanKaki');
    }
    const kunciCatatanWajib = ['ekspor', 'aplikasi'];
    for (final k in kunciCatatanWajib) {
      final val = catatanKaki[k] as String?;
      if (val == null || val.trim().isEmpty) {
        throw GalatKonten('Catatan kaki "$k" wajib ada dan tidak boleh kosong', berkas: namaBerkas, kolom: 'catatanKaki.$k');
      }
      periksaBahasaTeks(val, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    // 5. Baris
    final baris = data['baris'];
    if (baris is! Map<String, dynamic>) {
      throw GalatKonten('Kolom baris wajib berupa objek JSON', berkas: namaBerkas, kolom: 'baris');
    }
    const barisTeksTunggal = [
      'ringkasanAnggaran',
      'posLain',
      'saldoDompet',
      'sisaUtang',
      'kekayaanBersih',
      'arusKasSensor',
      'belumAdaAnggaran',
      'belumAdaTujuan',
      'belumAdaData',
    ];
    for (final k in barisTeksTunggal) {
      final val = baris[k] as String?;
      if (val == null || val.trim().isEmpty) {
        throw GalatKonten('Baris "$k" wajib ada dan tidak boleh kosong', berkas: namaBerkas, kolom: 'baris.$k');
      }
      _periksaPlaceholderLaporan(val, namaBerkas, 'baris.$k');
      _periksaKlaimKeuangan(val, namaBerkas, 'baris.$k');
      periksaBahasaTeks(val, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    // Periksa posAnggaran (normal & sensor)
    final posAnggaran = baris['posAnggaran'];
    if (posAnggaran is! Map<String, dynamic>) {
      throw GalatKonten('Baris posAnggaran wajib berupa objek dengan normal & sensor', berkas: namaBerkas, kolom: 'baris.posAnggaran');
    }
    for (final mode in ['normal', 'sensor']) {
      final val = posAnggaran[mode] as String?;
      if (val == null || val.trim().isEmpty) {
        throw GalatKonten('posAnggaran mode "$mode" wajib ada', berkas: namaBerkas, kolom: 'baris.posAnggaran.$mode');
      }
      _periksaPlaceholderLaporan(val, namaBerkas, 'baris.posAnggaran.$mode');
      periksaBahasaTeks(val, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    // Periksa tujuan (normal & sensor)
    final tujuan = baris['tujuan'];
    if (tujuan is! Map<String, dynamic>) {
      throw GalatKonten('Baris tujuan wajib berupa objek dengan normal & sensor', berkas: namaBerkas, kolom: 'baris.tujuan');
    }
    for (final mode in ['normal', 'sensor']) {
      final val = tujuan[mode] as String?;
      if (val == null || val.trim().isEmpty) {
        throw GalatKonten('tujuan mode "$mode" wajib ada', berkas: namaBerkas, kolom: 'baris.tujuan.$mode');
      }
      _periksaPlaceholderLaporan(val, namaBerkas, 'baris.tujuan.$mode');
      periksaBahasaTeks(val, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    // 6. Temuan
    final temuan = data['temuan'];
    if (temuan is! Map<String, dynamic>) {
      throw GalatKonten('Kolom temuan wajib berupa objek JSON', berkas: namaBerkas, kolom: 'temuan');
    }
    final kodeDitemukanTemuan = <String>{};
    for (final entry in temuan.entries) {
      final item = entry.value;
      if (item is! Map<String, dynamic>) {
        throw GalatKonten('Item temuan "${entry.key}" bukan objek JSON', berkas: namaBerkas, kolom: 'temuan.${entry.key}');
      }
      final kode = item['kode'] as String?;
      if (kode == null || !kodeTemuanLaporanResmi.contains(kode)) {
        throw GalatKonten('Kode temuan tidak valid atau asing: "$kode"', berkas: namaBerkas, kolom: 'temuan.${entry.key}.kode');
      }
      kodeDitemukanTemuan.add(kode);

      final normal = item['normal'] as String?;
      final sensor = item['sensor'] as String?;
      if (normal == null || normal.trim().isEmpty) {
        throw GalatKonten('Teks temuan normal "$kode" tidak boleh kosong', berkas: namaBerkas, kolom: 'temuan.${entry.key}.normal');
      }
      if (sensor == null || sensor.trim().isEmpty) {
        throw GalatKonten('Teks temuan sensor "$kode" tidak boleh kosong', berkas: namaBerkas, kolom: 'temuan.${entry.key}.sensor');
      }
      _periksaPlaceholderLaporan(normal, namaBerkas, 'temuan.${entry.key}.normal');
      _periksaPlaceholderLaporan(sensor, namaBerkas, 'temuan.${entry.key}.sensor');
      _periksaKlaimKeuangan(normal, namaBerkas, 'temuan.${entry.key}.normal');
      _periksaKlaimKeuangan(sensor, namaBerkas, 'temuan.${entry.key}.sensor');
      periksaBahasaTeks(normal, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
      periksaBahasaTeks(sensor, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    for (final kodeResmi in kodeTemuanLaporanResmi) {
      if (!kodeDitemukanTemuan.contains(kodeResmi)) {
        throw GalatKonten('Kode temuan resmi "$kodeResmi" wajib ada di temuan', berkas: namaBerkas, kolom: 'temuan');
      }
    }

    // 7. Saran
    final saran = data['saran'];
    if (saran is! Map<String, dynamic>) {
      throw GalatKonten('Kolom saran wajib berupa objek JSON', berkas: namaBerkas, kolom: 'saran');
    }
    final kodeDitemukanSaran = <String>{};
    for (final entry in saran.entries) {
      final item = entry.value;
      if (item is! Map<String, dynamic>) {
        throw GalatKonten('Item saran "${entry.key}" bukan objek JSON', berkas: namaBerkas, kolom: 'saran.${entry.key}');
      }
      final kode = item['kode'] as String?;
      if (kode == null || !kodeSaranLaporanResmi.contains(kode)) {
        throw GalatKonten('Kode saran tidak valid atau asing: "$kode"', berkas: namaBerkas, kolom: 'saran.${entry.key}.kode');
      }
      kodeDitemukanSaran.add(kode);

      final teks = item['teks'] as String?;
      if (teks == null || teks.trim().isEmpty) {
        throw GalatKonten('Teks saran "$kode" tidak boleh kosong', berkas: namaBerkas, kolom: 'saran.${entry.key}.teks');
      }
      _periksaPlaceholderLaporan(teks, namaBerkas, 'saran.${entry.key}.teks');
      _periksaKlaimKeuangan(teks, namaBerkas, 'saran.${entry.key}.teks');
      periksaBahasaTeks(teks, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
    }

    for (final kodeResmi in kodeSaranLaporanResmi) {
      if (!kodeDitemukanSaran.contains(kodeResmi)) {
        throw GalatKonten('Kode saran resmi "$kodeResmi" wajib ada di saran', berkas: namaBerkas, kolom: 'saran');
      }
    }
  }

  /// Memuat konten laporan dari aset aplikasi.
  static Future<KontenLaporan> muatLaporanDariAset(
    AssetBundle bundle, {
    String path = 'aset/konten/laporan.json',
  }) async {
    final jsonString = await bundle.loadString(path);
    return uraiLaporan(jsonString, namaBerkas: path);
  }
}

/// Model butir pertanyaan profil keuangan di tes awal.
class PertanyaanProfilKonten {
  final String kunci;
  final String tanya;
  final List<PilihanProfilKonten> pilihan;

  const PertanyaanProfilKonten({
    required this.kunci,
    required this.tanya,
    required this.pilihan,
  });

  factory PertanyaanProfilKonten.fromJson(Map<String, dynamic> json) {
    return PertanyaanProfilKonten(
      kunci: json['kunci'] as String? ?? '',
      tanya: json['tanya'] as String? ?? '',
      pilihan: (json['pilihan'] as List<dynamic>?)
              ?.map((e) => PilihanProfilKonten.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PilihanProfilKonten {
  final String nilai;
  final String teks;

  const PilihanProfilKonten({required this.nilai, required this.teks});

  factory PilihanProfilKonten.fromJson(Map<String, dynamic> json) {
    return PilihanProfilKonten(
      nilai: json['nilai'] as String? ?? '',
      teks: json['teks'] as String? ?? '',
    );
  }
}

class TujuanUtamaKonten {
  final String tanya;
  final String petunjuk;
  final int maksimalKarakter;

  const TujuanUtamaKonten({
    required this.tanya,
    required this.petunjuk,
    required this.maksimalKarakter,
  });

  factory TujuanUtamaKonten.fromJson(Map<String, dynamic> json) {
    return TujuanUtamaKonten(
      tanya: json['tanya'] as String? ?? '',
      petunjuk: json['petunjuk'] as String? ?? '',
      maksimalKarakter: (json['maksimalKarakter'] as num?)?.toInt() ?? 100,
    );
  }
}

class SoalTesAwalKonten {
  final String id;
  final String modulId;
  final String tanya;
  final List<String> pilihan;
  final int benar;
  final String penjelasan;

  const SoalTesAwalKonten({
    required this.id,
    required this.modulId,
    required this.tanya,
    required this.pilihan,
    required this.benar,
    required this.penjelasan,
  });

  factory SoalTesAwalKonten.fromJson(Map<String, dynamic> json) {
    return SoalTesAwalKonten(
      id: json['id'] as String? ?? '',
      modulId: json['modulId'] as String? ?? '',
      tanya: json['tanya'] as String? ?? '',
      pilihan: (json['pilihan'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      benar: (json['benar'] as num?)?.toInt() ?? 0,
      penjelasan: json['penjelasan'] as String? ?? '',
    );
  }
}

class KontenTesAwal {
  final int versi;
  final String judul;
  final String deskripsi;
  final List<PertanyaanProfilKonten> pertanyaanProfil;
  final TujuanUtamaKonten tujuanUtama;
  final List<SoalTesAwalKonten> soalTesAwal;

  const KontenTesAwal({
    required this.versi,
    required this.judul,
    required this.deskripsi,
    required this.pertanyaanProfil,
    required this.tujuanUtama,
    required this.soalTesAwal,
  });

  factory KontenTesAwal.fromJson(Map<String, dynamic> json) {
    return KontenTesAwal(
      versi: (json['versi'] as num?)?.toInt() ?? 1,
      judul: json['judul'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      pertanyaanProfil: (json['pertanyaanProfil'] as List<dynamic>?)
              ?.map((e) => PertanyaanProfilKonten.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tujuanUtama: TujuanUtamaKonten.fromJson(json['tujuanUtama'] as Map<String, dynamic>? ?? {}),
      soalTesAwal: (json['soalTesAwal'] as List<dynamic>?)
              ?.map((e) => SoalTesAwalKonten.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RekomendasiItemKonten {
  final String judul;
  final String deskripsi;

  const RekomendasiItemKonten({required this.judul, required this.deskripsi});

  factory RekomendasiItemKonten.fromJson(Map<String, dynamic> json) {
    return RekomendasiItemKonten(
      judul: json['judul'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
    );
  }
}

class KontenRekomendasi {
  final int versi;
  final Map<String, RekomendasiItemKonten> alasan;

  const KontenRekomendasi({required this.versi, required this.alasan});

  factory KontenRekomendasi.fromJson(Map<String, dynamic> json) {
    final alasanMap = <String, RekomendasiItemKonten>{};
    final rawAlasan = json['alasan'] as Map<String, dynamic>? ?? {};
    for (final entry in rawAlasan.entries) {
      if (entry.value is Map<String, dynamic>) {
        alasanMap[entry.key] = RekomendasiItemKonten.fromJson(entry.value as Map<String, dynamic>);
      }
    }
    return KontenRekomendasi(
      versi: (json['versi'] as num?)?.toInt() ?? 1,
      alasan: alasanMap,
    );
  }
}

/// Item temuan laporan bulanan dengan teks mode normal dan sensor.
class ItemTemuanLaporan {
  final String kode;
  final String normal;
  final String sensor;

  const ItemTemuanLaporan({
    required this.kode,
    required this.normal,
    required this.sensor,
  });

  factory ItemTemuanLaporan.fromJson(Map<String, dynamic> json) {
    return ItemTemuanLaporan(
      kode: json['kode'] as String? ?? '',
      normal: json['normal'] as String? ?? '',
      sensor: json['sensor'] as String? ?? '',
    );
  }
}

/// Item saran laporan bulanan.
class ItemSaranLaporan {
  final String kode;
  final String teks;

  const ItemSaranLaporan({
    required this.kode,
    required this.teks,
  });

  factory ItemSaranLaporan.fromJson(Map<String, dynamic> json) {
    return ItemSaranLaporan(
      kode: json['kode'] as String? ?? '',
      teks: json['teks'] as String? ?? '',
    );
  }
}

/// Format baris teks laporan bulanan.
class FormatBarisLaporan {
  final String ringkasanAnggaran;
  final String posAnggaranNormal;
  final String posAnggaranSensor;
  final String posLain;
  final String tujuanNormal;
  final String tujuanSensor;
  final String saldoDompet;
  final String sisaUtang;
  final String kekayaanBersih;
  final String arusKasSensor;
  final String belumAdaAnggaran;
  final String belumAdaTujuan;
  final String belumAdaData;

  const FormatBarisLaporan({
    required this.ringkasanAnggaran,
    required this.posAnggaranNormal,
    required this.posAnggaranSensor,
    required this.posLain,
    required this.tujuanNormal,
    required this.tujuanSensor,
    required this.saldoDompet,
    required this.sisaUtang,
    required this.kekayaanBersih,
    required this.arusKasSensor,
    required this.belumAdaAnggaran,
    required this.belumAdaTujuan,
    required this.belumAdaData,
  });

  factory FormatBarisLaporan.fromJson(Map<String, dynamic> json) {
    final posAnggaran = json['posAnggaran'] is Map<String, dynamic>
        ? json['posAnggaran'] as Map<String, dynamic>
        : <String, dynamic>{};
    final tujuan = json['tujuan'] is Map<String, dynamic>
        ? json['tujuan'] as Map<String, dynamic>
        : <String, dynamic>{};

    return FormatBarisLaporan(
      ringkasanAnggaran: json['ringkasanAnggaran'] as String? ?? '',
      posAnggaranNormal: posAnggaran['normal'] as String? ?? '',
      posAnggaranSensor: posAnggaran['sensor'] as String? ?? '',
      posLain: json['posLain'] as String? ?? '',
      tujuanNormal: tujuan['normal'] as String? ?? '',
      tujuanSensor: tujuan['sensor'] as String? ?? '',
      saldoDompet: json['saldoDompet'] as String? ?? '',
      sisaUtang: json['sisaUtang'] as String? ?? '',
      kekayaanBersih: json['kekayaanBersih'] as String? ?? '',
      arusKasSensor: json['arusKasSensor'] as String? ?? '',
      belumAdaAnggaran: json['belumAdaAnggaran'] as String? ?? '',
      belumAdaTujuan: json['belumAdaTujuan'] as String? ?? '',
      belumAdaData: json['belumAdaData'] as String? ?? '',
    );
  }
}

/// Konten lengkap laporan bulanan yang dimuat dari aset/konten/laporan.json.
class KontenLaporan {
  final int versi;
  final Map<String, String> judulBagian;
  final Map<String, String> label;
  final Map<String, String> frasaSifat;
  final Map<String, String> catatanKaki;
  final FormatBarisLaporan baris;
  final Map<String, ItemTemuanLaporan> temuan;
  final Map<String, ItemSaranLaporan> saran;

  const KontenLaporan({
    required this.versi,
    required this.judulBagian,
    required this.label,
    required this.frasaSifat,
    required this.catatanKaki,
    required this.baris,
    required this.temuan,
    required this.saran,
  });

  String frasaUntukSifat(String sifatKode) {
    if (sifatKode == 'belum_dilabeli' || sifatKode == 'belumDilabeli') {
      return frasaSifat['belumDilabeli'] ?? frasaSifat['belum_dilabeli'] ?? 'pengeluaran yang belum dilabeli';
    }
    return frasaSifat[sifatKode] ?? sifatKode;
  }

  ItemTemuanLaporan? temuanUntukKode(String kode) => temuan[kode];
  ItemSaranLaporan? saranUntukKode(String kode) => saran[kode];

  factory KontenLaporan.fromJson(Map<String, dynamic> json) {
    final judul = (json['judulBagian'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v.toString()));
    final lbl = (json['label'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v.toString()));
    final sifat = (json['frasaSifat'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v.toString()));
    final kaki = (json['catatanKaki'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v.toString()));
    final b = FormatBarisLaporan.fromJson(json['baris'] as Map<String, dynamic>? ?? {});

    final temuanMap = <String, ItemTemuanLaporan>{};
    final rawTemuan = json['temuan'] as Map<String, dynamic>? ?? {};
    for (final entry in rawTemuan.entries) {
      if (entry.value is Map<String, dynamic>) {
        final item = ItemTemuanLaporan.fromJson(entry.value as Map<String, dynamic>);
        temuanMap[entry.key] = item;
        if (item.kode.isNotEmpty) {
          temuanMap[item.kode] = item;
        }
      }
    }

    final saranMap = <String, ItemSaranLaporan>{};
    final rawSaran = json['saran'] as Map<String, dynamic>? ?? {};
    for (final entry in rawSaran.entries) {
      if (entry.value is Map<String, dynamic>) {
        final item = ItemSaranLaporan.fromJson(entry.value as Map<String, dynamic>);
        saranMap[entry.key] = item;
        if (item.kode.isNotEmpty) {
          saranMap[item.kode] = item;
        }
      }
    }

    return KontenLaporan(
      versi: (json['versi'] as num?)?.toInt() ?? 1,
      judulBagian: judul,
      label: lbl,
      frasaSifat: sifat,
      catatanKaki: kaki,
      baris: b,
      temuan: temuanMap,
      saran: saranMap,
    );
  }
}
