import os
import subprocess
import re
from PIL import Image, ImageDraw

def render_svg_to_png(svg_path, png_path, size=1024):
    edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    
    with open(svg_path, "r", encoding="utf-8") as f:
        svg_content = f.read()

    html_content = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * {{ box-sizing: border-box; }}
  html, body {{
    margin: 0;
    padding: 0;
    width: {size}px;
    height: {size}px;
    overflow: hidden;
    background: transparent;
  }}
  svg {{
    width: {size}px;
    height: {size}px;
    display: block;
  }}
</style>
</head>
<body>
{svg_content}
</body>
</html>
"""
    temp_html = os.path.join(os.path.dirname(png_path), f"temp_{size}.html")
    with open(temp_html, "w", encoding="utf-8") as f:
        f.write(html_content)

    cmd = [
        edge_path,
        "--headless",
        "--disable-gpu",
        f"--screenshot={png_path}",
        f"--window-size={size},{size}",
        f"--default-background-color=00000000",
        temp_html
    ]
    subprocess.run(cmd, check=True)
    if os.path.exists(temp_html):
        os.remove(temp_html)

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    svg_source = os.path.join(root_dir, "icon-funda.svg")
    aset_dir = os.path.join(root_dir, "aset", "gambar")
    res_dir = os.path.join(root_dir, "android", "app", "src", "main", "res")
    os.makedirs(aset_dir, exist_ok=True)

    print("1. Merender master icon 1024x1024 dari icon-funda.svg...")
    master_1024_path = os.path.join(aset_dir, "app_icon_1024.png")
    render_svg_to_png(svg_source, master_1024_path, size=1024)

    # Buat versi 512x512
    img_1024 = Image.open(master_1024_path).convert("RGBA")
    img_512 = img_1024.resize((512, 512), Image.Resampling.LANCZOS)
    img_512.save(os.path.join(aset_dir, "app_icon_512.png"))

    # 2. Siapkan SVG Foreground Saja (tanpa background rect hijau)
    with open(svg_source, "r", encoding="utf-8") as f:
        svg_raw = f.read()

    # Hapus elemen rect background hijau
    svg_foreground = re.sub(r'<rect\s+x="0"\s+y="0"[^>]*/>', '', svg_raw)
    
    # Bungkus dalam viewBox dengan margin 15% agar adaptive icon Android aman di safe zone
    # Skalakan grup monogram sedikit agar tidak terpotong masking lingkaran Android
    fg_svg_path = os.path.join(aset_dir, "temp_fg.svg")
    fg_png_temp = os.path.join(aset_dir, "temp_fg_1024.png")
    
    # Skala safe zone untuk adaptive icon (72% scale di tengah)
    # Ganti viewBox atau beri transform scaling
    svg_fg_safe = svg_foreground.replace(
        '<g transform="translate(-45, 35)"',
        '<g transform="translate(100, 110) scale(0.75)"'
    )
    with open(fg_svg_path, "w", encoding="utf-8") as f:
        f.write(svg_fg_safe)

    print("2. Merender foreground adaptive icon...")
    render_svg_to_png(fg_svg_path, fg_png_temp, size=1024)
    fg_1024 = Image.open(fg_png_temp).convert("RGBA")
    os.remove(fg_svg_path)
    os.remove(fg_png_temp)

    # 3. Siapkan Notifikasi Monokrom (Putih dengan latar transparan)
    print("3. Membuat ikon notifikasi monokrom...")
    notif_img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    fg_resized_notif = fg_1024.resize((128, 128), Image.Resampling.LANCZOS)
    # Ubah semua piksel non-transparan menjadi putih solid
    r, g, b, a = fg_resized_notif.split()
    white_img = Image.new("RGB", (128, 128), (255, 255, 255))
    notif_img = Image.merge("RGBA", (*white_img.split(), a))
    notif_img.save(os.path.join(res_dir, "drawable", "ic_notifikasi.png"))

    # 4. Generate Mipmap Icons
    print("4. Menghasilkan seluruh ukuran mipmap Android...")
    ukuran_mipmap = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    # Buat mask lingkaran untuk ic_launcher_round
    def buat_round_icon(base_img, size):
        scaled = base_img.resize((size, size), Image.Resampling.LANCZOS)
        mask = Image.new("L", (size, size), 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse([0, 0, size - 1, size - 1], fill=255)
        output = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        output.paste(scaled, (0, 0), mask)
        return output

    for folder, size in ukuran_mipmap.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)

        # ic_launcher.png (squircle asli)
        scaled_launcher = img_1024.resize((size, size), Image.Resampling.LANCZOS)
        scaled_launcher.save(os.path.join(folder_path, "ic_launcher.png"))

        # ic_launcher_round.png (lingkaran)
        round_icon = buat_round_icon(img_1024, size)
        round_icon.save(os.path.join(folder_path, "ic_launcher_round.png"))

        # ic_launcher_foreground.png (foreground transparan untuk adaptive icon)
        fg_scaled = fg_1024.resize((size, size), Image.Resampling.LANCZOS)
        fg_scaled.save(os.path.join(folder_path, "ic_launcher_foreground.png"))

        print(f"   -> {folder}: {size}x{size} selesai")

    # Salin juga master svg ke aset/gambar/app_icon.svg
    with open(os.path.join(aset_dir, "app_icon.svg"), "w", encoding="utf-8") as f:
        f.write(svg_raw)

    print("Semua aset ikon resmi berhasil di-generate dari icon-funda.svg!")

if __name__ == "__main__":
    main()
