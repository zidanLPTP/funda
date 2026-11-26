import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../tema/token.dart';

/// Kumpulan path aset SVG ilustrasi resmi Funda di `aset/gambar/ilustrasi/`.
abstract final class AsetIlustrasiFunda {
  static const dompet = 'aset/gambar/ilustrasi/dompet.svg';
  static const belumAdaDompet = 'aset/gambar/ilustrasi/belum-ada-dompet.svg';
  static const laporanBulanan = 'aset/gambar/ilustrasi/laporan_bulanan.svg';
  static const modeSandbox = 'aset/gambar/ilustrasi/mode_sandbox.svg';
  static const iconFunda = 'aset/gambar/ilustrasi/icon-funda.svg';
  static const anggaranKosong = 'aset/gambar/ilustrasi/anggaran_kosong.svg';
  static const catatTransaksi = 'aset/gambar/ilustrasi/catat_transaksi.svg';
  static const catatanKosong = 'aset/gambar/ilustrasi/catatan_kosong.svg';
  static const privasiLokal = 'aset/gambar/ilustrasi/privasi_lokal.svg';
  static const tagihanTenang = 'aset/gambar/ilustrasi/tagihan_tenang.svg';
  static const tujuanKosong = 'aset/gambar/ilustrasi/tujuan_kosong.svg';
  static const tutorialFiturLengkap =
      'aset/gambar/ilustrasi/tutorial_fitur_lengkap.svg';
  static const utangLunasKosong =
      'aset/gambar/ilustrasi/utang_lunas_kosong.svg';
  static const cadanganData = 'aset/gambar/ilustrasi/cadangan_data.svg';
  static const kantongKosong = 'aset/gambar/ilustrasi/kantong_kosong.svg';
  static const kekayaanBersih = 'aset/gambar/ilustrasi/kekayaan_bersih.svg';
  static const kuisLulus = 'aset/gambar/ilustrasi/kuis_lulus.svg';
  static const kuisUlangi = 'aset/gambar/ilustrasi/kuis_ulangi.svg';
  static const ruangTenang = 'aset/gambar/ilustrasi/ruang_tenang.svg';
  static const galatPemuatan = 'aset/gambar/ilustrasi/galat_pemuatan.svg';

  static const mulaiTesAwal = 'aset/gambar/ilustrasi/mulai-tes-awal.svg';
  static const anggaranArusKas =
      'aset/gambar/ilustrasi/anggaran-dan-arus-kas.svg';
  static const tabungan = 'aset/gambar/ilustrasi/tabungan.svg';
  static const danaDarurat = 'aset/gambar/ilustrasi/dana-darurat.svg';
  static const utangCicilan = 'aset/gambar/ilustrasi/utang_cicilan.svg';
  static const waspadaPenipuan = 'aset/gambar/ilustrasi/waspada_penipuan.svg';
  static const psikologiUang = 'aset/gambar/ilustrasi/psikologi_uang.svg';

  static const investasiDasar = 'aset/gambar/ilustrasi/investasi_dasar.svg';
  static const pajakDasar = 'aset/gambar/ilustrasi/pajak_dasar.svg';
  static const paylaterKredit = 'aset/gambar/ilustrasi/paylater_kredit.svg';
  static const penghasilanTambahan =
      'aset/gambar/ilustrasi/penghasilan_tambahan.svg';
  static const tujuanBesar = 'aset/gambar/ilustrasi/tujuan_besar.svg';
  static const proteksiDasar = 'aset/gambar/ilustrasi/proteksi_dasar.svg';

  static const investasiLanjutan =
      'aset/gambar/ilustrasi/investasi_lanjutan.svg';
  static const kprKreditBesar = 'aset/gambar/ilustrasi/kpr_kredit_besar.svg';
  static const pajakLanjutan = 'aset/gambar/ilustrasi/pajak_lanjutan.svg';
  static const pensiunKebebasanFinansial =
      'aset/gambar/ilustrasi/pensiun_kebebasan_finansial.svg';
  static const keuanganUsahaKecil =
      'aset/gambar/ilustrasi/keuangan_usaha_kecil.svg';
  static const proteksiKeluargaWarisan =
      'aset/gambar/ilustrasi/proteksi_keluarga_warisan.svg';
}

/// Kumpulan path aset ikon SVG custom Funda di `aset/gambar/ikon/`.
abstract final class AsetIkonFunda {
  static const navBerandaAktif = 'aset/gambar/ikon/ic_nav_beranda_aktif.svg';
  static const navBerandaNonaktif =
      'aset/gambar/ikon/ic_nav_beranda_nonaktif.svg';
  static const navCatatanAktif = 'aset/gambar/ikon/ic_nav_catatan_aktif.svg';
  static const navCatatanNonaktif =
      'aset/gambar/ikon/ic_nav_catatan_nonaktif.svg';
  static const navBelajarAktif = 'aset/gambar/ikon/ic_nav_belajar_aktif.svg';
  static const navBelajarNonaktif =
      'aset/gambar/ikon/ic_nav_belajar_nonaktif.svg';
  static const navLainnyaAktif = 'aset/gambar/ikon/ic_nav_lainnya_aktif.svg';
  static const navLainnyaNonaktif =
      'aset/gambar/ikon/ic_nav_lainnya_nonaktif.svg';

