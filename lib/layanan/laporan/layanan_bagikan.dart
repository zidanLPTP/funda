import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Provider layanan bagikan (default nyata, dapat di-override di test).
final penyediaLayananBagikan = Provider<LayananBagikan>((ref) {
  return const LayananBagikanNyata();
});

/// Antarmuka untuk menyimpan dan membagikan berkas ekspor laporan atau cadangan.
abstract class LayananBagikan {
  /// Menyimpan byte ke direktori cache sementara aplikasi.
  Future<File> simpanBerkas({
    required String namaBerkas,
    required List<int> bytes,
  });

  /// Membagikan berkas ke aplikasi eksternal via dialog bagikan sistem.
  Future<void> bagikanBerkas({
    required String pathBerkas,
    required String judul,
    String? teks,
  });

  /// Membersihkan berkas di folder ekspor yang berusia lebih dari 24 jam.
  /// Mengembalikan jumlah berkas yang berhasil dihapus.
  Future<int> bersihkanCacheKedaluwarsa({
    Duration batasUsia = const Duration(hours: 24),
  });
}

/// Implementasi nyata menggunakan direktori cache path_provider dan share_plus.
class LayananBagikanNyata implements LayananBagikan {
  const LayananBagikanNyata();

  Future<Directory> _dapatkanFolderEkspor() async {
    Directory tempDir;
    try {
      tempDir = await getTemporaryDirectory();
    } catch (_) {
      tempDir = Directory.systemTemp;
    }
    final folderEkspor = Directory(p.join(tempDir.path, 'funda_ekspor'));
    if (!await folderEkspor.exists()) {
      await folderEkspor.create(recursive: true);
    }
    return folderEkspor;
  }

  @override
  Future<File> simpanBerkas({
    required String namaBerkas,
    required List<int> bytes,
  }) async {
    final folder = await _dapatkanFolderEkspor();
    final file = File(p.join(folder.path, namaBerkas));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Future<void> bagikanBerkas({
    required String pathBerkas,
    required String judul,
    String? teks,
  }) async {
    final xFile = XFile(pathBerkas);
    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        text: teks,
        subject: judul,
        title: judul,
      ),
    );
  }

  @override
  Future<int> bersihkanCacheKedaluwarsa({
    Duration batasUsia = const Duration(hours: 24),
  }) async {
    try {
      final folder = await _dapatkanFolderEkspor();
      if (!await folder.exists()) return 0;

      final sekarang = DateTime.now();
      var terhapus = 0;

      await for (final entitas in folder.list()) {
        if (entitas is File) {
          final stat = await entitas.stat();
          if (sekarang.difference(stat.modified) > batasUsia) {
            await entitas.delete();
            terhapus++;
          }
        }
      }
      return terhapus;
    } catch (_) {
      return 0;
    }
  }
}

/// Implementasi palsu untuk pengujian unit dan widget tanpa efek samping sistem.
class LayananBagikanPalsu implements LayananBagikan {
  final Directory? direktoriUji;
  final List<String> riwayatDibagikan = [];
  final List<File> riwayatDisimpan = [];

  LayananBagikanPalsu({this.direktoriUji});

  @override
  Future<File> simpanBerkas({
    required String namaBerkas,
    required List<int> bytes,
  }) async {
    final dir = direktoriUji ?? Directory.systemTemp.createTempSync('funda_uji_ekspor_');
    final file = File(p.join(dir.path, namaBerkas));
    file.writeAsBytesSync(bytes, flush: true);
    riwayatDisimpan.add(file);
    return file;
  }

  @override
  Future<void> bagikanBerkas({
    required String pathBerkas,
    required String judul,
    String? teks,
  }) async {
    riwayatDibagikan.add('$pathBerkas ($judul)');
  }

  @override
  Future<int> bersihkanCacheKedaluwarsa({
    Duration batasUsia = const Duration(hours: 24),
  }) async {
    if (direktoriUji == null) return 0;
    final sekarang = DateTime.now();
    var terhapus = 0;
    if (await direktoriUji!.exists()) {
      for (final entitas in direktoriUji!.listSync()) {
        if (entitas is File) {
          final stat = entitas.statSync();
          if (sekarang.difference(stat.modified) > batasUsia) {
            entitas.deleteSync();
            terhapus++;
          }
        }
      }
    }
    return terhapus;
  }
}
