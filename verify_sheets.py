from PIL import Image
import os

target_files = [
    "$calf_brown_32x32.png",
    "$calf_holstein_32x32.png",
    "$calf_white_32x32.png",
    "$cow_brown_32x32.png",
    "$cow_holstein_32x32.png",
    "$cow_white_32x32.png",
    "$goat_32x32.png",
    "$lamb_32x32.png",
    "$sheep_32x32.png",
    "$cat_orange_32x32.png"
]

folder = "character reference"

for f in target_files:
    path = os.path.join(folder, f)
    if os.path.exists(path):
        try:
            img = Image.open(path)
            print(f"{f}: {img.size[0]} x {img.size[1]}")
        except Exception as e:
            print(f"Error reading {f}: {e}")
    else:
        print(f"MISSING: {f}")