  static const dompetBank = 'aset/gambar/ikon/ic_dompet_bank.svg';
  static const dompetEwallet = 'aset/gambar/ikon/ic_dompet_ewallet.svg';
  static const dompetTunai = 'aset/gambar/ikon/ic_dompet_tunai.svg';

  static const sifatKebutuhan = 'aset/gambar/ikon/ic_sifat_kebutuhan.svg';
  static const sifatKeinginan = 'aset/gambar/ikon/ic_sifat_keinginan.svg';
  static const sifatTabungan = 'aset/gambar/ikon/ic_sifat_tabungan.svg';
  static const sifatUtang = 'aset/gambar/ikon/ic_sifat_utang.svg';

  static const transaksiPemasukan =
      'aset/gambar/ikon/ic_transaksi_pemasukan.svg';
  static const transaksiPengeluaran =
      'aset/gambar/ikon/ic_transaksi_pengeluaran.svg';
  static const transaksiTransfer = 'aset/gambar/ikon/ic_transaksi_transfer.svg';

  static const modeSandbox = 'aset/gambar/ikon/ic_mode_sandbox.svg';

  static const metrikAnggaran = 'aset/gambar/ikon/ic_metrik_anggaran.svg';
  static const metrikDanaDarurat =
      'aset/gambar/ikon/ic_metrik_dana_darurat.svg';
  static const metrikRasioCicilan =
      'aset/gambar/ikon/ic_metrik_rasio_cicilan.svg';
  static const metrikTujuan = 'aset/gambar/ikon/ic_metrik_tujuan.svg';

  static const menuCadangan = 'aset/gambar/ikon/ic_menu_cadangan.svg';
  static const menuDompet = 'aset/gambar/ikon/ic_menu_dompet.svg';
  static const menuKantong = 'aset/gambar/ikon/ic_menu_kantong.svg';
  static const menuKategori = 'aset/gambar/ikon/ic_menu_kategori.svg';
  static const menuKekayaan = 'aset/gambar/ikon/ic_menu_kekayaan.svg';
  static const menuPanduan = 'aset/gambar/ikon/ic_menu_panduan.svg';
  static const menuPrivasi = 'aset/gambar/ikon/ic_menu_privasi.svg';
  static const menuTagihan = 'aset/gambar/ikon/ic_menu_tagihan.svg';
  static const menuTentang = 'aset/gambar/ikon/ic_menu_tentang.svg';
  static const menuUtang = 'aset/gambar/ikon/ic_menu_utang.svg';

  static const katBelanja = 'aset/gambar/ikon/ic_kat_belanja.svg';
  static const katBonus = 'aset/gambar/ikon/ic_kat_bonus.svg';
  static const katDonasi = 'aset/gambar/ikon/ic_kat_donasi.svg';
  static const katGaji = 'aset/gambar/ikon/ic_kat_gaji.svg';
  static const katHiburan = 'aset/gambar/ikon/ic_kat_hiburan.svg';
  static const katInternet = 'aset/gambar/ikon/ic_kat_internet.svg';
  static const katKesehatan = 'aset/gambar/ikon/ic_kat_kesehatan.svg';
  static const katKopi = 'aset/gambar/ikon/ic_kat_kopi.svg';
  static const katLainnya = 'aset/gambar/ikon/ic_kat_lainnya.svg';
  static const katListrik = 'aset/gambar/ikon/ic_kat_listrik.svg';
  static const katMakan = 'aset/gambar/ikon/ic_kat_makan.svg';
  static const katPendidikan = 'aset/gambar/ikon/ic_kat_pendidikan.svg';
  static const katRumah = 'aset/gambar/ikon/ic_kat_rumah.svg';
  static const katTransportasi = 'aset/gambar/ikon/ic_kat_transportasi.svg';

  static const arusKas = 'aset/gambar/ikon/ic_arus_kas.svg';
  static const trenNaik = 'aset/gambar/ikon/ic_tren_naik.svg';
  static const trenTurun = 'aset/gambar/ikon/ic_tren_turun.svg';
  static const modePrivat = 'aset/gambar/ikon/ic_mode_privat.svg';
  static const eksporPng = 'aset/gambar/ikon/ic_ekspor_png.svg';
  static const eksporPdf = 'aset/gambar/ikon/ic_ekspor_pdf.svg';

  static const belajarDurasi = 'aset/gambar/ikon/ic_belajar_durasi.svg';
  static const belajarMulai = 'aset/gambar/ikon/ic_belajar_mulai.svg';
  static const belajarTerkunci = 'aset/gambar/ikon/ic_belajar_terkunci.svg';
  static const tesAwal = 'aset/gambar/ikon/ic_tes_awal.svg';

  static const pengaturanNotifikasi =
      'aset/gambar/ikon/ic_pengaturan_notifikasi.svg';
  static const pengaturanNotifikasiNonaktif =
      'aset/gambar/ikon/ic_pengaturan_notifikasi_nonaktif.svg';
  static const pengaturanHaptik = 'aset/gambar/ikon/ic_pengaturan_haptik.svg';
  static const pengaturanTutorial =
      'aset/gambar/ikon/ic_pengaturan_tutorial.svg';
  static const pengaturanProfil = 'aset/gambar/ikon/ic_pengaturan_profil.svg';

  static const tujuanKendaraan = 'aset/gambar/ikon/ic_tujuan_kendaraan.svg';
  static const tujuanLaptop = 'aset/gambar/ikon/ic_tujuan_laptop.svg';
  static const tujuanLiburan = 'aset/gambar/ikon/ic_tujuan_liburan.svg';

