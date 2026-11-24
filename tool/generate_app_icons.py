import os
import math
from PIL import Image, ImageDraw

def buat_ikon_funda(ukuran, bentuk="squircle", foreground_saja=False, monokrom=False):
    """
    Membuat ikon Funda Opsi 3 asli (The Living Leaf):
    - Huruf 'F' putih murni solid (#FFFFFF).
    - Tunas daun di ujung palang berwarna hijau muda segar (#68D391).
    - Latar belakang Forest Green (#1A4332).
    - bentuk: 'squircle', 'lingkaran', 'kotak'
    - foreground_saja: True jika hanya gambar F + daun dengan latar transparan (untuk adaptive icon)
    - monokrom: True jika siluet putih murni (untuk notifikasi status bar)
    """
    img = Image.new("RGBA", (ukuran, ukuran), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    s = ukuran
    
    # 1. Gambar latar belakang jika bukan foreground_saja atau monokrom
    if not foreground_saja and not monokrom:
        warna_latar = (26, 67, 50, 255) # Forest Green #1A4332
        radius = int(s * 0.22) # Squircle radius
        if bentuk == "lingkaran":
            draw.ellipse([0, 0, s - 1, s - 1], fill=warna_latar)
        elif bentuk == "squircle":
            draw.rounded_rectangle([0, 0, s - 1, s - 1], radius=radius, fill=warna_latar)
        else:
            draw.rectangle([0, 0, s - 1, s - 1], fill=warna_latar)

    # 2. Skala koordinat gambar F dan Daun (berbasis kanvas normal 100x100)
    margin = 0.22 if foreground_saja else 0.18
    w_aktif = s * (1.0 - 2 * margin)
    h_aktif = s * (1.0 - 2 * margin)
    x0 = s * margin
    y0 = s * margin

    # Buat kanvas resolusi tinggi sementara untuk rendering anti-aliased halus (supersampling 4x)
    skala_super = 4
    super_w = s * skala_super
    super_fg = Image.new("RGBA", (super_w, super_w), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(super_fg)

    def skx(px):
        return (x0 + (px / 100.0) * w_aktif) * skala_super
    def sky(py):
        return (y0 + (py / 100.0) * h_aktif) * skala_super

    # Warna elemen
    warna_f = (255, 255, 255, 255) # Putih murni solid
    warna_daun = (255, 255, 255, 255) if monokrom else (104, 211, 145, 255) # Hijau muda tunas #68D391

    # A. Batang Vertikal 'F' (Putih)
    bx1, by1 = skx(28), sky(15)
    bx2, by2 = skx(43), sky(85)
    rad_batang = int(super_w * 0.035)
    s_draw.rounded_rectangle([bx1, by1, bx2, by2], radius=rad_batang, fill=warna_f)

    # B. Palang Horizontal Tengah 'F' (Putih)
    px1, py1 = skx(40), sky(45)
    px2, py2 = skx(68), sky(57)
    rad_palang = int(super_w * 0.025)
    s_draw.rounded_rectangle([px1, py1, px2, py2], radius=rad_palang, fill=warna_f)

    # C. Palang Horizontal Atas 'F' (Putih)
    ax1, ay1 = skx(38), sky(15)
    ax2, ay2 = skx(72), sky(27)
    s_draw.rounded_rectangle([ax1, ay1, ax2, ay2], radius=rad_palang, fill=warna_f)

    # D. Tunas Daun Pertama (Daun Utama mengarah ke kanan atas - Hijau Muda #68D391)
    titik_daun1 = [
        (skx(70), sky(18)),
        (skx(82), sky(12)),
        (skx(92), sky(14)),
        (skx(95), sky(24)),
        (skx(88), sky(32)),
        (skx(74), sky(28)),
    ]
    s_draw.polygon(titik_daun1, fill=warna_daun)

    # E. Tunas Daun Kedua (Daun Kecil di ketiak tunas - Hijau Muda #68D391)
    titik_daun2 = [
        (skx(66), sky(28)),
        (skx(78), sky(32)),
        (skx(85), sky(40)),
        (skx(78), sky(44)),
        (skx(68), sky(38)),
    ]
    s_draw.polygon(titik_daun2, fill=warna_daun)

    # Resize supersampled image kembali ke ukuran target dengan resampling berkualitas tinggi (LANCZOS)
    foreground = super_fg.resize((s, s), Image.Resampling.LANCZOS)

    # Gabungkan dengan kanvas utama
    img = Image.alpha_composite(img, foreground)
    return img

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    # Direktori tujuan
    res_dir = os.path.join(root_dir, "android", "app", "src", "main", "res")
    aset_dir = os.path.join(root_dir, "aset", "gambar")
    os.makedirs(aset_dir, exist_ok=True)
    os.makedirs(os.path.join(res_dir, "drawable"), exist_ok=True)

    # 1. Simpan Master Ikon Resolusi Tinggi di aset/gambar/
    master_512 = buat_ikon_funda(512, bentuk="squircle")
    master_512.save(os.path.join(aset_dir, "app_icon_512.png"))
    print("Tersimpan: aset/gambar/app_icon_512.png")

    master_1024 = buat_ikon_funda(1024, bentuk="squircle")
    master_1024.save(os.path.join(aset_dir, "app_icon_1024.png"))
    print("Tersimpan: aset/gambar/app_icon_1024.png")

    # 2. Simpan Android Mipmap Icons
    ukuran_mipmap = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, size in ukuran_mipmap.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # ic_launcher (squircle)
        ikon_launcher = buat_ikon_funda(size, bentuk="squircle")
        ikon_launcher.save(os.path.join(folder_path, "ic_launcher.png"))
        
        # ic_launcher_round (lingkaran)
        ikon_round = buat_ikon_funda(size, bentuk="lingkaran")
        ikon_round.save(os.path.join(folder_path, "ic_launcher_round.png"))
        
        # ic_launcher_foreground (untuk adaptive icon v26)
        ikon_fg = buat_ikon_funda(size, foreground_saja=True)
        ikon_fg.save(os.path.join(folder_path, "ic_launcher_foreground.png"))
        print(f"Tersimpan ikon Android asli Opsi 3: {folder} ({size}x{size})")

    # 3. Simpan Ikon Notifikasi Monokrom di res/drawable/ic_notifikasi.png
    notif_icon = buat_ikon_funda(96, monokrom=True)
    notif_icon.save(os.path.join(res_dir, "drawable", "ic_notifikasi.png"))
    print("Tersimpan: res/drawable/ic_notifikasi.png")

if __name__ == "__main__":
    main()
