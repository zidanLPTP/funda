import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_transaksi.dart';
import '../../../data/model/sifat_kategori.dart';
import '../../../data/penyedia_data.dart';
import '../../utang/kontroler/penyedia_utang.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';

/// Layar Formulir Catat Transaksi (Pemasukan, Pengeluaran, Transfer Antar Dompet).
class LayarFormTransaksi extends ConsumerStatefulWidget {
  const LayarFormTransaksi({
    super.key,
    this.transaksi,
    this.idTagihan,
    this.tanggalJatuhTempoTagihan,
    this.nominalAwalRupiah,
    this.kategoriIdAwal,
    this.dompetIdAwal,
    this.catatanAwal,
  });

  final EntitasTransaksi? transaksi;
  final String? idTagihan;
  final DateTime? tanggalJatuhTempoTagihan;
  final int? nominalAwalRupiah;
  final String? kategoriIdAwal;
  final String? dompetIdAwal;
  final String? catatanAwal;

  @override
  ConsumerState<LayarFormTransaksi> createState() => _LayarFormTransaksiState();
}

class _LayarFormTransaksiState extends ConsumerState<LayarFormTransaksi> {
  late JenisTransaksi _jenisTerpilih;
  late final TextEditingController _pengontrolNominal;
  late final TextEditingController _pengontrolBiayaAdmin;
  late final TextEditingController _pengontrolCatatan;

  String? _dompetIdTerpilih;
  String? _dompetTujuanIdTerpilih;
  String? _kategoriIdTerpilih;
  String? _utangIdTerpilih;
  late DateTime _waktuTransaksi;
  bool _memuat = false;

  bool get _sedangUbah => widget.transaksi != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaksi;

    _jenisTerpilih = t != null
        ? JenisTransaksi.dariKode(t.jenis)
        : JenisTransaksi.keluar;

    final nominalAwal = t != null
        ? t.jumlahRupiah
        : (widget.nominalAwalRupiah ?? 0);

    _pengontrolNominal = TextEditingController(
      text: nominalAwal > 0 ? formatRupiah(nominalAwal) : 'Rp 0',
    );
    _pengontrolBiayaAdmin = TextEditingController(
      text: t != null && t.biayaAdminRupiah > 0
          ? formatRupiah(t.biayaAdminRupiah)
          : 'Rp 0',
    );
    _pengontrolCatatan = TextEditingController(
      text: t?.catatan ?? (widget.catatanAwal ?? ''),
    );
    _dompetIdTerpilih = t?.dompetId ?? widget.dompetIdAwal;
    _dompetTujuanIdTerpilih = t?.dompetTujuanId;
    _kategoriIdTerpilih = t?.kategoriId ?? widget.kategoriIdAwal;
    _waktuTransaksi = t?.waktuTransaksi.toLocal() ?? DateTime.now();

