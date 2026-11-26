import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/basis_data.dart';
import '../../../data/model/jenis_transaksi.dart';
import '../../../data/model/sifat_kategori.dart';
import '../../../data/penyedia_data.dart';
import '../../../komponen/komponen_funda.dart';
import '../../../komponen/pembantu_ikon.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';
import '../../../tema/token.dart';
import '../../../util/format_rupiah.dart';
import '../../utang/kontroler/penyedia_utang.dart';

/// Layar Formulir Catat Transaksi bergaya editorial modern:
/// header kanvas pastel dinamis (Koral / Mint / Biru), papan nominal besar bebas kotak kaku,
/// kartu putih ber-border 1px, dan sticky bottom CTA pil gelap.
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

  Color get _warnaKanvasHeader => switch (_jenisTerpilih) {
    JenisTransaksi.keluar => WarnaFunda.kanvasKoral,
    JenisTransaksi.masuk => WarnaFunda.kanvasMint,
    _ => WarnaFunda.kanvasBiru,
  };

  Color get _warnaAksenJenis => switch (_jenisTerpilih) {
    JenisTransaksi.keluar => WarnaFunda.pengeluaran,
    JenisTransaksi.masuk => WarnaFunda.pemasukan,
    _ => WarnaFunda.utama,
  };

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

  void _bukaPemilihDompetSheet({
    required String judul,
    required List<EntitasDompet> daftarDompet,
    required Map<String, int> petaSaldo,
    required String? terpilihId,
    String? kecualikanId,
    required ValueChanged<String> padaPilih,
  }) {
    final tanpaAnimasi =
        MediaQuery.disableAnimationsOf(context) ||
        ref.read(penyediaTanpaAnimasi);
    final opsi = daftarDompet.where((d) => d.id != kecualikanId).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: tanpaAnimasi ? AnimationStyle.noAnimation : null,
      backgroundColor: WarnaFunda.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SudutFunda.lembar),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpasiFunda.l,
            SpasiFunda.m,
            SpasiFunda.l,
            SpasiFunda.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: WarnaFunda.garis,
                    borderRadius: BorderRadius.circular(SudutFunda.pil),
                  ),
                ),
              ),
              const SizedBox(height: SpasiFunda.m),
              TeksFunda.judulBagian(judul),
              const SizedBox(height: SpasiFunda.m),
              if (opsi.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: SpasiFunda.m),
                  child: TeksFunda.catatan(
                    'Belum ada dompet lain yang tersedia.',
                    warna: WarnaFunda.teksRedup,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: opsi.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: WarnaFunda.garis),
                    itemBuilder: (_, idx) {
                      final d = opsi[idx];
                      final saldo = petaSaldo[d.id] ?? d.saldoAwalRupiah;
                      final terpilih = d.id == terpilihId;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SpasiFunda.s,
                          vertical: 4,
                        ),
                        leading: IkonDompetFunda(
                          kodeJenis: d.jenis,
                          kunciIkonFallback: d.ikon,
                          ukuran: 22,
                          warnaFallback: terpilih
                              ? WarnaFunda.utama
                              : WarnaFunda.teksRedup,
                        ),
                        title: TeksFunda.label(d.nama),
                        subtitle: TeksFunda.catatan(
                          formatRupiah(saldo),
                          warna: WarnaFunda.teksRedup,
                        ),
                        trailing: terpilih
                            ? const IkonUiFunda(
                                pathAset: AsetIkonUiFunda.check,
                                ukuran: 18,
                                warna: WarnaFunda.utama,
                              )
                            : null,
                        onTap: () {
                          padaPilih(d.id);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _tukarDompetTransfer() {
    if (_dompetIdTerpilih == null && _dompetTujuanIdTerpilih == null) return;
    setState(() {
      final sementara = _dompetIdTerpilih;
      _dompetIdTerpilih = _dompetTujuanIdTerpilih;
      _dompetTujuanIdTerpilih = sementara;
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
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        router.pop();
      } else {
        Navigator.maybePop(context);
      }
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

    final dompetAsalObj = daftarDompetAktif
        .where((d) => d.id == _dompetIdTerpilih)
        .firstOrNull;
    final dompetTujuanObj = daftarDompetAktif
        .where((d) => d.id == _dompetTujuanIdTerpilih)
        .firstOrNull;

    return Scaffold(
      backgroundColor: WarnaFunda.latar,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Kanvas Pastel Dinamis + Segmen + Papan Nominal Besar
                  Container(
                    key: const Key('header_kanvas_form_transaksi'),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _warnaKanvasHeader,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(SudutFunda.petak),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SpasiFunda.l,
                          SpasiFunda.s,
                          SpasiFunda.l,
                          SpasiFunda.l,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris Tutup / Kembali Bulat & Judul
                            Row(
                              children: [
                                Semantics(
                                  button: true,
                                  label: 'Kembali',
                                  child: InkWell(
                                    key: const Key(
                                      'tombol_kembali_form_transaksi',
                                    ),
                                    onTap: () => Navigator.maybePop(context),
                                    borderRadius: BorderRadius.circular(
                                      SudutFunda.pil,
                                    ),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: WarnaFunda.permukaan,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: WarnaFunda.garis,
                                        ),
                                      ),
                                      child: const IkonUiFunda(
                                        pathAset: AsetIkonUiFunda.arrowLeft,
                                        ukuran: 18,
                                        warna: WarnaFunda.teks,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: SpasiFunda.m),
                                Expanded(
                                  child: TeksFunda.judulBagian(
                                    _sedangUbah
                                        ? 'Ubah Catatan Transaksi'
                                        : 'Catat Transaksi',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpasiFunda.m),

                            // Segmen Pil Jenis Transaksi (Keluar, Masuk, Transfer)
                            Container(
                              padding: const EdgeInsets.all(SpasiFunda.xs),
                              decoration: BoxDecoration(
                                color: WarnaFunda.permukaan,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.pil,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _ItemSegmen(
                                    judul: 'Pengeluaran',
                                    pathSvg: AsetIkonFunda.transaksiPengeluaran,
                                    terpilih:
                                        _jenisTerpilih == JenisTransaksi.keluar,
                                    warnaAktif: WarnaFunda.pengeluaran,
                                    padaPilih: () => setState(() {
                                      _jenisTerpilih = JenisTransaksi.keluar;
                                      _kategoriIdTerpilih = null;
                                    }),
                                  ),
                                  _ItemSegmen(
                                    judul: 'Pemasukan',
                                    pathSvg: AsetIkonFunda.transaksiPemasukan,
                                    terpilih:
                                        _jenisTerpilih == JenisTransaksi.masuk,
                                    warnaAktif: WarnaFunda.pemasukan,
                                    padaPilih: () => setState(() {
                                      _jenisTerpilih = JenisTransaksi.masuk;
                                      _kategoriIdTerpilih = null;
                                    }),
                                  ),
                                  _ItemSegmen(
                                    judul: 'Transfer',
                                    pathSvg: AsetIkonFunda.transaksiTransfer,
                                    terpilih:
                                        _jenisTerpilih ==
                                        JenisTransaksi.transfer,
                                    warnaAktif: WarnaFunda.utama,
                                    padaPilih: () => setState(() {
                                      _jenisTerpilih = JenisTransaksi.transfer;
                                      _kategoriIdTerpilih = null;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: SpasiFunda.l),

                            // Papan Input Nominal Besar Bebas Kotak Kaku
                            const TeksFunda.catatan(
                              'Nominal Transaksi',
                              warna: WarnaFunda.teksRedup,
                            ),
                            TextField(
                              controller: _pengontrolNominal,
                              keyboardType: TextInputType.number,
                              style: TipografiFunda.angkaBesar.copyWith(
                                color: WarnaFunda.teks,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: SpasiFunda.xs,
                                ),
                              ),
                              onChanged: (teks) {
                                try {
                                  final nominal = ambilAngkaRupiah(teks);
                                  final format = formatRupiah(nominal);
                                  if (format != teks) {
                                    _pengontrolNominal.value = TextEditingValue(
                                      text: format,
                                      selection: TextSelection.collapsed(
                                        offset: format.length,
                                      ),
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
                                  warnaAksen: _warnaAksenJenis,
                                  padaTekan: () =>
                                      _tambahNominalPintasan(10000),
                                ),
                                _TombolPintasanNominal(
                                  label: '+50rb',
                                  warnaAksen: _warnaAksenJenis,
                                  padaTekan: () =>
                                      _tambahNominalPintasan(50000),
                                ),
                                _TombolPintasanNominal(
                                  label: '+100rb',
                                  warnaAksen: _warnaAksenJenis,
                                  padaTekan: () =>
                                      _tambahNominalPintasan(100000),
                                ),
                                _TombolPintasanNominal(
                                  label: '+500rb',
                                  warnaAksen: _warnaAksenJenis,
                                  padaTekan: () =>
                                      _tambahNominalPintasan(500000),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Area Isian Formulir dalam Kartu Putih Bersih 1px Border
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SpasiFunda.l,
                      SpasiFunda.l,
                      SpasiFunda.l,
                      SpasiFunda.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Peringatan Lembut Bila Saldo Dompet Jadi Minus
                        if (apakahMinus) ...[
                          Container(
                            padding: const EdgeInsets.all(SpasiFunda.m),
                            decoration: BoxDecoration(
                              color: WarnaFunda.tintAmber,
                              borderRadius: BorderRadius.circular(
                                SudutFunda.kartu,
                              ),
                              border: Border.all(color: WarnaFunda.batasAmber),
                            ),
                            child: Row(
                              children: [
                                const IkonUiFunda(
                                  pathAset: AsetIkonUiFunda.circleAlert,
                                  warna: WarnaFunda.peringatan,
                                  ukuran: 20,
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
                          const SizedBox(height: SpasiFunda.m),
                        ],

                        // Kartu Dompet (Chip Horizontal untuk Keluar/Masuk; Alur Modal untuk Transfer)
                        if (_jenisTerpilih != JenisTransaksi.transfer)
                          _KartuPutihForm(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TeksFunda.label('Dompet Pembayaran'),
                                const SizedBox(height: SpasiFunda.m),
                                if (daftarDompetAktif.isEmpty)
                                  const TeksFunda.catatan(
                                    'Belum ada dompet aktif.',
                                    warna: WarnaFunda.teksRedup,
                                  )
                                else
                                  SingleChildScrollView(
                                    key: const Key('daftar_chip_dompet_cepat'),
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: daftarDompetAktif.map((d) {
                                        final terpilih =
                                            _dompetIdTerpilih == d.id;
                                        final saldo =
                                            petaSaldo[d.id] ??
                                            d.saldoAwalRupiah;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: SpasiFunda.s,
                                          ),
                                          child: Semantics(
                                            button: true,
                                            selected: terpilih,
                                            label:
                                                'Dompet ${d.nama}, saldo ${formatRupiah(saldo)}',
                                            child: InkWell(
                                              key: Key('chip_dompet_${d.id}'),
                                              onTap: () => setState(
                                                () => _dompetIdTerpilih = d.id,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SudutFunda.kartu,
                                                  ),
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 120,
                                                      minHeight: 48,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: SpasiFunda.m,
                                                      vertical: SpasiFunda.s,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: terpilih
                                                      ? WarnaFunda.utamaTipis
                                                      : WarnaFunda.latar,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        SudutFunda.kartu,
                                                      ),
                                                  border: Border.all(
                                                    color: terpilih
                                                        ? WarnaFunda.utama
                                                        : WarnaFunda.garis,
                                                    width: terpilih ? 1.5 : 1.0,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (pathSvgUntukJenisDompet(
                                                          d.jenis,
                                                        ) !=
                                                        null)
                                                      IkonSvgFunda(
                                                        pathAset:
                                                            pathSvgUntukJenisDompet(
                                                              d.jenis,
                                                            )!,
                                                        ukuran: 20,
                                                      )
                                                    else
                                                      Icon(
                                                        ambilIkonLucide(d.ikon),
                                                        size: 18,
                                                        color: terpilih
                                                            ? WarnaFunda
                                                                  .utamaGelap
                                                            : WarnaFunda.utama,
                                                      ),
                                                    const SizedBox(
                                                      width: SpasiFunda.s,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          d.nama,
                                                          style: TipografiFunda
                                                              .label
                                                              .copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    WarnaFunda
                                                                        .teks,
                                                              ),
                                                        ),
                                                        Text(
                                                          formatRupiah(saldo),
                                                          style: TipografiFunda
                                                              .catatan
                                                              .copyWith(
                                                                color: WarnaFunda
                                                                    .teksRedup,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        else
                          _KartuPutihForm(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const TeksFunda.label('Alur Transfer'),
                                    Semantics(
                                      button: true,
                                      label: 'Tukar dompet asal dan tujuan',
                                      child: InkWell(
                                        key: const Key(
                                          'tombol_tukar_dompet_transfer',
                                        ),
                                        onTap: _tukarDompetTransfer,
                                        borderRadius: BorderRadius.circular(
                                          SudutFunda.pil,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: SpasiFunda.s,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: WarnaFunda.tintNetral,
                                            borderRadius: BorderRadius.circular(
                                              SudutFunda.pil,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IkonUiFunda(
                                                pathAset:
                                                    AsetIkonUiFunda.arrowUpDown,
                                                ukuran: 14,
                                                warna: WarnaFunda.utama,
                                              ),
                                              SizedBox(width: 4),
                                              TeksFunda.catatan(
                                                'Tukar',
                                                warna: WarnaFunda.utama,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: SpasiFunda.m),
                                _BarisPilihDompetTransfer(
                                  key: const Key(
                                    'pemilih_dompet_asal_transfer',
                                  ),
                                  label: 'Dari Dompet Asal',
                                  dompet: dompetAsalObj,
                                  saldo: dompetAsalObj != null
                                      ? (petaSaldo[dompetAsalObj.id] ??
                                            dompetAsalObj.saldoAwalRupiah)
                                      : null,
                                  padaKetuk: () => _bukaPemilihDompetSheet(
                                    judul: 'Pilih Dompet Asal',
                                    daftarDompet: daftarDompetAktif,
                                    petaSaldo: petaSaldo,
                                    terpilihId: _dompetIdTerpilih,
                                    padaPilih: (id) => setState(() {
                                      _dompetIdTerpilih = id;
                                      if (_dompetTujuanIdTerpilih == id) {
                                        _dompetTujuanIdTerpilih = null;
                                      }
                                    }),
                                  ),
                                ),
                                const Divider(
                                  height: SpasiFunda.l,
                                  color: WarnaFunda.garis,
                                ),
                                _BarisPilihDompetTransfer(
                                  key: const Key(
                                    'pemilih_dompet_tujuan_transfer',
                                  ),
                                  label: 'Ke Dompet Tujuan',
                                  dompet: dompetTujuanObj,
                                  saldo: dompetTujuanObj != null
                                      ? (petaSaldo[dompetTujuanObj.id] ??
                                            dompetTujuanObj.saldoAwalRupiah)
                                      : null,
                                  padaKetuk: () => _bukaPemilihDompetSheet(
                                    judul: 'Pilih Dompet Tujuan',
                                    daftarDompet: daftarDompetAktif,
                                    petaSaldo: petaSaldo,
                                    terpilihId: _dompetTujuanIdTerpilih,
                                    kecualikanId: _dompetIdTerpilih,
                                    padaPilih: (id) => setState(
                                      () => _dompetTujuanIdTerpilih = id,
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: SpasiFunda.l,
                                  color: WarnaFunda.garis,
                                ),
                                const TeksFunda.catatan(
                                  'Biaya Admin Transfer (Opsional)',
                                  warna: WarnaFunda.teksRedup,
                                ),
                                TextField(
                                  controller: _pengontrolBiayaAdmin,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: SpasiFunda.xs,
                                    ),
                                  ),
                                  onChanged: (teks) {
                                    try {
                                      final nominal = ambilAngkaRupiah(teks);
                                      final format = formatRupiah(nominal);
                                      if (format != teks) {
                                        _pengontrolBiayaAdmin
                                            .value = TextEditingValue(
                                          text: format,
                                          selection: TextSelection.collapsed(
                                            offset: format.length,
                                          ),
                                        );
                                      }
                                    } catch (_) {}
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: SpasiFunda.m),

                        // Kartu Kategori (khusus Masuk & Keluar)
                        if (_jenisTerpilih != JenisTransaksi.transfer) ...[
                          _KartuPutihForm(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TeksFunda.label('Pilih Kategori'),
                                const SizedBox(height: SpasiFunda.m),
                                Wrap(
                                  spacing: SpasiFunda.s,
                                  runSpacing: SpasiFunda.s,
                                  children: kategoriSesuaiArus.map((kategori) {
                                    final terpilih =
                                        _kategoriIdTerpilih == kategori.id;
                                    final sifat = SifatKategori.dariKode(
                                      kategori.sifat,
                                    );

                                    final warnaSifat = switch (sifat) {
                                      SifatKategori.kebutuhan =>
                                        WarnaFunda.sifatKebutuhan,
                                      SifatKategori.keinginan =>
                                        WarnaFunda.sifatKeinginan,
                                      SifatKategori.tabungan =>
                                        WarnaFunda.sifatTabungan,
                                      SifatKategori.utang =>
                                        WarnaFunda.sifatUtang,
                                      _ => WarnaFunda.teksRedup,
                                    };

                                    return Semantics(
                                      button: true,
                                      selected: terpilih,
                                      label:
                                          'Kategori ${kategori.nama}, sifat ${sifat.label}',
                                      child: FilterChip(
                                        selected: terpilih,
                                        showCheckmark: false,
                                        avatar: IkonKategoriFunda(
                                          kunciIkon: kategori.ikon,
                                          ukuran: 18,
                                          warnaFallback: terpilih
                                              ? WarnaFunda.teksPutih
                                              : warnaSifat,
                                        ),
                                        label: Text(kategori.nama),
                                        labelStyle: TipografiFunda.catatan
                                            .copyWith(
                                              color: terpilih
                                                  ? WarnaFunda.teksPutih
                                                  : WarnaFunda.teks,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        backgroundColor: WarnaFunda.latar,
                                        selectedColor: warnaSifat,
                                        side: BorderSide(
                                          color: terpilih
                                              ? warnaSifat
                                              : WarnaFunda.garis,
                                        ),
                                        onSelected: (val) {
                                          setState(() {
                                            _kategoriIdTerpilih = val
                                                ? kategori.id
                                                : null;
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (apakahKategoriUtang &&
                                    daftarUtangAktif.isNotEmpty) ...[
                                  const SizedBox(height: SpasiFunda.l),
                                  const TeksFunda.label(
                                    'Hubungkan ke Utang (Opsional)',
                                  ),
                                  const SizedBox(height: SpasiFunda.s),
                                  DropdownButtonFormField<String?>(
                                    isExpanded: true,
                                    initialValue: _utangIdTerpilih,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: WarnaFunda.latar,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          SudutFunda.kartu,
                                        ),
                                        borderSide: const BorderSide(
                                          color: WarnaFunda.garis,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          SudutFunda.kartu,
                                        ),
                                        borderSide: const BorderSide(
                                          color: WarnaFunda.garis,
                                        ),
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
                                          child: Text(
                                            u.nama,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (val) {
                                      setState(() => _utangIdTerpilih = val);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: SpasiFunda.m),
                        ],

                        // Kartu Detail Tambahan: Tanggal & Catatan
                        _KartuPutihForm(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: _pilihTanggalWaktu,
                                borderRadius: BorderRadius.circular(
                                  SudutFunda.kecil,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SpasiFunda.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      const IkonUiFunda(
                                        pathAset: AsetIkonUiFunda.calendar,
                                        ukuran: 18,
                                        warna: WarnaFunda.utama,
                                      ),
                                      const SizedBox(width: SpasiFunda.m),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const TeksFunda.catatan(
                                              'Tanggal & Waktu',
                                              warna: WarnaFunda.teksRedup,
                                            ),
                                            const SizedBox(height: 2),
                                            TeksFunda.isiKecil(
                                              DateFormat(
                                                'EEEE, d MMMM yyyy HH:mm',
                                                'id_ID',
                                              ).format(_waktuTransaksi),
                                              warna: WarnaFunda.teks,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const IkonUiFunda(
                                        pathAset: AsetIkonUiFunda.chevronRight,
                                        ukuran: 16,
                                        warna: WarnaFunda.teksRedup,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                height: SpasiFunda.l,
                                color: WarnaFunda.garis,
                              ),
                              const TeksFunda.catatan(
                                'Catatan (Opsional)',
                                warna: WarnaFunda.teksRedup,
                              ),
                              TextField(
                                controller: _pengontrolCatatan,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Misal: Sarapan bubur ayam, bayar wifi bulanan',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: SpasiFunda.xs,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom CTA Pil Gelap Kontras Tinggi
          Container(
            padding: const EdgeInsets.fromLTRB(
              SpasiFunda.l,
              SpasiFunda.m,
              SpasiFunda.l,
              SpasiFunda.m,
            ),
            decoration: const BoxDecoration(
              color: WarnaFunda.permukaan,
              border: Border(top: BorderSide(color: WarnaFunda.garis)),
            ),
            child: SafeArea(
              top: false,
              child: TombolFunda.pilGelap(
                key: const Key('tombol_simpan_transaksi'),
                teks: _sedangUbah ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                memuat: _memuat,
                padaTekan: _simpan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuPutihForm extends StatelessWidget {
  final Widget child;

  const _KartuPutihForm({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpasiFunda.l),
      decoration: BoxDecoration(
        color: WarnaFunda.permukaan,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
        border: Border.all(color: WarnaFunda.garis, width: 1.0),
      ),
      child: child,
    );
  }
}

class _BarisPilihDompetTransfer extends StatelessWidget {
  final String label;
  final EntitasDompet? dompet;
  final int? saldo;
  final VoidCallback padaKetuk;

  const _BarisPilihDompetTransfer({
    super.key,
    required this.label,
    required this.dompet,
    required this.saldo,
    required this.padaKetuk,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: padaKetuk,
      borderRadius: BorderRadius.circular(SudutFunda.kecil),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (dompet != null)
              IkonDompetFunda(
                kodeJenis: dompet!.jenis,
                kunciIkonFallback: dompet!.ikon,
                ukuran: 22,
                warnaFallback: WarnaFunda.utama,
              )
            else
              const IkonSvgFunda(
                pathAset: AsetIkonFunda.menuDompet,
                ukuran: 22,
              ),
            const SizedBox(width: SpasiFunda.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TeksFunda.catatan(label, warna: WarnaFunda.teksRedup),
                  const SizedBox(height: 2),
                  Text(
                    dompet != null
                        ? '${dompet!.nama} (${formatRupiah(saldo ?? 0)})'
                        : 'Ketuk untuk memilih dompet',
                    style: TipografiFunda.label.copyWith(
                      color: dompet != null
                          ? WarnaFunda.teks
                          : WarnaFunda.teksRedup,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpasiFunda.s),
            const IkonUiFunda(
              pathAset: AsetIkonUiFunda.chevronRight,
              ukuran: 16,
              warna: WarnaFunda.teksRedup,
            ),
          ],
        ),
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
    this.pathSvg,
  });

  final String judul;
  final bool terpilih;
  final Color warnaAktif;
  final VoidCallback padaPilih;
  final String? pathSvg;

  @override
  Widget build(BuildContext context) {
    final teksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Expanded(
      child: GestureDetector(
        onTap: padaPilih,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpasiFunda.xs,
            vertical: SpasiFunda.s + 2,
          ),
          decoration: BoxDecoration(
            color: terpilih ? warnaAktif : WarnaFunda.transparan,
            borderRadius: BorderRadius.circular(SudutFunda.pil),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pathSvg != null && !teksBesar) ...[
                IkonSvgFunda(pathAset: pathSvg!, ukuran: 15),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  judul,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TipografiFunda.label.copyWith(
                    color: terpilih
                        ? WarnaFunda.teksPutih
                        : WarnaFunda.teksRedup,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TombolPintasanNominal extends StatelessWidget {
  const _TombolPintasanNominal({
    required this.label,
    required this.warnaAksen,
    required this.padaTekan,
  });

  final String label;
  final Color warnaAksen;
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
        ),
        child: Text(
          label,
          style: TipografiFunda.catatan.copyWith(
            fontWeight: FontWeight.w600,
            color: warnaAksen,
          ),
        ),
      ),
    );
  }
}
