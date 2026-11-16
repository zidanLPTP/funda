import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../perhitungan/perhitungan_tagihan.dart';
import 'layanan_pengingat.dart';

/// Implementasi nyata LayananPengingat menggunakan flutter_local_notifications
/// dan timezone perangkat. Penjadwalan bersifat inexact (ramah baterai, tanpa izin alarm presisi).
class LayananPengingatNyata implements LayananPengingat {
  LayananPengingatNyata([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _sudahInisialisasi = false;

  static const String _idKanal = 'funda_tagihan_pengingat';
  static const String _namaKanal = 'Pengingat Tagihan & Cicilan';
  static const String _deskripsiKanal =
      'Pemberitahuan ramah untuk jatuh tempo tagihan dan cicilan rutin Funda';

  @override
  Future<void> inisialisasi({
    void Function(String? rute)? padaKetukNotifikasi,
  }) async {
    if (_sudahInisialisasi) return;

    // 1. Inisialisasi basis data zona waktu
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = tzInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback ke Asia/Jakarta bila deteksi platform gagal
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {}
    }

    // 2. Pengaturan inisialisasi per platform
    // Izin awal iOS disetel false karena izin hanya boleh diminta saat saklar dinyalakan
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final rute = uraiPayloadNotifikasi(response.payload);
        padaKetukNotifikasi?.call(rute);
      },
    );

    _sudahInisialisasi = true;
  }

  @override
  Future<bool> mintaIzin() async {
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final diizinkan = await androidImpl?.requestNotificationsPermission();
      return diizinkan ?? false;
    } else if (Platform.isIOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final diizinkan = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return diizinkan ?? false;
    }
    return false;
  }

  @override
  Future<bool> cekStatusIzin() async {
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final diizinkan = await androidImpl?.areNotificationsEnabled();
      return diizinkan ?? false;
    } else if (Platform.isIOS) {
      // Di iOS status izin diperoleh saat memanggil requestPermissions tanpa memaksa dialog
      return true;
    }
    return false;
  }

  @override
  Future<void> jadwalkanPengingat(RencanaPengingat rencana) async {
    await inisialisasi();

    const androidDetails = AndroidNotificationDetails(
      _idKanal,
      _namaKanal,
      channelDescription: _deskripsiKanal,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const darwinDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final waktuLokal = tz.TZDateTime.from(rencana.waktuTayang, tz.local);

    await _plugin.zonedSchedule(
      id: rencana.idStabil,
      title: rencana.judul,
      body: rencana.isi,
      scheduledDate: waktuLokal,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: rencana.tujuanPayload,
    );
  }

  @override
  Future<void> batalkanSemuaPengingat() async {
    await inisialisasi();
    await _plugin.cancelAll();
  }

  @override
  Future<void> jadwalkanDaftarRencana(
    List<RencanaPengingat> daftarRencana,
  ) async {
    await batalkanSemuaPengingat();
    for (final rencana in daftarRencana) {
      await jadwalkanPengingat(rencana);
    }
  }
}
