# Panduan Rilis v1.0 Aplikasi Funda

Dokumen ini adalah panduan operasional langkah demi langkah untuk melakukan kompilasi, penandatanganan kode (code signing), publikasi toko aplikasi (Google Play Store & Apple App Store), dan pengujian akhir pada perangkat fisik.

---

## 1. Pembuatan Keystore & Signing Rilis Android

### A. Membuat Java Keystore (JKS)
Jalankan perintah berikut di terminal (simpan berkas keystore di tempat aman di luar repositori git):
```bash
keytool -genkey -v -keystore C:\Users\<NamaUser>\funda_upload_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias funda-upload
```

### B. Konfigurasi `key.properties`
Buat berkas `android/key.properties` (berkas ini sudah dimasukkan ke `.gitignore` agar tidak bocor):
```properties
storePassword=KATA_SANDI_KEYSTORE_ANDA
keyPassword=KATA_SANDI_ALIAS_ANDA
keyAlias=funda-upload
storeFile=C:\\Users\\<NamaUser>\\funda_upload_key.jks
```

### C. Menghubungkan ke `android/app/build.gradle.kts`
Saat siap melakukan signing produksi Play Store, perbarui blok `signingConfigs` di `build.gradle.kts`:
```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

### D. Perintah Build Android App Bundle (AAB) & APK Per-ABI (R8 Aktif)
Sejak v1.1.0, `android/app/build.gradle.kts` mengaktifkan `isMinifyEnabled = true`, `isShrinkResources = true`, serta aturan `android/app/proguard-rules.pro` untuk menjaga kelas Drift/SQLite/JNA dan `flutter_local_notifications`. Aset gambar besar yang tidak dirender di UI (`app_icon_1024.png` dan `icon-funda.svg`) dipisahkan ke `docs/desain/ikon/`.

1. **Untuk distribusi APK langsung per arsitektur (lebih ramping, cocok untuk perangkat Android modern):**
   ```bash
   flutter build apk --release --split-per-abi
   ```
   Berkas APK utama untuk perangkat Android modern (64-bit ARM): `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

2. **Untuk rilis ke Google Play Console (AAB):**
   ```bash
   flutter build appbundle --release
   ```
   Berkas output terletak di: `build/app/outputs/bundle/release/app-release.aab`.

---

## 2. Catatan Kompilasi iOS (macOS / Xcode)

### A. Kebutuhan Lingkungan
- Komputer Mac dengan macOS Sonoma / Sequoia terbaru.
- Xcode 15+ dengan Apple Developer Account aktif.
- CocoaPods (`sudo gem install cocoapods`) atau plugin Swift Package Manager.

### B. Konfigurasi Signing & Capabilities
1. Buka workspace di Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Pilih target **Runner** > tab **Signing & Capabilities**:
   - Pilih *Team* Apple Developer Anda.
   - Pastikan *Bundle Identifier* unik (mis. `com.funda.app`).
   - Tambahkan Capability: **Background Modes** (pilih *Remote notifications* / *Background fetch* bila diperlukan untuk pengingat).
3. Verifikasi Izin Notifikasi Lokal:
   - Plugin `flutter_local_notifications` menggunakan `UNUserNotificationCenter`.
   - Pastikan pada saat aplikasi pertama kali dijalankan, dialog izin notifikasi sistem iOS muncul dengan benar.

### C. Perintah Kompilasi iOS IPA
```bash
flutter build ipa --release
```
Unggah berkas arsip ke App Store Connect melalui Xcode Organizer atau Transporter.

---

## 3. Draf Pernyataan Privasi (Privacy Policy) untuk Play Store / App Store

> **Pernyataan Privasi Aplikasi Funda**  
> **Terakhir Diperbarui:** 24 November 2026  
>  
> Funda adalah aplikasi pencatat keuangan dan edukasi literasi keuangan yang beroperasi dengan prinsip **Privasi Penuh (Offline-First)**:  
> 1. **Tidak Ada Pengumpulan Data:** Seluruh data transaksi, dompet, kantong, utang, anggaran, catatan refleksi, dan progres belajar Anda disimpan secara lokal di perangkat Anda menggunakan SQLite terenkripsi pada sandbox sistem operasi.  
> 2. **Tidak Ada Pengiriman Data ke Server:** Aplikasi Funda tidak memiliki server backend dan tidak mengirimkan data keuangan atau data analitik perilaku Anda ke pihak ketiga mana pun.  
> 3. **Izin yang Digunakan:**  
>    - `POST_NOTIFICATIONS`: Digunakan hanya untuk membunyikan pengingat komitmen tagihan dan pengingat belajar harian yang Anda jadwalkan sendiri di perangkat.  
>    - `RECEIVE_BOOT_COMPLETED`: Digunakan untuk menjadwalkan ulang notifikasi lokal setelah perangkat dinyalakan kembali.  
> 4. **Kendali Cadangan Mandiri:** Fitur cadangan menghasilkan berkas JSON terisolasi yang Anda simpan dan kendalikan sendiri melalui aplikasi berkas perangkat.

---

## 4. Checklist Uji Manual Akhir di HP Fisik

Lakukan pengujian manual berikut pada perangkat fisik Android dan iOS sebelum meluncurkan rilis publik:

- [ ] **Aksesibilitas Pembaca Layar:**
  - Aktifkan TalkBack (Android) / VoiceOver (iOS).
  - Jelajahi Beranda, Form Transaksi, Pemutar Pelajaran, dan Kuis.
  - Pastikan seluruh tombol memiliki label semantik yang jelas dan dapat dibacakan.
- [ ] **Aksesibilitas Skala Teks 200% (Ukuran Font Maksimal):**
  - Ubah ukuran font perangkat ke ukuran terbesar di Pengaturan HP.
  - Periksa seluruh layar bento dan pemutar kartu pelajaran: bebas dari garis kuning-hitam `RenderFlex overflow`.
- [ ] **Cold Boot Notifikasi & Pengingat:**
  - Jadwalkan pengingat tagihan atau pengingat belajar 5 menit ke depan.
  - Lakukan *restart* (reboot) perangkat fisik.
  - Pastikan notifikasi lokal tetap berbunyi tepat waktu pasca-reboot.
- [ ] **Ekspor & Berbagi Gambar/PDF Laporan Bulanan:**
  - Buka Laporan Bulanan.
  - Coba opsi berbagi gambar PNG dan dokumen PDF ke aplikasi pihak ketiga (WhatsApp/Telegram/Drive).
  - Pastikan saklar sensor menyembunyikan nominal sensitif dengan tanda bintang.
- [ ] **Integritas Ekspor & Impor Cadangan:**
  - Ekspor data cadangan ke penyimpanan perangkat.
  - Hapus salah satu transaksi/dompet uji.
  - Pulihkan data dari berkas cadangan dan verifikasi seluruh transaksi kembali utuh.
- [ ] **Performa & Waktu Muat Dingin (Cold Start):**
  - Pastikan aplikasi terbuka dan menampilkan Dasbor Beranda dalam waktu < 2 detik pada kondisi data penuh (> 1.000 transaksi).