  static const analisisData = 'aset/gambar/ikon/ic_analisis_data.svg';
  static const kasKoin = 'aset/gambar/ikon/ic_kas_koin.svg';
  static const pembayaranUtang = 'aset/gambar/ikon/ic_pembayaran_utang.svg';
  static const penyimpananLokal = 'aset/gambar/ikon/ic_penyimpanan_lokal.svg';
}

/// Kumpulan path aset SVG ikon UI monokrom Funda di `aset/gambar/ikon/`.
abstract final class AsetIkonUiFunda {
  static const archive = 'aset/gambar/ikon/ic_ui_archive.svg';
  static const archiveRestore = 'aset/gambar/ikon/ic_ui_archive_restore.svg';
  static const arrowDownLeft = 'aset/gambar/ikon/ic_ui_arrow_down_left.svg';
  static const arrowDownRight = 'aset/gambar/ikon/ic_ui_arrow_down_right.svg';
  static const arrowLeft = 'aset/gambar/ikon/ic_ui_arrow_left.svg';
  static const arrowLeftRight = 'aset/gambar/ikon/ic_ui_arrow_left_right.svg';
  static const arrowRight = 'aset/gambar/ikon/ic_ui_arrow_right.svg';
  static const arrowUpDown = 'aset/gambar/ikon/ic_ui_arrow_up_down.svg';
  static const arrowUpRight = 'aset/gambar/ikon/ic_ui_arrow_up_right.svg';
  static const calendar = 'aset/gambar/ikon/ic_ui_calendar.svg';
  static const calendarClock = 'aset/gambar/ikon/ic_ui_calendar_clock.svg';
  static const calendarOff = 'aset/gambar/ikon/ic_ui_calendar_off.svg';
  static const check = 'aset/gambar/ikon/ic_ui_check.svg';
  static const checkCheck = 'aset/gambar/ikon/ic_ui_check_check.svg';
  static const checkSquare = 'aset/gambar/ikon/ic_ui_check_square.svg';
  static const chevronDown = 'aset/gambar/ikon/ic_ui_chevron_down.svg';
  static const chevronLeft = 'aset/gambar/ikon/ic_ui_chevron_left.svg';
  static const chevronRight = 'aset/gambar/ikon/ic_ui_chevron_right.svg';
  static const circle = 'aset/gambar/ikon/ic_ui_circle.svg';
  static const circleAlert = 'aset/gambar/ikon/ic_ui_circle_alert.svg';
  static const circleCheck = 'aset/gambar/ikon/ic_ui_circle_check.svg';
  static const circleDot = 'aset/gambar/ikon/ic_ui_circle_dot.svg';
  static const circleHelp = 'aset/gambar/ikon/ic_ui_circle_help.svg';
  static const circleMinus = 'aset/gambar/ikon/ic_ui_circle_minus.svg';
  static const circlePlus = 'aset/gambar/ikon/ic_ui_circle_plus.svg';
  static const clock = 'aset/gambar/ikon/ic_ui_clock.svg';
  static const code = 'aset/gambar/ikon/ic_ui_code.svg';
  static const copyPlus = 'aset/gambar/ikon/ic_ui_copy_plus.svg';
  static const download = 'aset/gambar/ikon/ic_ui_download.svg';
  static const ellipsisVertical =
      'aset/gambar/ikon/ic_ui_ellipsis_vertical.svg';
  static const externalLink = 'aset/gambar/ikon/ic_ui_external_link.svg';
  static const fastForward = 'aset/gambar/ikon/ic_ui_fast_forward.svg';
  static const forward = 'aset/gambar/ikon/ic_ui_forward.svg';
  static const info = 'aset/gambar/ikon/ic_ui_info.svg';
  static const listFilter = 'aset/gambar/ikon/ic_ui_list_filter.svg';
  static const listTodo = 'aset/gambar/ikon/ic_ui_list_todo.svg';
  static const minus = 'aset/gambar/ikon/ic_ui_minus.svg';
  static const pause = 'aset/gambar/ikon/ic_ui_pause.svg';
  static const pencil = 'aset/gambar/ikon/ic_ui_pencil.svg';
  static const play = 'aset/gambar/ikon/ic_ui_play.svg';
  static const plus = 'aset/gambar/ikon/ic_ui_plus.svg';
  static const rotateCcw = 'aset/gambar/ikon/ic_ui_rotate_ccw.svg';
  static const search = 'aset/gambar/ikon/ic_ui_search.svg';
  static const settings = 'aset/gambar/ikon/ic_ui_settings.svg';
  static const shieldAlert = 'aset/gambar/ikon/ic_ui_shield_alert.svg';
  static const skipForward = 'aset/gambar/ikon/ic_ui_skip_forward.svg';
  static const slidersHorizontal =
      'aset/gambar/ikon/ic_ui_sliders_horizontal.svg';
  static const square = 'aset/gambar/ikon/ic_ui_square.svg';
  static const trash = 'aset/gambar/ikon/ic_ui_trash.svg';
  static const triangleAlert = 'aset/gambar/ikon/ic_ui_triangle_alert.svg';
  static const undo = 'aset/gambar/ikon/ic_ui_undo.svg';
  static const upload = 'aset/gambar/ikon/ic_ui_upload.svg';
  static const x = 'aset/gambar/ikon/ic_ui_x.svg';
}

