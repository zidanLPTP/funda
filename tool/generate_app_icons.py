import os
import math
from PIL import Image, ImageDraw

def buat_ikon_funda(ukuran, bentuk="squircle", foreground_saja=False, monokrom=False):
    """
    Membuat ikon Funda (Opsi 3: The Living Leaf dengan transisi gradasi putih ke hijau daun).
    - bentuk: 'squircle', 'lingkaran', 'kotak'
    - foreground_saja: True jika hanya gambar F + tunas dengan latar transparan (untuk adaptive icon foreground)
    - monokrom: True jika siluet putih murni dengan latar transparan (untuk status bar notification)
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
    # Area aktif: 25% margin agar adaptive icon tidak terpotong (safe zone)
    margin = 0.22 if foreground_saja else 0.18
    w_aktif = s * (1.0 - 2 * margin)
    h_aktif = s * (1.0 - 2 * margin)
    x0 = s * margin
    y0 = s * margin

    # Fungsi pembantu untuk konversi koordinat persen (0..100) ke pixel
    def kx(px):
        return x0 + (px / 100.0) * w_aktif
    def ky(py):
        return y0 + (py / 100.0) * h_aktif

    # Buat kanvas resolusi tinggi sementara untuk rendering anti-aliased halus
    skala_super = 4
    super_w = s * skala_super
    super_img = Image.new("RGBA", (super_w, super_w), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(super_img)

    def skx(px):
        return (x0 + (px / 100.0) * w_aktif) * skala_super
    def sky(py):
        return (y0 + (py / 100.0) * h_aktif) * skala_super

    # Masking layer untuk monogram 'F' dan Daun
    mask_img = Image.new("L", (super_w, super_w), 0)
    mask_draw = ImageDraw.Draw(mask_img)

    # A. Batang Vertikal 'F'
    bx1, by1 = skx(28), sky(15)
    bx2, by2 = skx(43), sky(85)
    rad_batang = int(super_w * 0.035)
    mask_draw.rounded_rectangle([bx1, by1, bx2, by2], radius=rad_batang, fill=255)

    # B. Palang Horizontal Tengah 'F'
    px1, py1 = skx(40), sky(45)
    px2, py2 = skx(68), sky(57)
    rad_palang = int(super_w * 0.025)
    mask_draw.rounded_rectangle([px1, py1, px2, py2], radius=rad_palang, fill=255)

    # C. Palang Horizontal Atas 'F'
    ax1, ay1 = skx(38), sky(15)
    ax2, ay2 = skx(72), sky(27)
    mask_draw.rounded_rectangle([ax1, ay1, ax2, ay2], radius=rad_palang, fill=255)

    # D. Tunas Daun Pertama (Daun Utama mengarah ke kanan atas)
    titik_daun1 = [
        (skx(70), sky(18)),
        (skx(82), sky(12)),
        (skx(92), sky(14)),
        (skx(95), sky(24)),
        (skx(88), sky(32)),
        (skx(74), sky(28)),
    ]
    mask_draw.polygon(titik_daun1, fill=255)

    # E. Tunas Daun Kedua (Daun Kecil di ketiak tunas)
    titik_daun2 = [
        (skx(66), sky(28)),
        (skx(78), sky(32)),
        (skx(85), sky(40)),
        (skx(78), sky(44)),
        (skx(68), sky(38)),
    ]
    mask_draw.polygon(titik_daun2, fill=255)

    # 3. Warna atau Gradasi Monogram
    if monokrom:
        # Putih solid untuk notifikasi
        grad_img = Image.new("RGBA", (super_w, super_w), (255, 255, 255, 255))
    else:
        # Gradasi dari bawah ke atas: Putih Murni (#FFFFFF) -> Mint (#A8ECC4) -> Daun Segar (#52B788)
        grad_img = Image.new("RGBA", (super_w, super_w))
        warna_bawah = (255, 255, 255)       # Putih di bagian bawah huruf F
        warna_tengah = (215, 245, 225)      # Transisi putih-ke-mint halus
        warna_atas = (82, 183, 136)         # Hijau daun segar #52B788 di ujung tunas daun

        # Render gradasi vertikal bergaris
        for y in range(super_w):
            rasio = 1.0 - (y / float(super_w)) # 0 di bawah, 1 di atas
            if rasio < 0.45:
                # Bawah ke tengah
                t = rasio / 0.45
                r = int(warna_bawah[0] + t * (warna_tengah[0] - warna_bawah[0]))
                g = int(warna_bawah[1] + t * (warna_tengah[1] - warna_bawah[1]))
                b = int(warna_bawah[2] + t * (warna_tengah[2] - warna_bawah[2]))
            else:
                # Tengah ke atas
                t = (rasio - 0.45) / 0.55
                r = int(warna_tengah[0] + t * (warna_atas[0] - warna_tengah[0]))
                g = int(warna_tengah[1] + t * (warna_atas[1] - warna_tengah[1]))
                b = int(warna_tengah[2] + t * (warna_atas[2] - warna_tengah[2]))
            
            grad_draw = ImageDraw.Draw(grad_img)
            grad_draw.line([(0, y), (super_w, y)], fill=(r, g, b, 255))

    # Terapkan masking pada gradasi
    grad_img.putalpha(mask_img)

    # Resize supersampled image kembali ke ukuran target dengan resampling berkualitas tinggi (LANCZOS)
    foreground = grad_img.resize((s, s), Image.Resampling.LANCZOS)

    # Gabungkan dengan kanvas utama
    img = Image.alpha_composite(img, foreground)
    return img

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    # Buat direktori tujuan bila belum ada
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
        print(f"Tersimpan ikon Android: {folder} ({size}x{size})")

    # 3. Simpan Ikon Notifikasi Monokrom di res/drawable/ic_notifikasi.png
    notif_icon = buat_ikon_funda(96, monokrom=True)
    notif_icon.save(os.path.join(res_dir, "drawable", "ic_notifikasi.png"))
    print("Tersimpan: res/drawable/ic_notifikasi.png")

if __name__ == "__main__":
    main()
