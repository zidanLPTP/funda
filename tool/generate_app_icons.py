"""Generate Android, iOS, and in-app PNG icons from app-icon.svg."""

from __future__ import annotations

import pathlib
import re
import subprocess
import tempfile
from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
SVG_PATH = ROOT / "app-icon.svg"

BROWSER_CANDIDATES = [
    pathlib.Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe"),
    pathlib.Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
]

ANDROID_LAUNCHER_SIZES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

ANDROID_FOREGROUND_SIZES = {
    "mdpi": 108,
    "hdpi": 162,
    "xhdpi": 216,
    "xxhdpi": 324,
    "xxxhdpi": 432,
}


def find_browser() -> pathlib.Path:
    for candidate in BROWSER_CANDIDATES:
        if candidate.exists():
            return candidate
    raise FileNotFoundError("Chrome or Edge executable not found for SVG rasterization.")


def rasterize_svg(browser: pathlib.Path, svg_markup: str, size: int, out_png: pathlib.Path) -> Image.Image:
    with tempfile.TemporaryDirectory() as tmp:
        html_path = pathlib.Path(tmp) / "render.html"
        html_path.write_text(
            f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  html, body {{
    margin: 0;
    padding: 0;
    width: {size}px;
    height: {size}px;
    overflow: hidden;
    background: transparent;
  }}
  svg {{
    display: block;
    width: {size}px;
    height: {size}px;
  }}
</style>
</head>
<body>{svg_markup}</body>
</html>""",
            encoding="utf-8",
        )
        subprocess.run(
            [
                str(browser),
                "--headless",
                "--disable-gpu",
                "--hide-scrollbars",
                "--default-background-color=00000000",
                f"--window-size={size},{size}",
                f"--screenshot={out_png}",
                html_path.as_uri(),
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    return Image.open(out_png).convert("RGBA")


def make_square_full(svg_text: str) -> str:
    # Remove rounded corner rx="112" so full-bleed icons (iOS / 512px) have no transparent corners.
    return re.sub(r'(<rect[^>]*?)rx="[^"]+"', r"\1", svg_text, count=1)


def make_foreground_only(svg_text: str) -> str:
    # Remove the background <rect ... /> and scale the mascot into ~68% safe zone of 512x512.
    no_bg = re.sub(r'<rect[^>]*?fill="#FEF9C3"[^>]*?/?>', "", svg_text, count=1)
    inner = re.sub(r"^<svg[^>]*>|</svg>\s*$", "", no_bg.strip(), flags=re.DOTALL)
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">'
        '<g transform="translate(256 256) scale(0.70) translate(-256 -256)">'
        f"{inner}"
        "</g></svg>"
    )


def apply_circle_mask(img: Image.Image) -> Image.Image:
    size = img.size[0]
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size - 1, size - 1), fill=255)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def main() -> None:
    browser = find_browser()
    svg_text = SVG_PATH.read_text(encoding="utf-8")

    with tempfile.TemporaryDirectory() as tmp:
        tmp_dir = pathlib.Path(tmp)
        full_square = rasterize_svg(browser, make_square_full(svg_text), 1024, tmp_dir / "full.png")
        rounded = rasterize_svg(browser, svg_text, 1024, tmp_dir / "rounded.png")
        foreground = rasterize_svg(browser, make_foreground_only(svg_text), 1024, tmp_dir / "fg.png")

    # 1. In-app icon (512x512)
    app_icon_512 = full_square.resize((512, 512), Image.Resampling.LANCZOS)
    app_icon_512.save(ROOT / "aset" / "gambar" / "app_icon_512.png", format="PNG")

    # 2. Android mipmaps
    res_dir = ROOT / "android" / "app" / "src" / "main" / "res"
    for density, size in ANDROID_LAUNCHER_SIZES.items():
        mipmap_dir = res_dir / f"mipmap-{density}"
        rounded.resize((size, size), Image.Resampling.LANCZOS).save(
            mipmap_dir / "ic_launcher.png", format="PNG"
        )
        apply_circle_mask(full_square).resize((size, size), Image.Resampling.LANCZOS).save(
            mipmap_dir / "ic_launcher_round.png", format="PNG"
        )

    for density, size in ANDROID_FOREGROUND_SIZES.items():
        mipmap_dir = res_dir / f"mipmap-{density}"
        foreground.resize((size, size), Image.Resampling.LANCZOS).save(
            mipmap_dir / "ic_launcher_foreground.png", format="PNG"
        )

    # 3. iOS AppIcon.appiconset (preserve exact pixel dimensions of every existing asset)
    ios_dir = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    ios_base = full_square.convert("RGB")  # iOS App Store icons must be opaque RGB
    for icon_path in sorted(ios_dir.glob("Icon-App-*.png")):
        with Image.open(icon_path) as existing:
            target_size = existing.size
        ios_base.resize(target_size, Image.Resampling.LANCZOS).save(icon_path, format="PNG")

    print("Generated all app icons successfully from app-icon.svg.")


if __name__ == "__main__":
    main()