/// Memetakan [IconData] dari `LucideIcons` ke path SVG monokrom custom UI Funda.
String? pathSvgUiUntukLucide(IconData ikon) {
  if (ikon == LucideIcons.archive) return AsetIkonUiFunda.archive;
  if (ikon == LucideIcons.archiveRestore) return AsetIkonUiFunda.archiveRestore;
  if (ikon == LucideIcons.arrowDownLeft) return AsetIkonUiFunda.arrowDownLeft;
  if (ikon == LucideIcons.arrowDownRight) return AsetIkonUiFunda.arrowDownRight;
  if (ikon == LucideIcons.arrowLeft) return AsetIkonUiFunda.arrowLeft;
  if (ikon == LucideIcons.arrowLeftRight) return AsetIkonUiFunda.arrowLeftRight;
  if (ikon == LucideIcons.arrowRight) return AsetIkonUiFunda.arrowRight;
  if (ikon == LucideIcons.arrowUpDown) return AsetIkonUiFunda.arrowUpDown;
  if (ikon == LucideIcons.arrowUpRight) return AsetIkonUiFunda.arrowUpRight;
  if (ikon == LucideIcons.calendar) return AsetIkonUiFunda.calendar;
  if (ikon == LucideIcons.calendarClock) return AsetIkonUiFunda.calendarClock;
  if (ikon == LucideIcons.calendarOff) return AsetIkonUiFunda.calendarOff;
  if (ikon == LucideIcons.check) return AsetIkonUiFunda.check;
  if (ikon == LucideIcons.checkCheck) return AsetIkonUiFunda.checkCheck;
  if (ikon == LucideIcons.checkSquare) return AsetIkonUiFunda.checkSquare;
  if (ikon == LucideIcons.chevronDown) return AsetIkonUiFunda.chevronDown;
  if (ikon == LucideIcons.chevronLeft) return AsetIkonUiFunda.chevronLeft;
  if (ikon == LucideIcons.chevronRight) return AsetIkonUiFunda.chevronRight;
  if (ikon == LucideIcons.circle) return AsetIkonUiFunda.circle;
  if (ikon == LucideIcons.circleAlert || ikon == LucideIcons.alertCircle) {
    return AsetIkonUiFunda.circleAlert;
  }
  if (ikon == LucideIcons.circleCheck ||
      ikon == LucideIcons.checkCircle ||
      ikon == LucideIcons.checkCircle2) {
    return AsetIkonUiFunda.circleCheck;
  }
  if (ikon == LucideIcons.circleDot) return AsetIkonUiFunda.circleDot;
  if (ikon == LucideIcons.helpCircle) return AsetIkonUiFunda.circleHelp;
  if (ikon == LucideIcons.circleMinus) return AsetIkonUiFunda.circleMinus;
  if (ikon == LucideIcons.circlePlus) return AsetIkonUiFunda.circlePlus;
  if (ikon == LucideIcons.clock) return AsetIkonUiFunda.clock;
  if (ikon == LucideIcons.code) return AsetIkonUiFunda.code;
  if (ikon == LucideIcons.copyPlus) return AsetIkonUiFunda.copyPlus;
  if (ikon == LucideIcons.download) return AsetIkonUiFunda.download;
  if (ikon == LucideIcons.ellipsisVertical) {
    return AsetIkonUiFunda.ellipsisVertical;
  }
  if (ikon == LucideIcons.externalLink) return AsetIkonUiFunda.externalLink;
  if (ikon == LucideIcons.fastForward) return AsetIkonUiFunda.fastForward;
  if (ikon == LucideIcons.forward) return AsetIkonUiFunda.forward;
  if (ikon == LucideIcons.info) return AsetIkonUiFunda.info;
  if (ikon == LucideIcons.listFilter) return AsetIkonUiFunda.listFilter;
  if (ikon == LucideIcons.listTodo) return AsetIkonUiFunda.listTodo;
  if (ikon == LucideIcons.minus) return AsetIkonUiFunda.minus;
  if (ikon == LucideIcons.pause) return AsetIkonUiFunda.pause;
  if (ikon == LucideIcons.pencil) return AsetIkonUiFunda.pencil;
  if (ikon == LucideIcons.play) return AsetIkonUiFunda.play;
  if (ikon == LucideIcons.plus) return AsetIkonUiFunda.plus;
  if (ikon == LucideIcons.rotateCcw) return AsetIkonUiFunda.rotateCcw;
  if (ikon == LucideIcons.search) return AsetIkonUiFunda.search;
  if (ikon == LucideIcons.settings) return AsetIkonUiFunda.settings;
  if (ikon == LucideIcons.shieldAlert) return AsetIkonUiFunda.shieldAlert;
  if (ikon == LucideIcons.skipForward) return AsetIkonUiFunda.skipForward;
  if (ikon == LucideIcons.slidersHorizontal) {
    return AsetIkonUiFunda.slidersHorizontal;
  }
  if (ikon == LucideIcons.square) return AsetIkonUiFunda.square;
  if (ikon == LucideIcons.trash2) return AsetIkonUiFunda.trash;
  if (ikon == LucideIcons.triangleAlert || ikon == LucideIcons.alertTriangle) {
    return AsetIkonUiFunda.triangleAlert;
  }
  if (ikon == LucideIcons.undo2) return AsetIkonUiFunda.undo;
  if (ikon == LucideIcons.upload) return AsetIkonUiFunda.upload;
  if (ikon == LucideIcons.x) return AsetIkonUiFunda.x;
  return null;
}

