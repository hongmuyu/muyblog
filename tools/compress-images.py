#!/usr/bin/env python3
"""一次性/手动批量压缩工具：source/images 下 PNG → WebP（限宽 1200px）。

用法：python3 tools/compress-images.py [--dry-run] [目录]
约定：文字截图类 q85，照片/头像类 q80（用 --photo 文件名可单独指定）。
转换完成后请用 git mv 思路提交：删除原 PNG、新增 WebP，并批量替换引用。
"""
import os, sys
from PIL import Image

QUALITY_DEFAULT = 85   # 文字截图
QUALITY_PHOTO = 80     # 照片/插画类
MAX_WIDTH = 1200

def convert(png_path, quality=QUALITY_DEFAULT, dry=False):
    im = Image.open(png_path)
    w, h = im.size
    if w > MAX_WIDTH:
        im = im.resize((MAX_WIDTH, int(h * MAX_WIDTH / w)), Image.LANCZOS)
    webp_path = png_path[:-4] + ".webp"
    before = os.path.getsize(png_path)
    if dry:
        print(f"[dry] {png_path} {w}x{h} {before//1024}KB -> webp q{quality}")
        return None
    im.save(webp_path, "WEBP", quality=quality, method=6)
    after = os.path.getsize(webp_path)
    print(f"{os.path.basename(png_path)}: {w}x{h} {before//1024}KB -> "
          f"{im.size[0]}x{im.size[1]} {after//1024}KB (q{quality})")
    return webp_path

if __name__ == "__main__":
    dry = "--dry-run" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    root = args[0] if args else os.path.join(os.path.dirname(__file__), "..", "source", "images")
    photos = {"Kyle.png"}  # 非截图类，用 q80
    for f in sorted(os.listdir(root)):
        if not f.lower().endswith(".png"):
            continue
        q = QUALITY_PHOTO if f in photos else QUALITY_DEFAULT
        convert(os.path.join(root, f), q, dry)
