import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/basis_data.dart';
import '../../../data/penyedia_data.dart';
import '../../../data/repositori/foto_data_repositori.dart';
import '../../../data/repositori/hasil_misi_repositori.dart';
import '../../../data/repositori/kuis_repositori.dart';
import '../../../data/repositori/progres_repositori.dart';
import '../../../data/repositori/pernyataan_repositori.dart';
import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../perhitungan/perhitungan_tes_awal_personalisasi.dart';
import '../model/pembaca_konten.dart';

// Repositori Providers
final penyediaProgresRepositori = Provider<ProgresRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return ProgresRepositori(db);
});

final penyediaKuisRepositori = Provider<KuisRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return KuisRepositori(db);
});

final penyediaPernyataanRepositori = Provider<PernyataanRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return PernyataanRepositori(db);
});

final penyediaHasilMisiRepositori = Provider<HasilMisiRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return HasilMisiRepositori(db);
});

final penyediaFotoDataRepositori = Provider<FotoDataRepositori>((ref) {
  final db = ref.watch(penyediaBasisData);
  return FotoDataRepositori(db);
});

/// Provider kamus istilah keuangan Funda (cache in-memory).
final penyediaKamus = FutureProvider<Map<String, IstilahKamus>>((ref) async {
  return PembacaKonten.muatKamusDariAset(rootBundle);
});

/// Daftar ID dan tingkat modul 0 s.d. 18 sesuai kurikulum Funda.
const daftarMetadataModul = [
  ('pemula', 'mulai_tes_awal'),
  ('pemula', 'anggaran_arus_kas'),
  ('pemula', 'tabungan'),
  ('pemula', 'dana_darurat'),
  ('pemula', 'utang_cicilan'),
  ('pemula', 'waspada_penipuan'),
  ('pemula', 'psikologi_uang'),
  ('menengah', 'paylater_kredit'),
  ('menengah', 'penghasilan_tambahan'),
  ('menengah', 'pajak_dasar'),
  ('menengah', 'proteksi_dasar'),
  ('menengah', 'investasi_dasar'),
  ('menengah', 'tujuan_besar'),
  ('lanjutan', 'investasi_lanjutan'),
  ('lanjutan', 'kpr_kredit_besar'),
  ('lanjutan', 'pajak_lanjutan'),
  ('lanjutan', 'pensiun_kebebasan_finansial'),
  ('lanjutan', 'keuangan_usaha_kecil'),
  ('lanjutan', 'proteksi_keluarga_warisan'),
];

/// Cache in-memory untuk modul kurikulum agar tidak membaca 19 file JSON berulang kali.
List<ModulKonten>? _cacheSemuaModul;

/// Provider seluruh 19 modul konten dari aset (dengan cache in-memory O(1)).
final penyediaDaftarSemuaModul = FutureProvider<List<ModulKonten>>((ref) async {
  if (_cacheSemuaModul != null && _cacheSemuaModul!.isNotEmpty) {
    return _cacheSemuaModul!;
  }
  final hasil = <ModulKonten>[];
  for (final (tingkat, modulId) in daftarMetadataModul) {
    try {
      final modul = await PembacaKonten.muatModulDariAset(
        rootBundle,
        tingkat: tingkat,
        modulId: modulId,
      );
      hasil.add(modul);
    } catch (_) {}
  }
  hasil.sort((a, b) => a.urutan.compareTo(b.urutan));
  _cacheSemuaModul = hasil;
  return hasil;
});

final penyediaStreamPernyataan = StreamProvider<Map<String, String>>((ref) {
  return ref.watch(penyediaPernyataanRepositori).pantauSemuaPernyataan();
});

final penyediaStreamProgresPelajaran = StreamProvider((ref) {
  return ref.watch(penyediaProgresRepositori).pantauSemuaProgres();
});

final penyediaStreamHasilKuis = StreamProvider((ref) {
  return ref.watch(penyediaKuisRepositori).pantauSemuaHasilKuis();
});