/// Widget perender ikon UI monokrom SVG custom yang otomatis mengikuti
/// warna `IconTheme` (tombol, lencana status) atau [warna] eksplisit.
class IkonUiFunda extends StatelessWidget {
  final String pathAset;
  final double ukuran;
  final Color? warna;
  final String? labelAkses;

  const IkonUiFunda({
    super.key,
    required this.pathAset,
    this.ukuran = 20,
    this.warna,
    this.labelAkses,
  });

  @override
  Widget build(BuildContext context) {
    final warnaEfektif =
        warna ?? IconTheme.of(context).color ?? WarnaFunda.teks;
    return SvgPicture.asset(
      pathAset,
      width: ukuran,
      height: ukuran,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(warnaEfektif, BlendMode.srcIn),
      excludeFromSemantics: labelAkses == null,
      semanticsLabel: labelAkses,
    );
  }
}

/// Merender ikon UI SVG custom bila [ikon] tersedia di [pathSvgUiUntukLucide],
/// atau jatuh kembali ke [Icon] standar bila tidak ada padanannya.
Widget ikonUiDariLucide(
  IconData ikon, {
  double ukuran = 20,
  Color? warna,
  String? labelAkses,
}) {
  final pathSvg = pathSvgUiUntukLucide(ikon);
  if (pathSvg != null) {
    return IkonUiFunda(
      pathAset: pathSvg,
      ukuran: ukuran,
      warna: warna,
      labelAkses: labelAkses,
    );
  }
  return Icon(ikon, size: ukuran, color: warna, semanticLabel: labelAkses);
}

/// Widget perender ikon SVG custom berukuran tetap (default 24x24).
class IkonSvgFunda extends StatelessWidget {
  final String pathAset;
  final double ukuran;
  final String? labelAkses;

  const IkonSvgFunda({
    super.key,
    required this.pathAset,
    this.ukuran = 24,
    this.labelAkses,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      pathAset,
      width: ukuran,
      height: ukuran,
      fit: BoxFit.contain,
      excludeFromSemantics: labelAkses == null,
      semanticsLabel: labelAkses,
    );
  }
}

/// Mengembalikan path ikon SVG custom berdasarkan kode jenis dompet.
String? pathSvgUntukJenisDompet(String kodeJenis) {
  return switch (kodeJenis) {
    'rekening_bank' => AsetIkonFunda.dompetBank,
    'e_wallet' => AsetIkonFunda.dompetEwallet,
    'tunai' => AsetIkonFunda.dompetTunai,
    _ => null,
  };
}

/// Mengembalikan path ikon SVG custom berdasarkan kode sifat pengeluaran.
String? pathSvgUntukSifatKategori(String kodeSifat) {
  return switch (kodeSifat) {
    'kebutuhan' => AsetIkonFunda.sifatKebutuhan,
    'keinginan' => AsetIkonFunda.sifatKeinginan,
    'tabungan' => AsetIkonFunda.sifatTabungan,
    'utang' => AsetIkonFunda.sifatUtang,
    _ => null,
  };
}

/// Mengembalikan path ikon SVG custom berdasarkan kode jenis transaksi.
String pathSvgUntukJenisTransaksi(String kodeJenis) {
  return switch (kodeJenis) {
    'masuk' || 'penyesuaian_masuk' => AsetIkonFunda.transaksiPemasukan,
    'transfer' => AsetIkonFunda.transaksiTransfer,
    _ => AsetIkonFunda.transaksiPengeluaran,
  };
}

/// Widget perender ilustrasi SVG lokal dari aset Funda.
class IlustrasiSvgFunda extends StatelessWidget {
  final String pathAset;
  final double? lebar;
  final double tinggi;
  final BoxFit fit;
  final String? labelAkses;

  const IlustrasiSvgFunda({
    super.key,
    required this.pathAset,
    this.lebar,
    this.tinggi = 96,
    this.fit = BoxFit.contain,
    this.labelAkses,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      pathAset,
      width: lebar,
      height: tinggi,
      fit: fit,
      excludeFromSemantics: labelAkses == null,
      semanticsLabel: labelAkses,
    );
  }
}

/// Jenis ilustrasi vektor geometris buatan sendiri untuk modul & layar belajar Funda.
enum JenisIlustrasiFunda {
  kompas,
  neraca,
  celengan,
  rantaiKalender,
  perisai,
  pikiran,
  pajak,
  tunas,
  sasaran,
}

/// Pasangan warna kanvas solid cerah, aset SVG, & aksen kontras untuk modul.
class TemaVisualModul {
  final Color kanvas;
  final Color aksen;
  final Color warnaIkon;
  final IconData ikonGaris;
  final JenisIlustrasiFunda ilustrasi;
  final String pathSvg;

  const TemaVisualModul({
    required this.kanvas,
    required this.aksen,
    required this.warnaIkon,
    required this.ikonGaris,
    required this.ilustrasi,
    required this.pathSvg,
  });
}

