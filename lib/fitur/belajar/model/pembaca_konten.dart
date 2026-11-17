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
  };
  static const Set<String> umpanBalikMisiValid = {
    'arus_kas_bulan_ini',
    'komposisi_sifat_bulan_ini',
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
        }
      }
    }

    final tersedia = data['tersedia'] as bool? ?? false;
    final kuis = data['kuis'];
    if (tersedia && kuis is Map<String, dynamic>) {
      final jmlSoal = kuis['jumlahSoal'];
      if (jmlSoal is num && jmlSoal <= 0) {
        throw GalatKonten('Kolom kuis.jumlahSoal harus bernilai > 0 untuk modul yang tersedia', berkas: namaBerkas, kolom: 'kuis.jumlahSoal');
      }
      final bankSoal = kuis['bankSoal'];
      if (bankSoal is List) {
        final setSoal = <String>{};
        for (var i = 0; i < bankSoal.length; i++) {
          final soal = bankSoal[i];
          if (soal is Map<String, dynamic>) {
            final soalId = soal['id'] as String?;
            if (soalId != null && !setSoal.add(soalId)) {
              throw GalatKonten('Ditemukan ID soal kuis duplikat: "$soalId"', berkas: namaBerkas, kolom: 'kuis.bankSoal[$i].id');
            }
            final pelId = soal['pelajaranId'] as String?;
            if (pelId != null && setPelajaran.isNotEmpty && !setPelajaran.contains(pelId)) {
              throw GalatKonten('Soal "$soalId" mereferensikan pelajaranId "$pelId" yang tidak terdaftar di modul', berkas: namaBerkas, kolom: 'kuis.bankSoal[$i].pelajaranId');
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

        if (pilihan is List) {
          for (var j = 0; j < pilihan.length; j++) {
            final teksPilihan = pilihan[j].toString();
            _periksaIstilahKamus(teksPilihan, daftarIstilahKamus, namaBerkas, 'cekPaham[$i].pilihan[$j]');
            periksaBahasaTeks(teksPilihan, namaBerkas: namaBerkas, daftarPeringatan: daftarPeringatan);
          }
          if (benar is num) {
            if (benar < 0 || benar >= pilihan.length) {
              throw GalatKonten('Indeks benar di luar rentang pilihan', berkas: namaBerkas, kolom: 'cekPaham.benar');
            }
          }
        }
      }
    }

    // 7. Misi
    final misi = data['misi'];
    if (misi is! Map<String, dynamic>) {
      throw GalatKonten('Kolom misi wajib berupa objek', berkas: namaBerkas, kolom: 'misi');
    }
    final tipeMisi = misi['tipe'] as String?;
    if (tipeMisi == null) {
      throw GalatKonten('Kolom misi.tipe wajib ada', berkas: namaBerkas, kolom: 'misi.tipe');
    }
    const jenisMisiDidukung = {'ada_data', 'aturan_data', 'lihat_hitungan'};
    if (!jenisMisiDidukung.contains(tipeMisi)) {
      throw GalatKonten('Jenis misi "$tipeMisi" belum didukung pada versi ini', berkas: namaBerkas, kolom: 'misi.tipe');
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
    // (misi tidak boleh lebih longgar atau sama dengan gerbang), kecuali bertipe lihat_hitungan.
    if (tipeMisi != 'lihat_hitungan' && gerbang is List) {
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

  /// Memuat pelajaran dari aset aplikasi.
  static Future<PelajaranKonten> muatPelajaranDariAset(
    AssetBundle bundle, {
    required String tingkat,
    required String modulId,
    required String pelajaranId,
    Set<String>? daftarIstilahKamus,
  }) async {
    final path = 'aset/konten/$tingkat/$modulId/$pelajaranId.json';
    final jsonString = await bundle.loadString(path);
    return uraiPelajaran(
      jsonString,
      namaBerkas: path,
      daftarIstilahKamus: daftarIstilahKamus,
    );
  }
}