    if (t != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final relasi = await ref
            .read(penyediaUtangRepositori)
            .cariPembayaranBerdasarkanTransaksiId(t.id);
        if (relasi != null && mounted) {
          setState(() => _utangIdTerpilih = relasi.utangId);
        }
      });
    }
  }

  @override
  void dispose() {
    _pengontrolNominal.dispose();
    _pengontrolBiayaAdmin.dispose();
    _pengontrolCatatan.dispose();
    super.dispose();
  }

  void _tambahNominalPintasan(int tambahan) {
    var nominalSekarang = 0;
    try {
      nominalSekarang = ambilAngkaRupiah(_pengontrolNominal.text);
    } catch (_) {}

    final nominalBaru = nominalSekarang + tambahan;
    final teksFormat = formatRupiah(nominalBaru);
    setState(() {
      _pengontrolNominal.value = TextEditingValue(
        text: teksFormat,
        selection: TextSelection.collapsed(offset: teksFormat.length),
      );
    });
  }

  Future<void> _pilihTanggalWaktu() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _waktuTransaksi,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (tanggal == null || !mounted) return;

    final waktu = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_waktuTransaksi),
    );
    if (waktu == null || !mounted) return;

    setState(() {
      _waktuTransaksi = DateTime(
        tanggal.year,
        tanggal.month,
        tanggal.day,
        waktu.hour,
        waktu.minute,
      );
    });
  }

  Future<void> _simpan() async {
    int nominal = 0;
    try {
      nominal = ambilAngkaRupiah(_pengontrolNominal.text);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal transaksi belum valid.')),
      );
      return;
    }

    int biayaAdmin = 0;
    if (_jenisTerpilih == JenisTransaksi.transfer) {
      try {
        biayaAdmin = ambilAngkaRupiah(_pengontrolBiayaAdmin.text);
      } catch (_) {}
    }

    if (_dompetIdTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet terlebih dahulu.')),
      );
      return;
    }

    final validasi = validasiTransaksi(
      jenis: _jenisTerpilih,
      jumlahRupiah: nominal,
      dompetId: _dompetIdTerpilih!,
      dompetTujuanId: _dompetTujuanIdTerpilih,
      kategoriId: _kategoriIdTerpilih,
      biayaAdminRupiah: biayaAdmin,
    );

    if (!validasi.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validasi.pesanGalat ?? 'Masukan belum lengkap.'),
        ),
      );
      return;
    }

    setState(() => _memuat = true);
    final repoTransaksi = ref.read(penyediaTransaksiRepositori);
    final repoUtang = ref.read(penyediaUtangRepositori);
    final catatan = _pengontrolCatatan.text.trim();
    final waktuUtc = _waktuTransaksi.toUtc();

    if (_sedangUbah) {
      await repoTransaksi.perbaruiTransaksi(
        TabelTransaksiCompanion(
          id: drift.Value(widget.transaksi!.id),
          jenis: drift.Value(_jenisTerpilih.kode),
          jumlahRupiah: drift.Value(nominal),
          dompetId: drift.Value(_dompetIdTerpilih!),
          dompetTujuanId: drift.Value(_dompetTujuanIdTerpilih),
          kategoriId: drift.Value(_kategoriIdTerpilih),
          biayaAdminRupiah: drift.Value(biayaAdmin),
          catatan: drift.Value(catatan.isEmpty ? null : catatan),
          waktuTransaksi: drift.Value(waktuUtc),
          diubahPada: drift.Value(DateTime.now().toUtc()),
        ),
      );
      if (_utangIdTerpilih != null) {
        final relasiLama = await repoUtang.cariPembayaranBerdasarkanTransaksiId(
          widget.transaksi!.id,
        );
        if (relasiLama == null || relasiLama.utangId != _utangIdTerpilih) {
          await repoUtang.tautkanTransaksiKeUtang(
            utangId: _utangIdTerpilih!,
            transaksiId: widget.transaksi!.id,
          );
        }
      }
    } else {
      if (widget.idTagihan != null && widget.tanggalJatuhTempoTagihan != null) {
        final repoTagihan = ref.read(penyediaTagihanRepositori);
        await repoTagihan.tandaiTagihanDibayar(
          tagihanId: widget.idTagihan!,
          jatuhTempo: widget.tanggalJatuhTempoTagihan!,
          jumlahRupiah: nominal,
          dompetId: _dompetIdTerpilih!,
          kategoriId: _kategoriIdTerpilih!,
          catatan: catatan.isEmpty ? null : catatan,
          waktuTransaksi: waktuUtc,
        );
      } else {
        final idBaru = 't_${DateTime.now().millisecondsSinceEpoch}';
        await repoTransaksi.tambahTransaksi(
          TabelTransaksiCompanion(
            id: drift.Value(idBaru),
            jenis: drift.Value(_jenisTerpilih.kode),
            jumlahRupiah: drift.Value(nominal),
            dompetId: drift.Value(_dompetIdTerpilih!),
            dompetTujuanId: drift.Value(_dompetTujuanIdTerpilih),
            kategoriId: drift.Value(_kategoriIdTerpilih),
            biayaAdminRupiah: drift.Value(biayaAdmin),
            catatan: drift.Value(catatan.isEmpty ? null : catatan),
            waktuTransaksi: drift.Value(waktuUtc),
          ),
        );
        if (_utangIdTerpilih != null) {
          await repoUtang.tautkanTransaksiKeUtang(
            utangId: _utangIdTerpilih!,
            transaksiId: idBaru,
          );
        }
      }
    }

    if (mounted) {
      setState(() => _memuat = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarDompetAktif = ref.watch(penyediaDaftarDompetAktif).value ?? [];
    final semuaKategori = ref.watch(penyediaDaftarKategori).value ?? [];
    final petaSaldo = ref.watch(penyediaPetaSaldoDompet);
    final daftarUtangAktif = ref.watch(penyediaDaftarUtangAktif).value ?? [];

    final kategoriTerpilih = semuaKategori
        .where((k) => k.id == _kategoriIdTerpilih)
        .firstOrNull;
    final apakahKategoriUtang =
        kategoriTerpilih != null && kategoriTerpilih.sifat == 'utang';

    // Otomatis pilih dompet pertama jika belum dipilih
    if (_dompetIdTerpilih == null && daftarDompetAktif.isNotEmpty) {
      _dompetIdTerpilih = daftarDompetAktif.first.id;
    }

    final kategoriSesuaiArus = semuaKategori.where((k) {
      if (k.diarsipkan) return false;
      if (_jenisTerpilih == JenisTransaksi.masuk) return k.arus == 'masuk';
      if (_jenisTerpilih == JenisTransaksi.keluar) return k.arus == 'keluar';
      return false;
    }).toList();

    // Hitung apakah dompet asal akan minus
    var nominalKetik = 0;
    try {
      nominalKetik = ambilAngkaRupiah(_pengontrolNominal.text);
    } catch (_) {}

    var saldoSetelahAksi = 0;
    var apakahMinus = false;
    if (_dompetIdTerpilih != null) {
      final saldoSekarang = petaSaldo[_dompetIdTerpilih] ?? 0;
      if (_jenisTerpilih == JenisTransaksi.keluar) {
        saldoSetelahAksi = saldoSekarang - nominalKetik;
        apakahMinus = nominalKetik > 0 && saldoSetelahAksi < 0;
      } else if (_jenisTerpilih == JenisTransaksi.transfer) {
        var admin = 0;
        try {
          admin = ambilAngkaRupiah(_pengontrolBiayaAdmin.text);
        } catch (_) {}
        saldoSetelahAksi = saldoSekarang - (nominalKetik + admin);
        apakahMinus = nominalKetik > 0 && saldoSetelahAksi < 0;
      }
    }

    return PembungkusLayar(
      appBar: AppBar(
        title: TeksFunda.judulBagian(
          _sedangUbah ? 'Ubah Catatan Transaksi' : 'Catat Transaksi',
        ),
      ),
      bisaGulir: true,
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmen Jenis Transaksi (Keluar, Masuk, Transfer)
          Container(
            padding: const EdgeInsets.all(SpasiFunda.xs),
            decoration: BoxDecoration(
              color: WarnaFunda.permukaan,
              borderRadius: BorderRadius.circular(SudutFunda.pil),
              border: Border.all(color: WarnaFunda.garis),
            ),
            child: Row(
              children: [
                _ItemSegmen(
                  judul: 'Pengeluaran',
                  terpilih: _jenisTerpilih == JenisTransaksi.keluar,
                  warnaAktif: WarnaFunda.pengeluaran,
                  padaPilih: () => setState(() {
                    _jenisTerpilih = JenisTransaksi.keluar;
                    _kategoriIdTerpilih = null;
                  }),
                ),
                _ItemSegmen(
                  judul: 'Pemasukan',
                  terpilih: _jenisTerpilih == JenisTransaksi.masuk,
                  warnaAktif: WarnaFunda.pemasukan,
                  padaPilih: () => setState(() {
                    _jenisTerpilih = JenisTransaksi.masuk;
                    _kategoriIdTerpilih = null;
                  }),
                ),
                _ItemSegmen(
                  judul: 'Transfer',
                  terpilih: _jenisTerpilih == JenisTransaksi.transfer,
                  warnaAktif: WarnaFunda.utama,
                  padaPilih: () => setState(() {
                    _jenisTerpilih = JenisTransaksi.transfer;
                    _kategoriIdTerpilih = null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpasiFunda.xl),

          // Papan Input Nominal Besar
          const TeksFunda.isiKecil('Nominal Transaksi'),
          const SizedBox(height: SpasiFunda.xs),
          TextField(
            controller: _pengontrolNominal,
            keyboardType: TextInputType.number,
            style: TipografiFunda.angkaBesar.copyWith(
              color: _jenisTerpilih == JenisTransaksi.masuk
                  ? WarnaFunda.pemasukan
                  : (_jenisTerpilih == JenisTransaksi.keluar
                        ? WarnaFunda.pengeluaran
                        : WarnaFunda.utama),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: WarnaFunda.permukaan,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.l,
                vertical: SpasiFunda.m,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
            onChanged: (teks) {
              try {
                final nominal = ambilAngkaRupiah(teks);
                final format = formatRupiah(nominal);
                if (format != teks) {
                  _pengontrolNominal.value = TextEditingValue(
                    text: format,
                    selection: TextSelection.collapsed(offset: format.length),
                  );
                }
              } catch (_) {}
              setState(() {});
            },
          ),
          const SizedBox(height: SpasiFunda.s),

          // Pintasan Nominal Cepat (+10rb, +50rb, +100rb, +500rb)
          Wrap(
            spacing: SpasiFunda.s,
            runSpacing: SpasiFunda.s,
            children: [
              _TombolPintasanNominal(
                label: '+10rb',
                padaTekan: () => _tambahNominalPintasan(10000),
              ),
              _TombolPintasanNominal(
                label: '+50rb',
                padaTekan: () => _tambahNominalPintasan(50000),
              ),
              _TombolPintasanNominal(
                label: '+100rb',
                padaTekan: () => _tambahNominalPintasan(100000),
              ),
              _TombolPintasanNominal(
                label: '+500rb',
                padaTekan: () => _tambahNominalPintasan(500000),
              ),
            ],
          ),
          const SizedBox(height: SpasiFunda.l),

          // Peringatan Lembut Bila Saldo Dompet Jadi Minus
          if (apakahMinus) ...[
            Container(
              padding: const EdgeInsets.all(SpasiFunda.m),
              decoration: BoxDecoration(
                color: WarnaFunda.tintAmber,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                border: Border.all(color: WarnaFunda.peringatan.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    color: WarnaFunda.peringatan,
                    size: 20,
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: TeksFunda.catatan(
                      'Saldo dompet ini akan menjadi minus (${formatRupiah(saldoSetelahAksi)}). Tetap bisa disimpan kok, cek lagi catatannya jika ragu ya.',
                      warna: WarnaFunda.teks,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpasiFunda.l),
          ],

          // Pemilih Dompet Sumber / Asal
          TeksFunda.label(
            _jenisTerpilih == JenisTransaksi.transfer
                ? 'Dompet Asal'
                : 'Dompet Pembayaran',
          ),
          const SizedBox(height: SpasiFunda.s),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _dompetIdTerpilih,
            decoration: InputDecoration(
              filled: true,
              fillColor: WarnaFunda.permukaan,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
            items: daftarDompetAktif.map((d) {
              final saldo = petaSaldo[d.id] ?? d.saldoAwalRupiah;
              return DropdownMenuItem(
                value: d.id,
                child: Row(
                  children: [
                    Icon(
                      ambilIkonLucide(d.ikon),
                      size: 18,
                      color: WarnaFunda.utama,
                    ),
                    const SizedBox(width: SpasiFunda.s),
                    Expanded(
                      child: Text(
                        '${d.nama} (${formatRupiah(saldo)})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _dompetIdTerpilih = val),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Bagian Khusus Transfer: Dompet Tujuan & Biaya Admin
          if (_jenisTerpilih == JenisTransaksi.transfer) ...[
            const TeksFunda.label('Dompet Tujuan Transfer'),
            const SizedBox(height: SpasiFunda.s),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _dompetTujuanIdTerpilih,
              decoration: InputDecoration(
                hintText: 'Pilih dompet penerima',
                filled: true,
                fillColor: WarnaFunda.permukaan,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              items: daftarDompetAktif
                  .where((d) => d.id != _dompetIdTerpilih)
                  .map((d) {
                    return DropdownMenuItem(
                      value: d.id,
                      child: Row(
                        children: [
                          Icon(
                            ambilIkonLucide(d.ikon),
                            size: 18,
                            color: WarnaFunda.utama,
                          ),
                          const SizedBox(width: SpasiFunda.s),
                          Expanded(
                            child: Text(
                              d.nama,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
              onChanged: (val) => setState(() => _dompetTujuanIdTerpilih = val),
            ),
            const SizedBox(height: SpasiFunda.l),

            const TeksFunda.label('Biaya Admin Transfer (Opsional)'),
            const SizedBox(height: SpasiFunda.s),
            TextField(
              controller: _pengontrolBiayaAdmin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: WarnaFunda.permukaan,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SudutFunda.kartu),
                  borderSide: const BorderSide(color: WarnaFunda.garis),
                ),
              ),
              onChanged: (teks) {
                try {
                  final nominal = ambilAngkaRupiah(teks);
                  final format = formatRupiah(nominal);
                  if (format != teks) {
                    _pengontrolBiayaAdmin.value = TextEditingValue(
                      text: format,
                      selection: TextSelection.collapsed(offset: format.length),
                    );
                  }
                } catch (_) {}
                setState(() {});
              },
            ),
            const SizedBox(height: SpasiFunda.l),
          ],

          // Pemilih Kategori (khusus Masuk & Keluar)
          if (_jenisTerpilih != JenisTransaksi.transfer) ...[
            const TeksFunda.label('Pilih Kategori'),
            const SizedBox(height: SpasiFunda.s),
            Wrap(
              spacing: SpasiFunda.s,
              runSpacing: SpasiFunda.s,
              children: kategoriSesuaiArus.map((kategori) {
                final terpilih = _kategoriIdTerpilih == kategori.id;
                final sifat = SifatKategori.dariKode(kategori.sifat);

                final warnaSifat = switch (sifat) {
                  SifatKategori.kebutuhan => WarnaFunda.sifatKebutuhan,
                  SifatKategori.keinginan => WarnaFunda.sifatKeinginan,
                  SifatKategori.tabungan => WarnaFunda.sifatTabungan,
                  SifatKategori.utang => WarnaFunda.sifatUtang,
                  _ => WarnaFunda.teksRedup,
                };

                return Semantics(
                  button: true,
                  selected: terpilih,
                  label: 'Kategori ${kategori.nama}, sifat ${sifat.label}',
                  child: FilterChip(
                    selected: terpilih,
                    showCheckmark: false,
                    avatar: Icon(
                      ambilIkonLucide(kategori.ikon),
                      size: 16,
                      color: terpilih ? WarnaFunda.teksPutih : warnaSifat,
                    ),
                    label: Text(kategori.nama),
                    labelStyle: TipografiFunda.catatan.copyWith(
                      color: terpilih ? WarnaFunda.teksPutih : WarnaFunda.teks,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: WarnaFunda.permukaan,
                    selectedColor: warnaSifat,
                    side: BorderSide(
                      color: terpilih ? warnaSifat : WarnaFunda.garis,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _kategoriIdTerpilih = val ? kategori.id : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: SpasiFunda.l),

            // Dropdown Hubungkan ke Utang (jika kategori sifatnya utang)
            if (apakahKategoriUtang && daftarUtangAktif.isNotEmpty) ...[
              const TeksFunda.label('Hubungkan ke Utang (Opsional)'),
              const SizedBox(height: SpasiFunda.s),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: _utangIdTerpilih,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: WarnaFunda.permukaan,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SudutFunda.kartu),
                    borderSide: const BorderSide(color: WarnaFunda.garis),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'Tidak dihubungkan ke utang spesifik',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...daftarUtangAktif.map((u) {
                    return DropdownMenuItem<String?>(
                      value: u.id,
                      child: Text(u.nama, overflow: TextOverflow.ellipsis),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() => _utangIdTerpilih = val);
                },
              ),
              const SizedBox(height: SpasiFunda.l),
            ],
          ],

          // Tanggal & Waktu
          const TeksFunda.label('Tanggal & Waktu'),
          const SizedBox(height: SpasiFunda.s),
          InkWell(
            onTap: _pilihTanggalWaktu,
            borderRadius: BorderRadius.circular(SudutFunda.kartu),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpasiFunda.l,
                vertical: SpasiFunda.m,
              ),
              decoration: BoxDecoration(
                color: WarnaFunda.permukaan,
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                border: Border.all(color: WarnaFunda.garis),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: WarnaFunda.utama,
                  ),
                  const SizedBox(width: SpasiFunda.m),
                  Expanded(
                    child: TeksFunda.isi(
                      DateFormat(
                        'EEEE, d MMMM yyyy HH:mm',
                        'id_ID',
                      ).format(_waktuTransaksi),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.l),

          // Catatan Opsional
          const TeksFunda.label('Catatan (Opsional)'),
          const SizedBox(height: SpasiFunda.s),
          TextField(
            controller: _pengontrolCatatan,
            decoration: InputDecoration(
              hintText: 'Misal: Sarapan bubur ayam, bayar wifi bulanan',
              filled: true,
              fillColor: WarnaFunda.permukaan,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SudutFunda.kartu),
                borderSide: const BorderSide(color: WarnaFunda.garis),
              ),
            ),
          ),
          const SizedBox(height: SpasiFunda.xxxl),

          // Tombol Simpan
          TombolFunda.primer(
            teks: _sedangUbah ? 'Perbarui Transaksi' : 'Simpan Transaksi',
            lebarPenuh: true,
            memuat: _memuat,
            padaTekan: _simpan,
          ),
          const SizedBox(height: SpasiFunda.l),
        ],
      ),
    );
  }
}

class _ItemSegmen extends StatelessWidget {
  const _ItemSegmen({
    required this.judul,
    required this.terpilih,
    required this.warnaAktif,
    required this.padaPilih,
  });

  final String judul;
  final bool terpilih;
  final Color warnaAktif;
  final VoidCallback padaPilih;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: padaPilih,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: SpasiFunda.m),
          decoration: BoxDecoration(
            color: terpilih ? warnaAktif : Colors.transparent,
            borderRadius: BorderRadius.circular(SudutFunda.pil),
          ),
          child: Text(
            judul,
            textAlign: TextAlign.center,
            style: TipografiFunda.label.copyWith(
              color: terpilih ? WarnaFunda.teksPutih : WarnaFunda.teksRedup,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _TombolPintasanNominal extends StatelessWidget {
  const _TombolPintasanNominal({required this.label, required this.padaTekan});

  final String label;
  final VoidCallback padaTekan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: padaTekan,
      borderRadius: BorderRadius.circular(SudutFunda.pil),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.m,
          vertical: SpasiFunda.s,
        ),
        decoration: BoxDecoration(
          color: WarnaFunda.permukaan,
          borderRadius: BorderRadius.circular(SudutFunda.pil),
          border: Border.all(color: WarnaFunda.garis),
        ),
        child: Text(
          label,
          style: TipografiFunda.catatan.copyWith(
            fontWeight: FontWeight.w600,
            color: WarnaFunda.utama,
          ),
        ),
      ),
    );
  }
}