/// Mengembalikan pasangan warna kanvas, aset SVG, aksen ilustrasi, dan ikon per modul.
TemaVisualModul temaVisualUntukModul(String modulId) {
  return switch (modulId) {
    'mulai_tes_awal' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.compass,
      ilustrasi: JenisIlustrasiFunda.kompas,
      pathSvg: AsetIlustrasiFunda.mulaiTesAwal,
    ),
    'anggaran_arus_kas' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.sifatKebutuhan,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.scale,
      ilustrasi: JenisIlustrasiFunda.neraca,
      pathSvg: AsetIlustrasiFunda.anggaranArusKas,
    ),
    'tabungan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.piggyBank,
      ilustrasi: JenisIlustrasiFunda.celengan,
      pathSvg: AsetIlustrasiFunda.tabungan,
    ),
    'dana_darurat' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKuning,
      aksen: WarnaFunda.peringatan,
      warnaIkon: WarnaFunda.aksenIkonKuning,
      ikonGaris: LucideIcons.umbrella,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.danaDarurat,
    ),
    'utang_cicilan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKoral,
      aksen: WarnaFunda.pengeluaran,
      warnaIkon: WarnaFunda.aksenIkonKoral,
      ikonGaris: LucideIcons.calendarClock,
      ilustrasi: JenisIlustrasiFunda.rantaiKalender,
      pathSvg: AsetIlustrasiFunda.utangCicilan,
    ),
    'waspada_penipuan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKoral,
      aksen: WarnaFunda.bahaya,
      warnaIkon: WarnaFunda.aksenIkonKoral,
      ikonGaris: LucideIcons.shieldAlert,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.waspadaPenipuan,
    ),
    'psikologi_uang' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasUngu,
      aksen: WarnaFunda.sifatKeinginan,
      warnaIkon: WarnaFunda.aksenIkonUngu,
      ikonGaris: LucideIcons.brain,
      ilustrasi: JenisIlustrasiFunda.pikiran,
      pathSvg: AsetIlustrasiFunda.psikologiUang,
    ),
    'paylater_kredit' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKuning,
      aksen: WarnaFunda.peringatan,
      warnaIkon: WarnaFunda.aksenIkonKuning,
      ikonGaris: LucideIcons.creditCard,
      ilustrasi: JenisIlustrasiFunda.rantaiKalender,
      pathSvg: AsetIlustrasiFunda.paylaterKredit,
    ),
    'penghasilan_tambahan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.pemasukan,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.briefcase,
      ilustrasi: JenisIlustrasiFunda.neraca,
      pathSvg: AsetIlustrasiFunda.penghasilanTambahan,
    ),
    'pajak_dasar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.info,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.fileSpreadsheet,
      ilustrasi: JenisIlustrasiFunda.pajak,
      pathSvg: AsetIlustrasiFunda.pajakDasar,
    ),
    'pajak_lanjutan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.info,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.fileSpreadsheet,
      ilustrasi: JenisIlustrasiFunda.pajak,
      pathSvg: AsetIlustrasiFunda.pajakLanjutan,
    ),
    'proteksi_dasar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.sifatKebutuhan,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.shieldCheck,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.proteksiDasar,
    ),
    'proteksi_keluarga_warisan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.sifatKebutuhan,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.shieldCheck,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.proteksiKeluargaWarisan,
    ),
    'investasi_dasar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utamaGelap,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.sprout,
      ilustrasi: JenisIlustrasiFunda.tunas,
      pathSvg: AsetIlustrasiFunda.investasiDasar,
    ),
    'investasi_lanjutan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utamaGelap,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.sprout,
      ilustrasi: JenisIlustrasiFunda.tunas,
      pathSvg: AsetIlustrasiFunda.investasiLanjutan,
    ),
    'tujuan_besar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasUngu,
      aksen: WarnaFunda.sifatKeinginan,
      warnaIkon: WarnaFunda.aksenIkonUngu,
      ikonGaris: LucideIcons.target,
      ilustrasi: JenisIlustrasiFunda.sasaran,
      pathSvg: AsetIlustrasiFunda.tujuanBesar,
    ),
    'kpr_kredit_besar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasUngu,
      aksen: WarnaFunda.sifatKeinginan,
      warnaIkon: WarnaFunda.aksenIkonUngu,
      ikonGaris: LucideIcons.target,
      ilustrasi: JenisIlustrasiFunda.sasaran,
      pathSvg: AsetIlustrasiFunda.kprKreditBesar,
    ),
    'pensiun_kebebasan_finansial' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKuning,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonKuning,
      ikonGaris: LucideIcons.sun,
      ilustrasi: JenisIlustrasiFunda.tunas,
      pathSvg: AsetIlustrasiFunda.pensiunKebebasanFinansial,
    ),
    'keuangan_usaha_kecil' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKoral,
      aksen: WarnaFunda.pengeluaran,
      warnaIkon: WarnaFunda.aksenIkonKoral,
      ikonGaris: LucideIcons.store,
      ilustrasi: JenisIlustrasiFunda.neraca,
      pathSvg: AsetIlustrasiFunda.keuanganUsahaKecil,
    ),
    _ => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.bookOpen,
      ilustrasi: JenisIlustrasiFunda.sasaran,
      pathSvg: AsetIlustrasiFunda.mulaiTesAwal,
    ),
  };
}

/// Kanvas ilustrasi persegi panjang membulat besar berlatar pastel solid cerah
/// untuk kepala kartu di Pemutar Pelajaran.
class KanvasIlustrasiPelajaran extends StatelessWidget {
  final String modulId;
  final double tinggi;

  const KanvasIlustrasiPelajaran({
    super.key,
    required this.modulId,
    this.tinggi = 164,
  });

  @override
  Widget build(BuildContext context) {
    final tema = temaVisualUntukModul(modulId);
    return Container(
      width: double.infinity,
      height: tinggi,
      decoration: BoxDecoration(
        color: tema.kanvas,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
      ),
      child: Center(
        child: IlustrasiSvgFunda(pathAset: tema.pathSvg, tinggi: tinggi * 0.78),
      ),
    );
  }
}