/// Provider stream profil keuangan pengguna aktif.
final penyediaStreamProfilKeuangan =
    StreamProvider<EntitasProfilKeuangan?>((ref) {
  return ref.watch(penyediaProfilRepositori).pantauProfil();
});

/// Provider stream hasil tes awal terakhir.
final penyediaStreamHasilTesAwal = StreamProvider<EntitasHasilTesAwal?>((ref) {
  return ref.watch(penyediaTesAwalRepositori).pantauHasilTerakhir();
});

/// Provider konten tes awal dari aset JSON.
final penyediaKontenTesAwal = FutureProvider<KontenTesAwal>((ref) async {
  return PembacaKonten.muatTesAwalDariAset(rootBundle);
});

/// Provider konten rekomendasi dari aset JSON.
final penyediaKontenRekomendasi =
    FutureProvider<KontenRekomendasi>((ref) async {
  return PembacaKonten.muatRekomendasiDariAset(rootBundle);
});

/// Stream sinyal ringan perubahan transaksi untuk reaktivitas tanpa menarik seluruh baris ke memori Dart.
final penyediaSinyalTransaksiBerubah = StreamProvider<int>((ref) {
  return ref.watch(penyediaTransaksiRepositori).pantauJumlahTransaksi();
});

/// Provider snapshot foto data pengguna yang reaktif terhadap perubahan data via agregasi SQL.
final penyediaFotoData = FutureProvider<FotoDataPengguna>((ref) async {
  // Hubungkan dengan reaktivitas stream data ringan (bebas N+1)
  ref.watch(penyediaSinyalTransaksiBerubah);
  ref.watch(penyediaDaftarDompetAktif);
  ref.watch(penyediaStreamPernyataan);
  ref.watch(penyediaStreamProgresPelajaran);
  ref.watch(penyediaStreamHasilKuis);
  ref.watch(penyediaStreamProfilKeuangan);

  final repo = ref.watch(penyediaFotoDataRepositori);
  return repo.ambilFotoData();
});

/// Model agregat satu modul dalam peta belajar.
class ItemPetaModul {
  final ModulKonten modul;
  final HasilStatusBelajar statusModul;
  final List<(PelajaranKonten, HasilStatusBelajar)> daftarPelajaran;

  const ItemPetaModul({
    required this.modul,
    required this.statusModul,
    required this.daftarPelajaran,
  });
}

/// Provider peta belajar lengkap yang menggabungkan konten, foto data, dan status belajar.
final penyediaPetaBelajar = FutureProvider<List<ItemPetaModul>>((ref) async {
  final daftarModul = await ref.watch(penyediaDaftarSemuaModul.future);
  final fotoData = await ref.watch(penyediaFotoData.future);
  final kamus = (await ref.watch(penyediaKamus.future)).keys.toSet();

  final hasilPeta = <ItemPetaModul>[];

  for (final modul in daftarModul) {
    final statusModul = tentukanStatusModul(modul: modul, fotoData: fotoData);

    final listPelajaranItem = <(PelajaranKonten, HasilStatusBelajar)>[];
    if (modul.tersedia && modul.daftarPelajaran.isNotEmpty) {
      // Muat berkas pelajaran modul
      final objekPelajaran = <PelajaranKonten>[];
      for (final pelId in modul.daftarPelajaran) {
        try {
          final pel = await PembacaKonten.muatPelajaranDariAset(
            rootBundle,
            tingkat: modul.tingkat,
            modulId: modul.id,
            pelajaranId: pelId,
            daftarIstilahKamus: kamus,
          );
          objekPelajaran.add(pel);
        } catch (_) {}
      }

      for (var i = 0; i < objekPelajaran.length; i++) {
        final pel = objekPelajaran[i];
        final statusPel = tentukanStatusPelajaran(
          pelajaran: pel,
          posisiIndeks: i,
          daftarPelajaranModul: objekPelajaran,
          gerbangModul: modul.gerbang,
          fotoData: fotoData,
        );
        listPelajaranItem.add((pel, statusPel));
      }
    }

    hasilPeta.add(
      ItemPetaModul(
        modul: modul,
        statusModul: statusModul,
        daftarPelajaran: listPelajaranItem,
      ),
    );
  }

  return hasilPeta;
});

/// Model data rekomendasi petak "Lanjut Belajar" di Beranda.
class InfoLanjutBelajar {
  final String labelAksi; // 'Lanjutkan', 'Mulai', 'Satu langkah lagi', 'Hebat!'
  final String judul;
  final String keterangan;
  final String rute;
  final bool bisaDibuka;

  const InfoLanjutBelajar({
    required this.labelAksi,
    required this.judul,
    required this.keterangan,
    required this.rute,
    required this.bisaDibuka,
  });
}

/// Item rekomendasi lengkap dengan teks alasan dari rekomendasi.json
class InfoRekomendasiModul {
  final ModulKonten modul;
  final String judulAlasan;
  final String deskripsiAlasan;
  final HasilStatusBelajar statusModul;

  const InfoRekomendasiModul({
    required this.modul,
    required this.judulAlasan,
    required this.deskripsiAlasan,
    required this.statusModul,
  });
}

/// Provider daftar modul rekomendasi personalisasi.
final penyediaDaftarRekomendasiModul =
    FutureProvider<List<InfoRekomendasiModul>>((ref) async {
  final entitasProfil = ref.watch(penyediaStreamProfilKeuangan).value;
  final entitasTesAwal = ref.watch(penyediaStreamHasilTesAwal).value;
  final kontenRekomendasi = await ref.watch(penyediaKontenRekomendasi.future);
  final peta = await ref.watch(penyediaPetaBelajar.future);
  final fotoData = await ref.watch(penyediaFotoData.future);

  final profil = entitasProfil != null
      ? bangunProfil(
          jawabanProfil: {
            'punya_penghasilan': entitasProfil.punyaPenghasilan,
            'punya_utang': entitasProfil.punyaUtang,
            'dana_darurat': entitasProfil.danaDarurat,
            'menabung': entitasProfil.menabung,
            'investasi': entitasProfil.investasi,
            'mencatat_keuangan': entitasProfil.mencatatKeuangan,
          },
          tujuanUtama: entitasProfil.tujuanUtama,
        )
      : null;

  HasilSkorTesAwal? hasilTes;
  if (entitasTesAwal != null) {
    try {
      final decoded =
          jsonDecode(entitasTesAwal.skorPerModulJson) as Map<String, dynamic>;
      final skorPerModul =
          decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      hasilTes = HasilSkorTesAwal(
        skorPerModul: skorPerModul,
        skorTotalPersen: entitasTesAwal.skorTotalPersen,
        totalBenar: 0,
        totalSoal: 12,
      );
    } catch (_) {}
  }

  final daftarModul = peta.map((p) => p.modul).toList();
  final statusModul = {for (final p in peta) p.modul.id: p.statusModul};

  final daftarRekomendasi = rekomendasiModul(
    profil: profil,
    hasilTes: hasilTes,
    fotoData: fotoData,
    daftarModul: daftarModul,
    statusModul: statusModul,
  );

  final hasil = <InfoRekomendasiModul>[];
  for (final rek in daftarRekomendasi) {
    final itemPeta = peta.firstWhere(
      (p) => p.modul.id == rek.modulId,
      orElse: () => ItemPetaModul(
        modul: ModulKonten(
          id: rek.modulId,
          judul: rek.modulId,
          tingkat: 'pemula',
          urutan: 0,
          deskripsiSingkat: '',
          tersedia: rek.tersedia,
          gerbang: [],
          daftarPelajaran: [],
          kuis: const KuisKonten(jumlahSoal: 0, bankSoal: []),
        ),
        statusModul: HasilStatusBelajar(
          status: rek.terbuka ? StatusBelajar.terbuka : StatusBelajar.terkunci,
          apaYangKurang: rek.apaYangKurang,
        ),
        daftarPelajaran: [],
      ),
    );

    final alasanKey = rek.kodeAlasanUtama;
    final alasanInfo = kontenRekomendasi.alasan[alasanKey];
    hasil.add(
      InfoRekomendasiModul(
        modul: itemPeta.modul,
        judulAlasan: alasanInfo?.judul ?? 'Rekomendasi Untukmu',
        deskripsiAlasan: alasanInfo?.deskripsi ??
            'Bagus untuk mendukung langkah keuanganmu.',
        statusModul: itemPeta.statusModul,
      ),
    );
  }

  return hasil;
});