/// Ilustrasi vektor geometris murni yang digambar menggunakan CustomPainter
/// dengan palet Funda dan garis bersih tanpa dependensi gambar luar.
class IlustrasiGeometrisFunda extends StatelessWidget {
  final JenisIlustrasiFunda jenis;
  final Color warnaAksen;
  final double ukuran;

  const IlustrasiGeometrisFunda({
    super.key,
    required this.jenis,
    required this.warnaAksen,
    this.ukuran = 108,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ukuran,
      height: ukuran,
      child: CustomPaint(
        painter: _PelukisIlustrasiGeometris(
          jenis: jenis,
          warnaAksen: warnaAksen,
        ),
      ),
    );
  }
}

class _PelukisIlustrasiGeometris extends CustomPainter {
  final JenisIlustrasiFunda jenis;
  final Color warnaAksen;

  const _PelukisIlustrasiGeometris({
    required this.jenis,
    required this.warnaAksen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.42;

    final catIsiLembut = Paint()
      ..color = WarnaFunda.permukaan.withAlpha(220)
      ..style = PaintingStyle.fill;
    final catAksenIsi = Paint()
      ..color = warnaAksen
      ..style = PaintingStyle.fill;
    final catAksenLembut = Paint()
      ..color = warnaAksen.withAlpha(55)
      ..style = PaintingStyle.fill;
    final catGaris = Paint()
      ..color = WarnaFunda.tombolGelap
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.036
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final catGarisAksen = Paint()
      ..color = warnaAksen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.036
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (jenis) {
      case JenisIlustrasiFunda.sasaran:
        canvas.drawCircle(Offset(cx, cy), r, catIsiLembut);
        canvas.drawCircle(Offset(cx, cy), r, catGarisAksen);
        canvas.drawCircle(Offset(cx, cy), r * 0.64, catAksenLembut);
        canvas.drawCircle(Offset(cx, cy), r * 0.64, catGarisAksen);
        canvas.drawCircle(Offset(cx, cy), r * 0.28, catAksenIsi);
        // Panah diagonal bersih masuk tepat ke pusat sasaran
        final ujung = Offset(cx + r * 0.92, cy - r * 0.92);
        canvas.drawLine(Offset(cx, cy), ujung, catGaris);
        canvas.drawLine(ujung, Offset(ujung.dx - r * 0.24, ujung.dy), catGaris);
        canvas.drawLine(ujung, Offset(ujung.dx, ujung.dy + r * 0.24), catGaris);
      case JenisIlustrasiFunda.neraca:
        // Pilar & alas timbangan seimbang
        final alas = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + r * 0.72),
            width: r * 1.15,
            height: r * 0.2,
          ),
          Radius.circular(r * 0.1),
        );
        canvas.drawRRect(alas, catAksenIsi);
        canvas.drawLine(
          Offset(cx, cy + r * 0.62),
          Offset(cx, cy - r * 0.68),
          catGaris,
        );
        // Lengan timbangan
        canvas.drawLine(
          Offset(cx - r * 0.85, cy - r * 0.42),
          Offset(cx + r * 0.85, cy - r * 0.42),
          catGaris,
        );
        // Dua piringan seimbang
        final kiri = Offset(cx - r * 0.78, cy + r * 0.16);
        final kanan = Offset(cx + r * 0.78, cy + r * 0.16);
        canvas.drawLine(
          Offset(cx - r * 0.78, cy - r * 0.42),
          kiri,
          catGarisAksen,
        );
        canvas.drawLine(
          Offset(cx + r * 0.78, cy - r * 0.42),
          kanan,
          catGarisAksen,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kiri, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catIsiLembut,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kiri, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catGaris,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kanan, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catAksenLembut,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kanan, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catGaris,
        );
        canvas.drawCircle(Offset(cx, cy - r * 0.72), r * 0.14, catAksenIsi);
      case JenisIlustrasiFunda.celengan:
        // Koin di atas & kotak tabungan membulat
        final badan = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + r * 0.16),
            width: r * 1.55,
            height: r * 1.05,
          ),
          Radius.circular(r * 0.48),
        );
        canvas.drawRRect(badan, catIsiLembut);
        canvas.drawRRect(badan, catGaris);
        // Celah koin
        canvas.drawLine(
          Offset(cx - r * 0.25, cy - r * 0.16),
          Offset(cx + r * 0.25, cy - r * 0.16),
          catGaris,
        );
        // Koin masuk
        canvas.drawCircle(Offset(cx, cy - r * 0.62), r * 0.3, catAksenIsi);
        canvas.drawCircle(Offset(cx, cy - r * 0.62), r * 0.3, catGaris);
        canvas.drawCircle(
          Offset(cx + r * 0.42, cy + r * 0.05),
          r * 0.08,
          catAksenIsi,
        );
      case JenisIlustrasiFunda.perisai:
        final perisai = Path()
          ..moveTo(cx, cy - r * 0.92)
          ..lineTo(cx + r * 0.78, cy - r * 0.56)
          ..quadraticBezierTo(cx + r * 0.78, cy + r * 0.36, cx, cy + r * 0.92)
          ..quadraticBezierTo(
            cx - r * 0.78,
            cy + r * 0.36,
            cx - r * 0.78,
            cy - r * 0.56,
          )
          ..close();
        canvas.drawPath(perisai, catIsiLembut);
        canvas.drawPath(perisai, catGarisAksen);
        final centang = Path()
          ..moveTo(cx - r * 0.28, cy + r * 0.02)
          ..lineTo(cx - r * 0.05, cy + r * 0.26)
          ..lineTo(cx + r * 0.34, cy - r * 0.22);
        canvas.drawPath(centang, catGaris);
      case JenisIlustrasiFunda.tunas:
        // Batang diagram + daun tunas tumbuh ke atas
        final lebarBar = r * 0.28;
        final batang1 = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - r * 0.72, cy + r * 0.2, lebarBar, r * 0.6),
          Radius.circular(r * 0.08),
        );
        final batang2 = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - r * 0.14, cy - r * 0.1, lebarBar, r * 0.9),
          Radius.circular(r * 0.08),
        );
        final batang3 = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + r * 0.44, cy - r * 0.45, lebarBar, r * 1.25),
          Radius.circular(r * 0.08),
        );
        canvas.drawRRect(batang1, catIsiLembut);
        canvas.drawRRect(batang1, catGaris);
        canvas.drawRRect(batang2, catAksenLembut);
        canvas.drawRRect(batang2, catGaris);
        canvas.drawRRect(batang3, catAksenIsi);
        canvas.drawRRect(batang3, catGaris);
        // Garis panah naik
        final jalur = Path()
          ..moveTo(cx - r * 0.72, cy - r * 0.1)
          ..lineTo(cx - r * 0.02, cy - r * 0.45)
          ..lineTo(cx + r * 0.68, cy - r * 0.85);
        canvas.drawPath(jalur, catGarisAksen);
      case JenisIlustrasiFunda.kompas:
        canvas.drawCircle(Offset(cx, cy), r * 0.88, catIsiLembut);
        canvas.drawCircle(Offset(cx, cy), r * 0.88, catGaris);
        final jarumAtas = Path()
          ..moveTo(cx, cy - r * 0.56)
          ..lineTo(cx + r * 0.2, cy)
          ..lineTo(cx - r * 0.2, cy)
          ..close();
        final jarumBawah = Path()
          ..moveTo(cx, cy + r * 0.56)
          ..lineTo(cx + r * 0.2, cy)
          ..lineTo(cx - r * 0.2, cy)
          ..close();
        canvas.drawPath(jarumAtas, catAksenIsi);
        canvas.drawPath(jarumBawah, catAksenLembut);
        canvas.drawPath(jarumAtas, catGaris);
        canvas.drawCircle(Offset(cx, cy), r * 0.1, catIsiLembut);
      case JenisIlustrasiFunda.rantaiKalender:
        final kalender = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + r * 0.08),
            width: r * 1.48,
            height: r * 1.32,
          ),
          Radius.circular(r * 0.24),
        );
        canvas.drawRRect(kalender, catIsiLembut);
        canvas.drawRRect(kalender, catGaris);
        final pitaAtas = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - r * 0.74, cy - r * 0.58, r * 1.48, r * 0.36),
          Radius.circular(r * 0.18),
        );
        canvas.drawRRect(pitaAtas, catAksenIsi);
        canvas.drawLine(
          Offset(cx - r * 0.38, cy - r * 0.72),
          Offset(cx - r * 0.38, cy - r * 0.42),
          catGaris,
        );
        canvas.drawLine(
          Offset(cx + r * 0.38, cy - r * 0.72),
          Offset(cx + r * 0.38, cy - r * 0.42),
          catGaris,
        );
        canvas.drawCircle(
          Offset(cx - r * 0.28, cy + r * 0.18),
          r * 0.12,
          catAksenLembut,
        );
        canvas.drawCircle(
          Offset(cx + r * 0.24, cy + r * 0.18),
          r * 0.12,
          catAksenIsi,
        );
      case JenisIlustrasiFunda.pikiran:
        canvas.drawCircle(Offset(cx - r * 0.24, cy), r * 0.62, catIsiLembut);
        canvas.drawCircle(Offset(cx - r * 0.24, cy), r * 0.62, catGaris);
        canvas.drawCircle(Offset(cx + r * 0.26, cy), r * 0.62, catAksenLembut);
        canvas.drawCircle(Offset(cx + r * 0.26, cy), r * 0.62, catGarisAksen);
        canvas.drawCircle(Offset(cx, cy), r * 0.16, catAksenIsi);
      case JenisIlustrasiFunda.pajak:
        final kertas = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: r * 1.34,
            height: r * 1.62,
          ),
          Radius.circular(r * 0.2),
        );
        canvas.drawRRect(kertas, catIsiLembut);
        canvas.drawRRect(kertas, catGaris);
        canvas.drawLine(
          Offset(cx - r * 0.38, cy - r * 0.36),
          Offset(cx + r * 0.38, cy - r * 0.36),
          catGaris,
        );
        canvas.drawLine(
          Offset(cx - r * 0.38, cy - r * 0.04),
          Offset(cx + r * 0.22, cy - r * 0.04),
          catGarisAksen,
        );
        canvas.drawCircle(
          Offset(cx + r * 0.2, cy + r * 0.42),
          r * 0.24,
          catAksenIsi,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _PelukisIlustrasiGeometris oldDelegate) {
    return oldDelegate.jenis != jenis || oldDelegate.warnaAksen != warnaAksen;
  }
}