/// Provider dinamis petak "Lanjut Belajar" untuk Layar Beranda.
final penyediaLanjutBelajarBeranda =
    FutureProvider<InfoLanjutBelajar>((ref) async {
  final peta = await ref.watch(penyediaPetaBelajar.future);
  final rekomendasi = await ref.watch(penyediaDaftarRekomendasiModul.future);

  // 1. Cari pelajaran dengan status 'sedang' (prioritas tertinggi)
  for (final itemModul in peta) {
    for (final (pel, statusPel) in itemModul.daftarPelajaran) {
      if (statusPel.status == StatusBelajar.sedang) {
        return InfoLanjutBelajar(
          labelAksi: 'Lanjutkan',
          judul: pel.judul,
          keterangan: 'Lanjutkan kartu belajarmu dari langkah terakhir.',
          rute: '/belajar/pelajaran/${pel.modulId}/${pel.id}',
          bisaDibuka: true,
        );
      }
    }
  }

  // 2. Cari dari rekomendasi modul urutan pertama yang terbuka dan belum selesai
  for (final rek in rekomendasi) {
    ItemPetaModul? itemModul;
    for (final p in peta) {
      if (p.modul.id == rek.modul.id) {
        itemModul = p;
        break;
      }
    }
    if (itemModul != null &&
        itemModul.modul.tersedia &&
        itemModul.statusModul.status != StatusBelajar.terkunci) {
      for (final (pel, statusPel) in itemModul.daftarPelajaran) {
        if (statusPel.status == StatusBelajar.terbuka) {
          return InfoLanjutBelajar(
            labelAksi: 'Mulai',
            judul: pel.judul,
            keterangan: rek.deskripsiAlasan,
            rute: '/belajar/pelajaran/${pel.modulId}/${pel.id}',
            bisaDibuka: true,
          );
        }
      }
    }
  }

  // 3. Fallback: Cari pelajaran pertama dengan status 'terbuka' di peta belajar
  for (final itemModul in peta) {
    if (!itemModul.modul.tersedia) continue;
    for (final (pel, statusPel) in itemModul.daftarPelajaran) {
      if (statusPel.status == StatusBelajar.terbuka) {
        return InfoLanjutBelajar(
          labelAksi: 'Mulai',
          judul: pel.judul,
          keterangan: 'Pelajaran siap dipelajari sekarang.',
          rute: '/belajar/pelajaran/${pel.modulId}/${pel.id}',
          bisaDibuka: true,
        );
      }
    }
  }

  // 4. Bila ada pelajaran terkunci di modul pertama
  for (final itemModul in peta) {
    if (!itemModul.modul.tersedia) continue;
    for (final (pel, statusPel) in itemModul.daftarPelajaran) {
      if (statusPel.status == StatusBelajar.terkunci) {
        final pesan =
            statusPel.apaYangKurang.firstOrNull ?? 'Penuhi syarat data dulu';
        return InfoLanjutBelajar(
          labelAksi: 'Satu langkah lagi',
          judul: pel.judul,
          keterangan: pesan,
          rute: statusPel.ruteAksi ?? '/belajar',
          bisaDibuka: true,
        );
      }
    }
  }

  // 5. Semua pelajaran dan modul tersedia selesai
  return const InfoLanjutBelajar(
    labelAksi: 'Hebat!',
    judul: 'Semua Materi Selesai',
    keterangan: 'Kamu telah menuntaskan seluruh pelajaran yang tersedia.',
    rute: '/belajar',
    bisaDibuka: true,
  );
});
